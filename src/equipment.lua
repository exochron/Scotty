local _, ADDON = ...

local equipQueue = {}
local equipTicker
local requestedItemEquip = {}
local previousEquipment = {}
local slotsToScan = {}

local function scanDBForEquipmentSlots()
    local slots = {}
    for _, row in ipairs(ADDON.db) do
        if row.isEquippableItem then
            local slot = ADDON:GetItemSlot(row.item)
            tInsertUnique(slots,slot)
        end
    end
    slotsToScan = slots
end
local function scanCurrentEquipment()
    local currentEquip = {}
    for _,slot in ipairs(slotsToScan) do
        currentEquip[slot] = GetInventoryItemID("player", slot)
    end
    previousEquipment = currentEquip
end
ADDON.Events:RegisterCallback("OnLogin", scanDBForEquipmentSlots, "equipment-slots")
ADDON.Events:RegisterCallback("OnOpenTeleportMenu", scanCurrentEquipment, "equipment")

local function equipItem(itemId)
    if not itemId then return end

    local itemSlot = ADDON:GetItemSlot(itemId)

    equipQueue[itemSlot] = itemId

    ADDON.Events:RegisterFrameEventAndCallback("PLAYER_EQUIPMENT_CHANGED", function(_, equipmentSlot, hasCurrent)
        if itemSlot == equipmentSlot and false == hasCurrent and C_Item.IsEquippedItem(itemId) then
            if requestedItemEquip[itemSlot] == itemId then
                requestedItemEquip[itemSlot] = nil
            end
            ADDON.Events:UnregisterCallback("PLAYER_EQUIPMENT_CHANGED",'equipitem-'..itemId)
        end
    end, 'equipitem-'..itemId)

    if not equipTicker or equipTicker:IsCancelled() then
        equipTicker = C_Timer.NewTicker(0.2, function()
            local requestedEquip = false

            for queuedSlot, queuedItemId in pairs(equipQueue) do
                if queuedItemId and (
                    requestedItemEquip[queuedSlot] ~= nil
                    or not C_Item.IsEquippedItem(queuedItemId)
                ) then
                    requestedEquip = true
                    requestedItemEquip[queuedSlot] = queuedItemId
                    C_Item.EquipItemByName(queuedItemId, queuedSlot)
                    break
                end
            end

            if not requestedEquip then
                equipTicker:Cancel()
            end
        end)
    end
    equipTicker:Invoke()
end

ADDON.Events:RegisterCallback("OnPrepareTeleport", function(_,_,_, dbRow)
    if dbRow and dbRow.isEquippableItem then
        equipItem(dbRow.item)
    end
end, "equipment")
ADDON.Events:RegisterCallback("OnClearTeleport", function(_,_,slotId, dbRow)
    if dbRow and dbRow.isEquippableItem then
        equipItem(previousEquipment[slotId])
    end
end, "equipment")

ADDON.Events:RegisterCallback("OnInitializeTeleport", function(_,_,slotId, dbRow)
    if dbRow and dbRow.isEquippableItem then
        local previousEquippedItem = previousEquipment[slotId]
        if previousEquippedItem and previousEquippedItem ~= dbRow.item then
            local successHandle, stopHandle, errorHandle
            local function reequipAfterTeleport(handlerName, unit)
                if handlerName == "reequip-on-error" or unit == "player" then
                    equipItem(previousEquippedItem)
                    successHandle:Unregister()
                    stopHandle:Unregister()
                    errorHandle:Unregister()
                end
            end
            successHandle = ADDON.Events:RegisterFrameEventAndCallbackWithHandle("UNIT_SPELLCAST_SUCCEEDED", reequipAfterTeleport, 'reequip-after-teleport')
            stopHandle = ADDON.Events:RegisterFrameEventAndCallbackWithHandle("UNIT_SPELLCAST_STOP", reequipAfterTeleport, 'reequip-after-teleport')
            errorHandle = ADDON.Events:RegisterFrameEventAndCallbackWithHandle("UI_ERROR_MESSAGE", reequipAfterTeleport, 'reequip-on-error')
        end
    end
end, "equipment")