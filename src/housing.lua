local _, ADDON = ...

ADDON.PlayerHouseInfos = {}
ADDON.FriendsHouseInfos = {}
ADDON.GuildHouseInfos = {}

local TICKER_INTERVAL = 0.5
local friendsTicker, guildTicker
local friendsToScan, guildMembersToScan = {}, {}
local expectEvent = false -- event can be delayed onto next tick

local function ScanGuildMembers()
    if not expectEvent and (not HouseListFrame or not HouseListFrame:IsShown()) then
        local memberId = table.remove(guildMembersToScan)
        local info = memberId and C_Club.GetMemberInfo(C_Club.GetGuildClubId(), memberId)
        if info then
            local handle
            handle = ADDON.Events:RegisterFrameEventAndCallbackWithHandle("VIEW_HOUSES_LIST_RECIEVED", function(info, houseInfos)
                for _, houseInfo in ipairs(houseInfos) do
                    if houseInfo.ownerName then
                        ADDON.GuildHouseInfos[houseInfo.neighborhoodGUID..'-'..houseInfo.houseGUID..'-'..houseInfo.plotID] = houseInfo
                    end
                end
                handle:Unregister()
                expectEvent = false
            end, info)
            expectEvent = true
            C_Housing.GetOthersOwnedHouses(info.guid, nil, true)
        else
            guildTicker:Cancel()
        end
    end
end
local function StartScanningGuild()
    if IsInGuild() then
        guildMembersToScan = C_Club.GetClubMembers(C_Club.GetGuildClubId(), clubId)
        guildTicker = C_Timer.NewTicker(TICKER_INTERVAL, ScanGuildMembers)
    end
end

local function ScanFriends()
    if not expectEvent and (not HouseListFrame or not HouseListFrame:IsShown()) then
        local bnetInfo = table.remove(friendsToScan)
        if bnetInfo then
            local handle
            handle = ADDON.Events:RegisterFrameEventAndCallbackWithHandle("VIEW_HOUSES_LIST_RECIEVED", function(bnet, houseInfos)
                for _, houseInfo in ipairs(houseInfos) do
                    houseInfo.accountName = bnet.accountName
                    houseInfo.battleTag = bnet.battleTag
                    ADDON.FriendsHouseInfos[houseInfo.neighborhoodGUID..'-'..houseInfo.houseGUID..'-'..houseInfo.plotID] = houseInfo
                end
                handle:Unregister()
                expectEvent = false
            end, bnetInfo)

            expectEvent = true
            C_Housing.GetOthersOwnedHouses(nil, bnetInfo.bnetAccountID, false)
        else
            friendsTicker:Cancel()
            StartScanningGuild()
        end
    end
end
local function StartScanningFriends()
    local numBNetTotal = BNGetNumFriends();
    for index = 1, numBNetTotal do
        local bnetInfo = C_BattleNet.GetFriendAccountInfo(index)
        if bnetInfo then
            table.insert(friendsToScan, bnetInfo)
        end
    end

    friendsTicker = C_Timer.NewTicker(TICKER_INTERVAL, ScanFriends)
end

ADDON.Events:RegisterCallback("OnLogin", function()
    local playerIsTimerunning = PlayerIsTimerunning and PlayerIsTimerunning()
    if C_Housing and not playerIsTimerunning then
        -- see: https://warcraft.wiki.gg/wiki/PLAYER_HOUSE_LIST_UPDATED
        ADDON.Events:RegisterFrameEventAndCallback("PLAYER_HOUSE_LIST_UPDATED", function(_, houseInfos)
            ADDON.PlayerHouseInfos = houseInfos
        end, "player-housing")
        C_Housing.GetPlayerOwnedHouses() -- request loading player housing infos

        StartScanningFriends()
    end
end, "player-housing")
