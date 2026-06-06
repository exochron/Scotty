local _, ADDON = ...

-- Later as Library?
-- Later: Reset Button

ScottySetting_DropdownControlMixin = {}
function ScottySetting_DropdownControlMixin:SetupDropdownMenu(dropdown, setting, options, initTooltip)
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

    local function inserter(setting, rootDescription)
        for _, optionData in ipairs(options()) do
            Settings.CreateDropdownCheckbox(rootDescription, optionData, IsSelected, OnSelect)
        end
    end

    Settings.InitDropdown(dropdown, setting, inserter, initTooltip)
end

function ADDON:CreateMultiSelectDropdownButton(layout, setting, optionCallback, tooltipText)
    local initializer = Settings.CreateControlInitializer("ScottySetting_MultiSelectTemplate", setting, optionCallback, tooltipText)
    layout:AddInitializer(initializer)
    return initializer
end