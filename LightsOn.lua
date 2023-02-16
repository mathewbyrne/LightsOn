
local addonName, addon = ...

local SPELL_BEACON_IDS = {53563}
local SPELL_SHIELD_IDS = {53601}
local SPELL_GRACE_IDS = {31834}
local SPELL_JOP_IDS = {54153, 54152, 53657, 53656, 53655}
local SPELL_JOL_IDS = {20185}

local SPELL_JOL_DURATION = 20

local ICON_SIZE = 47
local ICON_PADDING = 1

local LightsOn = {}
LightsOn.__index = LightsOn

function LightsOn.new()
    local self = {}
    setmetatable(self, LightsOn)

    self.frame = CreateFrame("Frame", nil, UIParent)

    self.iconBeacon = LightsOn_Icon.new(SPELL_BEACON_IDS[1], self.frame)
    self.iconShield = LightsOn_Icon.new(SPELL_SHIELD_IDS[1], self.frame)
    self.iconGrace = LightsOn_Icon.new(SPELL_GRACE_IDS[1], self.frame)
    self.iconJoP = LightsOn_Icon.new(SPELL_JOP_IDS[1], self.frame)
    self.iconJoL = LightsOn_Icon.new(SPELL_JOL_IDS[1], self.frame)

    self:layout({
        iconSize = ICON_SIZE,
        iconPadding = ICON_PADDING,
        x = -238,
        y = -170,
        position = "BOTTOMRIGHT",
    })

    self.jolCache = {}

    self.frame:SetScript("OnUpdate", function()
        local enabled, remaining = LightsOn_Auras.AnyoneHasAuraFromPlayer(SPELL_BEACON_IDS)
        if enabled then
            self.iconBeacon:enable(remaining)
        else
            self.iconBeacon:disable()
        end

        local enabled, remaining = LightsOn_Auras.AnyoneHasAuraFromPlayer(SPELL_SHIELD_IDS)
        if enabled then
            self.iconShield:enable(remaining)
        else
            self.iconShield:disable()
        end

        local enabled, remaining = LightsOn_Auras.PlayerHasAuraFromPlayer(SPELL_GRACE_IDS)
        if enabled then
            self.iconGrace:enable(remaining)
        else
            self.iconGrace:disable()
        end

        local enabled, remaining = LightsOn_Auras.PlayerHasAuraFromPlayer(SPELL_JOP_IDS)
        if enabled then
            self.iconJoP:enable(remaining)
        else
            self.iconJoP:disable()
        end

        -- We just keep of record of units that have had JoL applied. The expiry counts as the latest of these to expire.
        local jolExpiry = 0
        local time = GetTime()
        for guid, expiry in pairs(self.jolCache) do
            if expiry < time then
                self.jolCache[guid] = nil
            else
                jolExpiry = math.max(jolExpiry, expiry - time)
            end
        end

        if jolExpiry > 0 then
            self.iconJoL:enable(jolExpiry)
        else
            self.iconJoL:disable()
        end
        local start, duration = GetSpellCooldown(20271)
        local progress = ((start + duration) - time)/duration
        self.iconJoL:setProgress(progress)
    end)

    self.frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    self.frame:SetScript("OnEvent", function(_, event)
        if event == "COMBAT_LOG_EVENT_UNFILTERED" then
            _, subEvent, _, sourceGUID, _, _, _, destGUID, _, _, _, spellID = CombatLogGetCurrentEventInfo()
            if (subEvent == "SPELL_AURA_APPLIED" or subEvent == "SPELL_AURA_REFRESH") and spellID == SPELL_JOL_IDS[1] and sourceGUID == UnitGUID("player") then
                -- All other methods are just too difficult so we're going to set an expiry in the future and stick with that.
                self.jolCache[destGUID] = GetTime() + SPELL_JOL_DURATION
            end
            if subEvent == "UNIT_DIED" then
                if self.jolCache[destGUID] ~= nil then
                    self.jolCache[destGUID] = nil
                end
            end
        end
    end)

    return self
end

function LightsOn:layout(config)
    self.frame:SetSize((2 * config.iconSize) + config.iconPadding, config.iconSize)

    self.iconBeacon:setSize(config.iconSize)
    self.iconShield:setSize(config.iconSize)
    self.iconGrace:setSize(config.iconSize)
    self.iconJoL:setSize(config.iconSize)
    self.iconJoP:setSize(config.iconSize)

    self.frame:ClearAllPoints()
    self.frame:SetPoint(config.position, UIParent, "CENTER", config.x, config.y)
    
    self.iconBeacon.frame:SetPoint("RIGHT", self.frame, "RIGHT")
    self.iconShield.frame:SetPoint("RIGHT", self.iconBeacon.frame, "LEFT", -config.iconPadding, 0)
    self.iconGrace.frame:SetPoint("RIGHT", self.iconShield.frame, "LEFT", -config.iconPadding, 0)
    self.iconJoP.frame:SetPoint("RIGHT", self.iconGrace.frame, "LEFT", -config.iconPadding, 0)
    self.iconJoL.frame:SetPoint("RIGHT", self.iconJoP.frame, "LEFT", -config.iconPadding, 0)
end

addon.lightsOn = LightsOn.new()
