local _, ADDON = ...

ADDON.PlayerHouseInfos = {}
ADDON.FriendsHouseInfos = {}
ADDON.GuildHouseInfos = {}

local TICKER_INTERVAL = 0.5
local friendsTicker, guildTicker
local expectEvent = false -- event can be delayed onto next tick

-- see: https://warcraft.wiki.gg/wiki/PLAYER_HOUSE_LIST_UPDATED
ADDON.Events:RegisterFrameEventAndCallback("PLAYER_HOUSE_LIST_UPDATED", function(_, houseInfos)
    ADDON.PlayerHouseInfos = houseInfos
end, "player-housing")

local membersToScan = {}
local function ScanGuildMembers()
    if not expectEvent and (not HouseListFrame or HouseListFrame:IsShown()) then
        local memberId = table.remove(membersToScan)
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
        membersToScan = C_Club.GetClubMembers(C_Club.GetGuildClubId(), clubId)
        guildTicker = C_Timer.NewTicker(TICKER_INTERVAL, ScanGuildMembers)
    end
end

local friendsTickerIndex = 1
local function ScanFriends()
    if not expectEvent and (not HouseListFrame or HouseListFrame:IsShown()) then
        local bnetInfo = C_BattleNet.GetFriendAccountInfo(friendsTickerIndex)
        if bnetInfo then
            friendsTickerIndex = friendsTickerIndex + 1

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

ADDON.Events:RegisterCallback("OnLogin", function()
    if C_Housing then
        C_Housing.GetPlayerOwnedHouses() -- request loading player housing infos
        friendsTicker = C_Timer.NewTicker(TICKER_INTERVAL, ScanFriends)
    end
end, "player-housing")
