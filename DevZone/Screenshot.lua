local _, ADDON = ...

function Scotty_TakeScreenshots()

    local gg = LibStub("GalleryGenerator")
    gg:TakeScreenshots(
        {
            function(api)
                api:BackScreen()
                ADDON:OpenTeleportMenu(BazookaPlugin_Scotty)

                local menuChildren = { Menu.GetManager():GetOpenMenu():GetChildren() }
                api:Point(menuChildren[18]) -- Broken Isles
            end,
            function(api)
                api:BackScreen()
                ADDON:OpenSettings()
            end,
        }
    )
end