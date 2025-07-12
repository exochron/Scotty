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
        alert("no Name detected for Instance: ".. row.instance)
    end
    if row.map ~= nil and nil == C_Map.GetMapInfo(row.map) then
        alert("no Name detected for Map: ".. row.map)
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
end

ADDON.Events:RegisterCallback("OnLogin", function()
    TestDB()
end, "tests")