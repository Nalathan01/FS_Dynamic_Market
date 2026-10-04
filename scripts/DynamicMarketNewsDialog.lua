DynamicMarketNewsDialog = {}
local DynamicMarketNewsDialog_mt = Class(DynamicMarketNewsDialog, MessageDialog)

function DynamicMarketNewsDialog.new(target, customMt)
    local self = MessageDialog.new(target, customMt or DynamicMarketNewsDialog_mt)
    self.i18n = g_i18n
    self.currentEntries = {}
    return self
end

function DynamicMarketNewsDialog:onCreate()
    DynamicMarketNewsDialog:superClass().onCreate(self)
end

function DynamicMarketNewsDialog:onGuiSetupFinished()
    DynamicMarketNewsDialog:superClass().onGuiSetupFinished(self)
    if self.dynamicMarketNewsTable ~= nil then
        self.dynamicMarketNewsTable:setDataSource(self)
        self.dynamicMarketNewsTable:setDelegate(self)
    end
end

function DynamicMarketNewsDialog:onOpen()
    DynamicMarketNewsDialog:superClass().onOpen(self)
    if self.dynamicMarketNewsTable ~= nil then
        FocusManager:setFocus(self.dynamicMarketNewsTable)
    end
end

function DynamicMarketNewsDialog:setNewsData(title, entries)
    if self.dialogTitleElement ~= nil then
        self.dialogTitleElement:setText(tostring(title or ""))
    end

    self.currentEntries = {}
    if type(entries) == "table" then
        for _, entry in ipairs(entries) do
            table.insert(self.currentEntries, entry)
        end
    end

    if self.dynamicMarketNewsTable ~= nil then
        self.dynamicMarketNewsTable:reloadData()
    end
end

function DynamicMarketNewsDialog:getNumberOfSections()
    return 1
end

function DynamicMarketNewsDialog:getNumberOfItemsInSection(list, section)
    return #self.currentEntries
end

function DynamicMarketNewsDialog:populateCellForItemInSection(list, section, index, cell)
    local entry = self.currentEntries[index]
    if entry == nil then
        return
    end

    local groupCell = cell:getAttribute("group")
    if groupCell ~= nil then
        local groupTitle = tostring(entry.groupTitle or "")
        groupCell:setText(string.upper(string.sub(groupTitle, 1, 1)) .. string.sub(groupTitle, 2))
    end

    local changeCell = cell:getAttribute("change")
    if changeCell ~= nil then
        changeCell:setText(tostring(entry.changeText or ""))
        if changeCell.setTextColor ~= nil then
            if changeCell.dmDefaultTextColor == nil and type(changeCell.textColor) == "table" then
                changeCell.dmDefaultTextColor = {changeCell.textColor[1], changeCell.textColor[2], changeCell.textColor[3], changeCell.textColor[4]}
            end
            local color = changeCell.dmDefaultTextColor
            if entry.direction == "up" then
                color = {0.35, 0.8, 0.25, 1}
            elseif entry.direction == "down" then
                color = {0.9, 0.3, 0.25, 1}
            end
            if color ~= nil then
                changeCell:setTextColor(color[1], color[2], color[3], color[4])
                if changeCell.setTextSelectedColor ~= nil then
                    changeCell:setTextSelectedColor(color[1], color[2], color[3], color[4])
                end
            end
        end
    end

    local reasonCell = cell:getAttribute("reason")
    if reasonCell ~= nil then
        reasonCell:setText(tostring(entry.reason or ""))
    end

    local stockCell = cell:getAttribute("stock")
    if stockCell ~= nil then
        stockCell:setText(tostring(entry.stockText or ""))
    end
end

function DynamicMarketNewsDialog:onClose()
    DynamicMarketNewsDialog:superClass().onClose(self)
end

function DynamicMarketNewsDialog:onClickBack(sender)
    self:close()
end
