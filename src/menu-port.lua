local ADDON_NAME, ADDON = ...

local MENU_TAG = ADDON_NAME.."-LDB-Teleport"

local menuActionButton = CreateFrame("Button", nil, nil, "InsecureActionButtonTemplate")
menuActionButton:SetAttribute("pressAndHoldAction", 1)
menuActionButton:RegisterForClicks("LeftButtonUp")
menuActionButton:SetPropagateMouseClicks(true)
menuActionButton:SetPropagateMouseMotion(true)
menuActionButton:Hide()

local scottyTooltip = CreateFrame("GameTooltip", "ScottyMenuToolTip", UIParent, "GameTooltipTemplate")

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

local function GetHousingIcon(neighborhoodGUID)
    local hoodRegion = select (3, strsplit("-", neighborhoodGUID))
    if hoodRegion == "1" then
        return "communities-icon-faction-alliance"
    elseif hoodRegion == "2" then
        return "communities-icon-faction-horde"
    end
    return "dashboard-panel-homestone-teleport-button"
end

local function GetBnetIcon()
    local appIconId = 0
    C_Texture.GetTitleIconTexture("App", 0, function(success, fileId)
      if success then
          appIconId = fileId
      end
    end)
    return appIconId
end

local function buildEntry(menuRoot, dbType, typeId, icon, location, tooltipSetter, hasCooldown, dbRow)
    local buttonText = location

    local currentlyClicking = false

    local element = menuRoot:CreateButton(buttonText, function()
        return MenuResponse.CloseAll
    end)
    element:AddInitializer(function(parent)
        local tex = parent:AttachTexture()
        if type(icon) == "number" then
            tex:SetTexture(icon)
            tex:SetTexCoord(0.1, 0.9, 0.1, 0.9)
        elseif type(icon) == "string" then
            tex:SetAtlas(icon, false)
        end
        tex:SetPoint("LEFT")
        tex:SetSize(21, 21)
        parent.Icon = tex
        parent.fontString:SetPoint("LEFT", tex, "RIGHT", 4, 0)
    end)
    element:AddResetter(function(parent)
        local tex = parent.Icon
        tex:ClearAllPoints()
        tex:SetSize(0,0)
        tex:SetTexture()
        tex:SetAlpha(1)
        parent.Icon = nil
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
            scottyTooltip:SetOwner(frame, "ANCHOR_NONE")
            scottyTooltip:ClearLines()
            tooltipSetter(scottyTooltip)
            local left, _, width = frame:GetRect()
            local remainingSpaceOnRight = GetScreenWidth() - left - width
            if remainingSpaceOnRight < scottyTooltip:GetWidth() then
                scottyTooltip:SetPoint("TOPRIGHT", frame, "TOPLEFT") -- on left side
            else
                scottyTooltip:SetPoint("TOPLEFT", frame, "TOPRIGHT") -- on right side
            end
            scottyTooltip:Show()
        end)
    end
    element:HookOnLeave(function()
        scottyTooltip:Hide()
        menuActionButton:Hide()
        menuActionButton:SetParent(nil)
        if not currentlyClicking then
            ADDON.Events:TriggerEvent("OnClearTeleport", dbType, typeId, dbRow)
        end
    end)
    if hasCooldown then
        local cdTimer
        element:AddInitializer(function(button)
            local cdSuffix = ""
            if type(hasCooldown) == "number" then
                cdSuffix = ADDON:BuildCooldownString(hasCooldown, true)
                if (cdSuffix == "0s" or cdSuffix == "1s" or cdSuffix == "2s") and ADDON:IsGCD() then
                    return
                end
            end
            button.fontString:SetText(buttonText.. cdSuffix)
            button.fontString:SetAlpha(0.5)
            button.Icon:SetAlpha(0.5)
            if (cdSuffix ~= "" and hasCooldown - GetTime() <= 60) then
                cdTimer = C_Timer.NewTicker(1, function()
                    if button.fontString then
                        cdSuffix = ADDON:BuildCooldownString(hasCooldown, true)
                        button.fontString:SetText(buttonText.. cdSuffix)
                        if cdSuffix == "" then
                            button.fontString:SetAlpha(1)
                            button.Icon:SetAlpha(1)
                        end
                    end
                end, hasCooldown - GetTime() + 1)
            end
        end)
        element:AddResetter(function(button)
            button.fontString:SetAlpha(1)
            if cdTimer then
                cdTimer:Cancel()
            end
        end)
    end
    if dbRow then
        element:AddInitializer(function(parent, elementDescription, menu)
            local star = parent:AttachFrame("CheckButton")
            star:SetNormalAtlas("auctionhouse-icon-favorite")
            star:SetHighlightAtlas("auctionhouse-icon-favorite-off", "ADD")
            star:SetPoint("LEFT", 0, 0)
            star:SetSize(12, 12)
            star:SetFrameStrata("TOOLTIP")

            parent.StarButton = star
            parent.Icon:SetPoint("LEFT", 17, 0)

            star:SetScript("OnEnter", function()
                local isFavorite = not ADDON.Api.IsFavorite(dbRow)

                scottyTooltip:SetOwner(star, "ANCHOR_CURSOR")
                scottyTooltip:ClearLines()
                scottyTooltip:SetText(isFavorite and BATTLE_PET_FAVORITE or BATTLE_PET_UNFAVORITE)
                scottyTooltip:AddLine(ADDON.L.FAVORITE_TOOLTIP_TEXT)
                scottyTooltip:Show()
            end)
            star:SetScript("OnLeave", function()
                scottyTooltip:Hide()
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
            star:SetFrameStrata("MEDIUM")
            star.UpdateTexture = nil
            parent.StarButton = nil
        end)
    end
    return element
end

local function buildToyEntry(menuRoot, itemId, location, dbRow)

    local cdTime, cdDuration = C_Container.GetItemCooldown(itemId)
    if cdTime > 0 then
        cdTime = cdTime + cdDuration
    else
        cdTime = false
    end

    return buildEntry(
            menuRoot,
            "toy",
            itemId,
            C_Item.GetItemIconByID(itemId),
            location,
            function(tooltip)
                GameTooltip.SetToyByItemID(tooltip, itemId)
            end,
            cdTime or not C_ToyBox.IsToyUsable(itemId),
            dbRow
    )
end

local function buildItemEntry(menuRoot, itemId, location, dbRow)
    local itemLocation = dbRow and dbRow.isEquippableItem and ADDON:GetItemSlot(itemId) or ADDON:FindItemInBags(itemId)

    if dbRow and dbRow.consumable then
        local _, bag, slot = SecureCmdItemParse(itemLocation)
        local containerInfo = C_Container.GetContainerItemInfo(bag, slot)
        if containerInfo then
            location = location .. " ["..containerInfo.stackCount.."x]"
        end
    end

    local cdTime, cdDuration = C_Container.GetItemCooldown(itemId)
    if cdTime > 0 then
        cdTime = cdTime + cdDuration
    else
        cdTime = false
    end

    return buildEntry(
        menuRoot,
        "item",
        itemLocation,
        C_Item.GetItemIconByID(itemId),
        location,
        function(tooltip)
            GameTooltip.SetItemByID(tooltip, itemId)
        end,
        cdTime,
        dbRow
    )
end

local function buildSpellEntry(menuRoot, spellId, location, portalId, dbRow)
    local cdTime = false
    local spellCooldown = C_Spell.GetSpellCooldown(spellId)
    if spellCooldown and not issecretvalue(spellCooldown.startTime) and spellCooldown.startTime > 0 then
        cdTime = spellCooldown.startTime + spellCooldown.duration
    end

    local element = buildEntry(
            menuRoot,
            "spell",
            spellId,
            C_Spell.GetSpellTexture(spellId),
            location,
            function(tooltip)
                GameTooltip.SetSpellByID(tooltip, spellId)
            end,
            cdTime or not C_Spell.IsSpellUsable(spellId),
            dbRow
    )

    if portalId and C_SpellBook.IsSpellInSpellBook(portalId) then
        element:AddInitializer(function(button, elementDescription, menu)
            local portalButton = MenuTemplates.AttachBasicButton(button)

            local portalIcon = button:AttachTexture()
            portalIcon:SetTexture(C_Spell.GetSpellTexture(portalId))
            portalIcon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
            portalIcon:SetSize(21, 21)
            portalIcon:SetParent(portalButton)
            portalIcon:SetPoint("RIGHT")
            button.PortalIcon = portalIcon

            portalButton:SetNormalFontObject("GameFontHighlight")
            portalButton:SetHighlightFontObject("GameFontHighlight")
            portalButton:SetText(" "..ADDON.L.MENU_PORTAL.."       ") -- space for portalIcon
            portalButton:SetSize(portalButton:GetTextWidth(), button.fontString:GetHeight())
            portalButton:SetPoint("RIGHT")
            portalButton:SetPoint("BOTTOM", button.fontString)
            button.PortalButton = portalButton

            if portalButton.Texture then
                portalButton.Texture:SetTexture() --reset previous textures
            end

            local portalCooldown = C_Spell.GetSpellCooldown(portalId)
            if portalCooldown and not issecretvalue(portalCooldown.duration) and portalCooldown.duration > 0 or not C_Spell.IsSpellUsable(portalId) then
                portalButton:SetAlpha(0.5)
            end

            portalButton:SetScript("OnClick", function()
                C_Timer.After(0.01, function()
                    menu:SendResponse(elementDescription, MenuResponse.CloseAll)
                end)
            end)
            portalButton:SetScript("OnEnter", function()
                GameTooltip.SetSpellByID(scottyTooltip, portalId)
                menuActionButton:SetAttribute("spell", portalId)
                button.highlight:ClearAllPoints()
                button.highlight:SetPoint("TOPRIGHT")
                button.highlight:SetPoint("BOTTOM")
                button.highlight:SetPoint("LEFT", portalButton, "LEFT", -5, 0)
            end)
            portalButton:SetScript("OnLeave", function()
                GameTooltip.SetSpellByID(scottyTooltip, spellId)
                menuActionButton:SetAttribute("spell", spellId)
                button.highlight:ClearAllPoints()
                button.highlight:SetPoint("TOPLEFT")
                button.highlight:SetPoint("BOTTOM")
                button.highlight:SetPoint("RIGHT", portalButton, "LEFT", 0, 0)
            end)
        end)
        element:HookOnEnter(function(parent)
            if parent.PortalButton and parent.PortalButton:IsMouseOver() then
                GameTooltip.SetSpellByID(scottyTooltip, portalId)
                menuActionButton:SetAttribute("spell", portalId)
                parent.highlight:ClearAllPoints()
                parent.highlight:SetPoint("TOPRIGHT")
                parent.highlight:SetPoint("BOTTOM")
                parent.highlight:SetPoint("LEFT", parent.PortalButton, "LEFT", -5, 0)
            else
                parent.highlight:ClearAllPoints()
                parent.highlight:SetPoint("TOPLEFT")
                parent.highlight:SetPoint("BOTTOM")
                parent.highlight:SetPoint("RIGHT", parent.PortalButton, "LEFT", 0, 0)
            end
        end)
        element:AddResetter(function(parent)
            parent.highlight:ClearAllPoints()

            local portal = parent.PortalButton
            portal:ClearAllPoints()
            portal:SetSize(0,0)
            portal:SetText("")
            portal:SetAlpha(1.0)
            portal:SetScript("OnClick", nil)
            portal:SetScript("OnEnter", nil)
            portal:SetScript("OnLeave", nil)
            parent.PortalButton = nil

            local portalIcon = parent.PortalIcon
            portalIcon:ClearAllPoints()
            portalIcon:SetSize(0, 0)
            portalIcon:SetTexture()
            parent.PortalIcon = nil
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
        local houseName = row.houseName
        if row.ownerName then
            houseName = row.ownerName .. ": " .. houseName
        end
        local button = buildEntry(menuRoot, "visithouse", 0, GetHousingIcon(row.neighborhoodGUID), houseName, nil, nil, row)
        button:HookOnEnter(function()
            menuActionButton:SetAttribute("house-neighborhood-guid", row.neighborhoodGUID)
            menuActionButton:SetAttribute("house-guid", row.houseGUID)
            menuActionButton:SetAttribute("house-plot-id", row.plotID)
        end)
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
    root:SetTag(MENU_TAG)
    root:SetScrollMode(GetScreenHeight() - 100)

    local hasGeneralSpells = false
    local playerHouseInfos, friendsHouseInfos, guildHousesInfos = ADDON.GetHouseInfos and ADDON.GetHouseInfos() or {}

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
                button.PortalButton:SetText(" "..ADDON.L.MENU_VULPERA_CAMP.."       ")
                button.PortalButton:SetSize(button.PortalButton:GetTextWidth(), button.fontString:GetHeight())
            end)
            hasGeneralSpells = true
        end
    end

    -- Haranir Root Walking
    do
        -- Return
        if C_SpellBook.IsSpellInSpellBook(1238695) then
            buildSpellEntry(root, 1238686, ScottyPersonalCache.RootWalking or C_Spell.GetSpellName(1238695))
            hasGeneralSpells = true
        else
            local rootSpells = tFilter({1260722, 1260806, 1261018, 1261022}, function(id) return C_SpellBook.IsSpellInSpellBook(id) end, true)
            if #rootSpells > 0 then
                buildSpellEntry(root, 1238686, C_Spell.GetSpellName(rootSpells[1]))
                hasGeneralSpells = true
            end
        end
    end

    do
        -- Player Houses
        -- HousingDashboardFrame.HouseInfoContent.ContentFrame.HouseUpgradeFrame.TeleportToHouseButton
        for _, playerHouse in ipairs(playerHouseInfos) do
            if C_HousingNeighborhood.CanReturnAfterVisitingHouse() and C_Housing.GetCurrentNeighborhoodGUID() == playerHouse.neighborhoodGUID then
                local location = ScottyPersonalCache.PlayerHomeReturn or HOUSING_DASHBOARD_RETURN
                buildEntry(root, "returnhome", 0, "dashboard-panel-homestone-teleport-out-button", location, function(tooltip)
                    GameTooltip_AddHighlightLine(tooltip, HOUSING_DASHBOARD_RETURN);
                end)
            else
                local houseCooldown = false
                local houseTpCd = C_Housing.GetVisitCooldownInfo()
                if houseTpCd.startTime > 0 then
                    houseCooldown = houseTpCd.startTime + houseTpCd.duration
                end

                local button = buildEntry(root, "teleporthome", 0, GetHousingIcon(playerHouse.neighborhoodGUID), playerHouse.houseName, function(tooltip)
        			GameTooltip_AddHighlightLine(tooltip, HOUSING_DASHBOARD_TELEPORT_TO_PLOT);
                end, houseCooldown)
                button:HookOnEnter(function()
                    menuActionButton:SetAttribute("house-neighborhood-guid", playerHouse.neighborhoodGUID)
                    menuActionButton:SetAttribute("house-guid", playerHouse.houseGUID)
                    menuActionButton:SetAttribute("house-plot-id", playerHouse.plotID)
                end)
            end
            --later: add maybe tooltips
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
                favoriteRoot:SetScrollMode(GetScreenHeight() - 100)
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
                seasonRoot:SetScrollMode(GetScreenHeight() - 100)
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
    if Settings.GetValue(ADDON_NAME.."_SHOW_FRIENDS_HOUSES") and friendsHouseInfos and TableHasAnyEntries(friendsHouseInfos) then
        local friendsRoot = root:CreateButton("|T"..GetBnetIcon()..":0|t "..ADDON.L.HOUSE_FRIENDS)
        friendsRoot:SetScrollMode(GetScreenHeight() - 100)
        local friendsHouses = GetValuesArray(friendsHouseInfos)
        -- AccountNames are protected Strings. so we can't use them for sorting.
        table.sort(friendsHouses, function(a, b)
            return strcmputf8i(a.battleTag, b.battleTag) < 0
        end)
        for _, houseInfo in ipairs(friendsHouses) do
            local button = buildEntry(friendsRoot, "visithouse", 0, GetHousingIcon(houseInfo.neighborhoodGUID), houseInfo.accountName .. ": " .. houseInfo.houseName, nil, nil, houseInfo)
            button:HookOnEnter(function()
                menuActionButton:SetAttribute("house-neighborhood-guid", houseInfo.neighborhoodGUID)
                menuActionButton:SetAttribute("house-guid", houseInfo.houseGUID)
                menuActionButton:SetAttribute("house-plot-id", houseInfo.plotID)
            end)
        end
        if not Settings.GetValue(ADDON_NAME.."_SHOW_GUILD_HOUSES") or not TableHasAnyEntries(guildHousesInfos) then
            root:QueueSpacer()
        end
    end
    -- guild member houses
    if Settings.GetValue(ADDON_NAME.."_SHOW_GUILD_HOUSES") and guildHousesInfos and TableHasAnyEntries(guildHousesInfos) then
        local guildRoot = root:CreateButton("|T135026:0|t "..ADDON.L.HOUSE_GUILDMEMBERS)
        guildRoot:SetScrollMode(GetScreenHeight() - 100)
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
            if GetExpansionLevel() == LE_EXPANSION_MIDNIGHT then
                -- push eastern kingdoms to the top
                table.sort(continents, function(a, b)
                    if a == 0 then return true end
                    if b == 0 then return false end
                    return a > b
                end)
            else
                table.sort(continents, function(a, b) return a > b end)
            end
            for _, continent in ipairs(continents) do
                local list = SortRowsByName(groupedByContinent[continent])
                local continentRoot = root:CreateButton(GetRealZoneText(continent))
                continentRoot:SetScrollMode(GetScreenHeight() - 100)
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

ADDON.Events:RegisterCallback("OnLogin", function()
    -- Make sure Icon is loaded
    GetBnetIcon()
end, "cache-icons")

-- close open menu when entering combat
ADDON.Events:RegisterFrameEventAndCallback("PLAYER_REGEN_DISABLED", function()
    local openTags = Menu.GetOpenMenuTags()
    if tContains(openTags, MENU_TAG) then
        Menu:GetManager():CloseMenus()
    end
end, "close-open-menu")