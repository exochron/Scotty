local _, ADDON = ...

SLASH_SCOTTY1 = '/scotty'

local function printHelp()
    print("Syntax:")
    print("/scotty options       Open addon options")
    print("/scotty teleport      Open teleport menu at mouse cursor")
end

function SlashCmdList.SCOTTY(input)
    local loweredInput = input:lower():trim()

    if ADDON.TakeScreenshots and loweredInput == "screenshot" then
        ADDON:TakeScreenshots()
    elseif loweredInput == "options" then
        ADDON:OpenOptions()
    elseif loweredInput == "teleport" then
        ADDON:OpenTeleportMenuAtCursor()
    else
        printHelp()
    end
end