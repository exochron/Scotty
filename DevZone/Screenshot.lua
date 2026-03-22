local ADDON_NAME, ADDON = ...

function ADDON:TakeScreenshots()
    Transmog_LoadUI()

    local favoritesSetting = Settings.GetValue(ADDON_NAME.."_GROUP_FAVORITES")
    Settings.SetValue(ADDON_NAME.."_GROUP_FAVORITES", true)

    local gg = LibStub("GalleryGenerator")
    gg:TakeScreenshots(
        {
            function(api)
                api:BackScreen()
                ADDON:OpenTeleportMenu(BazookaPlugin_Scotty)

                api:WaitAndPointOnMenuElement(1, 10, function() -- Eastern Kingdom
                    api:WaitAndPointOnMenuElement(2, 2) -- Duskwood
                end)
            end,
            function(api)
                api:BackScreen()
                TransmogFrame:Show()
                api:Wait()
                C_Timer.After(1, function()
                    api:Click(TransmogFrame.CharacterPreview.ScottyHearthstoneSlot)
                    api:Continue()
                end)
            end,
            function(api)
                TransmogFrame:Hide()
                api:BackScreen()
                ADDON:OpenSettings()
            end,
        },
        function()
            Settings.SetValue(ADDON_NAME.."_GROUP_FAVORITES", favoritesSetting)
        end
    )
end