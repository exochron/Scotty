local ADDON_NAME, ADDON = ...

-- waypoint support
ADDON.Events:RegisterCallback("TeleportInitialized", function(_, _, _, dbRow)
    if dbRow and dbRow.waypoint then
        local mapID = dbRow.waypoint[1]
        local posX = dbRow.waypoint[2]
        local posY = dbRow.waypoint[3]

        if TomTom then
            local opts = {
                title = ADDON:GetName(dbRow),
                from = C_AddOns.GetAddOnMetadata(ADDON_NAME, "Title"),
            }
            local ttUId = TomTom:AddWaypoint(mapID, posX, posY, opts)
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
        elseif C_Map.CanSetUserWaypointOnMap and C_Map.CanSetUserWaypointOnMap(mapID) then
            local uiMapPoint = UiMapPoint.CreateFromCoordinates(mapID, posX, posY)
            if uiMapPoint then
                C_Map.SetUserWaypoint(uiMapPoint)
                C_SuperTrack.SetSuperTrackedUserWaypoint(true)
            end
        end
    end
end, "waypoint")