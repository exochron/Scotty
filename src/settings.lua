local ADDON_NAME, ADDON = ...

local categoryID

local cachedItemNames = {}

local function cacheHearthstonesData()
    local hearthstones = tFilter(ADDON.db, function(row)
        return row.toy and row.category == ADDON.Category.Hearthstone
    end, true)
    for _, row in pairs(hearthstones) do
        local item = Item:CreateFromItemID(row.toy)
        item:ContinueOnItemLoad(function()
            cachedItemNames[row.toy] = item:GetItemName()
        end)
    end
end

local function registerSettings()
    local L = ADDON.L

    local category, layout = Settings.RegisterVerticalLayoutCategory(C_AddOns.GetAddOnMetadata(ADDON_NAME, "Title"))

    local minimapSetting = Settings.RegisterAddOnSetting(category, ADDON_NAME.."_MINIMAP", "showMinimap",
            ScottyGlobalSettings, Settings.VarType.Boolean, L.SETTING_MINIMAP, Settings.Default.True)
    Settings.CreateCheckbox(category, minimapSetting)

    local skipDialogSetting = Settings.RegisterAddOnSetting(category, ADDON_NAME.."_SKIP_DIALOG", "skipDialog",
            ScottyGlobalSettings, Settings.VarType.Boolean, L.SETTING_SKIP_DIALOG, Settings.Default.True)
    Settings.CreateCheckbox(category, skipDialogSetting)

    local groupFavoritesSetting = Settings.RegisterAddOnSetting(category, ADDON_NAME.."_GROUP_FAVORITES", "groupFavorites",
            ScottyGlobalSettings, Settings.VarType.Boolean, L.SETTING_GROUP_FAVORITES, Settings.Default.False)
    Settings.CreateCheckbox(category, groupFavoritesSetting)

    local groupSeasonSetting = Settings.RegisterAddOnSetting(category, ADDON_NAME.."_GROUP_SEASON", "groupSeason",
            ScottyGlobalSettings, Settings.VarType.Boolean, L.SETTING_GROUP_SEASON, Settings.Default.False)
    if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then -- no seasons in classic yet
        Settings.CreateCheckbox(category, groupSeasonSetting)
    end

    local function HearthstoneOptions()
        local container = Settings.CreateControlTextContainer();
        local hearthstones = tFilter(ADDON.db, function(row)
            return row.toy and row.category == ADDON.Category.Hearthstone and PlayerHasToy(row.toy)
        end, true)
        for _, row in pairs(hearthstones) do
            local label = "|T" .. (C_Item.GetItemIconByID(row.toy) or "") .. ":0|t "..(cachedItemNames[row.toy] or "")
            if not container.AddCheckbox then -- classic; cleanup later
                container:Add(row.toy, label)
            else -- retail
                container:AddCheckbox(row.toy, label)
            end
        end
        return container:GetData();
    end
    local hearthstonesSetting = Settings.RegisterAddOnSetting(category, ADDON_NAME.."_HEARTHSTONES", "hearthstones",
            ScottyGlobalSettings, "table", L.SETTING_HEARTHSTONES, {})
    if #HearthstoneOptions() > 0 then
        local initializer = ADDON:CreateMultiSelectDropdownButton(layout, hearthstonesSetting, HearthstoneOptions, L.SETTING_HEARTHSTONES_TOOLTIP)
        initializer.getSelectionTextFunc = function(selections)
            return #selections == 0 and ALL or nil
        end
    end

    local function onButtonClick()
        local keybindsCategory = SettingsPanel:GetCategory(Settings.KEYBINDINGS_CATEGORY_ID)
        local keybindsLayout = SettingsPanel:GetLayout(keybindsCategory)
        for _, initializer in keybindsLayout:EnumerateInitializers() do
            if initializer.data.name == ADDON_NAME then
                initializer.data.expanded = true
                Settings.OpenToCategory(Settings.KEYBINDINGS_CATEGORY_ID, ADDON_NAME)
                return
            end
        end
    end
    layout:AddInitializer(CreateSettingsButtonInitializer("", SETTINGS_KEYBINDINGS_LABEL, onButtonClick, nil, false))

    Settings.RegisterAddOnCategory(category)
    categoryID = category.ID
end

function ADDON:OpenSettings()
    Settings.OpenToCategory(categoryID)
end

local function CombineSettings(settings, defaultSettings)
    for key, value in pairs(defaultSettings) do
        if (settings[key] == nil) then
            settings[key] = value;
        elseif (type(value) == "table") and next(value) ~= nil then
            if type(settings[key]) ~= "table" then
                settings[key] = {}
            end
            CombineSettings(settings[key], value);
        end
    end

    -- Never cleanup or it would clear the registered settings!
end

ADDON.Events:RegisterCallback("OnInit", function()
    local defaults = {
        favorites = {
            toy = {},
            item = {},
            spell = {},
            house = {},
        },
        minimap = {} -- for LibDBIcon
    }

    ScottyGlobalSettings = ScottyGlobalSettings or defaults
    CombineSettings(ScottyGlobalSettings, defaults)

    cacheHearthstonesData()
    registerSettings()
end, "settings")