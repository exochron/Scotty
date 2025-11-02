local ADDON_NAME, ADDON = ...

-- waypoint support for TomTom
ADDON.Events:RegisterCallback("TeleportInitialized", function(_, _, _, dbRow)
    if TomTom and dbRow and dbRow.waypoint then
        local opts = {
            title = ADDON:GetName(dbRow),
            from = C_AddOns.GetAddOnMetadata(ADDON_NAME, "Title"),
        }
        TomTom:AddWaypoint(dbRow.waypoint[1],dbRow.waypoint[2],dbRow.waypoint[3], opts)
    end
end, "waypoint")