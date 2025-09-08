local _, ADDON = ...

function ADDON:TakeScreenshots()

    local gg = LibStub("GalleryGenerator")
    gg:TakeScreenshots(
        {
            function(api)
                api:BackScreen()
                ADDON:OpenTeleportMenu(BazookaPlugin_Scotty)

                api:WaitAndPointOnMenuElement(1,9, function() -- Khaz Algar
                    api:WaitAndPointOnMenuElement(2,5)
                end)
            end,
            function(api)
                api:BackScreen()
                ADDON:OpenSettings()
            end,
        }
    )
end