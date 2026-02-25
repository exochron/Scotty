local _, ADDON = ...

-- Usually a hearthstone or teleports automatically cancels the shapeshift of druids. Except for the flying form.
-- However, CancelShapeshiftForm() does trigger a small GCD
ADDON.Events:RegisterCallback("OnOpenTeleportMenu", function()
    C_Timer.After(0, function()
        -- https://warcraft.wiki.gg/wiki/API_GetShapeshiftFormID
        local formId = GetShapeshiftFormID()
        if (formId == 27 or formId == 29)
            and not InCombatLockdown()
            and not IsFlying()
        then
            CancelShapeshiftForm()
        end
    end)
end, "druid-cancel-flightform")