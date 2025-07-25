local ADDON_NAME, ADDON = ...

local menuActionButton
local equipQueue = {}
local equipTicker

local function equip(itemId)
    if itemId then
        local itemSlot = ADDON:GetItemSlot(itemId)

        equipQueue[itemSlot] = itemId
        local eventHandle
        eventHandle = ADDON.Events:RegisterFrameEventAndCallbackWithHandle("PLAYER_EQUIPMENT_CHANGED", function(_, equipmentSlot, hasCurrent)
            if itemSlot == equipmentSlot and false == hasCurrent and C_Item.IsEquippedItem(itemId) then
                if equipQueue[itemSlot] == itemId then
                    equipQueue[itemSlot] = nil
                end
                eventHandle:Unregister()
            end
        end, 'equipitem-'..itemId)

        if not equipTicker then
            equipTicker = C_Timer.NewTicker(0.1, function()
                local requestedEquip = false

                for queuedSlot, queuedItemId in pairs(equipQueue) do
                    if queuedItemId and not C_Item.IsEquippedItem(queuedItemId) then
                        C_Item.EquipItemByName(queuedItemId, queuedSlot)
                        requestedEquip = true
                        break
                    end
                end

                if not requestedEquip and equipTicker then
                    equipTicker:Cancel()
                    equipTicker = nil
                end
            end)
        end
    end
end

local function buildMenuActionButton()
    local button = CreateFrame("Button", nil, nil, "InsecureActionButtonTemplate")
    button:SetAttribute("pressAndHoldAction", 1)
    button:RegisterForClicks("LeftButtonUp")
    button:SetPropagateMouseClicks(true)
    button:SetPropagateMouseMotion(true)
    button:Hide()

    return button
end

local function OpenMenu(anchor, generator)
    local menuDescription = MenuUtil.CreateRootMenuDescription(MenuVariants.GetDefaultContextMenuMixin())

    local anchorSource = anchor:GetRelativeTo()
    Menu.PopulateDescription(generator, anchorSource, menuDescription)

    local menu = Menu.GetManager():OpenMenu(anchorSource, menuDescription, anchor)
    if menu then
        menu:HookScript("OnLeave", function()
            if not menu:IsMouseOver() then
                menu:Close()
            end
        end) -- OnLeave gets reset every time
    end

    return menu
end

local function generateTeleportMenu(_, root)
    root:SetTag(ADDON_NAME.."-LDB-Teleport")
    root:SetScrollMode(GetScreenHeight() - 100)

    local function buildEntry(menuRoot, type, typeId, icon, location, tooltipSetter, hasCooldown, dbRow)
        local element = menuRoot:CreateButton("|T" .. icon .. ":0|t "..location, function()
            return MenuResponse.CloseAll
        end)
        element:HookOnEnter(function(frame)
            menuActionButton:SetScript("PreClick", function() end)
            menuActionButton:SetScript("PostClick", function()
                ADDON.Events:TriggerEvent("TeleportInitialized", type, typeId, dbRow)
            end)
            menuActionButton:SetAttribute("type", type)
            menuActionButton:SetAttribute("typerelease", type)
            menuActionButton:SetAttribute(type, typeId)
            menuActionButton:SetParent(frame)
            menuActionButton:SetAllPoints(frame)
            menuActionButton:SetFrameStrata("TOOLTIP")
            menuActionButton:Show()

            GameTooltip:SetOwner(frame, "ANCHOR_NONE")
            GameTooltip:SetPoint("TOPLEFT", frame, "TOPRIGHT")
            GameTooltip:ClearLines()
            tooltipSetter(GameTooltip)
            GameTooltip:Show()
        end)
        element:HookOnLeave(function()
            GameTooltip:Hide()
            menuActionButton:Hide()
        end)
        if hasCooldown then
            element:AddInitializer(function(button)
                button.fontString:SetAlpha(0.5)
            end)
        end
        if dbRow then
            element:AddInitializer(function(parent, elementDescription, menu)
                local star = parent:AttachFrame("CheckButton")
                star:SetNormalAtlas("auctionhouse-icon-favorite")
                star:SetHighlightAtlas("auctionhouse-icon-favorite-off", "ADD")
                star:SetPoint("LEFT")
                star:SetSize(13, 12)

                parent.StarButton = star
                parent.fontString:SetPoint("LEFT", star, "RIGHT", 3, -1)

                star:SetScript("OnEnter", function()
                    local isFavorite = not ADDON.Api.IsFavorite(dbRow)

                    GameTooltip:SetOwner(star, "ANCHOR_CURSOR")
                    GameTooltip:ClearLines()
                    GameTooltip:SetText(isFavorite and BATTLE_PET_FAVORITE or BATTLE_PET_UNFAVORITE)
                    GameTooltip:AddLine(ADDON.L.FAVORITE_TOOLTIP_TEXT)
                    GameTooltip:Show()
                end)
                star:SetScript("OnLeave", function()
                    GameTooltip:Hide()
                end)
                star:SetScript("OnClick", function(self)
                    local isFavorite = not ADDON.Api.IsFavorite(dbRow)
                    ADDON.Api.SetFavorite(dbRow, isFavorite)
                    self:UpdateTexture(isFavorite)
                    menu:SendResponse(elementDescription, MenuResponse.Refresh)
                end)
                star.UpdateTexture = function (self, isFavorite)
                    local atlas = isFavorite and "auctionhouse-icon-favorite" or "auctionhouse-icon-favorite-off";
                    self:GetNormalTexture():SetAtlas(atlas);
                    self:GetHighlightTexture():SetAtlas(atlas)
                    self:GetHighlightTexture():SetAlpha(isFavorite and 0.2 or 0.4)
                end

                local isFavorite = ADDON.Api.IsFavorite(dbRow)
                star:SetChecked(isFavorite)
                star:UpdateTexture(isFavorite)
            end)
        end
        return element
    end

    local function buildToyEntry(menuRoot, itemId, location, dbRow)
        return buildEntry(
                menuRoot,
                "toy",
                itemId,
                C_Item.GetItemIconByID(itemId),
                location,
                function(tooltip)
                    GameTooltip.SetToyByItemID(tooltip, itemId)
                end,
                not C_ToyBox.IsToyUsable(itemId) or C_Container.GetItemCooldown(itemId) > 0,
                dbRow
        )
    end

    local function buildItemEntry(menuRoot, itemId, location, dbRow)
        local itemLocation = C_Item.IsEquippableItem(itemId) and ADDON:GetItemSlot(itemId) or ADDON:FindItemInBags(itemId)

        local element = buildEntry(
                menuRoot,
                "item",
                itemLocation,
                C_Item.GetItemIconByID(itemId),
                location,
                function(tooltip)
                    GameTooltip.SetItemByID(tooltip, itemId)
                end,
                C_Container.GetItemCooldown(itemId) > 0,
                dbRow
        )
        if C_Item.IsEquippableItem(itemId) then

            local previousEquippedItem = GetInventoryItemID("player", itemLocation)
            local currentlyClicking = false

            element:HookOnEnter(function()
                equip(itemId)
                menuActionButton:SetScript("PreClick", function()
                    currentlyClicking = true

                    if previousEquippedItem and previousEquippedItem ~= itemId then
                        local successHandle, stopHandle, errorHandle
                        local function reequipAfterTeleport(handlerName, unit)
                            if handlerName == "reequip-on-error" or unit == "player" then
                                equip(previousEquippedItem)
                                successHandle:Unregister()
                                stopHandle:Unregister()
                                errorHandle:Unregister()
                            end
                        end
                        successHandle = ADDON.Events:RegisterFrameEventAndCallbackWithHandle("UNIT_SPELLCAST_SUCCEEDED", reequipAfterTeleport, 'reequip-after-teleport')
                        stopHandle = ADDON.Events:RegisterFrameEventAndCallbackWithHandle("UNIT_SPELLCAST_STOP", reequipAfterTeleport, 'reequip-after-teleport')
                        errorHandle = ADDON.Events:RegisterFrameEventAndCallbackWithHandle("UI_ERROR_MESSAGE", reequipAfterTeleport, 'reequip-on-error')
                    end
                end)
            end)
            element:HookOnLeave(function()
                if not currentlyClicking then
                    equip(previousEquippedItem)
                end
            end)
        end

        return element
    end

    local function buildSpellEntry(menuRoot, spellId, location, portalId, dbRow)
        local element = buildEntry(
                menuRoot,
                "spell",
                spellId,
                C_Spell.GetSpellTexture(spellId),
                location,
                function(tooltip)
                    GameTooltip.SetSpellByID(tooltip, spellId)
                end,
                not C_Spell.IsSpellUsable(spellId),
                dbRow
        )

        if portalId and IsSpellKnown(portalId) then
            local portalButton
            element:AddInitializer(function(button, elementDescription, menu)
                portalButton = button:AttachTemplate("WowMenuAutoHideButtonTemplate")

                portalButton:SetNormalFontObject("GameFontHighlight")
                portalButton:SetHighlightFontObject("GameFontHighlight")
                portalButton:SetText(" "..ADDON.L.MENU_PORTAL.." |T" .. C_Spell.GetSpellTexture(portalId) .. ":0|t")
                portalButton:SetSize(portalButton:GetTextWidth(), button.fontString:GetHeight())
                portalButton:SetPoint("RIGHT")
                portalButton:SetPoint("BOTTOM", button.fontString)

                if not C_Spell.IsSpellUsable(portalId) then
                    portalButton.fontString:SetAlpha(0.5)
                end

                portalButton:SetScript("OnClick", function()
                    C_Timer.After(0.01, function()
                        menu:SendResponse(elementDescription, MenuResponse.CloseAll)
                    end)
                end)
                portalButton:SetScript("OnEnter", function()
                    GameTooltip.SetSpellByID(GameTooltip, portalId)
                    menuActionButton:SetAttribute("spell", portalId)
                end)
                portalButton:SetScript("OnLeave", function()
                    GameTooltip.SetSpellByID(GameTooltip, spellId)
                    menuActionButton:SetAttribute("spell", spellId)
                end)
            end)
            element:HookOnEnter(function()
                if portalButton and portalButton:IsMouseOver() then
                    GameTooltip.SetSpellByID(GameTooltip, portalId)
                    menuActionButton:SetAttribute("spell", portalId)
                end
            end)
        end

        return element
    end

    local function GetName(row)
        if row.name then
            return row.name
        end
        if row.instance then
            return GetRealZoneText(row.instance)
        end
        if row.map then
            return C_Map.GetMapInfo(row.map).name
        end
        if row.toy or row.item then
            return C_Item.GetItemNameByID(row.toy or row.item)
        end
        if row.spell then
            return C_Spell.GetSpellName(row.spell)
        end

        return ""
    end

    local function buildRow(row, menuRoot)
        if row.spell then
            buildSpellEntry(menuRoot, row.spell, GetName(row), row.portal, row)
        elseif row.toy then
            buildToyEntry(menuRoot, row.toy, GetName(row), row)
        elseif row.item then
            buildItemEntry(menuRoot, row.item, GetName(row), row)
        end
    end

    local function IsKnown(row)
        if row.quest then
            local quests = type(row.quest) == "table" and row.quest or {row.quest}
            for _, questId in ipairs(quests) do
                if not C_QuestLog.IsQuestFlaggedCompleted(questId) then
                    return false
                end
            end
        end

        return
            (
                nil == row.accountQuest
                or (C_QuestLog.IsQuestFlaggedCompletedOnAccount and C_QuestLog.IsQuestFlaggedCompletedOnAccount(row.accountQuest))
            ) and (
                (row.spell and IsSpellKnown(row.spell))
                or (row.toy and PlayerHasToy(row.toy)
                or (row.item and (C_Item.IsEquippedItem(row.item) or ADDON:PlayerHasItemInBag(row.item))))
            )
    end

    local function SortRowsByName(list)
        table.sort(list, function(a, b)
            return GetName(a) < GetName(b)
        end)
        return list
    end

    -- Hearthstone
    do
        local hearthstoneButton = _G[ADDON_NAME.."HearthstoneButton"]
        if hearthstoneButton:GetAttribute("toy") then
            buildToyEntry(root, hearthstoneButton:GetAttribute("toy"), GetBindLocation()):SetResponder(function()
                hearthstoneButton:ShuffleHearthstone()
                return MenuResponse.CloseAll
            end)
            root:QueueSpacer()
        elseif hearthstoneButton:GetAttribute("spell") then
            buildSpellEntry(root, hearthstoneButton:GetAttribute("spell"), GetBindLocation())
            root:QueueSpacer()
        elseif hearthstoneButton:GetAttribute("itemID") then
            buildItemEntry(root, hearthstoneButton:GetAttribute("itemID"), GetBindLocation())
            root:QueueSpacer()
        end
    end

    local hasUngroupedFavorites = false

    -- favorites
    local favorites = ADDON.Api.GetFavoriteDatabase()
    favorites = tFilter(favorites, function(row)
        return IsKnown(row)
    end, true)
    do
        if #favorites > 0 then
            local favoriteRoot = root
            if Settings.GetValue(ADDON_NAME.."_GROUP_FAVORITES") then
                favoriteRoot = root:CreateButton(FAVORITES)
            else
                favoriteRoot:CreateTitle(FAVORITES)
                hasUngroupedFavorites = true
            end
            favorites = SortRowsByName(favorites)
            for _, row in ipairs(favorites) do
                buildRow(row, favoriteRoot)
            end
        end
    end

    -- season dungeons
    do
        local seasonSpells = tFilter(ADDON.db, function(row)
            return row.category == ADDON.Category.SeasonInstance and IsKnown(row)
        end, true)
        if #seasonSpells > 0 then
            local seasonRoot = root
            local currentSeasonName = EJ_GetTierInfo(EJ_GetNumTiers())
            if Settings.GetValue(ADDON_NAME.."_GROUP_SEASON") then
                if #favorites > 0 and not Settings.GetValue(ADDON_NAME.."_GROUP_FAVORITES") then
                    root:QueueSpacer()
                end
                seasonRoot = root:CreateButton(currentSeasonName)
            else
                if #favorites > 0 then
                    root:QueueSpacer()
                end
                root:CreateTitle(currentSeasonName)
            end
            seasonSpells = SortRowsByName(seasonSpells)
            for _, row in ipairs(seasonSpells) do
                buildRow(row, seasonRoot)
            end
        end
    end

    -- continents
    do
        local groupedByContinent = {}
        for _, row in ipairs(ADDON.db) do
            if row.continent and IsKnown(row) then
                if not groupedByContinent[row.continent] then
                    groupedByContinent[row.continent] = {}
                end
                table.insert(groupedByContinent[row.continent], row)
            end
        end
        local continents = GetKeysArray(groupedByContinent)
        if #continents > 0 then
            root:QueueSpacer()
            table.sort(continents, function(a, b) return a > b end)
            for _, continent in ipairs(continents) do
                local list = SortRowsByName(groupedByContinent[continent])
                local continentRoot = root:CreateButton(GetRealZoneText(continent))
                for _, row in ipairs(list) do
                    buildRow(row, continentRoot)
                end
            end
        end
    end
end

function ADDON:OpenTeleportMenu(frame)
    local anchor = CreateAnchor("TOP", frame, "BOTTOM")
    return OpenMenu(anchor, generateTeleportMenu)
end
function ADDON:OpenTeleportMenuAtCursor()
    local uiScale, x, y = UIParent:GetEffectiveScale(), GetCursorPosition()
    x = x/uiScale
    y = y/uiScale

    local anchor = CreateAnchor("TOPLEFT", UIParent, "BOTTOMLEFT", x, y)
    local menu = OpenMenu(anchor, generateTeleportMenu)
    if menu:GetHeight() > y then
        anchor:Set("BOTTOMLEFT", UIParent, "BOTTOMLEFT", x, y)
        anchor:SetPoint(menu, true)
    end
end

Scotty_OpenTeleportMenuAtCursor = ADDON.OpenTeleportMenuAtCursor

ADDON.Events:RegisterCallback("OnLogin", function()
    menuActionButton = buildMenuActionButton()
end, "menu-teleport")