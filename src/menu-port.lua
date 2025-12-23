local ADDON_NAME, ADDON = ...

local menuActionButton = CreateFrame("Button", nil, nil, "InsecureActionButtonTemplate")
menuActionButton:SetAttribute("pressAndHoldAction", 1)
menuActionButton:RegisterForClicks("LeftButtonUp")
menuActionButton:SetPropagateMouseClicks(true)
menuActionButton:SetPropagateMouseMotion(true)
menuActionButton:Hide()

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

local function buildEntry(menuRoot, dbType, typeId, icon, location, tooltipSetter, hasCooldown, dbRow)
    local prefix = ""
    if type(icon) == "number" then
        prefix = "|T" .. icon .. ":0|t "
    elseif type(icon) == "string" then
        prefix = "|A:" .. icon .. ":16:16|a "
    end

    local currentlyClicking = false

    local element = menuRoot:CreateButton(prefix..location, function()
        return MenuResponse.CloseAll
    end)
    element:HookOnEnter(function(frame)
        menuActionButton:SetScript("PreClick", function()
            currentlyClicking = true
            ADDON.Events:TriggerEvent("OnInitializeTeleport", dbType, typeId, dbRow)
        end)
        menuActionButton:SetScript("PostClick", function()
            ADDON.Events:TriggerEvent("TeleportInitialized", dbType, typeId, dbRow)
        end)
        menuActionButton:SetAttribute("type", dbType)
        menuActionButton:SetAttribute("typerelease", dbType)
        menuActionButton:SetAttribute(dbType, typeId)
        menuActionButton:SetParent(frame)
        menuActionButton:SetAllPoints(frame)
        menuActionButton:SetFrameStrata("TOOLTIP")
        menuActionButton:Show()
        ADDON.Events:TriggerEvent("OnPrepareTeleport", dbType, typeId, dbRow)
    end)
    if tooltipSetter then
        element:HookOnEnter(function(frame)
            GameTooltip:SetOwner(frame, "ANCHOR_NONE")
            GameTooltip:ClearLines()
            tooltipSetter(GameTooltip)
            local left, _, width = frame:GetRect()
            local remainingSpaceOnRight = GetScreenWidth() - left - width
            if remainingSpaceOnRight < GameTooltip:GetWidth() then
                GameTooltip:SetPoint("TOPRIGHT", frame, "TOPLEFT") -- on left side
            else
                GameTooltip:SetPoint("TOPLEFT", frame, "TOPRIGHT") -- on right side
            end
            GameTooltip:Show()
        end)
    end
    element:HookOnLeave(function()
        GameTooltip:Hide()
        menuActionButton:Hide()
        menuActionButton:SetParent(nil)
        if not currentlyClicking then
            ADDON.Events:TriggerEvent("OnClearTeleport", dbType, typeId, dbRow)
        end
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
        element:AddResetter(function(parent)
            local star = parent.StarButton
            star:ClearAllPoints()
            star:ClearNormalTexture()
            star:ClearHighlightTexture()
            star:SetSize(0,0)
            star:SetScript("OnClick", nil)
            star:SetScript("OnEnter", nil)
            star:SetScript("OnLeave", nil)
            star.UpdateTexture = nil
            parent.StarButton = nil
        end)
    end
    return element
end

local function buildMacroEntry(menuRoot, macroText, icon, location, cooldown, dbRow)
    local element = buildEntry(
            menuRoot,
            "macro",
            nil,
            icon,
            location,
            nil, --tooltip
            cooldown,
            dbRow
    )
    element:HookOnEnter(function()
        menuActionButton:SetAttribute("macrotext", macroText)
    end)
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
    local itemLocation = dbRow and dbRow.isEquippableItem and ADDON:GetItemSlot(itemId) or ADDON:FindItemInBags(itemId)

    return buildEntry(
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
end

local function buildSpellEntry(menuRoot, spellId, location, portalId, dbRow)
    local cooldown = C_Spell.GetSpellCooldown(spellId)

    local element = buildEntry(
            menuRoot,
            "spell",
            spellId,
            C_Spell.GetSpellTexture(spellId),
            location,
            function(tooltip)
                GameTooltip.SetSpellByID(tooltip, spellId)
            end,
            cooldown.duration > 0 or not C_Spell.IsSpellUsable(spellId),
            dbRow
    )

    if portalId and C_SpellBook.IsSpellInSpellBook(portalId) then
        element:AddInitializer(function(button, elementDescription, menu)
            local portalButton = button:AttachTemplate("WowMenuAutoHideButtonTemplate")

            portalButton:SetNormalFontObject("GameFontHighlight")
            portalButton:SetHighlightFontObject("GameFontHighlight")
            portalButton:SetText(" "..ADDON.L.MENU_PORTAL.." |T" .. C_Spell.GetSpellTexture(portalId) .. ":0|t")
            portalButton:SetSize(portalButton:GetTextWidth(), button.fontString:GetHeight())
            portalButton:SetPoint("RIGHT")
            portalButton:SetPoint("BOTTOM", button.fontString)
            button.PortalButton = portalButton

            local cooldown = C_Spell.GetSpellCooldown(portalId)
            if cooldown.duration > 0 or not C_Spell.IsSpellUsable(portalId) then
                portalButton:SetAlpha(0.5)
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
        element:HookOnEnter(function(parent)
            if parent.PortalButton and parent.PortalButton:IsMouseOver() then
                GameTooltip.SetSpellByID(GameTooltip, portalId)
                menuActionButton:SetAttribute("spell", portalId)
            end
        end)
        element:AddResetter(function(parent)
            local portal = parent.PortalButton
            portal:ClearAllPoints()
            portal:SetSize(0,0)
            portal:SetText("")
            portal:SetScript("OnClick", nil)
            portal:SetScript("OnEnter", nil)
            portal:SetScript("OnLeave", nil)
            parent.PortalButton = nil
        end)
    end

    return element
end

local function buildRow(row, menuRoot)
    if row.spell then
        buildSpellEntry(menuRoot, row.spell, ADDON:GetName(row), row.portal, row)
    elseif row.toy then
        buildToyEntry(menuRoot, row.toy, ADDON:GetName(row), row)
    elseif row.item then
        buildItemEntry(menuRoot, row.item, ADDON:GetName(row), row)
    elseif row.neighborhoodGUID and row.houseGUID and row.plotID then
        local macroText = "/run C_Housing.VisitHouse(\""..row.neighborhoodGUID.."\",\""..row.houseGUID.."\",\""..row.plotID.."\")"
        buildMacroEntry(menuRoot, macroText, "dashboard-panel-homestone-teleport-button", row.ownerName .. ": " .. row.houseName, nil, row)
    end
end

local function IsKnown(row)
    if row.neighborhoodGUID and row.houseGUID and row.plotID then
        return true
    end

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
            (row.spell and C_SpellBook.IsSpellInSpellBook(row.spell))
            or (row.toy and PlayerHasToy(row.toy)
            or (row.item and (C_Item.IsEquippedItem(row.item) or ADDON:PlayerHasItemInBag(row.item))))
        )
end

local function SortRowsByName(list)
    table.sort(list, function(a, b)
        return ADDON:GetName(a) < ADDON:GetName(b)
    end)
    return list
end

local function generateTeleportMenu(_, root)
    root:SetTag(ADDON_NAME.."-LDB-Teleport")
    root:SetScrollMode(GetScreenHeight() - 100)

    local hasGeneralSpells = false
    local playerHouseInfos, friendsHouseInfos, guildHousesInfos = ADDON.GetHouseInfos()

    -- Hearthstone
    do
        local hearthstoneButton = _G[ADDON_NAME.."HearthstoneButton"]
        if hearthstoneButton:GetAttribute("toy") then
            buildToyEntry(root, hearthstoneButton:GetAttribute("toy"), GetBindLocation()):SetResponder(function()
                hearthstoneButton:ShuffleHearthstone()
                return MenuResponse.CloseAll
            end)
            hasGeneralSpells = true
        elseif hearthstoneButton:GetAttribute("spell") then
            buildSpellEntry(root, hearthstoneButton:GetAttribute("spell"), GetBindLocation())
            hasGeneralSpells = true
        elseif hearthstoneButton:GetAttribute("itemID") then
            buildItemEntry(root, hearthstoneButton:GetAttribute("itemID"), GetBindLocation())
            hasGeneralSpells = true
        end
    end

    -- Vulperas Make Camp
    do
        if C_SpellBook.IsSpellInSpellBook(312372) then
            local location = ScottyPersonalCache.VulperaCamp or C_Spell.GetSpellName(312372)
            buildSpellEntry(root, 312372, location, 312370):AddInitializer(function(button)
                button.PortalButton:SetText(" "..ADDON.L.MENU_VULPERA_CAMP.." |T" .. C_Spell.GetSpellTexture(312370) .. ":0|t")
                button.PortalButton:SetSize(button.PortalButton:GetTextWidth(), button.fontString:GetHeight())
            end)
            hasGeneralSpells = true
        end
    end

    do
        -- Player Houses
        -- HousingDashboardFrame.HouseInfoContent.ContentFrame.HouseUpgradeFrame.TeleportToHouseButton
        for _, playerHouse in ipairs(playerHouseInfos) do
            -- C_Housing.ReturnAfterVisitingHouse() taints hard. can not use that yet :-/
            --if C_HousingNeighborhood.CanReturnAfterVisitingHouse() and C_Housing.GetCurrentNeighborhoodGUID() == playerHouse.neighborhoodGUID then
            --    buildClickEntry(root, "/run C_Housing.ReturnAfterVisitingHouse()", "dashboard-panel-homestone-teleport-out-button", HOUSING_DASHBOARD_RETURN)
            --else
            local cd = C_Housing.GetVisitCooldownInfo()
            local macroText = "/run C_Housing.TeleportHome(\""..playerHouse.neighborhoodGUID.."\",\""..playerHouse.houseGUID.."\",\""..playerHouse.plotID.."\")"
            buildMacroEntry(root, macroText, "dashboard-panel-homestone-teleport-button", playerHouse.houseName, cd.duration > 0)
            --end
            hasGeneralSpells = true
        end
    end

    if hasGeneralSpells then
        root:QueueSpacer()
    end

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
            end
            favorites = SortRowsByName(favorites)
            for _, row in ipairs(favorites) do
                buildRow(row, favoriteRoot)
            end
        end
    end

    -- season dungeons
    local seasonSpells = tFilter(ADDON.db, function(row)
        return row.category == ADDON.Category.SeasonInstance and IsKnown(row)
    end, true)
    do
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

    if #favorites > 0 or #seasonSpells > 0 then
        root:QueueSpacer()
    end

    -- friends houses
    if TableHasAnyEntries(friendsHouseInfos) then
        local friendsRoot = root:CreateButton("|T-13:0|t "..ADDON.L.HOUSE_FRIENDS)
        local friendsHouses = GetValuesArray(friendsHouseInfos)
        -- AccountNames are protected Strings. so we can't use them for sorting.
        table.sort(friendsHouses, function(a, b)
            return strcmputf8i(a.battleTag, b.battleTag) < 0
        end)
        for _, houseInfo in ipairs(friendsHouses) do
            local macroText = "/run C_Housing.VisitHouse(\""..houseInfo.neighborhoodGUID.."\",\""..houseInfo.houseGUID.."\",\""..houseInfo.plotID.."\")"
            buildMacroEntry(friendsRoot, macroText, "dashboard-panel-homestone-teleport-button", houseInfo.accountName .. ": " .. houseInfo.houseName, nil, houseInfo)
        end
        if not TableHasAnyEntries(guildHousesInfos) then
            root:QueueSpacer()
        end
    end
    -- guild member houses
    if TableHasAnyEntries(guildHousesInfos) then
        local guildRoot = root:CreateButton("|T135026:0|t "..ADDON.L.HOUSE_GUILDMEMBERS)
        local guildHouses = GetValuesArray(guildHousesInfos)
        table.sort(guildHouses, function(a, b)
            return strcmputf8i(a.ownerName, b.ownerName) < 0
        end)
        for _, houseInfo in ipairs(guildHouses) do
            buildRow(houseInfo, guildRoot)
        end
        root:QueueSpacer()
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
    local menu = OpenMenu(anchor, generateTeleportMenu)
    ADDON.Events:TriggerEvent("OnOpenTeleportMenu", menu)
    return menu
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
    ADDON.Events:TriggerEvent("OnOpenTeleportMenu", menu)
    return menu
end

Scotty_OpenTeleportMenuAtCursor = ADDON.OpenTeleportMenuAtCursor
