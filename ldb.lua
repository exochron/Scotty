local ADDON_NAME, ADDON = ...

local tFilter = tFilter

local hearthstoneButton
local menuActionButton
local function buildMenuActionButton()
    local button = CreateFrame("Button", nil, nil, "InsecureActionButtonTemplate")
    button:SetAttribute("pressAndHoldAction", 1)
    button:RegisterForClicks("LeftButtonUp")
    button:SetPropagateMouseClicks(true)
    button:SetPropagateMouseMotion(true)
    button:Hide()

    return button
end

local equipQueue = {}
local equipAwaitingConfirmationForSlot
local function equip(itemId, priority)
    if itemId and not C_Item.IsEquippedItem(itemId) then
        local itemSlot = ADDON:GetItemSlot(itemId)
        if not equipAwaitingConfirmationForSlot and #equipQueue == 0 then
            equipAwaitingConfirmationForSlot = itemSlot
            local eventHandle
            eventHandle = ADDON.Events:RegisterFrameEventAndCallbackWithHandle("PLAYER_EQUIPMENT_CHANGED", function(_, equipmentSlot, hasCurrent)
                if equipmentSlot and false == hasCurrent and C_Item.IsEquippedItem(itemId) then
                    equipAwaitingConfirmationForSlot = nil

                    local nextItemId
                    repeat
                        nextItemId = table.remove(equipQueue)
                    until not nextItemId or not C_Item.IsEquippedItem(nextItemId)

                    if nextItemId then
                        equipAwaitingConfirmationForSlot = ADDON:GetItemSlot(nextItemId)
                        C_Item.EquipItemByName(nextItemId)
                    else
                        eventHandle:Unregister()
                    end
                end
            end, 'equipchanged')

            -- something might prevent equipping. an error message appears than. please prevent that case.
            C_Item.EquipItemByName(itemId)
        elseif equipAwaitingConfirmationForSlot then
            if priority then
                table.insert(equipQueue, itemId)
            else
                table.insert(equipQueue, 1, itemId)
            end
        end
    end
end

local function generateTeleportMenu(_, root)
    root:SetTag(ADDON_NAME.."-LDB-Teleport")
    root:SetScrollMode(GetScreenHeight() - 100)

    --root:CreateTitle("Teleports")

    local function buildEntry(root, type, id, icon, location, tooltipSetter, hasCooldown)
        local element = root:CreateButton("|T" .. icon .. ":0|t "..location, function()
            return MenuResponse.CloseAll
        end)
        element:HookOnEnter(function(frame)
            menuActionButton:SetAttribute("type", type)
            menuActionButton:SetAttribute("typerelease", type)
            menuActionButton:SetAttribute(type, id)
            menuActionButton:SetParent(frame)
            menuActionButton:SetAllPoints(frame)
            menuActionButton:SetFrameStrata("FULLSCREEN_DIALOG")
            menuActionButton:SetFrameLevel(10000)
            menuActionButton:Show()

            GameTooltip:SetOwner(frame, "ANCHOR_NONE")
            GameTooltip:SetPoint("TOPLEFT", frame, "TOPRIGHT")
            GameTooltip:ClearLines()
            tooltipSetter(GameTooltip, id)
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
        return element
    end

    local function buildToyEntry(root, itemId, location)
        return buildEntry(
                root,
            "toy",
            itemId,
            C_Item.GetItemIconByID(itemId),
            location,
            GameTooltip.SetToyByItemID,
                not C_ToyBox.IsToyUsable(itemId) or C_Container.GetItemCooldown(itemId) > 0
        )
    end

    local function buildItemEntry(root, itemId, location)
        if not C_Item.IsEquippedItem(itemId) and not ADDON:PlayerHasItemInBag(itemId) then
            return
        end

        local element = buildEntry(
                root,
            "item",
            itemId,
            C_Item.GetItemIconByID(itemId),
            location,
            GameTooltip.SetItemByID,
                C_Container.GetItemCooldown(itemId) > 0
        )
        if C_Item.IsEquippableItem(itemId) then

            local inventorySlot = ADDON:GetItemSlot(itemId)
            local previousEquippedItem = GetInventoryItemID("player", inventorySlot)
            local currentlyClicking = false

            element:HookOnEnter(function()
                menuActionButton:SetScript("PreClick", function()
                    currentlyClicking = true
                    menuActionButton:SetAttribute("item", "")
                    menuActionButton:SetAttribute("slot", inventorySlot)

                    if previousEquippedItem then
                        local successHandle, stopHandle
                        local function reequipAfterTeleport(_, unit)
                            if unit == "player" then
                                equip(previousEquippedItem, false)
                                successHandle:Unregister()
                                stopHandle:Unregister()
                            end
                        end
                        successHandle = ADDON.Events:RegisterFrameEventAndCallbackWithHandle("UNIT_SPELLCAST_SUCCEEDED", reequipAfterTeleport, 'reequip-after-teleport')
                        stopHandle = ADDON.Events:RegisterFrameEventAndCallbackWithHandle("UNIT_SPELLCAST_STOP", reequipAfterTeleport, 'reequip-after-teleport')
                    end
                end)
                if not C_Item.IsEquippedItem(itemId) then
                    equip(itemId, true)
                end
            end)
            element:HookOnLeave(function()
                if not currentlyClicking then
                    equip(previousEquippedItem, false)
                end
            end)
        end

        return element
    end

    local function buildSpellEntry(root, spellId, location, portalId)
        local element = buildEntry(
                root,
            "spell",
            spellId,
            C_Spell.GetSpellTexture(spellId),
            location,
            GameTooltip.SetSpellByID,
            not C_Spell.IsSpellUsable(spellId)
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
        if row.instance then
            return GetRealZoneText(row.instance)
        end
        if row.map then
            return C_Map.GetMapInfo(row.map).name
        end
        --if row.toy then
        --    return C_Item.GetItemNameByID(row.toy)
        --end
        --if row.item then
        --    return C_Item.GetItemNameByID(row.item)
        --end
        --if row.spell then
        --    return C_Spell.GetSpellName(row.spell)
        --end

        return ""
    end

    local function SortRowsByName(list)
        table.sort(list, function(a, b)
            return GetName(a) < GetName(b)
        end)
        return list
    end

    -- Hearthstone
    if hearthstoneButton:GetAttribute("toy") then
        buildToyEntry(root, hearthstoneButton:GetAttribute("toy"), GetBindLocation()):SetResponder(function()
            hearthstoneButton:ShuffleHearthstone()
            return MenuResponse.CloseAll
        end)
    elseif hearthstoneButton:GetAttribute("spell") then
        buildItemEntry(root, hearthstoneButton:GetAttribute("spell"), GetBindLocation())
    else
        buildItemEntry(root, hearthstoneButton:GetAttribute("item"), GetBindLocation())
    end
    root:QueueSpacer()

    -- season dungeons
    local seasonSpells = tFilter(ADDON.db, function(row)
        return row.category == ADDON.Category.SeasonInstance and row.spell and IsSpellKnown(row.spell)
    end, true)
    seasonSpells = SortRowsByName(seasonSpells)
    for _, row in ipairs(seasonSpells) do
        buildSpellEntry(root, row.spell, GetRealZoneText(row.instance))
    end
    root:QueueSpacer()

    -- continents
    local groupedByContinent = {}
    for _, row in ipairs(ADDON.db) do
        if row.continent then
            if not groupedByContinent[row.continent] then
                groupedByContinent[row.continent] = {}
            end
            table.insert(groupedByContinent[row.continent], row)
        end
    end
    local continents = GetKeysArray(groupedByContinent)
    table.sort(continents, function(a, b) return a > b end)
    for _, continent in ipairs(continents) do
        local list = groupedByContinent[continent]
        list = tFilter(list, function(row) return (row.spell and IsSpellKnown(row.spell)) or (row.toy and PlayerHasToy(row.toy) or (row.item)) end, true)
        if #list > 0 then
            list = SortRowsByName(list)
            local continentRoot = root:CreateButton(GetRealZoneText(continent))
            for _, row in ipairs(list) do
                if row.spell then
                    buildSpellEntry(continentRoot, row.spell, GetName(row), row.portal)
                elseif row.toy then
                    buildToyEntry(continentRoot, row.toy, GetName(row))
                elseif row.item then
                    buildItemEntry(continentRoot, row.item, GetName(row))
                end
            end
        end
    end
end

local function OpenMenu(anchorSource, generator)
    local menuDescription = MenuUtil.CreateRootMenuDescription(MenuVariants.GetDefaultContextMenuMixin())

    local point, relativeTo, relativePoint, offsetX, offsetY = anchorSource:GetPoint(1)

    Menu.PopulateDescription(generator, relativeTo, menuDescription)

    local anchor = CreateAnchor(point, relativeTo, relativePoint, offsetX, offsetY)
    local menu = Menu.GetManager():OpenMenu(relativeTo, menuDescription, anchor)
    if menu then
        menu:HookScript("OnLeave", function()
            if not menu:IsMouseOver() then
                menu:Close()
            end
        end) -- OnLeave gets reset every time
    end

    return menu
end

local function buildHearthstoneButton()
    local button = CreateFrame("Button", nil, nil, "SecureActionButtonTemplate")

    local function GetRandomHearthstoneToy()
        local stones = tFilter(ADDON.db, function(row)
            return row.category == ADDON.Category.Hearthstone and row.toy and PlayerHasToy(row.toy)
        end, true)
        stones = TableUtil.Transform(stones, function(row) return row.toy end)

        -- avoid last used hearthstone
        if #stones > 1 and button:GetAttribute("toy") then
            local skipToy = button:GetAttribute("toy")
            stones = tFilter(stones, function(v) return v ~= skipToy end, true)
        end

        return GetRandomArrayEntry(stones)
    end
    button.ShuffleHearthstone = function(self)
        local toy = GetRandomHearthstoneToy()
        if toy then
            self:SetAttribute("type", "toy")
            self:SetAttribute("typerelease", "toy")
            self:SetAttribute("toy", toy)
            self:SetAttribute("item", nil)
            self:SetAttribute("spell", nil)
            return
        end

        local AstralRecall = 556
        if IsSpellKnown(AstralRecall) and C_Spell.IsSpellUsable(AstralRecall) then
            self:SetAttribute("type", "spell")
            self:SetAttribute("typerelease", "spell")
            self:SetAttribute("spell", AstralRecall)
            self:SetAttribute("item", nil)
            self:SetAttribute("toy", nil)
        end

        local item = C_Container.PlayerHasHearthstone and C_Container.PlayerHasHearthstone() or PlayerHasHearthstone()
        if item then
            self:SetAttribute("type", "item")
            self:SetAttribute("typerelease", "item")
            self:SetAttribute("item", item)
            self:SetAttribute("toy", nil)
            self:SetAttribute("spell", nil)
        end
    end

    button:SetAttribute("pressAndHoldAction", 1)
    button:RegisterForClicks("LeftButtonUp")
    button:SetPropagateMouseClicks(true)
    button:SetPropagateMouseMotion(true)
    button:SetFrameStrata("DIALOG")
    button:SetSize(1,1)
    button:SetPoint("RIGHT", -10, -10)
    button:Show()
    button:ShuffleHearthstone()
    button:HookScript("PreClick", function()
        if not InCombatLockdown() and button:GetParent():IsDragging() then
            button:SetAttribute("type", "")
            button:SetAttribute("typerelease", "")
        end
    end)
    button:HookScript("PostClick", function(self)
        if not InCombatLockdown() then
            self:ShuffleHearthstone()
        end
    end)

    return button
end

ADDON.Events:RegisterCallback("OnLogin", function()
    local ldb = LibStub and LibStub("LibDataBroker-1.1", true)
    if not ldb then
        return
    end

    menuActionButton = buildMenuActionButton()
    hearthstoneButton = buildHearthstoneButton()

    local menu
    local tooltipProxy = CreateFrame("Frame")
    tooltipProxy:Hide()
    tooltipProxy:HookScript("OnShow", function()
        if not InCombatLockdown() then
            local point, relativeTo, relativePoint, offsetX, offsetY = tooltipProxy:GetPoint(1)
            hearthstoneButton:SetParent(relativeTo)
            hearthstoneButton:SetAllPoints(relativeTo)

            menu = OpenMenu(tooltipProxy, generateTeleportMenu)
        end
    end)
    tooltipProxy:HookScript("OnHide", function()
        if menu and not menu:IsMouseOver() then
            menu:Close()
        end
    end)

    local hearthstoneItem = hearthstoneButton:GetAttribute("toy") or hearthstoneButton:GetAttribute("item")
    local ldbDataObject = ldb:NewDataObject( ADDON_NAME, {
        type = "data source",
        text = GetBindLocation(),
        label = C_Item.GetItemNameByID(hearthstoneItem),
        icon = C_Item.GetItemIconByID(hearthstoneItem),
        tooltip = tooltipProxy,

        OnClick = function(_, button)
            if button == "RightButton" then
            else
            end
        end,
    } )

    hearthstoneButton:HookScript("OnAttributeChanged", function(_, name, value)
        if value and (name == "toy" or name == "item") then
            ldbDataObject.label = C_Item.GetItemNameByID(value)
            ldbDataObject.icon = C_Item.GetItemIconByID(value)
        end
    end)

    ADDON.Events:RegisterFrameEventAndCallback("HEARTHSTONE_BOUND", function()
        ldbDataObject.text = GetBindLocation()
    end, 'ldb-plugin')

end, "ldb-plugin")