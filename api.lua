local _, ADDON = ...

local tContains = tContains
local tInsertUnique = tInsertUnique
local tIndexOf = tIndexOf
local tUnorderedRemove = tUnorderedRemove
local tInvert = tInvert

ADDON.Api = {}

ADDON.Api.IsFavorite = function(type, typeId)
    if ScottyGlobalSettings.favorites[type] then
        return tContains(ScottyGlobalSettings.favorites[type], typeId)
    end

    return false
end
ADDON.Api.SetFavorite = function(type, typeId, isFavorite)
    if ScottyGlobalSettings.favorites[type] then
        if isFavorite then
            tInsertUnique(ScottyGlobalSettings.favorites[type], typeId)
        else
            local index = tIndexOf(ScottyGlobalSettings.favorites[type], typeId)
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

    return tFilter(ADDON.db, function(row)
        return (row.toy and favoriteToys[row.toy])
                or (row.spell and favoriteSpells[row.spell])
                or (row.item and favoriteItems[row.item])
    end, true)
end