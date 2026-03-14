local ADDON_NAME, ADDON = ...

-- waypoint support for TomTom
ADDON.Events:RegisterCallback("TeleportInitialized", function(_, _, _, dbRow)
    if dbRow and dbRow.waypoint then
        if TomTom then
            local opts = {
                title = ADDON:GetName(dbRow),
                from = C_AddOns.GetAddOnMetadata(ADDON_NAME, "Title"),
            }
            local ttUId = TomTom:AddWaypoint(dbRow.waypoint[1],dbRow.waypoint[2],dbRow.waypoint[3], opts)
            -- todo: clear waypoint on reached mapid
        else
            -- try adding normal waypoint
        end
    end
end, "waypoint")