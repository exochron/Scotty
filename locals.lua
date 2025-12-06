local _, ADDON = ...

ADDON.L = {}
local L = ADDON.L

L.MENU_PORTAL = "Portal"
L.MENU_VULPERA_CAMP = "Camp"
L.BINDING_HEARTHSTONE = "Use random hearthstone"
L.BINDING_TELEPORT = "Open teleport menu"
L.HOUSE_FRIENDS = "Houses of friends"
L.HOUSE_GUILDMEMBERS = "Houses of guild members"
L.FAVORITE_TOOLTIP_TEXT = "For the updated favorites list|nplease reopen the menu."
L.SETTING_GROUP_FAVORITES = "Group Favorites"
L.SETTING_GROUP_SEASON = "Group Season Teleports"
L.SETTING_MINIMAP = "Show Minimap Icon"
L.SETTING_SKIP_DIALOG = "Select destination on dialogs automatically"
L.SETTING_HEARTHSTONES = "Choose favorite Hearthstones"
L.SETTING_HEARTHSTONES_TOOLTIP = "You can narrow down your favorite Hearthstones for the Randomizer. It automatically uses all available Hearthstones if none are selected."


local locale = GetLocale()
if locale == "deDE" then
    --@localization(locale="deDE", format="lua_additive_table", handle-unlocalized=comment)@
    --@localization(locale="deDE", namespace="Settings", format="lua_additive_table", handle-unlocalized=comment)@

elseif locale == "esES" then
    --@localization(locale="esES", format="lua_additive_table", handle-unlocalized=comment)@
    --@localization(locale="esES", namespace="Settings", format="lua_additive_table", handle-unlocalized=comment)@

elseif locale == "esMX" then
    --@localization(locale="esMX", format="lua_additive_table", handle-unlocalized=comment)@
    --@localization(locale="esMX", namespace="Settings", format="lua_additive_table", handle-unlocalized=comment)@

elseif locale == "frFR" then
    --@localization(locale="frFR", format="lua_additive_table", handle-unlocalized=comment)@
    --@localization(locale="frFR", namespace="Settings", format="lua_additive_table", handle-unlocalized=comment)@

elseif locale == "itIT" then
    --@localization(locale="itIT", format="lua_additive_table", handle-unlocalized=comment)@
    --@localization(locale="itIT", namespace="Settings", format="lua_additive_table", handle-unlocalized=comment)@

elseif locale == "koKR" then
    --@localization(locale="koKR", format="lua_additive_table", handle-unlocalized=comment)@
    --@localization(locale="koKR", namespace="Settings", format="lua_additive_table", handle-unlocalized=comment)@

elseif locale == "ptBR" then
    --@localization(locale="ptBR", format="lua_additive_table", handle-unlocalized=comment)@
    --@localization(locale="ptBR", namespace="Settings", format="lua_additive_table", handle-unlocalized=comment)@

elseif locale == "ruRU" then
    --@localization(locale="ruRU", format="lua_additive_table", handle-unlocalized=comment)@
    --@localization(locale="ruRU", namespace="Settings", format="lua_additive_table", handle-unlocalized=comment)@

elseif locale == "zhCN" then
    --@localization(locale="zhCN", format="lua_additive_table", handle-unlocalized=comment)@
    --@localization(locale="zhCN", namespace="Settings", format="lua_additive_table", handle-unlocalized=comment)@

elseif locale == "zhTW" then
    --@localization(locale="zhTW", format="lua_additive_table", handle-unlocalized=comment)@
    --@localization(locale="zhTW", namespace="Settings", format="lua_additive_table", handle-unlocalized=comment)@
end

-- update labels for keyboard bindings (see: Bindings.xml)
BINDING_NAME_SCOTTY_TELEPORT = L.BINDING_TELEPORT
_G["BINDING_NAME_CLICK ScottyHearthstoneButton:LeftButton"] = L.BINDING_HEARTHSTONE