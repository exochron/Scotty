local ADDON_NAME, ADDON = ...

ADDON.Events = CreateFromMixins(EventRegistry)
ADDON.Events:OnLoad()
ADDON.Events:SetUndefinedEventsAllowed(true)

ADDON.Events:RegisterFrameEventAndCallback("PLAYER_ENTERING_WORLD", function(_, isLogin, isReload)
    if isLogin or isReload then

        ADDON:InitDatabase()
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