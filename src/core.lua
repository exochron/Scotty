local ADDON_NAME, ADDON = ...

ScottyAccountCache = ScottyAccountCache or {}
ScottyPersonalCache = ScottyPersonalCache or {}

ADDON.Events = CreateFromMixins(EventRegistry)
ADDON.Events:OnLoad()
ADDON.Events:SetUndefinedEventsAllowed(true)
-- Polyfill for split Unregister behaviour in 12.0
-- Later: remove after classic has it
if not ADDON.Events.UnregisterEventsByEventTable then
    ADDON.Events.UnregisterEventsByEventTable = ADDON.Events.UnregisterEvents
end

local issecretvalue = issecretvalue or function() return false end

ADDON.Events:RegisterFrameEventAndCallback("PLAYER_ENTERING_WORLD", function(_, isLogin, isReload)
    if isLogin or isReload then

        ADDON:InitDatabase()
        ADDON.Events:TriggerEvent("OnInit")
        ADDON.Events:TriggerEvent("OnLogin")
        ADDON.Events:UnregisterEventsByEventTable({"OnInit", "OnLogin"})
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
    local maxBags = NUM_BAG_SLOTS
    if LE_EXPANSION_LEVEL_CURRENT >= LE_EXPANSION_DRAGONFLIGHT then
        maxBags = maxBags+1 -- include reagent bag
    end

    for containerID = 0, maxBags do
        local numSlots = C_Container.GetContainerNumSlots(containerID)
        for slotID = 1, numSlots do
            if C_Container.GetContainerItemID(containerID, slotID) == itemId then
                return containerID.." "..slotID
            end
        end
    end
    return nil
end
function ADDON:PlayerHasItemInBag(itemId)
    return ADDON:FindItemInBags(itemId) ~= nil
end

function ADDON:GetName(row)
    local name = ""

    if row.name then
        name = row.name
    elseif row.ownerName then
        name = row.ownerName
    elseif row.instance then
        name = GetRealZoneText(row.instance)
    elseif row.map then
        local info = C_Map.GetMapInfo(row.map)
        if info and info.name then
            name = info.name
        end
    end

    if name ~= "" and row.nameSuffix then
        name = name.." "..row.nameSuffix
    end

    return name
end

function ADDON:BuildCooldownString(cooldownEndTime, asSuffix)
    local cdTime = cooldownEndTime - GetTime()
    local value = ""
    if cdTime > 3600 then
        value = string.format("%.1fh", cdTime / 3600)
    elseif cdTime > 60 then
        value = string.format("%dm", cdTime / 60)
    elseif cdTime > 0 then
        value = string.format("%ds", cdTime)
    end
    if value ~= "" and asSuffix then
        return " ["..value.."]"
    end

    return value
end

function ADDON:IsGCD()
    local spellCooldownInfo = C_Spell.GetSpellCooldown(61304)
    if spellCooldownInfo and not issecretvalue(spellCooldownInfo.duration) and spellCooldownInfo.duration > 0 then
        return true
    end
    return false
end