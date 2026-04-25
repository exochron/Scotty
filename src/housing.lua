local ADDON_NAME, ADDON = ...

local issecretvalue = issecretvalue or function() return false end

local PlayerHouseInfos = {}
local FriendsHouseInfos = {}
local GuildHouseInfos = {}

ADDON.GetHouseInfos = function ()
    return PlayerHouseInfos,
            ScottyAccountCache["houseinfo-friends"] or FriendsHouseInfos,
            ScottyPersonalCache["houseinfo-guild"] or GuildHouseInfos
end

local TICKER_INTERVAL = 0.5
local friendsTicker, guildTicker
local friendsToScan, guildMembersToScan = {}, {}
local expectEvent = false -- event can be delayed onto next tick

local function ScanGuildMembers()
    if not expectEvent and (not HouseListFrame or not HouseListFrame:IsShown()) then
        local memberId = table.remove(guildMembersToScan)
        local info = memberId and C_Club.GetMemberInfo(C_Club.GetGuildClubId(), memberId)
        if info then
            if InCombatLockdown() or issecretvalue(info) or issecretvalue(info.guid) then
                -- retry on next tick
                table.insert(guildMembersToScan, memberId)
                return
            end
            local handle
            handle = ADDON.Events:RegisterFrameEventAndCallbackWithHandle("VIEW_HOUSES_LIST_RECIEVED", function(_, houseInfos)
                for _, houseInfo in ipairs(houseInfos) do
                    if houseInfo.ownerName then
                        GuildHouseInfos[houseInfo.neighborhoodGUID..'-'..houseInfo.houseGUID..'-'..houseInfo.plotID] = houseInfo
                    end
                end
                handle:Unregister()
                expectEvent = false
            end, info)
            expectEvent = true
            C_Housing.GetOthersOwnedHouses(info.guid, nil, true)
        else
            guildTicker:Cancel()
            ScottyPersonalCache["houseinfo-guild"] = GuildHouseInfos
            GuildHouseInfos = {}
        end
    end
end
local function StartScanningGuild()
    if Settings.GetValue(ADDON_NAME.."_SHOW_GUILD_HOUSES") then
        local clubId = C_Club.GetGuildClubId()
        if clubId then
            guildMembersToScan = C_Club.GetClubMembers(clubId)
            if issecretvalue(guildMembersToScan) then
                C_Timer.After(10, StartScanningGuild)
            else
                guildTicker = C_Timer.NewTicker(TICKER_INTERVAL, ScanGuildMembers)
            end
        end
    end
end

local function ScanFriends()
    if not expectEvent and (not HouseListFrame or not HouseListFrame:IsShown()) then
        local bnetInfo = table.remove(friendsToScan)
        if bnetInfo then
            if InCombatLockdown() or issecretvalue(bnetInfo) or issecretvalue(bnetInfo.bnetAccountID) then
                -- retry on next tick
                table.insert(friendsToScan, bnetInfo)
                return
            end
            local handle
            handle = ADDON.Events:RegisterFrameEventAndCallbackWithHandle("VIEW_HOUSES_LIST_RECIEVED", function(bnet, houseInfos)
                for _, houseInfo in ipairs(houseInfos) do
                    local infoIndex = houseInfo.neighborhoodGUID..'-'..houseInfo.houseGUID..'-'..houseInfo.plotID
                    if FriendsHouseInfos[infoIndex] then
                        -- server sometimes sends same response of previous request
                        C_Housing.GetOthersOwnedHouses(nil, bnet.bnetAccountID, false)
                        return
                    end
                    houseInfo.accountName = bnet.accountName
                    houseInfo.battleTag = bnet.battleTag
                    FriendsHouseInfos[infoIndex] = houseInfo
                end
                handle:Unregister()
                expectEvent = false
            end, bnetInfo)

            expectEvent = true
            C_Housing.GetOthersOwnedHouses(nil, bnetInfo.bnetAccountID, false)
        else
            friendsTicker:Cancel()
            ScottyAccountCache["houseinfo-friends"] = FriendsHouseInfos
            FriendsHouseInfos = {}
            StartScanningGuild()
        end
    end
end
local function StartScanningFriends()
    friendsToScan = {}
    if Settings.GetValue(ADDON_NAME.."_SHOW_FRIENDS_HOUSES") then
        local numBNetTotal = BNGetNumFriends();
        for index = 1, numBNetTotal do
            local bnetInfo = C_BattleNet.GetFriendAccountInfo(index)
            if bnetInfo then
                table.insert(friendsToScan, bnetInfo)
            end
        end
    end

    friendsTicker = C_Timer.NewTicker(TICKER_INTERVAL, ScanFriends)
end

ADDON.Events:RegisterCallback("OnLogin", function()
    local playerIsTimerunning = PlayerIsTimerunning and PlayerIsTimerunning()
    if C_Housing and not playerIsTimerunning then
        -- see: https://warcraft.wiki.gg/wiki/PLAYER_HOUSE_LIST_UPDATED
        ADDON.Events:RegisterFrameEventAndCallback("PLAYER_HOUSE_LIST_UPDATED", function(_, houseInfos)
            PlayerHouseInfos = houseInfos
        end, "player-housing")
        C_Housing.GetPlayerOwnedHouses() -- request loading player housing infos

        StartScanningFriends()
    end
end, "player-housing")
