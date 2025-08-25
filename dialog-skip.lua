local ADDON_NAME, ADDON = ...

local SETTING_NAME = ADDON_NAME.."_SKIP_DIALOG"

local gossipQueue = {}
local resetTimer = nil

local function resetQueueAndTimer()
    gossipQueue = {}
    if resetTimer then
        resetTimer:Cancel()
        resetTimer = nil
    end
end

ADDON.Events:RegisterCallback("TeleportInitialized", function(_, _, _, dbRow)
    if Settings.GetValue(SETTING_NAME) and dbRow and dbRow.gossip then
        resetQueueAndTimer()
        gossipQueue = CopyTable(dbRow.gossip)

        resetTimer = C_Timer.NewTimer(120, function()
            gossipQueue = {}
        end)
    end
end, "dialog-skip")

ADDON.Events:RegisterFrameEventAndCallback("GOSSIP_SHOW", function()
    if Settings.GetValue(SETTING_NAME) then
        local gossipTarget = table.remove(gossipQueue, 1)
        if gossipTarget then
            for _, gossip in ipairs(C_GossipInfo.GetOptions()) do
                if gossip.gossipOptionID and gossip.gossipOptionID == gossipTarget then
                    C_GossipInfo.SelectOption(gossipTarget)
                    return
                end
            end

            resetQueueAndTimer()
        end
    end
end, "dialog-skip")

ADDON.Events:RegisterFrameEventAndCallback("GOSSIP_CLOSED", resetQueueAndTimer, "dialog-skip")