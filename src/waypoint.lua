local ADDON_NAME, ADDON = ...

-- waypoint support for TomTom
ADDON.Events:RegisterCallback("TeleportInitialized", function(_, _, _, dbRow)
    if dbRow and dbRow.waypoint then
        if TomTom then
            local opts = {
                title = ADDON:GetName(dbRow),
                from = C_AddOns.GetAddOnMetadata(ADDON_NAME, "Title"),
                crazy = true,
            }
            local ttUId = TomTom:AddWaypoint(dbRow.waypoint[1],dbRow.waypoint[2],dbRow.waypoint[3], opts)
            -- clear waypoint after reaching 2 zones
            local handle
            local triggeredZoneChange = 0
            handle = ADDON.Events:RegisterFrameEventAndCallbackWithHandle("ZONE_CHANGED_NEW_AREA", function()
                triggeredZoneChange = triggeredZoneChange + 1
                if triggeredZoneChange >= 2 then
                    TomTom:RemoveWaypoint(ttUId)
                    handle:Unregister()
                end
            end, ttUId)
        else
            -- todo: add normal waypoints
        end
        --todo test with waypoint UI
    end
end, "waypoint")