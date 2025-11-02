local _, ADDON = ...

-- Later as Library?
-- Later: Reset Button

local DropdownWithLabelMixin = {}
function DropdownWithLabelMixin:SetEnabled(enabled)
    self.Dropdown:SetEnabled(enabled)
end
ScottySetting_DropdownWithLabelMixin = CreateFromMixins(DropdownWithLabelMixin)

local DropdownControlMixin = {}
function DropdownControlMixin:SetupDropdownMenu(dropdown, setting, options, initTooltip)
    local function IsSelected(optionData)
        return tContains(setting:GetValue(), optionData.value)
    end

    local function OnSelect(optionData)
        local list = setting:GetValue()
        if tContains(list, optionData.value) then
            tDeleteItem(list, optionData.value)
        else
            table.insert(list, optionData.value)
        end

        setting:SetValue(list)

        return MenuResponse.Refresh
    end

    local function inserter(rootDescription)
        for _, optionData in ipairs(options()) do
            rootDescription:CreateCheckbox(optionData.text.." ", IsSelected, OnSelect, optionData)
        end
    end

    Settings.InitDropdown(dropdown, setting, inserter, initTooltip)

    -- align dropdown field
    local point, relativeTo, relativePoint, _, offsetY = dropdown:GetParent():GetPoint(1)
    dropdown:GetParent():SetPoint(point, relativeTo, relativePoint, -78, offsetY)

    if setting.modifyDropdownCallback then
        local callback = setting.modifyDropdownCallback
        callback(dropdown)
    end
end
ScottySetting_DropdownControlMixin = CreateFromMixins(DropdownControlMixin)

function ADDON:CreateMultiSelectDropdownButton(layout, setting, optionCallback, tooltipText, modifyDropdownCallback)
    setting.modifyDropdownCallback = modifyDropdownCallback

    local initializer = Settings.CreateControlInitializer("ScottySetting_MultiSelectTemplate", setting, optionCallback, tooltipText)
    layout:AddInitializer(initializer)
end