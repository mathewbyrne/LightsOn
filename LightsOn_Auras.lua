LightsOn_Auras = {}

function LightsOn_Auras.AnyoneHasAuraFromPlayer(auraSpellIDs)
    local groupType
    if IsInRaid() then
        groupType = "raid"
    elseif IsInGroup() then
        groupType = "party"
    else
        groupType = "player"
    end

    local unitCount
    if groupType == "player" then
        unitCount = 1
    else 
        unitCount = GetNumGroupMembers()
    end
    
    for i = 1, unitCount do
        local unit = "player"
        if groupType ~= "player" then
            unit = groupType..i
        end
        hasAura, remaining = LightsOn_Auras.HasAuraFromPlayer(unit, auraSpellIDs);
        if hasAura then
            return true, remaining;
        end
    end

    return false, 0
end

function LightsOn_Auras.PlayerHasAuraFromPlayer(auraSpellIDs)
    return LightsOn_Auras.HasAuraFromPlayer("player", auraSpellIDs)
end

function LightsOn_Auras.HasAuraFromPlayer(unit, auraSpellIDs, more)
    local i = 1
    local name, _, _, _, _, expirationTime, _, _, _, spellID = UnitAura(unit, i, "PLAYER")
    while name do
        for _, auraSpellID in ipairs(auraSpellIDs) do
            if spellID == auraSpellID then
                return true, expirationTime - GetTime()
            end
        end
        i = i + 1
        name, _, _, _, _, expirationTime, _, _, _, spellID = UnitAura(unit, i, "PLAYER")
    end
    return false, 0
end
