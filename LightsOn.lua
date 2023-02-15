
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

    local frame = CreateFrame("Frame", nil, UIParent)
    frame:SetSize((2 * ICON_SIZE) + ICON_PADDING, ICON_SIZE)
    frame:SetPoint("BOTTOMRIGHT", UIParent, "CENTER", -238, -170)

    local iconBeacon = LightsOn_Icon.new(SPELL_BEACON_IDS[1], frame, ICON_SIZE)
    iconBeacon.frame:SetPoint("RIGHT", frame, "RIGHT")

    local iconShield = LightsOn_Icon.new(SPELL_SHIELD_IDS[1], frame, ICON_SIZE)
    iconShield.frame:SetPoint("RIGHT", iconBeacon.frame, "LEFT", -ICON_PADDING, 0)

    local iconGrace = LightsOn_Icon.new(SPELL_GRACE_IDS[1], frame, ICON_SIZE)
    iconGrace.frame:SetPoint("RIGHT", iconShield.frame, "LEFT", -ICON_PADDING, 0)

    local iconJoP = LightsOn_Icon.new(SPELL_JOP_IDS[1], frame, ICON_SIZE)
    iconJoP.frame:SetPoint("RIGHT", iconGrace.frame, "LEFT", -ICON_PADDING, 0)

    local iconJoL = LightsOn_Icon.new(SPELL_JOL_IDS[1], frame, ICON_SIZE)
    iconJoL.frame:SetPoint("RIGHT", iconJoP.frame, "LEFT", -ICON_PADDING, 0)

    self.frame = frame
    self.iconBeacon = iconBeacon
    self.iconShield = iconShield
    self.iconGrace = iconGrace
    self.iconJoL = iconJoL
    self.iconJoP = iconJoP

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

    frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    frame:SetScript("OnEvent", function(_, event)
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

LightsOn.new()
