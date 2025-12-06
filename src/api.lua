local _, ADDON = ...

local tContains = tContains
local tInsertUnique = tInsertUnique
local tIndexOf = tIndexOf
local tUnorderedRemove = tUnorderedRemove
local tInvert = tInvert

ADDON.Api = {}

local function buildFavoriteKey(dbRow)
    local type, typeId

    if dbRow.neighborhoodGUID and dbRow.houseGUID and dbRow.plotID then
        type = "house"
        typeId = dbRow.neighborhoodGUID..'-'..dbRow.houseGUID..'-'..dbRow.plotID
    elseif dbRow.toy then
        type = "toy"
        typeId = dbRow.toy
    elseif dbRow.item then
        type = "item"
        typeId = dbRow.item
    elseif dbRow.spell then
        type = "spell"
        typeId = dbRow.spell
    end
    if type and typeId then
        if dbRow.isMultiDestination and dbRow.map then
            return type, typeId.."-"..dbRow.map
        elseif dbRow.isMultiDestination then
            return type, typeId.."-"..dbRow.continent
        end
        return type, typeId
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

    for k, v in pairs(ADDON.FriendsHouseInfos) do
        if favoriteHouses[k] then
            table.insert(dbRows, v)
            favoriteHouses[k] = nil
        end
    end
    for k, v in pairs(ADDON.GuildHouseInfos) do
        if favoriteHouses[k] then
            table.insert(dbRows, v)
        end
    end

    return dbRows
end