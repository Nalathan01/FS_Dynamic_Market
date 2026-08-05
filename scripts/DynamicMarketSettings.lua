DynamicMarketSettings = {}
DynamicMarketSettings._mt = Class(DynamicMarketSettings)

function DynamicMarketSettings.new(dynamicMarket, customMt)
    local self = setmetatable({}, customMt or DynamicMarketSettings._mt)
    self.dynamicMarket = dynamicMarket
    self.installed = false
    self.mode = dynamicMarket ~= nil and dynamicMarket.PRICE_BASE_YEAR_AVERAGE or 2
    self.dailyRecalcMode = dynamicMarket ~= nil and dynamicMarket.DAILY_RECALC_DISABLED or 1
    self.stationThresholdState = 2
    self.stationPercentState = 2
    self.settingsHeader = nil
    self.settingsRow = nil
    self.dailyRecalcRow = nil
    self.priceBaseOption = nil
    self.dailyRecalcOption = nil
    self.settingsInitialized = false
    return self
end

function DynamicMarketSettings:install()
    if self.installed == true then
        return true
    end
    if InGameMenuSettingsFrame == nil or Utils == nil or Utils.appendedFunction == nil then
        return false
    end

    InGameMenuSettingsFrame.onFrameOpen = Utils.appendedFunction(InGameMenuSettingsFrame.onFrameOpen, function()
        self:onSettingsFrameOpen()
    end)

    if InGameMenuSettingsFrame.update ~= nil then
        InGameMenuSettingsFrame.update = Utils.appendedFunction(InGameMenuSettingsFrame.update, function(_, dt)
            self:onSettingsFrameUpdate(dt)
        end)
    end

    self.installed = true
    return true
end

function DynamicMarketSettings:getSaveKey()
    return "gameSettings.dynamicMarket.priceBase#mode"
end

function DynamicMarketSettings:getDailyRecalcSaveKey()
    return "gameSettings.dynamicMarket.dailyRecalc#mode"
end

function DynamicMarketSettings:normalizeMode(mode)
    mode = tonumber(mode) or 2
    if mode ~= 1 and mode ~= 2 then
        mode = 2
    end
    return mode
end

function DynamicMarketSettings:normalizeDailyRecalcMode(mode)
    local disabled = self.dynamicMarket ~= nil and self.dynamicMarket.DAILY_RECALC_DISABLED or 1
    local enabled = self.dynamicMarket ~= nil and self.dynamicMarket.DAILY_RECALC_ENABLED or 2
    mode = tonumber(mode) or disabled
    if mode ~= disabled and mode ~= enabled then
        mode = disabled
    end
    return mode
end

function DynamicMarketSettings:normalizeStationThresholdMode(state)
    state = tonumber(state) or 2
    local count = #self.STATION_THRESHOLD_VALUES
    if state < 1 or state > count then
        state = 2
    end
    return state
end

function DynamicMarketSettings:normalizeStationPercentMode(state)
    state = tonumber(state) or 2
    local count = #self.STATION_PERCENT_VALUES
    if state < 1 or state > count then
        state = 2
    end
    return state
end

function DynamicMarketSettings:getStationThresholdSaveKey()
    return "gameSettings.dynamicMarket.stationThreshold#state"
end

function DynamicMarketSettings:getStationPercentSaveKey()
    return "gameSettings.dynamicMarket.stationPercent#state"
end

function DynamicMarketSettings:loadSettings()
    local mode = self.mode
    if g_savegameXML ~= nil and getXMLInt ~= nil then
        mode = Utils.getNoNil(getXMLInt(g_savegameXML, self:getSaveKey()), mode)
    end
    self.mode = self:normalizeMode(mode)

    local dailyRecalcMode = self.dailyRecalcMode
    if g_savegameXML ~= nil and getXMLInt ~= nil then
        dailyRecalcMode = Utils.getNoNil(getXMLInt(g_savegameXML, self:getDailyRecalcSaveKey()), dailyRecalcMode)
    end
    self.dailyRecalcMode = self:normalizeDailyRecalcMode(dailyRecalcMode)

    local stationThresholdState = self.stationThresholdState
    if g_savegameXML ~= nil and getXMLInt ~= nil then
        stationThresholdState = Utils.getNoNil(getXMLInt(g_savegameXML, self:getStationThresholdSaveKey()), stationThresholdState)
    end
    self.stationThresholdState = self:normalizeStationThresholdMode(stationThresholdState)

    local stationPercentState = self.stationPercentState
    if g_savegameXML ~= nil and getXMLInt ~= nil then
        stationPercentState = Utils.getNoNil(getXMLInt(g_savegameXML, self:getStationPercentSaveKey()), stationPercentState)
    end
    self.stationPercentState = self:normalizeStationPercentMode(stationPercentState)
end

function DynamicMarketSettings:saveSettings()
    if g_savegameXML ~= nil and setXMLInt ~= nil then
        setXMLInt(g_savegameXML, self:getSaveKey(), self.mode)
        setXMLInt(g_savegameXML, self:getDailyRecalcSaveKey(), self.dailyRecalcMode)
        setXMLInt(g_savegameXML, self:getStationThresholdSaveKey(), self.stationThresholdState)
        setXMLInt(g_savegameXML, self:getStationPercentSaveKey(), self.stationPercentState)
    end
end

function DynamicMarketSettings:applyToModule(save)
    self.mode = self:normalizeMode(self.mode)
    self.dailyRecalcMode = self:normalizeDailyRecalcMode(self.dailyRecalcMode)
    self.stationThresholdState = self:normalizeStationThresholdMode(self.stationThresholdState)
    self.stationPercentState = self:normalizeStationPercentMode(self.stationPercentState)
    if self.dynamicMarket ~= nil and self.dynamicMarket.setPriceBaseMode ~= nil then
        self.dynamicMarket:setPriceBaseMode(self.mode, "gameSetting")
    end
    if self.dynamicMarket ~= nil and self.dynamicMarket.setDailyRecalcMode ~= nil then
        self.dynamicMarket:setDailyRecalcMode(self.dailyRecalcMode, "gameSetting")
    end
    if self.dynamicMarket ~= nil then
        self.dynamicMarket.STATION_PRESSURE_THRESHOLD_LITERS = self.STATION_THRESHOLD_VALUES[self.stationThresholdState]
        self.dynamicMarket.STATION_PRESSURE_PERCENT_PER_STEP = self.STATION_PERCENT_VALUES[self.stationPercentState]
    end
    if save == true then
        self:saveSettings()
    end
end

function DynamicMarketSettings:findElementRecursive(root, predicate)
    if root == nil then
        return nil
    end
    if predicate(root) then
        return root
    end
    if root.elements ~= nil then
        for _, child in ipairs(root.elements) do
            local found = self:findElementRecursive(child, predicate)
            if found ~= nil then
                return found
            end
        end
    end
    return nil
end

function DynamicMarketSettings:isMultiTextOptionElement(element)
    return element ~= nil
        and MultiTextOptionElement ~= nil
        and element.isa ~= nil
        and element:isa(MultiTextOptionElement)
end

function DynamicMarketSettings:getGameSettingsLayout()
    if g_inGameMenu == nil or g_inGameMenu.pageSettings == nil then
        return nil
    end
    return g_inGameMenu.pageSettings.gameSettingsLayout
end

function DynamicMarketSettings:hasMultiTextOption(element)
    if element == nil then
        return false
    end
    return self:findElementRecursive(element, function(child)
        return self:isMultiTextOptionElement(child)
    end) ~= nil
end

function DynamicMarketSettings:getTemplates(layout)
    if layout == nil or layout.elements == nil then
        return nil, nil
    end

    local sectionHeader = nil
    local optionRow = nil

    for _, element in pairs(layout.elements) do
        if element.name == "sectionHeader" and sectionHeader == nil then
            sectionHeader = element
        end

        if optionRow == nil and element.typeName == "Bitmap" and self:hasMultiTextOption(element) then
            optionRow = element
        end

        if sectionHeader ~= nil and optionRow ~= nil then
            break
        end
    end

    return sectionHeader, optionRow
end


function DynamicMarketSettings:setTooltipText(element, text)
    if element == nil then
        return
    end
    element.toolTip = text
    element.tooltip = text
    element.toolTipText = text
    element.tooltipText = text
    element.helpText = text
    element.description = text
    if element.setTooltip ~= nil then
        element:setTooltip(text)
    end
    if element.setToolTip ~= nil then
        element:setToolTip(text)
    end
    if element.setHelpText ~= nil then
        element:setHelpText(text)
    end
    if element.setDescription ~= nil then
        element:setDescription(text)
    end
end

DynamicMarketSettings.STATION_THRESHOLD_VALUES = {10000, 25000, 50000, 100000, 200000}
DynamicMarketSettings.STATION_PERCENT_VALUES = {1, 2, 3, 5}

DynamicMarketSettings.OPTION_DEFS = {
    priceBase = {
        rowName = "dmPriceBaseRow",
        optionId = "dmPriceBase",
        modeField = "mode",
        titleKey = "dm_setting_pricebase_title",
        descKey = "dm_setting_pricebase_desc",
        textKeys = {"dm_setting_pricebase_normal", "dm_setting_pricebase_year"},
        optionField = "priceBaseOption",
        rowField = "settingsRow",
        normalizeFn = "normalizeMode",
        onClickFn = "onClickPriceBase"
    },
    dailyRecalc = {
        rowName = "dmDailyRecalcRow",
        optionId = "dmDailyRecalc",
        modeField = "dailyRecalcMode",
        titleKey = "dm_setting_dailyrecalc_title",
        descKey = "dm_setting_dailyrecalc_desc",
        textKeys = {"dm_setting_dailyrecalc_off", "dm_setting_dailyrecalc_on"},
        optionField = "dailyRecalcOption",
        rowField = "dailyRecalcRow",
        normalizeFn = "normalizeDailyRecalcMode",
        onClickFn = "onClickDailyRecalc"
    },
    stationThreshold = {
        rowName = "dmStationThresholdRow",
        optionId = "dmStationThreshold",
        modeField = "stationThresholdState",
        titleKey = "dm_setting_stationthreshold_title",
        descKey = "dm_setting_stationthreshold_desc",
        textKeys = {"dm_setting_stationthreshold_1", "dm_setting_stationthreshold_2", "dm_setting_stationthreshold_3", "dm_setting_stationthreshold_4", "dm_setting_stationthreshold_5"},
        optionField = "stationThresholdOption",
        rowField = "stationThresholdRow",
        normalizeFn = "normalizeStationThresholdMode",
        onClickFn = "onClickStationThreshold"
    },
    stationPercent = {
        rowName = "dmStationPercentRow",
        optionId = "dmStationPercent",
        modeField = "stationPercentState",
        titleKey = "dm_setting_stationpercent_title",
        descKey = "dm_setting_stationpercent_desc",
        textKeys = {"dm_setting_stationpercent_1", "dm_setting_stationpercent_2", "dm_setting_stationpercent_3", "dm_setting_stationpercent_4"},
        optionField = "stationPercentOption",
        rowField = "stationPercentRow",
        normalizeFn = "normalizeStationPercentMode",
        onClickFn = "onClickStationPercent"
    }
}

DynamicMarketSettings.OPTION_ORDER = {"priceBase", "dailyRecalc", "stationThreshold", "stationPercent"}

function DynamicMarketSettings:getDescriptionText(kind)
    local def = self.OPTION_DEFS[kind or "priceBase"]
    if g_i18n ~= nil and def ~= nil then
        return g_i18n:getText(def.descKey)
    end
    return ""
end

function DynamicMarketSettings:setNativeOptionTooltip(option, text)
    if option == nil then
        return
    end

    local function setIfText(element)
        if element ~= nil and element.setText ~= nil and element.typeName == "Text" then
            if element ~= option.labelElement and element ~= option.textElement then
                element:setText(text)
                return true
            end
        end
        return false
    end

    if option.elements ~= nil then
        if setIfText(option.elements[1]) then
            return
        end

        for _, child in pairs(option.elements) do
            if setIfText(child) then
                return
            end
        end
    end
end

function DynamicMarketSettings:updateSettingsDescriptionText(kind)
    local def = self.OPTION_DEFS[kind or "priceBase"]
    if def == nil then
        return
    end
    self:setNativeOptionTooltip(self[def.optionField], self:getDescriptionText(kind))
end

function DynamicMarketSettings:getIsOptionFocused(kind)
    local def = self.OPTION_DEFS[kind]
    if def == nil then
        return false
    end
    local option = self[def.optionField]
    if option == nil then
        return false
    end
    if option.getIsFocused ~= nil then
        local ok, focused = pcall(option.getIsFocused, option)
        if ok and focused == true then
            return true
        end
    end
    if option.focused == true or option.focusActive == true then
        return true
    end
    if FocusManager ~= nil and FocusManager.currentFocusData ~= nil then
        return FocusManager.currentFocusData.focusElement == option
    end
    return false
end

function DynamicMarketSettings:getIsPriceBaseFocused()
    return self:getIsOptionFocused("priceBase")
end

function DynamicMarketSettings:onOptionFocus(kind)
    self:updateSettingsDescriptionText(kind)
end

function DynamicMarketSettings:onPriceBaseFocus()
    self:onOptionFocus("priceBase")
end

function DynamicMarketSettings:onDailyRecalcFocus()
    self:onOptionFocus("dailyRecalc")
end

function DynamicMarketSettings:refreshFocusHandling(element)
    if element ~= nil and element.reloadFocusHandling ~= nil then
        element:reloadFocusHandling(true)
    end
end

function DynamicMarketSettings:resetFocusData(element)
    if element == nil then
        return
    end

    element.focusId = nil
    element.focusChangeData = {}
    element.focusActive = false
    element.isAlwaysFocusedOnOpen = false

    if element.elements ~= nil then
        for _, child in pairs(element.elements) do
            self:resetFocusData(child)
        end
    end
end

function DynamicMarketSettings:registerFocusData(element)
    if element == nil or FocusManager == nil or FocusManager.loadElementFromCustomValues == nil then
        return false
    end

    return FocusManager:loadElementFromCustomValues(element, nil, {}, false, false)
end

function DynamicMarketSettings:setOptionTexts(kind)
    local def = self.OPTION_DEFS[kind]
    if def == nil then
        return
    end
    local option = self[def.optionField]
    if option == nil then
        return
    end

    if option.setLabel ~= nil then
        option:setLabel(g_i18n:getText(def.titleKey))
    end
    if option.setTexts ~= nil then
        local texts = {}
        for i, textKey in ipairs(def.textKeys) do
            texts[i] = g_i18n:getText(textKey)
        end
        option:setTexts(texts)
    end
    if option.setState ~= nil then
        option:setState(self[def.modeField])
    end
    self:setTooltipText(option, g_i18n:getText(def.descKey))
end

function DynamicMarketSettings:getStateFromCallback(kind, a, b, c)
    local def = self.OPTION_DEFS[kind]
    if type(a) == "number" then
        return a
    end
    if type(b) == "number" then
        return b
    end
    if type(c) == "number" then
        return c
    end
    local option = def ~= nil and self[def.optionField] or nil
    if option ~= nil and option.getState ~= nil then
        return option:getState()
    end
    return def ~= nil and self[def.modeField] or 1
end

function DynamicMarketSettings:onClickPriceBase(a, b, c)
    self.mode = self:normalizeMode(self:getStateFromCallback("priceBase", a, b, c))
    self:applyToModule(true)
    self:setOptionTexts("priceBase")
    self:onPriceBaseFocus()
end

function DynamicMarketSettings:onClickDailyRecalc(a, b, c)
    self.dailyRecalcMode = self:normalizeDailyRecalcMode(self:getStateFromCallback("dailyRecalc", a, b, c))
    self:applyToModule(true)
    self:setOptionTexts("dailyRecalc")
    self:onDailyRecalcFocus()
end

function DynamicMarketSettings:onClickStationThreshold(a, b, c)
    self.stationThresholdState = self:normalizeStationThresholdMode(self:getStateFromCallback("stationThreshold", a, b, c))
    self:applyToModule(true)
    self:setOptionTexts("stationThreshold")
    self:onOptionFocus("stationThreshold")
end

function DynamicMarketSettings:onClickStationPercent(a, b, c)
    self.stationPercentState = self:normalizeStationPercentMode(self:getStateFromCallback("stationPercent", a, b, c))
    self:applyToModule(true)
    self:setOptionTexts("stationPercent")
    self:onOptionFocus("stationPercent")
end

function DynamicMarketSettings:prepareOptionRow(row, kind)
    local def = self.OPTION_DEFS[kind]
    if row == nil or def == nil then
        return false
    end

    self:resetFocusData(row)

    local description = self:getDescriptionText(kind)

    local function prepareChild(element)
        if element == nil then
            return
        end
        element.id = nil
        self:setTooltipText(element, description)
        element.onFocusCallback = function()
            self:onOptionFocus(kind)
        end
        element.onHighlightCallback = function()
            self:onOptionFocus(kind)
        end
        if element.elements ~= nil then
            for _, child in pairs(element.elements) do
                prepareChild(child)
            end
        end
    end

    row.id = nil
    row.name = def.rowName
    row.onFocusCallback = function()
        self:onOptionFocus(kind)
    end
    row.onHighlightCallback = function()
        self:onOptionFocus(kind)
    end
    self[def.rowField] = row
    self:setTooltipText(row, description)

    if row.elements ~= nil then
        for _, element in pairs(row.elements) do
            prepareChild(element)
            if element.typeName == "Text" and element.setText ~= nil then
                element:setText(g_i18n:getText(def.titleKey))
            end
        end
    end

    local option = self:findElementRecursive(row, function(element)
        return self:isMultiTextOptionElement(element)
    end)

    if option == nil then
        return false
    end

    option.id = def.optionId
    option.name = def.optionId
    option.handleFocus = true
    if option.setHandleFocus ~= nil then
        option:setHandleFocus(true)
    end
    if option.setCanChangeState ~= nil then
        option:setCanChangeState(true)
    else
        option.canChangeState = true
    end
    option.isAlwaysFocusedOnOpen = false
    option.focused = false
    option.onFocusCallback = function()
        self:onOptionFocus(kind)
    end
    option.onHighlightCallback = function()
        self:onOptionFocus(kind)
    end
    option.onClickCallback = function(a, b, c)
        if FocusManager ~= nil then
            FocusManager:setFocus(option)
        end
        self:onOptionFocus(kind)
        self[def.onClickFn](self, a, b, c)
    end
    self[def.optionField] = option
    self:setOptionTexts(kind)
    self:refreshFocusHandling(row)
    self:refreshFocusHandling(option)
    return true
end

function DynamicMarketSettings:initializeSettingsOption()
    if self.settingsInitialized == true then
        return true
    end

    local layout = self:getGameSettingsLayout()
    if layout == nil or layout.elements == nil then
        return false
    end

    local headerTemplate, rowTemplate = self:getTemplates(layout)
    if headerTemplate == nil or rowTemplate == nil or headerTemplate.clone == nil or rowTemplate.clone == nil then
        return false
    end

    local header = headerTemplate:clone(layout)
    header:setText(g_i18n:getText("dm_settings_header"))
    self.settingsHeader = header

    for _, kind in ipairs(self.OPTION_ORDER) do
        local row = rowTemplate:clone(layout)
        if not self:prepareOptionRow(row, kind) then
            return false
        end
    end

    self.settingsInitialized = true
    if layout.invalidateLayout ~= nil then
        layout:invalidateLayout()
    end

    self:registerFocusData(header)
    for _, kind in ipairs(self.OPTION_ORDER) do
        local def = self.OPTION_DEFS[kind]
        self:registerFocusData(self[def.rowField])
    end

    if FocusManager ~= nil and FocusManager.setGui ~= nil and g_inGameMenu ~= nil then
        FocusManager:setGui(g_inGameMenu)
    end

    self:refreshFocusHandling(layout)
    for _, kind in ipairs(self.OPTION_ORDER) do
        local def = self.OPTION_DEFS[kind]
        self:refreshFocusHandling(self[def.rowField])
        self:refreshFocusHandling(self[def.optionField])
    end
    self:updateSettingsFrame()
    return true
end

function DynamicMarketSettings:updateSettingsFrame()
    self:loadSettings()
    self:applyToModule(false)

    if self.settingsHeader ~= nil then
        self.settingsHeader:setVisible(true)
    end

    for _, kind in ipairs(self.OPTION_ORDER) do
        local def = self.OPTION_DEFS[kind]
        self:setOptionTexts(kind)
        local row = self[def.rowField]
        if row ~= nil then
            row:setVisible(true)
        end
        self:refreshFocusHandling(row)
        self:refreshFocusHandling(self[def.optionField])
    end
end

function DynamicMarketSettings:onSettingsFrameUpdate(dt)
    for _, kind in ipairs(self.OPTION_ORDER) do
        if self:getIsOptionFocused(kind) then
            self:updateSettingsDescriptionText(kind)
        end
    end
end

function DynamicMarketSettings:onSettingsFrameOpen()
    if self.settingsInitialized ~= true then
        self:initializeSettingsOption()
    end
    self:updateSettingsFrame()
end
