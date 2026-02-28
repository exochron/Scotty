local _, ADDON = ...

function ADDON:TakeScreenshots()
    Transmog_LoadUI()

    local gg = LibStub("GalleryGenerator")
    gg:TakeScreenshots(
        {
            function(api)
                api:BackScreen()
                ADDON:OpenTeleportMenu(BazookaPlugin_Scotty)

                api:WaitAndPointOnMenuElement(1,14, function() -- Khaz Algar
                    api:WaitAndPointOnMenuElement(2,8)
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
        }
    )
end