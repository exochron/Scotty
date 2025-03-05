local ADDON_NAME, ADDON = ...

local hearthstoneButton
local function buildHearthstoneButton()
    local button = CreateFrame("Button", ADDON_NAME.."HearthstoneButton", nil, "SecureActionButtonTemplate")

    local function GetRandomHearthstoneToy()
        local stones = tFilter(ADDON.db, function(row)
            return row.category == ADDON.Category.Hearthstone and row.toy and PlayerHasToy(row.toy)
        end, true)
        stones = TableUtil.Transform(stones, function(row) return row.toy end)

        local preferedToys = Settings.GetValue(ADDON_NAME.."_HEARTHSTONES")
        if #preferedToys > 0 then
            preferedToys = CopyValuesAsKeys(preferedToys)
            stones = tFilter(stones, function(toyId)
                return preferedToys[toyId]
            end, true)
        end

        -- avoid last used hearthstone
        if #stones > 1 and button:GetAttribute("toy") then
            local skipToy = button:GetAttribute("toy")
            stones = tFilter(stones, function(v) return v ~= skipToy end, true)
        end

        if #stones > 0 then
            return GetRandomArrayEntry(stones)
        end

        return nil
    end
    button.ShuffleHearthstone = function(self)
        local toy = GetRandomHearthstoneToy()
        if toy then
            self:SetAttribute("type", "toy")
            self:SetAttribute("typerelease", "toy")
            self:SetAttribute("toy", toy)
            self:SetAttribute("item", nil)
            self:SetAttribute("itemID", nil)
            self:SetAttribute("spell", nil)
            return
        end

        local AstralRecall = 556
        if IsSpellKnown(AstralRecall) and C_Spell.IsSpellUsable(AstralRecall) then
            self:SetAttribute("type", "spell")
            self:SetAttribute("typerelease", "spell")
            self:SetAttribute("spell", AstralRecall)
            self:SetAttribute("item", nil)
            self:SetAttribute("itemID", nil)
            self:SetAttribute("toy", nil)
        end

        local item = C_Container.PlayerHasHearthstone and C_Container.PlayerHasHearthstone()
                or ADDON:FindItemInBags(HEARTHSTONE_ITEM_ID) and HEARTHSTONE_ITEM_ID
        if item then
            self:SetAttribute("type", "item")
            self:SetAttribute("typerelease", "item")
            self:SetAttribute("item", ADDON:FindItemInBags(item))
            self:SetAttribute("itemID", item)
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
        if not InCombatLockdown() and button:GetParent() and button:GetParent():IsDragging() then
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
    local ldb = LibStub("LibDataBroker-1.1")

    hearthstoneButton = buildHearthstoneButton()
    Settings.SetOnValueChangedCallback(ADDON_NAME.."_HEARTHSTONES", function()
        hearthstoneButton:ShuffleHearthstone()
    end, ADDON_NAME.."-ldb")

    local menu
    local hearthstoneItem = hearthstoneButton:GetAttribute("toy") or hearthstoneButton:GetAttribute("itemID")
    local ldbDataObject = ldb:NewDataObject( ADDON_NAME, {
        type = "data source",
        text = GetBindLocation(),
        label = C_Item.GetItemNameByID(hearthstoneItem),
        icon = C_Item.GetItemIconByID(hearthstoneItem),

        OnEnter = function(frame)
            if not InCombatLockdown() then
                hearthstoneButton:SetParent(frame)
                hearthstoneButton:SetAllPoints(frame)

                menu = ADDON:OpenTeleportMenu(frame)
            end
        end,
        OnLeave = function()
            if menu and not menu:IsMouseOver() then
                menu:Close()
            end
        end,

        OnClick = function(_, mouseButton)
            if mouseButton == "RightButton" then
                ADDON:OpenSettings()
            end
        end,
    } )

    hearthstoneButton:HookScript("OnAttributeChanged", function(_, name, value)
        if value and (name == "toy" or name == "itemID") then
            ldbDataObject.label = C_Item.GetItemNameByID(value)
            ldbDataObject.icon = C_Item.GetItemIconByID(value)
        end
    end)

    ADDON.Events:RegisterFrameEventAndCallback("HEARTHSTONE_BOUND", function()
        ldbDataObject.text = GetBindLocation()
    end, 'ldb-plugin')

    local icon = LibStub("LibDBIcon-1.0")
    icon:Register(ADDON_NAME, ldbDataObject, ScottyGlobalSettings.minimap)
    Settings.SetOnValueChangedCallback(ADDON_NAME.."_MINIMAP", function(_, _, value)
        ScottyGlobalSettings.minimap.hide = not value
        icon:Refresh(ADDON_NAME, ScottyGlobalSettings.minimap)
    end, ADDON_NAME.."-ldb")

end, "ldb-plugin")