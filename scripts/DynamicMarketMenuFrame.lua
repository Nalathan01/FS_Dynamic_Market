DynamicMarketMenuFrame = {}
DynamicMarketMenuFrame._mt = Class(DynamicMarketMenuFrame, TabbedMenuFrameElement)
DynamicMarketMenuFrame.sortColumn = "price"
DynamicMarketMenuFrame.sortAscending = false

local function dmLowerText(value)
    return string.lower(tostring(value or ""))
end

local function dmNumber(value)
    return tonumber(value) or 0
end

local function dmFormatStock(value)
    local liters = tonumber(value) or 0
    if g_i18n ~= nil and g_i18n.formatVolume ~= nil then
        local ok, text = pcall(g_i18n.formatVolume, g_i18n, liters, 0)
        if ok and text ~= nil then
            return text
        end
    end
    return string.format("%d l", math.floor(liters + 0.5))
end

local function dmMonthOrder(value)
    local month = tonumber(value)
    if month ~= nil then
        return math.max(1, math.min(12, math.floor(month)))
    end
    local text = dmLowerText(value)
    local names = {
        ["jan"] = 1, ["januar"] = 1, ["january"] = 1,
        ["feb"] = 2, ["februar"] = 2, ["february"] = 2, ["fevrier"] = 2, ["février"] = 2,
        ["mar"] = 3, ["mär"] = 3, ["maerz"] = 3, ["märz"] = 3, ["march"] = 3, ["mars"] = 3,
        ["apr"] = 4, ["april"] = 4, ["avril"] = 4,
        ["mai"] = 5, ["may"] = 5,
        ["jun"] = 6, ["juni"] = 6, ["june"] = 6, ["juin"] = 6,
        ["jul"] = 7, ["juli"] = 7, ["july"] = 7, ["juillet"] = 7,
        ["aug"] = 8, ["august"] = 8, ["aout"] = 8, ["août"] = 8,
        ["sep"] = 9, ["sept"] = 9, ["september"] = 9, ["septembre"] = 9,
        ["okt"] = 10, ["oktober"] = 10, ["oct"] = 10, ["october"] = 10, ["octobre"] = 10,
        ["nov"] = 11, ["november"] = 11, ["novembre"] = 11,
        ["dez"] = 12, ["dezember"] = 12, ["dec"] = 12, ["december"] = 12, ["decembre"] = 12, ["décembre"] = 12
    }
    return names[text] or 99
end

local function dmIsMissingText(value)
    local text = string.lower(tostring(value or ""))
    return string.find(text, "missing", 1, true) ~= nil
end

local function dmMonthLabel(value)
    local month = dmMonthOrder(value)
    local keys = {
        "dm_month_jan", "dm_month_feb", "dm_month_mar", "dm_month_apr",
        "dm_month_may", "dm_month_jun", "dm_month_jul", "dm_month_aug",
        "dm_month_sep", "dm_month_oct", "dm_month_nov", "dm_month_dec"
    }
    local fallback = {"Jan", "Feb", "März", "Apr", "Mai", "Jun", "Jul", "Aug", "Sep", "Okt", "Nov", "Dez"}
    local key = keys[month]
    local label = key ~= nil and g_i18n ~= nil and g_i18n:getText(key) or nil
    if label == nil or label == "" or dmIsMissingText(label) then
        label = fallback[month] or ""
    end
    return label
end

function DynamicMarketMenuFrame.new(i18n, messageCenter)
    local self = DynamicMarketMenuFrame:superClass().new(nil, DynamicMarketMenuFrame._mt)
    self.name = "DynamicMarketMenuFrame"
    self.i18n = i18n
    self.messageCenter = messageCenter
    self.rows = {}
    self.allRows = {}
    self.searchText = ""
    self.stockFilterState = 0
    self.isOpen = false
    self.refreshTimerMs = 0
    self.lastUiPriceRefreshToken = -1
    self.backButtonInfo = {
        inputAction = InputAction.MENU_BACK
    }
    self.showStockButtonInfo = {
        text = self.i18n:getText("dm_action_show_stock_locations"),
        inputAction = InputAction.MENU_ACTIVATE,
        disabled = true,
        callback = function()
            self:showStockLocations()
        end
    }
    self.mapHotspotButtonInfo = {
        text = self.i18n:getText("dm_action_show_on_map"),
        inputAction = InputAction.MENU_ACCEPT,
        disabled = true,
        callback = function()
            self:onClickMapHotspot()
        end
    }
    self.toggleFavoriteButtonInfo = {
        text = self.i18n:getText("dm_action_add_favorite"),
        inputAction = InputAction.MENU_EXTRA_1,
        disabled = true,
        callback = function()
            self:onClickToggleFavorite()
        end
    }
    self:setMenuButtonInfo({self.backButtonInfo, self.showStockButtonInfo, self.mapHotspotButtonInfo, self.toggleFavoriteButtonInfo})
    return self
end

function DynamicMarketMenuFrame:delete()
    self.isOpen = false
    self.refreshTimerMs = 0
    self:deactivateSearchInput()
    DynamicMarketMenuFrame:superClass().delete(self)
end

function DynamicMarketMenuFrame:copyAttributes(src)
    DynamicMarketMenuFrame:superClass().copyAttributes(self, src)
    self.i18n = src.i18n
end

function DynamicMarketMenuFrame:onGuiSetupFinished()
    DynamicMarketMenuFrame:superClass().onGuiSetupFinished(self)
    if self.searchInput ~= nil and self.searchInput.setText ~= nil then
        self.searchInput:setText("")
    end
    if self.dynamicMarketTable ~= nil then
        self.dynamicMarketTable:setDataSource(self)
        self.dynamicMarketTable:setDelegate(self)
    end
    if self.storedOnlyButton ~= nil then
        self.storedOnlyButton:setText(g_i18n:getText("dm_filter_stored_off"))
    end
    self:updateYearlyAverageOptionVisibility()
    self:updateSortIcons()
end

function DynamicMarketMenuFrame:initialize()
end

function DynamicMarketMenuFrame:isYearlyAverageEnabled()
    return DynamicMarket ~= nil
        and DynamicMarket.ENABLE_YEARLY_AVERAGE == true
        and DynamicMarket.USE_YEARLY_AVERAGE_AS_BASE_PRICE == true
end

function DynamicMarketMenuFrame:updateYearlyAverageOptionVisibility()
    local yearlyMode = self:isYearlyAverageEnabled()
    if self.yearlyAverageHeader ~= nil then
        self.yearlyAverageHeader:setVisible(true)
    end
    if self.monthHeader ~= nil then
        self.monthHeader:setVisible(yearlyMode ~= true)
    end
    if yearlyMode == true and DynamicMarketMenuFrame.sortColumn == "month" then
        DynamicMarketMenuFrame.sortColumn = "price"
        DynamicMarketMenuFrame.sortAscending = true
    end
end

function DynamicMarketMenuFrame:onFrameOpen()
    DynamicMarketMenuFrame:superClass().onFrameOpen(self)
    self.isOpen = true
    self.refreshTimerMs = 0
    if DynamicMarket ~= nil and DynamicMarket.ensurePricesReadyForUi ~= nil then
        DynamicMarket:ensurePricesReadyForUi("menuOpen")
    end
    self.lastUiPriceRefreshToken = DynamicMarket ~= nil and (tonumber(DynamicMarket.__uiPriceRefreshToken) or 0) or -1
    self:updateYearlyAverageOptionVisibility()
    self:updateContent()
    self:updateSortIcons()
    self:deactivateSearchInput()
    if self.dynamicMarketTable ~= nil and FocusManager ~= nil then
        FocusManager:setFocus(self.dynamicMarketTable)
    end
end

function DynamicMarketMenuFrame:onFrameClose()
    self.isOpen = false
    self.refreshTimerMs = 0
    self:deactivateSearchInput()
    DynamicMarketMenuFrame:superClass().onFrameClose(self)
end

function DynamicMarketMenuFrame:activateSearchInput()
    if self.searchInput ~= nil then
        FocusManager:setFocus(self.searchInput)
        if self.searchInput.setForcePressed ~= nil then
            self.searchInput:setForcePressed(true)
        elseif self.searchInput.onFocusActivate ~= nil then
            self.searchInput:onFocusActivate()
        end
    end
end

function DynamicMarketMenuFrame:deactivateSearchInput()
    if self.searchInput ~= nil and self.searchInput.setForcePressed ~= nil then
        self.searchInput:setForcePressed(false)
    end
end

function DynamicMarketMenuFrame:resetListPosition()
    local list = self.dynamicMarketTable
    if list == nil then
        return
    end
    if list.setSelectedItem ~= nil then
        list:setSelectedItem(1, 1, nil, 0)
    end
    if list.smoothScrollTo ~= nil then
        list:smoothScrollTo(0)
    end
    if list.setScrollOffset ~= nil then
        list:setScrollOffset(0)
    end
    if list.viewOffset ~= nil then
        list.viewOffset = 0
    end
    if list.targetViewOffset ~= nil then
        list.targetViewOffset = 0
    end
end

function DynamicMarketMenuFrame:update(dt)
    DynamicMarketMenuFrame:superClass().update(self, dt)

    if self.isOpen ~= true then
        return
    end

    local delta = tonumber(dt) or 0
    self.refreshTimerMs = (tonumber(self.refreshTimerMs) or 0) + delta
    if self.refreshTimerMs >= 250 then
        self.refreshTimerMs = 0
        local token = DynamicMarket ~= nil and (tonumber(DynamicMarket.__uiPriceRefreshToken) or 0) or -1
        if token ~= self.lastUiPriceRefreshToken then
            self.lastUiPriceRefreshToken = token
            self:updateContent()
        end
    end
end

function DynamicMarketMenuFrame:getSortValue(row, column)
    if column == "good" then
        return dmLowerText(row.title)
    elseif column == "group" then
        return dmLowerText(row.groupTitle)
    elseif column == "market" then
        return dmNumber(row.marketFactor)
    elseif column == "price" then
        return dmNumber(row.bestPrice or row.currentBestPrice)
    elseif column == "pressure" then
        return dmNumber(row.pressureAmount)
    elseif column == "stock" then
        return dmNumber(row.stockLevel)
    elseif column == "yearlyAverage" then
        return dmNumber(row.baseCurrentPrice)
    elseif column == "stockValue" then
        return dmNumber(row.stockLevel) * dmNumber(row.bestPrice or row.currentBestPrice)
    elseif column == "station" then
        return dmLowerText(row.bestStation)
    elseif column == "month" then
        return tonumber(row.bestMonthNumber) or dmMonthOrder(row.bestMonth)
    elseif column == "favorite" then
        return DynamicMarket ~= nil and DynamicMarket:isFavorite(row.name) and 1 or 0
    end
    return dmLowerText(row.title)
end

function DynamicMarketMenuFrame:sortRows()
    local column = DynamicMarketMenuFrame.sortColumn or "good"
    local ascending = DynamicMarketMenuFrame.sortAscending ~= false
    table.sort(self.rows, function(a, b)
        local av = self:getSortValue(a, column)
        local bv = self:getSortValue(b, column)
        if av == bv then
            return dmLowerText(a.title) < dmLowerText(b.title)
        end
        if ascending then
            return av < bv
        end
        return av > bv
    end)
end

function DynamicMarketMenuFrame:rowMatchesSearch(row)
    if self.stockFilterState == 1 and dmNumber(row.stockLevel) <= 0 then
        return false
    end
    if self.stockFilterState == 2 and not (DynamicMarket ~= nil and DynamicMarket:isFavorite(row.name)) then
        return false
    end
    local search = dmLowerText(self.searchText)
    if search == nil or search == "" then
        return true
    end
    return string.find(dmLowerText(row.title), search, 1, true) ~= nil
        or string.find(dmLowerText(row.name), search, 1, true) ~= nil
        or string.find(dmLowerText(row.groupTitle), search, 1, true) ~= nil
end
function DynamicMarketMenuFrame:applySearchFilter()
    self.rows = {}
    for _, row in ipairs(self.allRows or {}) do
        if self:rowMatchesSearch(row) then
            table.insert(self.rows, row)
        end
    end
    self:sortRows()
end

function DynamicMarketMenuFrame:updateContent()
    self:updateYearlyAverageOptionVisibility()
    if DynamicMarket ~= nil and DynamicMarket.buildMarketOverviewRows ~= nil then
        self.allRows = DynamicMarket:buildMarketOverviewRows()
    else
        self.allRows = {}
    end
    self:applySearchFilter()
    if self.currentBalanceText ~= nil then
        self.currentBalanceText:setText(g_i18n:formatMoney(g_currentMission:getMoney(), 0, true, true))
    end
    if self.totalVisible ~= nil then
        self.totalVisible:setText(tostring(#self.rows))
    end
    if self.dynamicMarketTable ~= nil then
        self.dynamicMarketTable:reloadData()
    end
    if self.selectedRow == nil and self.rows[1] ~= nil then
        self.selectedRow = self.rows[1]
    end
    self:updateActionButtonStates()
end

function DynamicMarketMenuFrame:setSortColumn(column)
    self:playSample(GuiSoundPlayer.SOUND_SAMPLES.CLICK)
    if DynamicMarketMenuFrame.sortColumn == column then
        DynamicMarketMenuFrame.sortAscending = not DynamicMarketMenuFrame.sortAscending
    else
        DynamicMarketMenuFrame.sortColumn = column
        DynamicMarketMenuFrame.sortAscending = true
    end
    self:updateSortIcons()
    self:applySearchFilter()
    if self.dynamicMarketTable ~= nil then
        self.dynamicMarketTable:reloadData()
        self:resetListPosition()
        FocusManager:setFocus(self.dynamicMarketTable)
    end
end

function DynamicMarketMenuFrame:onSearchChanged(element, text)
    self.searchText = tostring(text or "")
    self:applySearchFilter()
    if self.dynamicMarketTable ~= nil then
        self.dynamicMarketTable:reloadData()
    end
end

function DynamicMarketMenuFrame:onSearchEnterPressed(element)
    self:activateSearchInput()
end


function DynamicMarketMenuFrame:onClickStoredOnly(element)
    self.stockFilterState = (self.stockFilterState + 1) % 3
    if self.storedOnlyButton ~= nil then
        if self.stockFilterState == 1 then
            self.storedOnlyButton:setText(g_i18n:getText("dm_filter_stored_on"))
        elseif self.stockFilterState == 2 then
            self.storedOnlyButton:setText(g_i18n:getText("dm_filter_favorites_on"))
        else
            self.storedOnlyButton:setText(g_i18n:getText("dm_filter_stored_off"))
        end
    end
    self:applySearchFilter()
    if self.dynamicMarketTable ~= nil then
        self.dynamicMarketTable:reloadData()
    end
end

function DynamicMarketMenuFrame:getSortHeaderLabelKey(column)
    if column == "yearlyAverage" then
        if self:isYearlyAverageEnabled() then
            return "dm_header_yearlyaverage"
        end
        return "dm_header_baseprice"
    elseif column == "stockValue" then
        return "dm_header_difference"
    elseif column == "good" then
        return "dm_header_good"
    elseif column == "group" then
        return "dm_header_group"
    elseif column == "price" then
        return "dm_header_price"
    elseif column == "stock" then
        return "dm_header_stock"
    elseif column == "market" then
        return "dm_header_market"
    elseif column == "station" then
        return "dm_header_station"
    elseif column == "month" then
        return "dm_header_bestmonth"
    end
    return nil
end

function DynamicMarketMenuFrame:getSortHeaderElements()
    return {
        good = self.goodsHeader,
        group = self.groupHeader,
        price = self.priceHeader,
        stock = self.stockHeader,
        market = self.marketHeader,
        yearlyAverage = self.yearlyAverageHeader,
        stockValue = self.stockValueHeader,
        station = self.stationHeader,
        month = self.monthHeader
    }
end

function DynamicMarketMenuFrame:updateSortIcons()
    if g_i18n == nil then
        return
    end
    for column, element in pairs(self:getSortHeaderElements()) do
        if element ~= nil and element.setText ~= nil then
            local labelKey = self:getSortHeaderLabelKey(column)
            local label = labelKey ~= nil and g_i18n:getText(labelKey) or ""
            element:setText(label)
        end
    end
end

function DynamicMarketMenuFrame:getNumberOfSections()
    return 1
end

function DynamicMarketMenuFrame:getNumberOfItemsInSection(list, section)
    return #self.rows
end

function DynamicMarketMenuFrame:populateCellForItemInSection(list, section, index, cell)
    local row = self.rows[index]
    if row == nil then
        return
    end

    local icon = cell:getAttribute("icon")
    if icon ~= nil and row.hudOverlayFilename ~= nil then
        icon:setImageFilename(row.hudOverlayFilename)
    end

    local favoriteCell = cell:getAttribute("favorite")
    if favoriteCell ~= nil then
        local isFav = DynamicMarket ~= nil and DynamicMarket:isFavorite(row.name)
        favoriteCell:setText(isFav and "*" or "-")
        local r, g, b = 0.4, 0.4, 0.4
        if isFav then
            r, g, b = 1, 0.85, 0.15
        end
        if favoriteCell.setTextColor ~= nil then
            favoriteCell:setTextColor(r, g, b, 1)
        end
        if favoriteCell.setTextSelectedColor ~= nil then
            favoriteCell:setTextSelectedColor(r, g, b, 1)
        end
        if favoriteCell.setTextFocusedColor ~= nil then
            favoriteCell:setTextFocusedColor(r, g, b, 1)
        end
        if favoriteCell.setTextHighlightedColor ~= nil then
            favoriteCell:setTextHighlightedColor(r, g, b, 1)
        end
    end

    local goodCell = cell:getAttribute("good")
    if goodCell ~= nil then
        goodCell:setText(row.title or "")
    end

    local groupCell = cell:getAttribute("group")
    if groupCell ~= nil then
        groupCell:setText(row.groupTitle or "")
    end

    local marketCell = cell:getAttribute("market")
    if marketCell ~= nil then
        local direction = row.trendDirection or "stable"
        local r, g, b = 0.75, 0.75, 0.75
        if direction == "up" then
            r, g, b = 0.55, 0.82, 0.10
        elseif direction == "down" then
            r, g, b = 0.95, 0.10, 0.10
        end
        marketCell:setText(tostring(row.marketText or ""))
        if marketCell.setTextColor ~= nil then
            marketCell:setTextColor(r, g, b, 1)
        end
    end

    local stockCell = cell:getAttribute("stock")
    if stockCell ~= nil then
        stockCell:setText(dmFormatStock(row.stockLevel))
    end

    local priceCell = cell:getAttribute("price")
    if priceCell ~= nil then
        priceCell:setText(g_i18n:formatMoney((tonumber(row.bestPrice or row.currentBestPrice) or 0) * 1000, 0, true, true))
        if priceCell.setTextColor ~= nil then
            if row.stationPressureActive == true then
                priceCell:setTextColor(0.95, 0.10, 0.10, 1)
            else
                priceCell:setTextColor(1, 1, 1, 1)
            end
        end
    end

    local pressureCell = cell:getAttribute("pressure")
    if pressureCell ~= nil then
        local pressureAmount = tonumber(row.pressureAmount) or 0
        if row.pressureActive == true then
            pressureCell:setText(g_i18n:formatMoney(pressureAmount * 1000, 0, true, true))
            if pressureCell.setTextColor ~= nil then
                if row.pressureRecovering == true then
                    pressureCell:setTextColor(0.95, 0.65, 0.10, 1)
                else
                    pressureCell:setTextColor(0.95, 0.10, 0.10, 1)
                end
            end
        else
            pressureCell:setText("-")
            if pressureCell.setTextColor ~= nil then
                pressureCell:setTextColor(0.55, 0.55, 0.55, 1)
            end
        end
    end

    local yearlyAverage = cell:getAttribute("yearlyaverage")
    if yearlyAverage ~= nil then
        yearlyAverage:setText(g_i18n:formatMoney((tonumber(row.baseCurrentPrice) or 0) * 1000, 0, true, true))
    end
    local stationCell = cell:getAttribute("station")
    if stationCell ~= nil then
        stationCell:setText(row.bestStation or "")
    end


    local stockValueCell = cell:getAttribute("stockvalue")
    if stockValueCell ~= nil then
        local stockLevel = tonumber(row.stockLevel) or 0
        local totalValue = stockLevel * (tonumber(row.bestPrice or row.currentBestPrice) or 0)
        stockValueCell:setText(g_i18n:formatMoney(totalValue, 0, true, true))
        if stockValueCell.setTextColor ~= nil then
            if stockLevel > 0 then
                stockValueCell:setTextColor(1, 1, 1, 1)
            else
                stockValueCell:setTextColor(0.55, 0.55, 0.55, 1)
            end
        end
    end

    local monthCell = cell:getAttribute("month")
    if monthCell ~= nil then
        if self:isYearlyAverageEnabled() then
            monthCell:setText("")
            if monthCell.setVisible ~= nil then
                monthCell:setVisible(false)
            end
        else
            if monthCell.setVisible ~= nil then
                monthCell:setVisible(true)
            end
            monthCell:setText(dmMonthLabel(row.bestMonthNumber or row.bestMonth))
        end
    end
end

function DynamicMarketMenuFrame:onClickGoodsHeader(element)
    self:setSortColumn("good")
end

function DynamicMarketMenuFrame:onClickGroupHeader(element)
    self:setSortColumn("group")
end

function DynamicMarketMenuFrame:onClickMarketHeader(element)
    self:setSortColumn("market")
end

function DynamicMarketMenuFrame:onClickPriceHeader(element)
    self:setSortColumn("price")
end

function DynamicMarketMenuFrame:onClickPressureHeader(element)
    self:setSortColumn("pressure")
end

function DynamicMarketMenuFrame:onClickStockHeader(element)
    self:setSortColumn("stock")
end

function DynamicMarketMenuFrame:onClickFavoriteHeader(element)
    self:setSortColumn("favorite")
end

function DynamicMarketMenuFrame:updateActionButtonStates()
    local row = self.selectedRow

    if self.showStockButtonInfo ~= nil then
        self.showStockButtonInfo.disabled = row == nil
    end

    self.mapHotspot = nil
    if row ~= nil and DynamicMarket ~= nil and DynamicMarket.getStationMapHotspot ~= nil then
        self.mapHotspot = DynamicMarket:getStationMapHotspot(row.bestStationObject)
    end
    if self.mapHotspotButtonInfo ~= nil then
        self.mapHotspotButtonInfo.disabled = self.mapHotspot == nil
        if self.mapHotspot ~= nil and g_currentMission ~= nil and self.mapHotspot == g_currentMission.currentMapTargetHotspot then
            self.mapHotspotButtonInfo.text = self.i18n:getText("dm_action_hide_from_map")
        else
            self.mapHotspotButtonInfo.text = self.i18n:getText("dm_action_show_on_map")
        end
    end

    if self.toggleFavoriteButtonInfo ~= nil then
        self.toggleFavoriteButtonInfo.disabled = row == nil
        if row ~= nil and DynamicMarket ~= nil and DynamicMarket:isFavorite(row.name) then
            self.toggleFavoriteButtonInfo.text = self.i18n:getText("dm_action_remove_favorite")
        else
            self.toggleFavoriteButtonInfo.text = self.i18n:getText("dm_action_add_favorite")
        end
    end

    self:setMenuButtonInfoDirty()
end

function DynamicMarketMenuFrame:onListSelectionChanged(list, section, index)
    self.selectedRow = self.rows[index]
    self:updateActionButtonStates()
end

function DynamicMarketMenuFrame:onClickMapHotspot()
    local hotspot = self.mapHotspot
    if hotspot == nil or g_currentMission == nil then
        return
    end

    if hotspot == g_currentMission.currentMapTargetHotspot then
        g_currentMission:setMapTargetHotspot()
    else
        g_currentMission:setMapTargetHotspot(hotspot)
    end

    self:updateActionButtonStates()
end

function DynamicMarketMenuFrame:onClickToggleFavorite()
    local row = self.selectedRow
    if row == nil or DynamicMarket == nil then
        return
    end

    DynamicMarket:setFavorite(row.name, not DynamicMarket:isFavorite(row.name))
    self:updateActionButtonStates()
    if self.dynamicMarketTable ~= nil then
        self.dynamicMarketTable:reloadData()
    end
end

function DynamicMarketMenuFrame:showStockLocations()
    local row = self.selectedRow
    if row == nil then
        return
    end

    if g_gui == nil or g_gui.showDialog == nil then
        return
    end

    local dialog = g_gui:showDialog("DynamicMarketStockLocationDialog")
    if dialog ~= nil and dialog.target ~= nil and dialog.target.setStockData ~= nil then
        dialog.target:setStockData(tostring(row.title or ""), row.stockLocations)
    end
end

function DynamicMarketMenuFrame:onClickYearlyAverageHeader(element)
    if self:isYearlyAverageEnabled() then
        self:setSortColumn("yearlyAverage")
    end
end

function DynamicMarketMenuFrame:onClickStationHeader(element)
    self:setSortColumn("station")
end

function DynamicMarketMenuFrame:onClickStockValueHeader(element)
    self:setSortColumn("stockValue")
end

function DynamicMarketMenuFrame:onClickMonthHeader(element)
    if not self:isYearlyAverageEnabled() then
        self:setSortColumn("month")
    end
end
