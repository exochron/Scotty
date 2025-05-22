local ADDON_NAME, ADDON = ...

local ASTRAL_RECALL = 556

local hearthstoneButton

local function loadHearthStoneItemIds()
    local stones = tFilter(ADDON.db, function(row)
        return row.category == ADDON.Category.Hearthstone and row.toy and PlayerHasToy(row.toy)
    end, true)
    stones = TableUtil.Transform(stones, function(row) return row.toy end)
    return stones
end
local function buildHearthstoneButton()
    local button = CreateFrame("Button", ADDON_NAME.."HearthstoneButton", nil, "SecureActionButtonTemplate")

    local function GetRandomHearthstoneToy()
        local stones = loadHearthStoneItemIds()

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

        if (not toy or C_Container.GetItemCooldown(toy)>0) and IsSpellKnown(ASTRAL_RECALL) and C_Spell.IsSpellUsable(ASTRAL_RECALL) then
            local spellOnCoolDown = false
            if C_Spell.GetSpellCooldown then -- Retail
                local spellCooldown = C_Spell.GetSpellCooldown(ASTRAL_RECALL)
                spellOnCoolDown = spellCooldown.startTime > 0
            elseif GetSpellCooldown then -- Classics
                spellOnCoolDown = GetSpellCooldown(ASTRAL_RECALL) > 0
            end
            if not spellOnCoolDown then
                self:SetAttribute("type", "spell")
                self:SetAttribute("typerelease", "spell")
                self:SetAttribute("spell", ASTRAL_RECALL)
                self:SetAttribute("item", nil)
                self:SetAttribute("itemid", nil)
                self:SetAttribute("toy", nil)
                return
            end
        end
        if toy then
            self:SetAttribute("type", "toy")
            self:SetAttribute("typerelease", "toy")
            self:SetAttribute("toy", toy)
            self:SetAttribute("item", nil)
            self:SetAttribute("itemid", nil)
            self:SetAttribute("spell", nil)
            return
        end

        local item = C_Container.PlayerHasHearthstone and C_Container.PlayerHasHearthstone()
                or ADDON:FindItemInBags(HEARTHSTONE_ITEM_ID) and HEARTHSTONE_ITEM_ID
        if item then
            self:SetAttribute("type", "item")
            self:SetAttribute("typerelease", "item")
            self:SetAttribute("item", ADDON:FindItemInBags(item))
            self:SetAttribute("itemid", item)
            self:SetAttribute("toy", nil)
            self:SetAttribute("spell", nil)
        end
    end

    button:SetAttribute("pressAndHoldAction", 1)
    button:RegisterForClicks("LeftButtonUp")
    button:SetPropagateMouseMotion(true)
    button:SetFrameStrata("DIALOG")
    button:SetSize(1,1)
    button:SetPoint("RIGHT", -10, -10)
    button:RegisterForDrag("LeftButton")
    button:Show()

    -- forward dragging to parent since mouse click propagation doesn't work anymore
    button:SetScript("OnDragStart", function(self)
        if not InCombatLockdown() then
            --disable click handler
            button:SetAttribute("type", "")
            button:SetAttribute("typerelease", "")

            local parent = self:GetParent()
            local handler = parent:GetScript("OnDragStart")
            handler(parent)
        end
    end)
    button:SetScript("OnDragStop", function(self)
        if not InCombatLockdown() then
            local parent = self:GetParent()
            local handler = parent:GetScript("OnDragStop")
            handler(parent)

            -- reset attributes
            self:ShuffleHearthstone()
        end
    end)
    button:HookScript("OnMouseDown", function(_, mouseButton)
        if mouseButton == "RightButton" then
            ADDON:OpenSettings()
        end
    end)
    button:HookScript("PreClick", function()
        button:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
    end)
    button:HookScript("PostClick", function(self)
        if not InCombatLockdown() then
            self:ShuffleHearthstone()
        end
    end)
    button:HookScript("OnEvent", function(self, event, unitTarget, _, spellID)
        if event == "UNIT_SPELLCAST_SUCCEEDED" and unitTarget == "player" then
            self:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED")

            local isHearthstoneSpell = spellID == ASTRAL_RECALL
            if not isHearthstoneSpell then
                local stones = loadHearthStoneItemIds()
                for _, itemId in ipairs(stones) do
                    local _, itemSpell = C_Item.GetItemSpell(itemId)
                    if itemSpell == spellID then
                        isHearthstoneSpell = true
                        break
                    end
                end
            end

            if isHearthstoneSpell then
                C_Timer.After(0.1, function()
                    if not InCombatLockdown() then
                        self:ShuffleHearthstone()
                    end
                end)
            end

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

    local attachHSButtonToFrame = function(frame)
        if frame then
            hearthstoneButton:SetParent(frame)
            hearthstoneButton:SetAllPoints(frame)
        end
    end

    local menu
    local ldbDataObject = ldb:NewDataObject( ADDON_NAME, {
        type = "data source",
        text = GetBindLocation(),
        label = ADDON_NAME,
        icon = "Interface\Addons\Scotty\icon.png",

        OnEnter = function(frame)
            if not InCombatLockdown() then
                attachHSButtonToFrame(frame)
                menu = ADDON:OpenTeleportMenu(frame)
            end
        end,
        OnLeave = function()
            if menu and not menu:IsMouseOver() then
                menu:Close()
            end
        end,
    } )

    hearthstoneButton:HookScript("OnAttributeChanged", function(_, name, value)
        if value and (name == "toy" or name == "itemid") then
            ldbDataObject.label = C_Item.GetItemNameByID(value)
            ldbDataObject.icon = C_Item.GetItemIconByID(value)
        elseif value and name == "spell" then
            local info = C_Spell.GetSpellInfo(value)
            ldbDataObject.label = info.name
            ldbDataObject.icon = info.iconID
        end
    end)
    hearthstoneButton:ShuffleHearthstone()

    ADDON.Events:RegisterFrameEventAndCallback("HEARTHSTONE_BOUND", function()
        ldbDataObject.text = GetBindLocation()
    end, 'ldb-plugin')

    local icon = LibStub("LibDBIcon-1.0")
    if Settings.GetValue(ADDON_NAME.."_MINIMAP") then
        icon:Register(ADDON_NAME, ldbDataObject, ScottyGlobalSettings.minimap)
    end
    Settings.SetOnValueChangedCallback(ADDON_NAME.."_MINIMAP", function(_, _, value)
        ScottyGlobalSettings.minimap.hide = not value
        if icon:IsRegistered(ADDON_NAME) then
            icon:Refresh(ADDON_NAME, ScottyGlobalSettings.minimap)
        else
            icon:Register(ADDON_NAME, ldbDataObject, ScottyGlobalSettings.minimap)
        end
    end, ADDON_NAME.."-ldb")

    -- initially attach to possible best matched frame.
    -- only the target frame can use the hearthstone button, when directly entering combat.
    attachHSButtonToFrame(BazookaPlugin_Scotty or LibDBIcon10_Scotty)

end, "ldb-plugin")