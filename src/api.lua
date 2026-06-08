local _, ADDON = ...

local tContains = tContains
local tInsertUnique = tInsertUnique
local tIndexOf = tIndexOf
local tUnorderedRemove = tUnorderedRemove
local tInvert = tInvert
local tFilter = tFilter

ADDON.Api = {}

local function buildFavoriteKey(dbRow)
    local dbType, dbTypeId

    if dbRow.neighborhoodGUID and dbRow.plotID then
        dbType = "house"
        dbTypeId = dbRow.neighborhoodGUID..'-'..dbRow.plotID
    elseif dbRow.toy then
        dbType = "toy"
        dbTypeId = dbRow.toy
    elseif dbRow.item then
        dbType = "item"
        dbTypeId = dbRow.item
    elseif dbRow.spell then
        dbType = "spell"
        dbTypeId = dbRow.spell
    end
    if dbType and dbTypeId then
        if dbRow.isMultiDestination and dbRow.map then
            return dbType, dbTypeId.."-"..dbRow.map
        elseif dbRow.isMultiDestination then
            return dbType, dbTypeId.."-"..dbRow.continent
        end
        return dbType, dbTypeId
    end
end

ADDON.Api.IsFavorite = function(dbRow)
    local type, typeKey = buildFavoriteKey(dbRow)

    if type and typeKey and ScottyGlobalSettings.favorites[type] then
        return tContains(ScottyGlobalSettings.favorites[type], typeKey)
    end

    return false
end
ADDON.Api.SetFavorite = function(dbRow, isFavorite)
    local type, typeKey = buildFavoriteKey(dbRow)

    if type and ScottyGlobalSettings.favorites[type] then
        if isFavorite then
            tInsertUnique(ScottyGlobalSettings.favorites[type], typeKey)
        else
            local index = tIndexOf(ScottyGlobalSettings.favorites[type], typeKey)
            if index then
                tUnorderedRemove(ScottyGlobalSettings.favorites[type], index)
            end
        end
    end
end
ADDON.Api.GetFavoriteDatabase = function()
    local favorites = ScottyGlobalSettings.favorites
    local favoriteToys = tInvert(favorites.toy)
    local favoriteSpells = tInvert(favorites.spell)
    local favoriteItems = tInvert(favorites.item)
    local favoriteHouses = tInvert(favorites.house)

    local dbRows = tFilter(ADDON.db, function(dbRow)
        local type, typeKey = buildFavoriteKey(dbRow)

        return (type == "toy" and favoriteToys[typeKey])
                or (type == "spell" and favoriteSpells[typeKey])
                or (type == "item" and favoriteItems[typeKey])
    end, true)

    local friendsHouseInfos, guildHouseInfos = {}, {}
    if ADDON.GetHouseInfos then
        _, friendsHouseInfos, guildHouseInfos = ADDON.GetHouseInfos()
    end
    for _, friendsHouse in pairs(friendsHouseInfos) do
        local _, key = buildFavoriteKey(friendsHouse)
        if favoriteHouses[key] then
            table.insert(dbRows, friendsHouse)
            favoriteHouses[key] = nil
        end
    end
    for _, guildHouse in pairs(guildHouseInfos) do
        local _, key = buildFavoriteKey(guildHouse)
        if favoriteHouses[key] then
            table.insert(dbRows, guildHouse)
        end
    end

    return dbRows
end