local ADDON_NAME, ADDON = ...

ADDON.Events = CreateFromMixins(EventRegistry)
ADDON.Events:OnLoad()
ADDON.Events:SetUndefinedEventsAllowed(true)

-- the actual function C_Item.DoesItemExistByID() is misleading and only checks for non empty parameter.
-- see: https://github.com/Stanzilla/WoWUIBugs/issues/449#issuecomment-2638266396
function ADDON.DoesItemExistInGame(itemId)
    return C_Item.GetItemIconByID(itemId) ~= 134400 -- question icon
end

-- Item data is cached by the client. you need to request it beforehand. however, the client cache can also be unloaded.
-- https://github.com/exochron/Scotty/issues/25#issuecomment-3341952850
local cachedItemData = {}

function ADDON.GetItemName(itemId)
    return cachedItemData[itemId] and cachedItemData[itemId].name
end
function ADDON.IsEquippableItem(itemId)
    return cachedItemData[itemId] and cachedItemData[itemId].equip
end

local function cacheItems(onDone)
    -- some item function (C_Item.IsEquippableItem()) might not properly work, when data is not cached.

    local inLoop, requestedCount = true, 0
    for _, row in ipairs(ADDON.db) do
        local itemId = row.item or row.toy
        if itemId and ADDON.DoesItemExistInGame(itemId) then
            local item = Item:CreateFromItemID(itemId)
            requestedCount = requestedCount + 1
            item:ContinueOnItemLoad(function()
                cachedItemData[itemId] = {name=item:GetItemName(), equip=C_Item.IsEquippableItem(itemId)}
                requestedCount = requestedCount - 1
                if not inLoop and requestedCount==0 then
                    onDone()
                end
            end)
        end
    end
    if requestedCount==0 then
        onDone()
    else
        inLoop = false
    end
end

ADDON.Events:RegisterFrameEventAndCallback("PLAYER_ENTERING_WORLD", function(_, isLogin, isReload)
    if isLogin or isReload then

        ADDON:InitDatabase()
        cacheItems(function()
            ADDON.Events:TriggerEvent("OnInit")
            ADDON.Events:TriggerEvent("OnLogin")
            ADDON.Events:UnregisterEvents({"OnInit", "OnLogin"})
            ADDON.Events:UnregisterFrameEvent("PLAYER_ENTERING_WORLD")

            if AddonCompartmentFrame then
                AddonCompartmentFrame:RegisterAddon({
                    text = C_AddOns.GetAddOnMetadata(ADDON_NAME, "Title"),
                    icon = C_AddOns.GetAddOnMetadata(ADDON_NAME, "IconTexture"),
                    notCheckable = true,
                    func = ADDON.OpenSettings
                })
            end
        end)
    end
end, "init")

function ADDON:GetItemSlot(itemId)
    local invTypeId = C_Item.GetItemInventoryTypeByID(itemId)
    -- from https://warcraft.wiki.gg/wiki/Enum.InventoryType
    if invTypeId < 12 then
        return invTypeId
    end
    if invTypeId == 20 then return  5 end
    if invTypeId == 12 then return 13 end
    if invTypeId == 16 then return 15 end
    if invTypeId == 13 or invTypeId == 15 or invTypeId == 17 or invTypeId == 21 or invTypeId == 22 or invTypeId == 25 or invTypeId == 26 then
        return 16
    end
    if invTypeId == 14 or invTypeId == 23 then
        return 17
    end
    if invTypeId == 19 then return 19 end
end

function ADDON:FindItemInBags(itemId)
    for bagID = 0, NUM_BAG_SLOTS do
        local numSlots = C_Container.GetContainerNumSlots(bagID)
        for slotID = 1, numSlots do
            if C_Container.GetContainerItemID(bagID, slotID) == itemId then
                return bagID.." "..slotID
            end
        end
    end
    return nil
end
function ADDON:PlayerHasItemInBag(itemId)
    return ADDON:FindItemInBags(itemId) ~= nil
end

-- detect Vulperas Make Camp location
ADDON.Events:RegisterCallback("OnLogin", function(self)
    if IsSpellKnown(312372) then
        ADDON.Events:RegisterFrameEventAndCallback("UNIT_SPELLCAST_SUCCEEDED", function(_, _, _, spellId)
            if spellId == 312370 then
                ScottyPersonalSettings = ScottyPersonalSettings or {}
                ScottyPersonalSettings.VulperaCamp = GetZoneText()
            end
        end, self)
    end
end, "vulpera-camp")