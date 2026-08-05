DynamicMarketStockLocationDialog = {}
local DynamicMarketStockLocationDialog_mt = Class(DynamicMarketStockLocationDialog, MessageDialog)

local function dmSetButtonDisabled(element, disabled)
    if element == nil then
        return
    end
    element.disabled = disabled
    if element.setDisabled ~= nil then
        element:setDisabled(disabled)
    end
end

function DynamicMarketStockLocationDialog.new(target, customMt)
    local self = MessageDialog.new(target, customMt or DynamicMarketStockLocationDialog_mt)
    self.i18n = g_i18n
    self.currentLocations = {}
    return self
end

function DynamicMarketStockLocationDialog:onCreate()
    DynamicMarketStockLocationDialog:superClass().onCreate(self)
end

function DynamicMarketStockLocationDialog:onGuiSetupFinished()
    DynamicMarketStockLocationDialog:superClass().onGuiSetupFinished(self)
    if self.dynamicMarketStockLocationTable ~= nil then
        self.dynamicMarketStockLocationTable:setDataSource(self)
        self.dynamicMarketStockLocationTable:setDelegate(self)
    end
end

function DynamicMarketStockLocationDialog:onOpen()
    DynamicMarketStockLocationDialog:superClass().onOpen(self)
    if self.dynamicMarketStockLocationTable ~= nil then
        FocusManager:setFocus(self.dynamicMarketStockLocationTable)
    end
end

function DynamicMarketStockLocationDialog:setStockData(title, locations)
    if self.dialogTitleElement ~= nil then
        self.dialogTitleElement:setText(tostring(title or ""))
    end

    self.currentLocations = {}
    if type(locations) == "table" then
        for _, entry in ipairs(locations) do
            table.insert(self.currentLocations, entry)
        end
    end

    self.mapHotspot = nil
    dmSetButtonDisabled(self.dialogButtonTag, true)

    if self.dynamicMarketStockLocationTable ~= nil then
        self.dynamicMarketStockLocationTable:reloadData()
    end
end

function DynamicMarketStockLocationDialog:getNumberOfSections()
    return 1
end

function DynamicMarketStockLocationDialog:getNumberOfItemsInSection(list, section)
    return #self.currentLocations
end

function DynamicMarketStockLocationDialog:populateCellForItemInSection(list, section, index, cell)
    local entry = self.currentLocations[index]
    if entry == nil then
        return
    end
    local nameCell = cell:getAttribute("name")
    if nameCell ~= nil then
        nameCell:setText(tostring(entry.name or "?"))
    end
    local amountCell = cell:getAttribute("amount")
    if amountCell ~= nil then
        local liters = tonumber(entry.amount) or 0
        if self.i18n ~= nil and self.i18n.formatVolume ~= nil then
            amountCell:setText(self.i18n:formatVolume(liters, 0))
        else
            amountCell:setText(string.format("%d l", math.floor(liters + 0.5)))
        end
    end
end

function DynamicMarketStockLocationDialog:onListSelectionChanged(list, section, index)
    local entry = self.currentLocations[index]
    self.mapHotspot = entry ~= nil and entry.hotspot or nil

    if self.dialogButtonTag ~= nil then
        if self.mapHotspot ~= nil then
            dmSetButtonDisabled(self.dialogButtonTag, false)
            if g_currentMission ~= nil and self.mapHotspot == g_currentMission.currentMapTargetHotspot then
                self.dialogButtonTag:setText(self.i18n:getText("dm_action_hide_from_map"))
            else
                self.dialogButtonTag:setText(self.i18n:getText("dm_action_show_on_map"))
            end
        else
            dmSetButtonDisabled(self.dialogButtonTag, true)
        end
    end
end

function DynamicMarketStockLocationDialog:onTagLocation(sender)
    local hotspot = self.mapHotspot
    if hotspot == nil or g_currentMission == nil then
        return
    end

    if hotspot == g_currentMission.currentMapTargetHotspot then
        g_currentMission:setMapTargetHotspot()
        if self.dialogButtonTag ~= nil then
            self.dialogButtonTag:setText(self.i18n:getText("dm_action_show_on_map"))
        end
    else
        g_currentMission:setMapTargetHotspot(hotspot)
        if self.dialogButtonTag ~= nil then
            self.dialogButtonTag:setText(self.i18n:getText("dm_action_hide_from_map"))
        end
    end
end

function DynamicMarketStockLocationDialog:onClose()
    DynamicMarketStockLocationDialog:superClass().onClose(self)
end

function DynamicMarketStockLocationDialog:onClickBack(sender)
    self:close()
end
