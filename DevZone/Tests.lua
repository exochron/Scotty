local _, ADDON = ...

local function alert(msg, row)
    if row then
        msg = msg.." ("
        if row.toy then
            msg = msg.."toy: "..row.toy
        elseif row.item then
            msg = msg.."item: "..row.item
        elseif row.spell then
            msg = msg.."spell: "..row.spell
        end
        msg = msg..")"
    end
    print("Scotty: "..msg)
end

local function CheckNameAvailable(row)
    if row.instance ~= nil and nil == GetRealZoneText(row.instance) then
        alert("no Name detected for Instance: ".. row.instance, row)
    end
    if row.map ~= nil and nil == C_Map.GetMapInfo(row.map) then
        alert("no Name detected for Map: ".. row.map, row)
    end
    if (row.toy or row.item) and not ADDON.GetItemName(row.toy or row.item) then
        alert("item name not available! "..(C_Item.IsItemDataCachedByID(row.toy or row.item) and "cached" or "not cached"), row)
    end
end

local function CheckPortalExistsAsWell(row)
    if row.spell and row.portal and false == C_Spell.DoesSpellExist(row.portal) then
        alert("Teleport Portal does not exist: ".. row.portal)
    end
end

local function CheckForRequiredFields(row)
    if not row.category and not row.continent then
        alert("Required Continent or Category is missing!", row)
    end
end

local function CheckForDoubleHearthstoneEntry()
    local hearthstones = tFilter(ADDON.db, function(row)
        return row.toy and row.category == ADDON.Category.Hearthstone
    end, true)
    hearthstones = TableUtil.Transform(hearthstones, function(row)
        return row.toy
    end)
    if #hearthstones > CountTable(tInvert(hearthstones)) then
        alert("Same Hearthstone entry in database detected!");
    end
end

local function TestDB()
    for _, row in ipairs(ADDON.db) do
        if (row.item and ADDON.DoesItemExistInGame(row.item))
            or (row.toy and ADDON.DoesItemExistInGame(row.toy))
            or (row.spell and C_Spell.DoesSpellExist(row.spell))
        then
            CheckNameAvailable(row)
            CheckPortalExistsAsWell(row)
        end
        CheckForRequiredFields(row)
    end

    CheckForDoubleHearthstoneEntry()
end

-- quest checker for dragonflight wormhole triangulation
local minQuestId, maxQuestId = 10000, 76017
local quests = {}
local function InitialCheckQuests()
    for i = minQuestId, maxQuestId do
        if not C_QuestLog.IsQuestFlaggedCompleted(i) then
           quests[i] = false
        end
    end
end

function Scotty_RecheckQuests()
    for i = minQuestId, maxQuestId do
        if C_QuestLog.IsQuestFlaggedCompleted(i) and false == quests[i] then
           print("Found Completed Quest!", i)
        end
    end
    print("finished check")
end

ADDON.Events:RegisterCallback("OnLogin", function()
    TestDB()
    --InitialCheckQuests()
end, "tests")