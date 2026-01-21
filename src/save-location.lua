local _, ADDON = ...

-- save locations when certains spells are cast
ADDON.Events:RegisterCallback("OnLogin", function(self)
    local observeSpells = {
        [312370] = "VulperaCamp", -- Make Camp (Vulpera)
        [1233637] = "PlayerHomeReturn", -- Teleport Home (Housing)
    }

    ADDON.Events:RegisterFrameEventAndCallback("UNIT_SPELLCAST_SUCCEEDED", function(_, unitTarget, _, spellId)
        if unitTarget == "player" and observeSpells[spellId] then
            ScottyPersonalCache[observeSpells[spellId]] = GetZoneText()
        end
    end, self)
end, "vulpera-camp")