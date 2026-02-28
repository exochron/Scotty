local ADDON_NAME, ADDON = ...

local RANDOM_ICON = 1669485 -- pvp_rune_random
SCOTTY_HEARTHSTONE_SLOT = "Hearthstone" -- default fallback tooltip name

ADDON.Events:RegisterCallback("OnLogin", function()
    local item = Item:CreateFromItemID(6948) -- Hearthstone
    item:ContinueOnItemLoad(function()
        SCOTTY_HEARTHSTONE_SLOT = item:GetItemName()
    end)
end, "load-hearthstone-name")

local function GetOutfitToys(outfitId)
    return outfitId and ScottyPersonalSettings.outfitHearthstones[outfitId] or {}
end

local function GetViewedOutfitToys()
    return GetOutfitToys(C_TransmogOutfitInfo.GetCurrentlyViewedOutfitID())
end
local function SetViewedOutfitToys(toys)
    local outfitId = C_TransmogOutfitInfo.GetCurrentlyViewedOutfitID()
    ScottyPersonalSettings.outfitHearthstones[outfitId] = toys
end

function ADDON:GetMogOutfitHearthstones()
    return GetOutfitToys(C_TransmogOutfitInfo and C_TransmogOutfitInfo.GetActiveOutfitID() or nil)
end

local transmogLocation, mogFrame
local function InitLocationData()
    local locationData = {
        slot = Enum.TransmogOutfitSlot.WeaponRanged,
        slotID = nil,
        transmogType = Enum.TransmogType.Appearance,
        isSecondary = false
    };
    local location = CreateFromMixins(TransmogLocationMixin)
    location:Set(locationData)
    location.GetSlotName = function()
        return "SCOTTY_HEARTHSTONE_SLOT"
    end
    location.IsAppearance = function()
        return false
    end

    return location
end

local function BuildMoggFrame()
    local frame = CreateFrame("Frame", nil, TransmogFrame.WardrobeCollection.TabContent)
    --TransmogFrame.WardrobeCollection.TabContent.ScottyToySelection = frame
    frame:SetAllPoints(TransmogFrame.WardrobeCollection.TabContent)
    frame.ActiveSlotTitle = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightHuge")
    frame.ActiveSlotTitle:SetPoint("TOPLEFT", frame, "TOPLEFT", 23, -58)
    frame.ActiveSlotTitle:SetText(SCOTTY_HEARTHSTONE_SLOT)
    frame.Divider = frame:CreateTexture(nil, "OVERLAY")
    frame.Divider:SetAtlas("transmog-tabs-header-line", true)
    frame.Divider:SetAlpha(0.1)
    frame.Divider:SetPoint("TOPLEFT", frame.ActiveSlotTitle, "BOTTOMLEFT", 0, -2)

    frame.ToyList = CreateFrame("Frame", nil, frame, "VerticalLayoutFrame")
    frame.ToyList.spacing = 10
    frame.ToyList:SetPoint("TOPLEFT", frame.ActiveSlotTitle, "BOTTOMLEFT", 16, -21)

    frame.IgnoreButton = CreateFrame("Button", nil, frame.ToyList, "DisplayTypeButtonTemplate")
    frame.IgnoreButton.layoutIndex = 0
    frame.IgnoreButton:SetText(ADDON.L.MOG_SLOT_DEFAULT)
    frame.IgnoreButton.IconFrame.Icon:SetTexture(RANDOM_ICON)
    frame.IgnoreButton:SetScript("OnClick", function()
        PlaySound(SOUNDKIT.UI_TRANSMOG_ITEM_CLICK)
        SetViewedOutfitToys(nil)
        frame:RefreshButtons()
    end)

    frame.HorizontalRowFramePool = CreateFramePool("Frame", frame.ToyList, "HorizontalLayoutFrame", Pool_HideAndClearAnchors)
    frame.ToyButtonPool = CreateFramePool("Button", frame.ToyList, "DisplayTypeButtonTemplate", Pool_HideAndClearAnchors)

    frame.RefreshList = function(self)
        self.HorizontalRowFramePool:ReleaseAll()
        self.ToyButtonPool:ReleaseAll()

        local stones = tFilter(ADDON.db, function(row)
            return row.category == ADDON.Category.Hearthstone and row.toy and PlayerHasToy(row.toy)
        end, true)
        local layoutIndex = 0
        local currentRow
        for i, dbRow in ipairs(stones) do
            if i%3 == 1 then
                currentRow = self.HorizontalRowFramePool:Acquire()
                layoutIndex = layoutIndex + 1
                currentRow.layoutIndex = layoutIndex
                currentRow.spacing = 15
                currentRow:Show()
            end

            local button = self.ToyButtonPool:Acquire()
            button:SetParent(currentRow)
            button.layoutIndex = i%3
            button.itemId = dbRow.toy

            button:SetScript("OnClick", function()
                PlaySound(SOUNDKIT.UI_TRANSMOG_ITEM_CLICK)
                SetViewedOutfitToys({dbRow.toy})
                frame:RefreshButtons()
            end)

            local item = Item:CreateFromItemID(dbRow.toy)
            item:ContinueOnItemLoad(function()
                button:SetText(item:GetItemName())
                button.IconFrame.Icon:SetTexture(item:GetItemIcon())
            end)

            button:Show()
        end

        self.ToyList:Layout()
    end

    frame.RefreshButtons = function(self)
        local mogToys = GetViewedOutfitToys()
        local mogToy = #mogToys == 1 and mogToys[1] or nil

        self.IgnoreButton.StateTexture:SetShown(mogToy == nil)
        for slotFrame in self.ToyButtonPool:EnumerateActive() do
            slotFrame.StateTexture:SetShown(slotFrame.itemId == mogToy)
        end

        _G[ADDON_NAME.."HearthstoneButton"]:ShuffleHearthstone()
        TransmogFrame.CharacterPreview:RefreshSlots()
    end

    -- called from click on slotbutton
    frame.SelectSlot = function(_, slotFrame, forceRefresh)
        TransmogFrame.CharacterPreview:UpdateSlot(slotFrame.slotData, forceRefresh)

        TransmogFrame.WardrobeCollection:SetToItemsTab()
        TransmogFrame.WardrobeCollection.TabContent.ItemsFrame:Hide()
        frame:RefreshList()
        frame:RefreshButtons()
        frame:Show()
    end
    frame:Hide()

    hooksecurefunc(TransmogFrame, "SelectSlot", function()
        local wc = TransmogFrame.WardrobeCollection
        if TabSystemOwnerMixin.GetTab(wc) == wc.itemsTabID then
            wc.TabContent.ItemsFrame:Show()
        end
        frame:Hide()
    end)
    hooksecurefunc(TabSystemOwnerMixin, "SetTab", function(_, tabID)
        local data = TransmogFrame.CharacterPreview:GetSelectedSlotData()
        if tabID == TransmogFrame.WardrobeCollection.itemsTabID and data and data.IsScottyHearthstoneSlot then
            TransmogFrame.WardrobeCollection.TabContent.ItemsFrame:Hide()
            frame:Show()
        else
            frame:Hide()
        end
    end)

    return frame
end

local function addSlot()
    local charPreview = TransmogFrame.CharacterPreview

    local slotData = {
        transmogLocation = transmogLocation,
        transmogFrame = mogFrame,
        currentWeaponOptionInfo = nil,
        texture = nil,
        canTransmogrify = true,
        IsScottyHearthstoneSlot = true
    };

    local slotFrame = charPreview.CharacterAppearanceSlotFramePool:Acquire();
    slotFrame.IsScottyHearthstoneSlot = true
    slotFrame:Init(slotData);
    slotFrame:SetParent(charPreview)
    slotFrame:SetFrameLevel(5)
    slotFrame:Show()

    slotFrame:SetPoint("TOP", charPreview.BottomSlots, "TOP")
    slotFrame:SetPoint("LEFT", charPreview.RightSlots, "LEFT")

    slotFrame.GetSlotInfo = function()
        local mogToys = GetViewedOutfitToys()
        local mogToy = #mogToys == 1 and mogToys[1] or nil

        return {
            transmogID = 0,
            displayType = mogToy and Enum.TransmogOutfitDisplayType.Assigned or Enum.TransmogOutfitDisplayType.Unassigned,
            isTransmogrified = true,
            hasPending = false,
            isPendingCollected = true,
            canTransmogrify = true,
            warning = Enum.TransmogOutfitSlotWarning.Ok,
            warningText = "",
            error = Enum.TransmogOutfitSlotError.Ok,
            errorText = "",
            texture = mogToy and C_Item.GetItemIconByID(mogToy) or RANDOM_ICON,
        }
    end

    slotFrame:SetScript("OnEnter", function(self)
        local mogToys = GetViewedOutfitToys()
        local mogToy = #mogToys == 1 and mogToys[1] or nil
        if mogToy then
            local item = Item:CreateFromItemID(mogToy)
            self.itemDataLoadedCancelFunc = item:ContinueWithCancelOnItemLoad(function()
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip_AddColoredLine(GameTooltip, item:GetItemName(), item:GetItemQualityColor().color)
                GameTooltip:Show();
            end)
        else
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(ADDON.L.MOG_SLOT_DEFAULT)
            GameTooltip:Show();
        end
    end)
end

local function cleanupSlotFrame(slotFrame)
    slotFrame.IsScottyHearthstoneSlot = nil
    slotFrame.GetSlotInfo = TransmogSlotMixin.GetSlotInfo
    slotFrame:SetScript("OnEnter", TransmogSlotMixin.OnEnter)
end

local init = true
ADDON.Events:RegisterFrameEventAndCallback("ADDON_LOADED", function()
    if TransmogFrame and init then
        init = false
        transmogLocation = InitLocationData()
        mogFrame = BuildMoggFrame()

        hooksecurefunc(TransmogFrame.CharacterPreview, "SetupSlots", addSlot)
        hooksecurefunc(TransmogSlotMixin, "Release", function(self)
            if self.IsScottyHearthstoneSlot then
                cleanupSlotFrame(self)
            end
        end)
    end
end, "mog-hearthstone")
-- triggered when active outfit changed
ADDON.Events:RegisterFrameEventAndCallback("TRANSMOG_DISPLAYED_OUTFIT_CHANGED", function()
    _G[ADDON_NAME.."HearthstoneButton"]:ShuffleHearthstone()
end, "shuffle-mog-hearthstone")