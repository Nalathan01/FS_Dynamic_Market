DynamicMarket = {}

DynamicMarket.MOD_NAME = g_currentModName or "FS25_DynamicMarket"
DynamicMarket.MOD_DIR = g_currentModDirectory or ""
DynamicMarket.LOG_PREFIX = "[DynamicMarket]"
DynamicMarket.VERSION = "1.2.0.0"

DynamicMarket.APPLY_CURVES = true

DynamicMarket.CHANGE_EXISTING_CURVES = true

DynamicMarket.PLAYER_MARKET_NOTICES = true

DynamicMarket.INCLUDE_PRODUCTION_STOCK = true

DynamicMarket.ENABLE_YEARLY_AVERAGE = true
DynamicMarket.USE_YEARLY_AVERAGE_AS_BASE_PRICE = true
DynamicMarket.YEARLY_AVERAGE_FLAT_BASEGAME_GRAPH = true
DynamicMarket.PRICE_BASE_NORMAL = 1
DynamicMarket.PRICE_BASE_YEAR_AVERAGE = 2
DynamicMarket.priceBaseMode = DynamicMarket.PRICE_BASE_YEAR_AVERAGE

DynamicMarket.DAILY_RECALC_DISABLED = 1
DynamicMarket.DAILY_RECALC_ENABLED = 2
DynamicMarket.dailyRecalcMode = DynamicMarket.DAILY_RECALC_DISABLED

DynamicMarket.MARKET_NOTICE_MIN_MOVEMENT = 0.015
DynamicMarket.STOCK_PRICE_ALERT_MIN_MOVEMENT = 0.05

DynamicMarket.STATION_PRESSURE_ENABLED = true
DynamicMarket.STATION_PRESSURE_THRESHOLD_LITERS = 25000
DynamicMarket.STATION_PRESSURE_PERCENT_PER_STEP = 2
DynamicMarket.STATION_PRESSURE_MAX_PERCENT = 15
DynamicMarket.STATION_PRESSURE_DECAY_PERCENT_PER_HOUR = 15
DynamicMarket.__stationPressure = {}
DynamicMarket.__pendingStationPressureRestore = {}
DynamicMarket.STATION_SALE_POLL_INTERVAL_MS = 1000
DynamicMarket.__stationSalePollMs = 0
DynamicMarket.__stationPressureDecayMs = 0
DynamicMarket.__lastReceivedByStationFillType = {}

DynamicMarket.FILLTYPE_GROUP_OVERRIDES = {
}

DynamicMarket.PERIOD_CHECK_INTERVAL_MS = 5000
DynamicMarket.RECHECK_SALES_ON_STATION_COUNT_CHANGE = true
DynamicMarket.APPLY_MONTHLY_MARKET_TO_SALES = true
DynamicMarket.MIN_PRICE_PER_LITER = 0.000001
DynamicMarket.STABLE_DELAY_MS = 500
DynamicMarket.MIN_APPLY_DELAY_MS = 1000
DynamicMarket.EXISTING_CURVE_WEIGHT = 0.25
DynamicMarket.GROUP_CURVE_WEIGHT = 0.75

DynamicMarket.DIAGNOSTICS = {
    debugLog = false,
    everyFillType = false,
    changedNames = false,
    market = false,
    unsafeNames = false,
    skippedDetails = false,
    saleMarket = false,
    finalStatus = false,
    saleMarketNames = false,
    marketModel = false,
    maxSkippedDetailNames = 80,
    maxSaleMarketNames = 0,
    maxChangedNames = 80,
    maxUnsafeNames = 120
}

DynamicMarket.PERIODS = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12}

source(DynamicMarket.MOD_DIR .. "scripts/DynamicMarketMenuFrame.lua")
source(DynamicMarket.MOD_DIR .. "scripts/DynamicMarketStockLocationDialog.lua")
source(DynamicMarket.MOD_DIR .. "scripts/DynamicMarketSettings.lua")

DynamicMarket.CURVES = {
    cropFarming =     {1.14, 1.10, 1.05, 1.00, 0.95, 0.91, 0.88, 0.91, 0.97, 1.04, 1.10, 1.13},
    forage =          {1.12, 1.06, 1.00, 0.94, 0.88, 0.82, 0.80, 0.86, 0.96, 1.05, 1.11, 1.13},
    animalProduct =   {1.08, 1.05, 1.02, 0.99, 0.96, 0.94, 0.94, 0.97, 1.01, 1.04, 1.07, 1.08},
    livestock =       {1.12, 1.08, 1.04, 1.00, 0.96, 0.93, 0.92, 0.95, 1.00, 1.05, 1.09, 1.12},
    processedGoods =  {1.06, 1.04, 1.02, 1.00, 0.98, 0.96, 0.96, 0.98, 1.01, 1.03, 1.05, 1.06},
    buildingMaterial ={1.07, 1.05, 1.02, 1.00, 0.97, 0.95, 0.94, 0.97, 1.01, 1.04, 1.07, 1.08},
    mapOwn =          {1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00}
}

DynamicMarket.MARKET_GROUPS = {
    cropFarming =      {volatility = 0.18, weather = 0.25, supply = 0.30, demand = 0.45},
    forage =           {volatility = 0.17, weather = 0.40, supply = 0.25, demand = 0.35},
    animalProduct =    {volatility = 0.04, weather = 0.05, supply = 0.20, demand = 0.75},
    livestock =        {volatility = 0.07, weather = 0.10, supply = 0.35, demand = 0.55},
    processedGoods =   {volatility = 0.045, weather = 0.045, supply = 0.20, demand = 0.76},
    buildingMaterial = {volatility = 0.065, weather = 0.085, supply = 0.20, demand = 0.72},
    mapOwn =           {volatility = 0.045, weather = 0.045, supply = 0.20, demand = 0.76}
}

DynamicMarket.__marketFactors = {}
DynamicMarket.__marketKey = nil
DynamicMarket.__lastSalesMarketKey = nil
DynamicMarket.__lastObservedMarketKey = nil
DynamicMarket.__periodCheckMs = 0
DynamicMarket.__lastSaleMarketReport = nil
DynamicMarket.__lastSellingStationCount = 0
DynamicMarket.__uiPriceRefreshToken = 0
DynamicMarket.__marketDriverReport = nil
DynamicMarket.__lastPlayerNoticeKey = nil
DynamicMarket.__lastStockAlertKey = nil
DynamicMarket.__hasShownLoadNotice = false
DynamicMarket.__hasShownLoadStockAlert = false


DynamicMarket.NOTICE_TEXTS = {
    en = {
        dm_notice_title = "Dynamic Market",
        dm_notice_stable = "Market groups remain stable.",
        dm_group_cropFarming = "crop farming",
        dm_group_forage = "forage crops",
        dm_group_animalProduct = "animal products",
        dm_group_livestock = "livestock",
        dm_group_processedGoods = "processed goods",
        dm_group_buildingMaterial = "building materials",
        dm_group_mapOwn = "map-specific"
    },
    de = {
        dm_notice_title = "Dynamischer Markt",
        dm_notice_stable = "Warengruppen bleiben stabil.",
        dm_group_cropFarming = "Ackerfrüchte",
        dm_group_forage = "Futterpflanzen",
        dm_group_animalProduct = "Tierprodukte",
        dm_group_livestock = "Nutztiere",
        dm_group_processedGoods = "verarbeitete Waren",
        dm_group_buildingMaterial = "Baustoffe & Holz",
        dm_group_mapOwn = "Kartenspezifisch"
    },
    fr = {
        dm_notice_title = "Marché Dynamique",
        dm_notice_stable = "Les groupes de produits restent stables.",
        dm_group_cropFarming = "cultures",
        dm_group_forage = "fourrages",
        dm_group_animalProduct = "produits animaux",
        dm_group_livestock = "bétail",
        dm_group_processedGoods = "produits transformés",
        dm_group_buildingMaterial = "matériaux de construction",
        dm_group_mapOwn = "spécifique à la carte"
    }
}

DynamicMarket.GROUPS = {
    cropFarming = {
        WHEAT = true, WINTERWHEAT = true, BARLEY = true, WINTERBARLEY = true, OAT = true,
        SORGHUM = true, RYE = true, TRITICALE = true, SPELT = true, RICE = true, RICELONGGRAIN = true,
        MAIZE = true, CORN = true,
        WHEAT_CUT = true, BARLEY_CUT = true, OAT_CUT = true, RYE_CUT = true, TRITICALE_CUT = true,
        SPELT_CUT = true,
        CANOLA = true, SUNFLOWER = true, SOYBEAN = true, OLIVE = true, LINSEED = true, FLAX = true,
        POPPY = true, SOYBEAN_CUT = true,
        POTATO = true, SUGARBEET = true, SUGARBEET_CUT = true, BEETROOT = true, CARROT = true,
        PARSNIP = true, ONION = true, TURNIP = true, SUGARCANE = true,
        GREENBEAN = true, PEA = true, SPINACH = true, GRAPE = true, LETTUCE = true, TOMATO = true,
        STRAWBERRY = true, APPLE = true, CABBAGE = true, CUCUMBER = true, PUMPKIN = true,
        CHILLI = true, GARLIC = true, ENOKI = true, OYSTER = true, MUSTARD = true, SPRING_ONION = true,
        COTTON = true, ROUNDBALE_COTTON = true, SQUAREBALE_COTTON = true
    },
    forage = {
        GRASS = true, GRASS_WINDROW = true, DRYGRASS = true, DRYGRASS_WINDROW = true, HAY = true,
        STRAW = true, FORAGE = true, CHAFF = true, SILAGE = true, POPLAR = true,
        CLOVER = true, CLOVER_WINDROW = true, DRYCLOVER = true, DRYCLOVER_WINDROW = true,
        ALFALFA = true, ALFALFA_WINDROW = true, DRYALFALFA = true, DRYALFALFA_WINDROW = true,
        LUCERNE = true, FIELDGRASS = true, GREENRYE = true, VETCHRYE = true, SILAGEMAIZE = true,
        FORAGE_MIXING = true, CHICKENFOOD = true, GRAINGRIST = true, PROTEINGRIST = true,
        LUPROSIL = true, CCM = true, CCMRAW = true,
        ROUNDBALE = true, ROUNDBALE_DRYGRASS = true, ROUNDBALE_GRASS = true,
        SQUAREBALE = true, SQUAREBALE_DRYGRASS = true, SQUAREBALE_GRASS = true
    },
    animalProduct = {
        MILK = true, GOATMILK = true, BUFFALOMILK = true, EGG = true, WOOL = true, HONEY = true,
        MANURE = true, LIQUIDMANURE = true, DIGESTATE = true
    },
    livestock = {
        COW_ANGUS = true, COW_HIGHLAND_CATTLE = true, COW_HOLSTEIN = true, COW_LIMOUSIN = true,
        COW_SWISS_BROWN = true, PIG_BERKSHIRE = true, PIG_BLACK_PIED = true, PIG_LANDRACE = true,
        SHEEP_BLACK_WELSH = true, SHEEP_LANDRACE = true, SHEEP_STEINSCHAF = true, SHEEP_SWISS_MOUNTAIN = true
    },
    processedGoods = {
        FLOUR = true, RICEFLOUR = true, BREAD = true, CAKE = true, BUTTER = true, CHEESE = true, GOATCHEESE = true,
        CHOCOLATE = true, SUGAR = true, CEREAL = true, SUNFLOWER_OIL = true, CANOLA_OIL = true,
        OLIVE_OIL = true, RICE_OIL = true, RAISINS = true, GRAPEJUICE = true, FABRIC = true,
        CLOTHES = true, PAPER = true, PAPERROLL = true, ROPE = true, PELLETS = true, COMPOST = true,
        COMPOSTRAW = true, COMPOST_BOXED = true, QUALITYCOMPOST = true, MOLASSES = true,
        BUFFALOMOZZARELLA = true, BUFFALOMILK_BOTTLED = true, GOATMILK_BOTTLED = true,
        MILK_BOTTLED = true, CARTONROLL = true,
        POTATOCHIPS = true, RICEROLLS = true, FERMENTEDNAPACABBAGE = true, NOODLESOUP = true,
        PRESERVEDCARROTS = true, PRESERVEDPARSNIP = true, PRESERVEDBEETROOT = true,
        SOUPCANSMIXED = true, SOUPCANSCARROTS = true, SOUPCANSPARSNIP = true, SOUPCANSBEETROOT = true,
        SOUPCANSPOTATO = true, CANNED_PEAS = true, JARRED_GREENBEAN = true, SPINACH_BAGS = true,
        RICE_BAGS = true, RICE_BOXES = true, BAGGED = true, BOXED = true, PALLET = true,
        BARREL = true, BUCKET = true, BATHTUB = true, EMPTYPALLET = true, EMPTYPALLETBOX = true,
        EMPTYBARREL = true, EMPTYBUCKET = true, EMPTYBOX = true, EMPTYPACKAGE = true
    },
    buildingMaterial = {
        CEMENT = true, CEMENTBRICKS = true, CONCRETE = true, STONE = true, GRAVEL = true, SAND = true,
        ROOFPLATES = true, PREFABWALL = true,
        WOOD = true, WOODCHIPS = true, PLANKS = true, FURNITURE = true, BOARDS = true, TIMBER = true,
        WOODBEAM = true, TREE = true, ROUNDBALE_WOOD = true, SQUAREBALE_WOOD = true
    },
    mapOwn = {}
}

DynamicMarket.GROUP_ORDER = {
    "cropFarming", "forage", "animalProduct", "livestock", "processedGoods", "buildingMaterial", "mapOwn"
}

DynamicMarket.PATTERN_GROUP_ORDER = {
    "processedGoods", "buildingMaterial"
}

DynamicMarket.EXCLUDED_EXACT = {
    UNKNOWN = true,
    DIESEL = true, DEF = true, ELECTRICCHARGE = true, METHANE = true, WATER = true, AIR = true,
    FERTILIZER = true, LIQUIDFERTILIZER = true, HERBICIDE = true, LIME = true, SEEDS = true,
    SILAGE_ADDITIVE = true, MINERAL_FEED = true, PIGFOOD = true, ROAD_SALT = true, SNOW = true,
    OILSEEDRADISH = true, FLOWERINGCATCHCROP = true, HUMUSACTIVE = true, MEADOW = true,
    BALE_NET = true, BALE_TWINE = true, BALE_WRAP = true
}

DynamicMarket.EXCLUDED_PATTERNS = {
    "FERTILIZER", "HERBICIDE", "ADDITIVE", "DIESEL", "FUEL", "METHANE", "ELECTRIC", "WATER",
    "SEED", "SAPLING", "CUTTER", "HEADER"
}

DynamicMarket.GROUP_PATTERNS = {
    processedGoods = {"EMPTY", "AUXILIARY", "CANNED", "CAN", "SOUP", "PRESERVED", "JARRED", "FERMENTED",
        "CHIPS", "ROLLS", "BAG", "BOX", "PACKED", "PACKAGE", "PALLET", "FLOUR", "BREAD", "CAKE",
        "BUTTER", "CHEESE", "OIL", "JUICE", "FABRIC", "CLOTHES", "PAPER", "PELLET", "COMPOST",
        "MOLASSES", "ROPE"},
    buildingMaterial = {"CEMENT", "CONCRETE", "BRICK", "ROOF", "GRAVEL", "SAND", "BATHTUB",
        "PLANK", "FURNITURE", "BOARD", "TIMBER"}
}

DynamicMarket.__lastFillTypeCount = -1
DynamicMarket.__stableMs = 0
DynamicMarket.__finalApplied = false
DynamicMarket.__loadMapSeen = false
DynamicMarket.__applyPass = 0
DynamicMarket.__runtimeMs = 0
DynamicMarket.__armedLogged = false
DynamicMarket.__favorites = {}

function DynamicMarket:formatCurve(curve)
    if curve == nil then
        return ""
    end

    local parts = {}
    for _, period in ipairs(self.PERIODS) do
        table.insert(parts, string.format("%.2f", tonumber(curve[period]) or 1))
    end

    return table.concat(parts, ",")
end

function DynamicMarket:getFillTypeName(fillType)
    if fillType == nil or type(fillType) ~= "table" then
        return "UNKNOWN"
    end

    return tostring(fillType.name or "UNKNOWN"):upper()
end

function DynamicMarket:isExcludedName(name)
    if self.EXCLUDED_EXACT[name] == true then
        return true
    end
    for _, pattern in ipairs(self.EXCLUDED_PATTERNS) do
        if string.find(name, pattern, 1, true) ~= nil then
            return true
        end
    end
    return false
end

function DynamicMarket:getGroup(fillType)
    local name = self:getFillTypeName(fillType)
    local overrideGroup = self.FILLTYPE_GROUP_OVERRIDES[name]

    if overrideGroup ~= nil and self.GROUPS[overrideGroup] ~= nil then
        return overrideGroup, "override"
    end

    local isExcluded = self:isExcludedName(name)

    if not isExcluded then
        for _, groupName in ipairs(self.GROUP_ORDER) do
            local names = self.GROUPS[groupName]
            if names ~= nil and names[name] == true then
                return groupName, "exact"
            end
        end

        for _, groupName in ipairs(self.PATTERN_GROUP_ORDER) do
            local patterns = self.GROUP_PATTERNS[groupName]
            if patterns ~= nil then
                for _, pattern in ipairs(patterns) do
                    if string.find(name, pattern, 1, true) ~= nil then
                        return groupName, "pattern:" .. pattern
                    end
                end
            end
        end
    end

    return "mapOwn", isExcluded and "mapOwnExcluded" or "mapOwnUnknown"
end

function DynamicMarket:getExistingCurve(fillType)
    if fillType == nil or type(fillType) ~= "table" then
        return nil
    end

    if type(fillType.economicCurve) == "table" then
        return fillType.economicCurve
    end

    if fillType.economy ~= nil and type(fillType.economy.factors) == "table" then
        return fillType.economy.factors
    end

    return nil
end

function DynamicMarket:hasMeaningfulCurve(fillType)
    local curve = self:getExistingCurve(fillType)
    if curve == nil then
        return false
    end

    for _, period in ipairs(self.PERIODS) do
        local value = tonumber(curve[period]) or 1
        if math.abs(value - 1) > 0.0001 then
            return true
        end
    end

    return false
end

function DynamicMarket:getSkipReason(fillType, groupName)
    if fillType == nil then
        return "nilFillType"
    end

    if type(fillType) ~= "table" then
        return "invalidFillTypeEntry"
    end

    local name = self:getFillTypeName(fillType)

    if name == "UNKNOWN" or name == "" then
        return "unknownName"
    end

    if fillType.pricePerLiter == nil or tonumber(fillType.pricePerLiter) == nil or tonumber(fillType.pricePerLiter) < self.MIN_PRICE_PER_LITER then
        return "noValidBasePrice"
    end

    if groupName == nil then
        return "noSafeCategory"
    end

    return nil
end

function DynamicMarket:copyCurve(curve)
    local copied = {}
    for _, period in ipairs(self.PERIODS) do
        copied[period] = tonumber(curve ~= nil and curve[period] or nil) or 1
    end
    return copied
end

function DynamicMarket:buildDynamicCurve(fillType, groupName)
    local groupCurve = self.CURVES[groupName]
    if groupCurve == nil then
        return nil
    end

    local existing = self:getExistingCurve(fillType)
    local useExisting = self:hasMeaningfulCurve(fillType)
    local curve = {}

    for _, period in ipairs(self.PERIODS) do
        local groupValue = tonumber(groupCurve[period]) or 1
        local existingValue = tonumber(existing ~= nil and existing[period] or nil) or 1

        if useExisting then
            curve[period] = (groupValue * self.GROUP_CURVE_WEIGHT) + (existingValue * self.EXISTING_CURVE_WEIGHT)
        else
            curve[period] = groupValue
        end
    end

    return curve
end

function DynamicMarket:cacheBaseGameEconomy(fillType)
    if fillType == nil or type(fillType) ~= "table" or fillType.dynamicMarketBaseGameEconomyCached == true then
        return
    end

    fillType.dynamicMarketBaseGameEconomyCached = true
    fillType.dynamicMarketBaseGameEconomicCurve = {}
    fillType.dynamicMarketBaseGameFactors = {}
    fillType.dynamicMarketBaseGameHistory = {}

    if type(fillType.economicCurve) == "table" then
        for _, period in ipairs(self.PERIODS) do
            fillType.dynamicMarketBaseGameEconomicCurve[period] = tonumber(fillType.economicCurve[period])
        end
    end

    if fillType.economy ~= nil then
        if type(fillType.economy.factors) == "table" then
            for _, period in ipairs(self.PERIODS) do
                fillType.dynamicMarketBaseGameFactors[period] = tonumber(fillType.economy.factors[period])
            end
        end
        if type(fillType.economy.history) == "table" then
            for _, period in ipairs(self.PERIODS) do
                fillType.dynamicMarketBaseGameHistory[period] = tonumber(fillType.economy.history[period])
            end
        end
    end
end

function DynamicMarket:applyCurve(fillType, curve)
    if fillType == nil or type(fillType) ~= "table" or curve == nil then
        return false
    end

    self:cacheBaseGameEconomy(fillType)

    fillType.economy = fillType.economy or {}
    fillType.economy.factors = fillType.economy.factors or {}
    fillType.economy.history = fillType.economy.history or {}

    for _, period in ipairs(self.PERIODS) do
        local factor = tonumber(curve[period]) or 1
        fillType.economy.factors[period] = factor
        fillType.economy.history[period] = factor * tonumber(fillType.pricePerLiter or 0)
    end

    fillType.dynamicMarketApplied = true
    fillType.dynamicMarketVersion = self.VERSION

    return true
end

function DynamicMarket:getFillTypes(manager)
    if manager ~= nil and manager.fillTypes ~= nil then
        return manager.fillTypes
    end

    if g_fillTypeManager ~= nil and g_fillTypeManager.fillTypes ~= nil then
        return g_fillTypeManager.fillTypes
    end

    return nil
end

function DynamicMarket:getFillTypeCount(manager)
    local fillTypes = self:getFillTypes(manager)
    if fillTypes == nil then
        return 0
    end

    local count = 0
    for _, _ in ipairs(fillTypes) do
        count = count + 1
    end

    return count
end


function DynamicMarket:getMissionPeriod()
    local mission = g_currentMission
    if mission ~= nil and mission.environment ~= nil then
        local period = mission.environment.currentPeriod or mission.environment.currentSeason or mission.environment.currentMonth
        if period ~= nil then
            period = tonumber(period)
            if period ~= nil then
                return math.max(1, math.min(12, period))
            end
        end
    end
    return 1
end

function DynamicMarket:getMissionYear()
    local mission = g_currentMission
    if mission ~= nil and mission.environment ~= nil then
        local year = mission.environment.currentYear or mission.environment.year or 1
        year = tonumber(year)
        if year ~= nil then
            return math.max(1, math.floor(year))
        end
    end
    return 1
end

function DynamicMarket:getMissionDayInPeriod()
    local mission = g_currentMission
    if mission ~= nil and mission.environment ~= nil then
        local day = mission.environment.currentDayInPeriod or mission.environment.currentDay
        if day ~= nil then
            day = tonumber(day)
            if day ~= nil then
                return math.max(1, math.floor(day))
            end
        end
    end
    return 1
end

function DynamicMarket:isDailyRecalculationEnabled()
    return self.dailyRecalcMode == self.DAILY_RECALC_ENABLED
end

function DynamicMarket:stableHash(text)
    local hash = 5381
    text = tostring(text or "")
    for i = 1, string.len(text) do
        hash = ((hash * 33) + string.byte(text, i)) % 1000000007
    end
    return hash
end

function DynamicMarket:noise01(seedText)
    local h = self:stableHash(seedText)
    return (h % 1000000) / 1000000
end

function DynamicMarket:noiseSigned(seedText)
    return (self:noise01(seedText) * 2) - 1
end

function DynamicMarket:getMarketKeyForPeriod(period, year, mapName, day)
    period = tonumber(period) or 1
    year = tonumber(year) or 1
    mapName = tostring(mapName or "unknownMap")
    local key = mapName .. ":" .. tostring(year) .. ":" .. tostring(period)
    if self:isDailyRecalculationEnabled() then
        key = key .. ":" .. tostring(tonumber(day) or 1)
    end
    return key
end

function DynamicMarket:getMarketKey()
    local period = self:getMissionPeriod()
    local year = self:getMissionYear()
    local day = self:getMissionDayInPeriod()
    local mapName = "unknownMap"
    if g_currentMission ~= nil and g_currentMission.missionInfo ~= nil then
        mapName = g_currentMission.missionInfo.mapId or g_currentMission.missionInfo.mapTitle or g_currentMission.missionInfo.mapName or mapName
    end
    mapName = tostring(mapName)
    return self:getMarketKeyForPeriod(period, year, mapName, day), period, year, mapName
end

function DynamicMarket:clampMarketFactor(value)
    value = tonumber(value) or 1
    if value < 0.75 then
        return 0.75
    elseif value > 1.25 then
        return 1.25
    end
    return value
end


function DynamicMarket:getSeasonalSupplyPressure(groupName, period)
    period = tonumber(period) or 1
    local profiles = {
        cropFarming = {[1]=-0.18, [2]=-0.14, [3]=-0.05, [4]=0.07, [5]=0.20, [6]=0.34, [7]=0.39, [8]=0.31, [9]=0.19, [10]=0.04, [11]=-0.07, [12]=-0.15},
        forage = {[1]=-0.22, [2]=-0.12, [3]=0.10, [4]=0.32, [5]=0.42, [6]=0.38, [7]=0.28, [8]=0.08, [9]=-0.04, [10]=-0.15, [11]=-0.28, [12]=-0.32},
        animalProduct = {[1]=0.00, [2]=0.00, [3]=0.00, [4]=0.05, [5]=0.05, [6]=0.05, [7]=0.00, [8]=0.00, [9]=-0.05, [10]=-0.05, [11]=0.00, [12]=0.00},
        livestock = {[1]=0.00, [2]=0.00, [3]=0.05, [4]=0.05, [5]=0.05, [6]=0.00, [7]=0.00, [8]=-0.05, [9]=-0.05, [10]=0.00, [11]=0.00, [12]=0.00},
        processedGoods = {[1]=-0.03, [2]=-0.03, [3]=-0.01, [4]=0.03, [5]=0.06, [6]=0.08, [7]=0.07, [8]=0.06, [9]=0.03, [10]=0.03, [11]=0.02, [12]=-0.03},
        buildingMaterial = {[1]=-0.04, [2]=-0.04, [3]=0.04, [4]=0.12, [5]=0.15, [6]=0.12, [7]=0.08, [8]=0.06, [9]=0.02, [10]=0.00, [11]=-0.04, [12]=-0.04}
    }
    local profile = profiles[groupName]
    if profile == nil then
        return 0
    end
    return tonumber(profile[period]) or 0
end

function DynamicMarket:buildMarketFactorForGroup(groupName, period, year, mapName)
    local cfg = self.MARKET_GROUPS[groupName]
    if cfg == nil then
        return 1, nil
    end

    period = tonumber(period) or 1
    year = tonumber(year) or 1
    mapName = tostring(mapName or "unknownMap")

    local key = self:getMarketKeyForPeriod(period, year, mapName, self:getMissionDayInPeriod())
    local volatility = tonumber(cfg.volatility) or 0.05
    local weather = self:noiseSigned(key .. ":weather:" .. groupName)
    local randomSupplyPressure = self:noiseSigned(key .. ":regionalSupply:" .. groupName)
    local seasonalSupplyPressure = self:getSeasonalSupplyPressure(groupName, period)
    local supplyPressure = (randomSupplyPressure * 0.65) + (seasonalSupplyPressure * 0.35)
    local demand = self:noiseSigned(key .. ":demand:" .. groupName)
    local supplyEffect = -supplyPressure
    local raw = ((weather * (cfg.weather or 0)) + (supplyEffect * (cfg.supply or 0)) + (demand * (cfg.demand or 0))) * volatility
    local factor = self:clampMarketFactor(1 + raw)

    return factor, {
        factor = factor,
        weather = weather,
        supply = supplyEffect,
        supplyPressure = supplyPressure,
        seasonalSupplyPressure = seasonalSupplyPressure,
        demand = demand,
        volatility = volatility
    }
end

function DynamicMarket:getEconomyPriceMultiplier()
    local mission = g_currentMission
    local manager = nil
    local difficulty = nil

    if mission ~= nil then
        manager = mission.economyManager
        if mission.missionInfo ~= nil then
            difficulty = tonumber(mission.missionInfo.economicDifficulty)
        end
    end

    if difficulty == nil then
        difficulty = 2
    end

    if manager ~= nil and type(manager.PRICE_MULTIPLIER) == "table" then
        return tonumber(manager.PRICE_MULTIPLIER[difficulty]) or 1
    end

    if EconomyManager ~= nil and type(EconomyManager.PRICE_MULTIPLIER) == "table" then
        return tonumber(EconomyManager.PRICE_MULTIPLIER[difficulty]) or 1
    end

    return 1
end

function DynamicMarket:getBaseGameYearlyAverageRawPrice(fillType)
    if fillType == nil then
        return 0
    end

    self:cacheBaseGameEconomy(fillType)

    local sum = 0
    local count = 0
    if type(fillType.dynamicMarketBaseGameHistory) == "table" then
        for period = 1, 12 do
            local price = tonumber(fillType.dynamicMarketBaseGameHistory[period])
            if price ~= nil and price > 0 then
                sum = sum + price
                count = count + 1
            end
        end
    end

    local baseAverage = nil
    if count > 0 then
        baseAverage = sum / count
    else
        local basePrice = tonumber(fillType.pricePerLiter) or 0
        local yearlyFactor = self:getBaseGameYearlyOrientationFactor(fillType)
        baseAverage = basePrice * yearlyFactor
    end

    if baseAverage == nil or baseAverage <= 0 then
        return 0
    end

    return baseAverage
end

function DynamicMarket:getBaseGameYearlyAveragePrice(fillType, station, fillTypeIndex, baseCurrentPrice)
    local rawAverage = self:getBaseGameYearlyAverageRawPrice(fillType)
    if rawAverage == nil or rawAverage <= 0 then
        return 0
    end

    return rawAverage * self:getEconomyPriceMultiplier()
end

function DynamicMarket:getStationRawPriceBase(station, fillTypeIndex)
    if station == nil or type(station) ~= "table" or fillTypeIndex == nil then
        return nil
    end

    station.dynamicMarketOriginalRawPrices = station.dynamicMarketOriginalRawPrices or {}
    local cached = tonumber(station.dynamicMarketOriginalRawPrices[fillTypeIndex])
    if cached ~= nil and cached > 0 then
        return cached
    end

    local rawPrice = nil
    if station.fillTypePrices ~= nil then
        rawPrice = tonumber(station.fillTypePrices[fillTypeIndex])
    end
    if (rawPrice == nil or rawPrice <= 0) and station.originalFillTypePricesUnscaled ~= nil then
        rawPrice = tonumber(station.originalFillTypePricesUnscaled[fillTypeIndex])
    end
    if (rawPrice == nil or rawPrice <= 0) and station.originalFillTypePrices ~= nil then
        rawPrice = tonumber(station.originalFillTypePrices[fillTypeIndex])
    end

    if rawPrice ~= nil and rawPrice > 0 then
        station.dynamicMarketOriginalRawPrices[fillTypeIndex] = rawPrice
        return rawPrice
    end

    return nil
end

function DynamicMarket:getStationMapHotspot(station)
    if station == nil then
        return nil
    end

    if station.owningPlaceable ~= nil and station.owningPlaceable.spec_hotspots ~= nil and type(station.owningPlaceable.spec_hotspots.mapHotspots) == "table" then
        for _, mapHotSpot in ipairs(station.owningPlaceable.spec_hotspots.mapHotspots) do
            if mapHotSpot.worldX ~= nil and mapHotSpot.worldZ ~= nil then
                return mapHotSpot
            end
        end
    end

    if station.spec_sellingStation ~= nil and station.spec_sellingStation.spec_hotspots ~= nil and type(station.spec_sellingStation.spec_hotspots.mapHotspots) == "table" then
        for _, mapHotSpot in ipairs(station.spec_sellingStation.spec_hotspots.mapHotspots) do
            if mapHotSpot.worldX ~= nil and mapHotSpot.worldZ ~= nil then
                return mapHotSpot
            end
        end
    end

    return nil
end

function DynamicMarket:isValidSellingStationForFillType(station, fillTypeIndex)
    if station == nil or type(station) ~= "table" or fillTypeIndex == nil then
        return false
    end

    if SellingStation ~= nil and station.isa ~= nil and not station:isa(SellingStation) then
        return false
    end

    if station.hideFromPricesMenu == true then
        return false
    end

    if station.acceptedFillTypes ~= nil and station.acceptedFillTypes[fillTypeIndex] ~= true then
        return false
    end

    local mission = g_currentMission
    if mission ~= nil and mission.getFarmId ~= nil and station.ownerFarmId ~= nil and station.ownerFarmId == mission:getFarmId() then
        return false
    end

    return true
end

function DynamicMarket:prepareStationBasePriceCache(sellingStations)
    self.__bestStationRawPriceByFillType = {}
    self.__bestStationNameByFillType = {}
    self.__bestStationObjectByFillType = {}
    self.__stationCountByFillType = {}

    if sellingStations == nil or type(sellingStations) ~= "table" then
        return
    end

    for _, station in pairs(sellingStations) do
        if station ~= nil and type(station) == "table" and station.fillTypePrices ~= nil and type(station.fillTypePrices) == "table" then
            for key, _ in pairs(station.fillTypePrices) do
                if self:isValidSellingStationForFillType(station, key) then
                    local rawPrice = self:getStationRawPriceBase(station, key)
                    if rawPrice ~= nil and rawPrice > 0 then
                        self.__stationCountByFillType[key] = (tonumber(self.__stationCountByFillType[key]) or 0) + 1
                        local currentBest = tonumber(self.__bestStationRawPriceByFillType[key]) or 0
                        local stationName = ""
                        if station.getName ~= nil then
                            stationName = tostring(station:getName() or "")
                        end
                        local currentName = tostring(self.__bestStationNameByFillType[key] or "")
                        if rawPrice > currentBest or (rawPrice == currentBest and stationName ~= "" and (currentName == "" or stationName < currentName)) then
                            self.__bestStationRawPriceByFillType[key] = rawPrice
                            self.__bestStationNameByFillType[key] = stationName
                            self.__bestStationObjectByFillType[key] = station
                        end
                    end
                end
            end
        end
    end
end

function DynamicMarket:reapplyStationPrice(station, fillTypeIndex)
    if station == nil or fillTypeIndex == nil or station.fillTypePrices == nil then
        return
    end
    local fillType = self:getFillTypeByIndex(fillTypeIndex)
    if fillType == nil then
        return
    end
    local groupName = self:getGroup(fillType)
    if self:getSkipReason(fillType, groupName) ~= nil then
        return
    end

    local basePrice = tonumber(station.fillTypePrices[fillTypeIndex])
    local finalPrice, _, targetSkipReason = self:getTargetSalePrice(station, fillTypeIndex, fillType, basePrice)
    if finalPrice ~= nil and targetSkipReason == nil and self.APPLY_MONTHLY_MARKET_TO_SALES then
        self:writeTargetSalePrice(station, fillTypeIndex, finalPrice)
        self.__uiPriceRefreshToken = (tonumber(self.__uiPriceRefreshToken) or 0) + 1
    end
end

function DynamicMarket:registerStationSale(station, fillTypeIndex, litersSold)
    if self.STATION_PRESSURE_ENABLED ~= true or station == nil or fillTypeIndex == nil then
        return
    end
    litersSold = tonumber(litersSold) or 0
    if litersSold <= 0 then
        return
    end

    self:getStationRawPriceBase(station, fillTypeIndex)

    local threshold = tonumber(self.STATION_PRESSURE_THRESHOLD_LITERS) or 25000
    if threshold <= 0 then
        return
    end
    local percentPerStep = tonumber(self.STATION_PRESSURE_PERCENT_PER_STEP) or 2
    local maxPercent = tonumber(self.STATION_PRESSURE_MAX_PERCENT) or 15

    self.__stationPressure[station] = self.__stationPressure[station] or {}
    local byFillType = self.__stationPressure[station]
    local entry = byFillType[fillTypeIndex]
    if entry == nil then
        entry = {percent = 0, overflowLiters = 0, peakPercent = 0, recoveryMilestone = 0}
        byFillType[fillTypeIndex] = entry
    end

    local percentBefore = entry.percent
    entry.overflowLiters = entry.overflowLiters + litersSold
    while entry.overflowLiters >= threshold and entry.percent < maxPercent do
        entry.overflowLiters = entry.overflowLiters - threshold
        entry.percent = math.min(entry.percent + percentPerStep, maxPercent)
    end
    if entry.percent >= maxPercent then
        entry.overflowLiters = 0
    end

    if entry.percent ~= percentBefore then
        self:reapplyStationPrice(station, fillTypeIndex)
        entry.peakPercent = entry.percent
        entry.recoveryMilestone = 0
        self:showStationPressureNotice(station, fillTypeIndex, true, entry.percent)
        self:saveStationPressureEntry(station, fillTypeIndex)
    end
end

function DynamicMarket:resetAllStationPressure()
    if type(self.__stationPressure) ~= "table" then
        return
    end

    for station, byFillType in pairs(self.__stationPressure) do
        for fillTypeIndex, entry in pairs(byFillType) do
            if entry.percent ~= nil and entry.percent > 0 then
                local wasNotifiedPartially = tonumber(entry.peakPercent) ~= nil and entry.peakPercent > 0
                entry.percent = 0
                entry.overflowLiters = 0
                entry.peakPercent = 0
                entry.recoveryMilestone = 0
                if wasNotifiedPartially then
                    self:showStationPressureNotice(station, fillTypeIndex, false, 0)
                end
                self:reapplyStationPrice(station, fillTypeIndex)
            end
        end
    end

    self:saveStationPressureEntry(nil, nil)
end

function DynamicMarket:decayStationPressure(dt)
    if self.STATION_PRESSURE_ENABLED ~= true or type(self.__stationPressure) ~= "table" then
        return
    end

    self.__stationPressureDecayMs = (self.__stationPressureDecayMs or 0) + (tonumber(dt) or 0)
    if self.__stationPressureDecayMs < self.STATION_SALE_POLL_INTERVAL_MS then
        return
    end
    local elapsedMs = self.__stationPressureDecayMs
    self.__stationPressureDecayMs = 0

    local decayPerHour = tonumber(self.STATION_PRESSURE_DECAY_PERCENT_PER_HOUR) or 15
    if decayPerHour <= 0 then
        return
    end
    local elapsedHours = elapsedMs / 3600000
    if elapsedHours <= 0 then
        return
    end

    local threshold = tonumber(self.STATION_PRESSURE_THRESHOLD_LITERS) or 25000
    local stockLevels = self:getStockLevelsByFillType()

    for station, byFillType in pairs(self.__stationPressure) do
        for fillTypeIndex, entry in pairs(byFillType) do
            if entry.percent > 0 then
                local stockLevel = tonumber(stockLevels[fillTypeIndex]) or 0
                local effectiveDecayPerHour = decayPerHour / (1 + (stockLevel / threshold))
                local percentBefore = entry.percent
                entry.percent = math.max(entry.percent - effectiveDecayPerHour * elapsedHours, 0)

                if entry.percent ~= percentBefore then
                    self:reapplyStationPrice(station, fillTypeIndex)

                    if tonumber(entry.peakPercent) ~= nil and entry.peakPercent > 0 then
                        local recoveredFraction = 1 - (entry.percent / entry.peakPercent)
                        local milestone = math.floor(recoveredFraction * 4 + 0.0001)
                        if milestone > (tonumber(entry.recoveryMilestone) or 0) then
                            entry.recoveryMilestone = milestone
                            self:showStationPressureNotice(station, fillTypeIndex, false, entry.percent)
                        end
                    end

                    if entry.percent <= 0 then
                        entry.percent = 0
                        entry.overflowLiters = 0
                        entry.peakPercent = 0
                        entry.recoveryMilestone = 0
                    end

                    self:saveStationPressureEntry(station, fillTypeIndex)
                end
            end
        end
    end
end

function DynamicMarket:getStationUniqueId(station)
    if station == nil or station.owningPlaceable == nil then
        return nil
    end
    local placeable = station.owningPlaceable
    if placeable.getUniqueId == nil then
        return nil
    end
    local callOk, uniqueId = pcall(placeable.getUniqueId, placeable)
    if not callOk or uniqueId == nil or uniqueId == "" then
        return nil
    end
    return uniqueId
end

function DynamicMarket:getStationPressureSaveKey()
    return "gameSettings.dynamicMarket.stationPressure"
end

function DynamicMarket:saveStationPressureEntry(station, fillTypeIndex)
    if g_savegameXML == nil or setXMLString == nil or setXMLFloat == nil or setXMLInt == nil or removeXMLProperty == nil then
        return
    end
    if type(self.__stationPressure) ~= "table" then
        return
    end

    local basePath = self:getStationPressureSaveKey()
    removeXMLProperty(g_savegameXML, basePath)

    local index = 0
    for pressureStation, byFillType in pairs(self.__stationPressure) do
        local stationId = self:getStationUniqueId(pressureStation)
        if stationId ~= nil then
            for entryFillType, entry in pairs(byFillType) do
                if entry.percent ~= nil and entry.percent > 0 then
                    local entryPath = string.format("%s.entry(%d)", basePath, index)
                    setXMLString(g_savegameXML, entryPath .. "#stationId", stationId)
                    setXMLInt(g_savegameXML, entryPath .. "#fillType", entryFillType)
                    setXMLFloat(g_savegameXML, entryPath .. "#percent", entry.percent)
                    setXMLFloat(g_savegameXML, entryPath .. "#overflowLiters", entry.overflowLiters or 0)
                    setXMLFloat(g_savegameXML, entryPath .. "#peakPercent", entry.peakPercent or 0)
                    setXMLInt(g_savegameXML, entryPath .. "#recoveryMilestone", entry.recoveryMilestone or 0)
                    index = index + 1
                end
            end
        end
    end
end

function DynamicMarket:loadStationPressureFromSavegame()
    self.__pendingStationPressureRestore = {}

    if g_savegameXML == nil or hasXMLProperty == nil or getXMLString == nil or getXMLInt == nil or getXMLFloat == nil then
        return
    end

    local basePath = self:getStationPressureSaveKey()
    local i = 0
    while true do
        local entryPath = string.format("%s.entry(%d)", basePath, i)
        if not hasXMLProperty(g_savegameXML, entryPath) then
            break
        end

        local stationId = getXMLString(g_savegameXML, entryPath .. "#stationId")
        local fillTypeIndex = getXMLInt(g_savegameXML, entryPath .. "#fillType")
        local percent = getXMLFloat(g_savegameXML, entryPath .. "#percent")

        if stationId ~= nil and stationId ~= "" and fillTypeIndex ~= nil and percent ~= nil and percent > 0 then
            self.__pendingStationPressureRestore[stationId] = self.__pendingStationPressureRestore[stationId] or {}
            self.__pendingStationPressureRestore[stationId][fillTypeIndex] = {
                percent = percent,
                overflowLiters = Utils.getNoNil(getXMLFloat(g_savegameXML, entryPath .. "#overflowLiters"), 0),
                peakPercent = Utils.getNoNil(getXMLFloat(g_savegameXML, entryPath .. "#peakPercent"), percent),
                recoveryMilestone = Utils.getNoNil(getXMLInt(g_savegameXML, entryPath .. "#recoveryMilestone"), 0)
            }
        end

        i = i + 1
    end
end

function DynamicMarket:restoreStationPressureIfPending(station)
    if type(self.__pendingStationPressureRestore) ~= "table" or next(self.__pendingStationPressureRestore) == nil then
        return
    end

    local stationId = self:getStationUniqueId(station)
    if stationId == nil then
        return
    end

    local pendingByFillType = self.__pendingStationPressureRestore[stationId]
    if pendingByFillType == nil then
        return
    end

    self.__stationPressure[station] = self.__stationPressure[station] or {}
    for fillTypeIndex, pendingEntry in pairs(pendingByFillType) do
        self.__stationPressure[station][fillTypeIndex] = {
            percent = pendingEntry.percent,
            overflowLiters = pendingEntry.overflowLiters,
            peakPercent = pendingEntry.peakPercent,
            recoveryMilestone = pendingEntry.recoveryMilestone
        }
        self:reapplyStationPrice(station, fillTypeIndex)
    end

    self.__pendingStationPressureRestore[stationId] = nil
end

function DynamicMarket:isFavorite(fillTypeName)
    return self.__favorites[tostring(fillTypeName)] == true
end

function DynamicMarket:setFavorite(fillTypeName, isFavorite)
    local key = tostring(fillTypeName)
    if isFavorite == true then
        self.__favorites[key] = true
    else
        self.__favorites[key] = nil
    end
    self:saveFavorites()
end

function DynamicMarket:getFavoritesSaveKey()
    return "gameSettings.dynamicMarket.favorites"
end

function DynamicMarket:saveFavorites()
    if g_savegameXML == nil or setXMLString == nil or removeXMLProperty == nil then
        return
    end

    local basePath = self:getFavoritesSaveKey()
    removeXMLProperty(g_savegameXML, basePath)

    local index = 0
    for fillTypeName, isFavorite in pairs(self.__favorites) do
        if isFavorite == true then
            local entryPath = string.format("%s.entry(%d)", basePath, index)
            setXMLString(g_savegameXML, entryPath .. "#fillType", fillTypeName)
            index = index + 1
        end
    end
end

function DynamicMarket:loadFavoritesFromSavegame()
    self.__favorites = {}

    if g_savegameXML == nil or hasXMLProperty == nil or getXMLString == nil then
        return
    end

    local basePath = self:getFavoritesSaveKey()
    local i = 0
    while true do
        local entryPath = string.format("%s.entry(%d)", basePath, i)
        if not hasXMLProperty(g_savegameXML, entryPath) then
            break
        end

        local fillTypeName = getXMLString(g_savegameXML, entryPath .. "#fillType")
        if fillTypeName ~= nil and fillTypeName ~= "" then
            self.__favorites[fillTypeName] = true
        end

        i = i + 1
    end
end

function DynamicMarket:showStationPressureNotice(station, fillTypeIndex, isFalling, currentPercent)
    if self.PLAYER_MARKET_NOTICES ~= true then
        return
    end
    local mission = g_currentMission
    if mission == nil or mission.addIngameNotification == nil then
        return
    end

    local fillType = self:getFillTypeByIndex(fillTypeIndex)
    local goodName = tostring(fillType ~= nil and (fillType.title or fillType.name) or fillTypeIndex)
    local stationName = tostring(self:getPlaceableDisplayName(station ~= nil and station.owningPlaceable or nil))
    local percentValue = math.floor((tonumber(currentPercent) or 0) + 0.5)

    local currentPrice = nil
    if station ~= nil and station.getEffectiveFillTypePrice ~= nil then
        local callOk, result = pcall(station.getEffectiveFillTypePrice, station, fillTypeIndex)
        if callOk and type(result) == "number" and result > 0 then
            currentPrice = result
        end
    end
    if currentPrice == nil and station ~= nil and station.fillTypePrices ~= nil and station.fillTypePrices[fillTypeIndex] ~= nil then
        currentPrice = tonumber(station.fillTypePrices[fillTypeIndex])
        if currentPrice ~= nil then
            currentPrice = currentPrice * self:getEconomyPriceMultiplier()
        end
    end
    local priceText = ""
    if currentPrice ~= nil and g_i18n ~= nil and g_i18n.formatMoney ~= nil then
        priceText = g_i18n:formatMoney(currentPrice * 1000, 0, true, true)
    end

    local text
    if isFalling then
        text = string.format(self:getLocalizedText("dm_notice_station_pressure_falling", "%s bei %s: Preis auf %s gefallen (-%d%%)."), goodName, stationName, priceText, percentValue)
    elseif percentValue > 0 then
        text = string.format(self:getLocalizedText("dm_notice_station_pressure_recovering", "%s bei %s: Preis auf %s gestiegen (noch -%d%%)."), goodName, stationName, priceText, percentValue)
    else
        text = string.format(self:getLocalizedText("dm_notice_station_pressure_recovered", "%s bei %s: Preis wieder bei %s."), goodName, stationName, priceText)
    end

    local notificationType = 0
    if FSBaseMission ~= nil and FSBaseMission.INGAME_NOTIFICATION_OK ~= nil then
        notificationType = FSBaseMission.INGAME_NOTIFICATION_OK
    end
    mission:addIngameNotification(notificationType, text)
end

function DynamicMarket:isStationPressureRecovering(station, fillTypeIndex)
    if self.STATION_PRESSURE_ENABLED ~= true or type(self.__stationPressure) ~= "table" then
        return false
    end
    local byFillType = self.__stationPressure[station]
    if byFillType == nil then
        return false
    end
    local entry = byFillType[fillTypeIndex]
    if entry == nil or entry.percent == nil or entry.percent <= 0 then
        return false
    end
    local peak = tonumber(entry.peakPercent) or 0
    return peak > 0 and entry.percent < peak
end

function DynamicMarket:getStationPressureScale(station, fillTypeIndex)
    if self.STATION_PRESSURE_ENABLED ~= true or type(self.__stationPressure) ~= "table" then
        return 1
    end
    local byFillType = self.__stationPressure[station]
    if byFillType == nil then
        return 1
    end
    local entry = byFillType[fillTypeIndex]
    if entry == nil or entry.percent == nil or entry.percent <= 0 then
        return 1
    end
    return 1 - (entry.percent / 100)
end

function DynamicMarket:getStationNegativePriceScale(station, fillTypeIndex)
    if not self:isValidSellingStationForFillType(station, fillTypeIndex) then
        return 1
    end

    local stationCount = self.__stationCountByFillType ~= nil and tonumber(self.__stationCountByFillType[fillTypeIndex]) or 0
    if stationCount <= 1 then
        return 1
    end

    local rawPrice = self:getStationRawPriceBase(station, fillTypeIndex)
    local bestRawPrice = self.__bestStationRawPriceByFillType ~= nil and tonumber(self.__bestStationRawPriceByFillType[fillTypeIndex]) or nil

    if rawPrice == nil or rawPrice <= 0 or bestRawPrice == nil or bestRawPrice <= 0 then
        return 1
    end

    if rawPrice >= bestRawPrice then
        return 1
    end

    local scale = rawPrice / bestRawPrice
    if scale > 1 then
        scale = 1
    elseif scale < 0.01 then
        scale = 0.01
    end

    return scale
end

function DynamicMarket:getSaleBasePrice(station, fillTypeIndex, fillType, currentBasePrice)
    local basePrice = tonumber(currentBasePrice)

    if self.ENABLE_YEARLY_AVERAGE == true and self.USE_YEARLY_AVERAGE_AS_BASE_PRICE == true then
        local yearlyAverage = self:getBaseGameYearlyAveragePrice(fillType, station, fillTypeIndex, basePrice)
        if yearlyAverage ~= nil and yearlyAverage > 0 then
            return yearlyAverage
        end
    end

    local rawStationBase = self:getStationRawPriceBase(station, fillTypeIndex)
    if rawStationBase ~= nil and rawStationBase > 0 then
        return rawStationBase * self:getEconomyPriceMultiplier()
    end

    return basePrice
end

function DynamicMarket:getNeutralMarketPrice(fillType, fillTypeIndex, currentBasePrice, station)
    if fillType == nil then
        return nil, nil, nil
    end

    local groupName = self:getGroup(fillType)
    local skipReason = self:getSkipReason(fillType, groupName)
    if skipReason ~= nil then
        return nil, groupName, skipReason
    end

    local factor = self:getMarketFactor(groupName)
    local saleBasePrice = self:getSaleBasePrice(station, fillTypeIndex, fillType, currentBasePrice)
    if saleBasePrice == nil or factor == nil then
        return nil, groupName, "noNeutralPrice"
    end

    return saleBasePrice * factor, groupName, nil
end

function DynamicMarket:getTargetSalePrice(station, fillTypeIndex, fillType, currentBasePrice)
    local neutralPrice, groupName, skipReason = self:getNeutralMarketPrice(fillType, fillTypeIndex, currentBasePrice, station)
    if neutralPrice == nil or skipReason ~= nil then
        return nil, groupName, skipReason
    end

    local stationScale = self:getStationNegativePriceScale(station, fillTypeIndex)
    local pressureScale = self:getStationPressureScale(station, fillTypeIndex)
    return neutralPrice * stationScale * pressureScale, groupName, nil
end

function DynamicMarket:writeTargetSalePrice(station, fillTypeIndex, targetPrice)
    if station == nil or type(station) ~= "table" or targetPrice == nil then
        return false
    end

    local key = fillTypeIndex
    local effectiveTargetPrice = tonumber(targetPrice)
    if effectiveTargetPrice == nil or effectiveTargetPrice <= 0 then
        return false
    end

    local economyMultiplier = self:getEconomyPriceMultiplier()
    if economyMultiplier == nil or economyMultiplier <= 0 then
        economyMultiplier = 1
    end

    local rawStationPrice = effectiveTargetPrice / economyMultiplier

    if station.fillTypePrices ~= nil then
        station.fillTypePrices[key] = rawStationPrice
    end

    if station.originalFillTypePrices ~= nil then
        station.originalFillTypePrices[key] = rawStationPrice
    end

    if station.originalFillTypePricesUnscaled ~= nil then
        station.originalFillTypePricesUnscaled[key] = rawStationPrice
    end

    if station.priceMultipliers ~= nil then
        station.priceMultipliers[key] = 1
    end

    if station.fillTypePriceRandomDelta ~= nil then
        station.fillTypePriceRandomDelta[key] = 0
    end

    if station.pendingPriceDrop ~= nil then
        station.pendingPriceDrop[key] = 0
    end

    return true
end

function DynamicMarket:getBaseGameYearlyOrientationFactor(fillType)
    if fillType == nil or type(fillType) ~= "table" then
        return 1
    end

    self:cacheBaseGameEconomy(fillType)

    local sum = 0
    local count = 0
    for period = 1, 12 do
        local factor = tonumber(self:getBaseGameEconomyValueForPeriod(fillType, period))
        if factor ~= nil then
            sum = sum + factor
            count = count + 1
        end
    end

    if count <= 0 then
        return 1
    end

    return sum / count
end

function DynamicMarket:buildYearlyAverageCurve(fillType)
    local orientationFactor = self:getBaseGameYearlyOrientationFactor(fillType)
    local curve = {}
    for _, period in ipairs(self.PERIODS) do
        curve[period] = orientationFactor
    end
    return curve
end

function DynamicMarket:isMissingTranslation(text, key)
    if text == nil or text == "" then
        return true
    end
    if key ~= nil and text == key then
        return true
    end
    return string.find(tostring(text), "missing", 1, true) ~= nil
end

function DynamicMarket:buildRestoredBaseGameCurve(fillType)
    self:cacheBaseGameEconomy(fillType)

    local curve = {}
    for _, period in ipairs(self.PERIODS) do
        local factor = nil
        if type(fillType.dynamicMarketBaseGameFactors) == "table" then
            factor = tonumber(fillType.dynamicMarketBaseGameFactors[period])
        end
        if factor == nil and type(fillType.dynamicMarketBaseGameEconomicCurve) == "table" then
            factor = tonumber(fillType.dynamicMarketBaseGameEconomicCurve[period])
        end
        curve[period] = factor or 1
    end
    return curve
end

function DynamicMarket:buildMarketFactors(stats)
    local key, period, year, mapName = self:getMarketKey()
    if self.__marketKey == key and self.__marketFactors ~= nil then
        return self.__marketFactors, key, period, year, mapName
    end
    
    local factors = {}
    local marketParts = {}
    for groupName, _ in pairs(self.MARKET_GROUPS) do
        local factor, data = self:buildMarketFactorForGroup(groupName, period, year, mapName)
        factors[groupName] = data
        table.insert(marketParts, string.format("%s=%+.1f%%", groupName, (factor - 1) * 100))
    end
    table.sort(marketParts)
    self.__marketFactors = factors
    self.__marketKey = key

    local positiveGroups = {}
    local negativeGroups = {}
    
    for groupName, data in pairs(factors) do
        local value = tonumber(data.factor) or 1
        if value > 1.005 then
            table.insert(positiveGroups, {name = groupName, factor = value})
        elseif value < 0.995 then
            table.insert(negativeGroups, {name = groupName, factor = value})
        end
    end
    
    table.sort(positiveGroups, function(a, b) return a.factor > b.factor end)
    table.sort(negativeGroups, function(a, b) return a.factor < b.factor end)
    
    self.__marketDriverReport = {
        positiveGroups = positiveGroups,
        negativeGroups = negativeGroups,
        strongestPositiveName = #positiveGroups > 0 and positiveGroups[1].name or nil,
        strongestNegativeName = #negativeGroups > 0 and negativeGroups[1].name or nil,
        strongestPositiveFactor = #positiveGroups > 0 and positiveGroups[1].factor or 1,
        strongestNegativeFactor = #negativeGroups > 0 and negativeGroups[1].factor or 1
    }
    
    if self.DIAGNOSTICS.marketModel then
        Logging.info("%s marketModel version=%s type=regionalSupplyDemand seasonalSupply=yes storageRead=no yieldChange=no priceOnly=yes positiveCount=%d negativeCount=%d",
            self.LOG_PREFIX,
            self.VERSION,
            #positiveGroups,
            #negativeGroups
        )
    end
    
    if self.DIAGNOSTICS.market then
        Logging.info("%s market version=%s period=%d year=%d map=%s mode=stationPriceTables saleHook=priceTable model=regionalSupplyDemand factors=%s",
            self.LOG_PREFIX,
            self.VERSION,
            period,
            year,
            tostring(mapName),
            table.concat(marketParts, ",")
        )
    end
    
    return factors, key, period, year, mapName
end

function DynamicMarket:getMarketFactor(groupName)
    if groupName == nil then
        return 1
    end
    local factors = self.__marketFactors
    if factors == nil or factors[groupName] == nil then
        return 1
    end
    return tonumber(factors[groupName].factor) or 1
end


function DynamicMarket:getFillTypeByIndex(fillTypeIndex)
    local index = tonumber(fillTypeIndex)
    if index == nil then
        return nil
    end
    local fillTypes = self:getFillTypes(g_fillTypeManager)
    if fillTypes == nil then
        return nil
    end
    return fillTypes[index]
end

function DynamicMarket:addSellingStationCandidate(list, seen, station)
    if station == nil or type(station) ~= "table" then
        return
    end
    if station.fillTypePrices == nil or type(station.fillTypePrices) ~= "table" then
        return
    end

    local key = tostring(station)
    if seen[key] == true then
        return
    end

    seen[key] = true
    table.insert(list, station)
end

function DynamicMarket:getSellingStationsForPriceWrite()
    local stations = {}
    local seen = {}
    local mission = g_currentMission

    local economyManager = mission ~= nil and mission.economyManager or nil
    local economyStations = economyManager ~= nil and economyManager.sellingStations or nil
    if economyStations ~= nil and type(economyStations) == "table" then
        for _, entry in pairs(economyStations) do
            local station = type(entry) == "table" and entry.station or entry
            self:addSellingStationCandidate(stations, seen, station)
        end
    end

    local storageSystem = mission ~= nil and mission.storageSystem or nil
    if storageSystem ~= nil and storageSystem.getUnloadingStations ~= nil then
        local unloadingStations = storageSystem:getUnloadingStations()
        if unloadingStations ~= nil and type(unloadingStations) == "table" then
            for _, station in pairs(unloadingStations) do
                if station ~= nil and station.isa ~= nil and SellingStation ~= nil and station:isa(SellingStation) then
                    self:addSellingStationCandidate(stations, seen, station)
                end
            end
        end
    end

    return stations
end

function DynamicMarket:getSellingStationCount()
    return #self:getSellingStationsForPriceWrite()
end

function DynamicMarket:addUniqueName(list, seen, name, maxCount)
    if list == nil or seen == nil or name == nil then
        return
    end
    local key = tostring(name)
    if key == "" or seen[key] == true then
        return
    end
    seen[key] = true
    if #list < maxCount then
        table.insert(list, key)
    end
end

function DynamicMarket:applyMonthlyMarketToSellingStations(passName)
    local marketKey, period, year, mapName = self:getMarketKey()
    self:buildMarketFactors(nil)

    self.__lastSaleMarketReport = {
        passName = tostring(passName or "unknown"),
        enabled = self.APPLY_MONTHLY_MARKET_TO_SALES == true,
        period = tonumber(period) or 1,
        year = tonumber(year) or 1,
        stations = 0,
        adjusted = 0,
        uniqueFillTypes = 0,
        skipped = 0,
        minFactor = 1,
        maxFactor = 1,
        success = false,
        reason = "notApplied"
    }

    local sellingStations = self:getSellingStationsForPriceWrite()
    self:prepareStationBasePriceCache(sellingStations)

    if sellingStations == nil or type(sellingStations) ~= "table" or #sellingStations == 0 then
        self.__lastSaleMarketReport.reason = "noSellingStations"
        if self.DIAGNOSTICS.saleMarket then
            Logging.info("%s saleMarketApplied version=%s pass=%s mode=stationPriceTables enabled=%s stations=0 adjusted=0 skipped=0 reason=noSellingStations",
                self.LOG_PREFIX,
                self.VERSION,
                tostring(passName or "unknown"),
                tostring(self.APPLY_MONTHLY_MARKET_TO_SALES)
            )
        end
        return
    end

    local stationCount = 0
    local adjusted = 0
    local skipped = 0
    local groupCounts = {}
    local changedNames = {}
    local changedNameSeen = {}
    local uniqueAdjustedFillTypes = 0
    local minFactor = 999
    local maxFactor = -999

    for _, station in pairs(sellingStations) do
        if station ~= nil and type(station) == "table" and station.fillTypePrices ~= nil and type(station.fillTypePrices) == "table" then
            stationCount = stationCount + 1
            for key, price in pairs(station.fillTypePrices) do
                local fillType = self:getFillTypeByIndex(key)
                local groupName = self:getGroup(fillType)
                local skipReason = self:getSkipReason(fillType, groupName)
                local basePrice = tonumber(price)
                local finalPrice, targetGroupName, targetSkipReason = self:getTargetSalePrice(station, key, fillType, basePrice)
                if targetGroupName ~= nil then
                    groupName = targetGroupName
                end
                local factor = self:getMarketFactor(groupName)

                if fillType ~= nil and skipReason == nil and targetSkipReason == nil and basePrice ~= nil and finalPrice ~= nil and factor ~= nil then
                    if self.APPLY_MONTHLY_MARKET_TO_SALES then
                        self:writeTargetSalePrice(station, key, finalPrice)
                    end
                    adjusted = adjusted + 1
                    groupCounts[groupName] = (groupCounts[groupName] or 0) + 1
                    minFactor = math.min(minFactor, factor)
                    maxFactor = math.max(maxFactor, factor)
                    local fillTypeName = self:getFillTypeName(fillType)
                    if changedNameSeen[fillTypeName] ~= true then
                        uniqueAdjustedFillTypes = uniqueAdjustedFillTypes + 1
                    end
                    self:addUniqueName(changedNames, changedNameSeen, fillTypeName, self.DIAGNOSTICS.maxSaleMarketNames)
                else
                    skipped = skipped + 1
                end
            end
        end
    end

    if minFactor == 999 then
        minFactor = 1
    end
    if maxFactor == -999 then
        maxFactor = 1
    end

    self.__lastSaleMarketReport.stations = stationCount
    self.__lastSaleMarketReport.adjusted = adjusted
    self.__lastSaleMarketReport.uniqueFillTypes = uniqueAdjustedFillTypes
    self.__lastSaleMarketReport.skipped = skipped
    self.__lastSaleMarketReport.minFactor = minFactor
    self.__lastSaleMarketReport.maxFactor = maxFactor
    self.__lastSaleMarketReport.success = adjusted > 0
    self.__lastSaleMarketReport.reason = adjusted > 0 and "applied" or "noAdjustedPrices"
    self.__lastSellingStationCount = stationCount
    if adjusted > 0 then
        self.__uiPriceRefreshToken = (tonumber(self.__uiPriceRefreshToken) or 0) + 1
    end

    local previousMarketKey = self.__lastSalesMarketKey
    self.__lastSalesMarketKey = marketKey
    self.__lastObservedMarketKey = marketKey

    if previousMarketKey ~= nil and previousMarketKey ~= marketKey then
        self:resetAllStationPressure()
    end

    if self.DIAGNOSTICS.saleMarket then
        table.sort(changedNames)
        if self.DIAGNOSTICS.saleMarketNames then
            Logging.info("%s saleMarketApplied version=%s pass=%s mode=stationPriceTables enabled=%s period=%d year=%d stations=%d adjusted=%d uniqueFillTypes=%d skipped=%d factorRange=%s names=%s",
                self.LOG_PREFIX,
                self.VERSION,
                tostring(passName or "unknown"),
                tostring(self.APPLY_MONTHLY_MARKET_TO_SALES),
                tonumber(period) or 1,
                tonumber(year) or 1,
                stationCount,
                adjusted,
                uniqueAdjustedFillTypes,
                skipped,
                self:formatFactorRange(minFactor, maxFactor),
                self:formatLimitedList(changedNames, self.DIAGNOSTICS.maxSaleMarketNames)
            )
        else
            Logging.info("%s saleMarketApplied version=%s pass=%s mode=stationPriceTables enabled=%s period=%d year=%d stations=%d adjusted=%d uniqueFillTypes=%d skipped=%d factorRange=%s names=disabled",
                self.LOG_PREFIX,
                self.VERSION,
                tostring(passName or "unknown"),
                tostring(self.APPLY_MONTHLY_MARKET_TO_SALES),
                tonumber(period) or 1,
                tonumber(year) or 1,
                stationCount,
                adjusted,
                uniqueAdjustedFillTypes,
                skipped,
                self:formatFactorRange(minFactor, maxFactor)
            )
        end
    end
end


function DynamicMarket:formatSignedPercent(value)
    value = tonumber(value) or 1
    return string.format("%+.1f%%", (value - 1) * 100)
end

function DynamicMarket:formatFactorRange(minFactor, maxFactor)
    return string.format("%s to %s", self:formatSignedPercent(minFactor), self:formatSignedPercent(maxFactor))
end

function DynamicMarket:formatDriver(value)
    value = tonumber(value) or 0
    return string.format("%+.2f", value)
end

function DynamicMarket:formatMarketDriverShort(groupName, data)
    if data == nil then
        return tostring(groupName or "none") .. "=none"
    end
    return string.format("%s=%s", tostring(groupName or "unknown"), self:formatSignedPercent(data.factor or 1))
end

function DynamicMarket:formatMarketDriver(groupName, data)
    if data == nil then
        return tostring(groupName or "none") .. "=none"
    end

    return string.format("%s=%s(weather=%s,supply=%s,demand=%s,volatility=%.2f)",
        tostring(groupName or "none"),
        self:formatSignedPercent(data.factor),
        self:formatDriver(data.weather),
        self:formatDriver(data.supply),
        self:formatDriver(data.demand),
        tonumber(data.volatility) or 0
    )
end

function DynamicMarket:getGameLanguage()
    local lang = nil
    if type(g_languageShort) == "string" and g_languageShort ~= "" then
        lang = g_languageShort
    elseif g_i18n ~= nil then
        if type(g_i18n.languageShort) == "string" and g_i18n.languageShort ~= "" then
            lang = g_i18n.languageShort
        elseif type(g_i18n.currentLanguage) == "string" and g_i18n.currentLanguage ~= "" then
            lang = g_i18n.currentLanguage
        end
    end

    lang = string.lower(tostring(lang or "en"))
    return string.sub(lang, 1, 2)
end

function DynamicMarket:getLocalizedText(key, fallback)
    if key == nil then
        return tostring(fallback or "")
    end

    if g_i18n ~= nil and g_i18n.getText ~= nil then
        local text = g_i18n:getText(key)
        if not self:isMissingTranslation(text, key) then
            return text
        end
    end

    local lang = self:getGameLanguage()
    local texts = self.NOTICE_TEXTS or {}
    if texts[lang] ~= nil and texts[lang][key] ~= nil then
        return texts[lang][key]
    end
    if texts.en ~= nil and texts.en[key] ~= nil then
        return texts.en[key]
    end
    return tostring(fallback or key or "")
end

function DynamicMarket:getMarketGroupDisplayName(groupName)
    local fallbacks = {
        cropFarming = "Ackerfrüchte",
        forage = "Futterpflanzen",
        animalProduct = "Tierprodukte",
        livestock = "Nutztiere",
        processedGoods = "verarbeitete Waren",
        buildingMaterial = "Baustoffe & Holz",
        mapOwn = "Kartenspezifisch"
    }

    return self:getLocalizedText("dm_group_" .. tostring(groupName or "unknown"), fallbacks[groupName] or tostring(groupName or "Markt"))
end

function DynamicMarket:formatMarketPercent(factor)
    local diff = ((tonumber(factor) or 1) - 1) * 100
    if diff >= 0 then
        return string.format("+%.1f%%", diff)
    end
    return string.format("%.1f%%", diff)
end

function DynamicMarket:formatNoticeMovement(groupName, factor)
    factor = tonumber(factor) or 1
    local diff = factor - 1
    local absDiff = math.abs(diff)
    if absDiff < (tonumber(self.MARKET_NOTICE_MIN_MOVEMENT) or 0.015) then
        return nil
    end

    return string.format("%s %s", self:getMarketGroupDisplayName(groupName), self:formatMarketPercent(factor))
end

function DynamicMarket:getStockPriceAlerts()
    local alerts = {}
    local stockLevels = self:getStockLevelsByFillType()
    local threshold = tonumber(self.STOCK_PRICE_ALERT_MIN_MOVEMENT) or 0.05

    for fillTypeIndex, stockLevel in pairs(stockLevels) do
        if tonumber(stockLevel) ~= nil and stockLevel > 0 then
            local fillType = self:getFillTypeByIndex(fillTypeIndex)
            if fillType ~= nil then
                local groupName = self:getGroup(fillType)
                local factor = self:getMarketFactor(groupName)
                if factor - 1 >= threshold then
                    table.insert(alerts, {
                        title = tostring(fillType.title or fillType.name or fillTypeIndex),
                        factor = factor
                    })
                end
            end
        end
    end

    table.sort(alerts, function(a, b)
        return a.factor > b.factor
    end)

    return alerts
end

function DynamicMarket:showStockPriceAlert(passName)
    if self.PLAYER_MARKET_NOTICES ~= true or tostring(passName or "") ~= "periodUpdate" then
        return
    end

    local mission = g_currentMission
    if mission == nil or mission.getFarmId == nil then
        return
    end
    local farmId = mission:getFarmId()
    local spectatorFarmId = FarmManager ~= nil and FarmManager.SPECTATOR_FARM_ID or 0
    if farmId == nil or farmId == spectatorFarmId then
        return
    end

    local marketKey = self.__lastSalesMarketKey or self:getMarketKey()
    if marketKey == nil or marketKey == self.__lastStockAlertKey then
        return
    end
    self.__lastStockAlertKey = marketKey

    local alerts = self:getStockPriceAlerts()
    if #alerts == 0 then
        return
    end

    local parts = {}
    local maxItems = 4
    for i = 1, math.min(#alerts, maxItems) do
        local alert = alerts[i]
        table.insert(parts, string.format("%s %s", alert.title, self:formatMarketPercent(alert.factor)))
    end

    local title = self:getLocalizedText("dm_stock_alert_title", "Preisanstieg im Lager")
    local text = title .. ": " .. table.concat(parts, ", ")

    if mission.addIngameNotification ~= nil then
        local notificationType = 0
        if FSBaseMission ~= nil and FSBaseMission.INGAME_NOTIFICATION_OK ~= nil then
            notificationType = FSBaseMission.INGAME_NOTIFICATION_OK
        end
        mission:addIngameNotification(notificationType, text)
    end
end

function DynamicMarket:showLoadNoticesOnce()
    if self.__hasShownLoadNotice == true then
        return
    end
    self.__hasShownLoadNotice = true
    self:showMarketNotice("periodUpdate")
end

function DynamicMarket:pollStationSales(dt)
    if self.STATION_PRESSURE_ENABLED ~= true then
        return
    end
    self.__stationSalePollMs = (self.__stationSalePollMs or 0) + (tonumber(dt) or 0)
    if self.__stationSalePollMs < self.STATION_SALE_POLL_INTERVAL_MS then
        return
    end
    self.__stationSalePollMs = 0

    local mission = g_currentMission
    if mission == nil or mission.storageSystem == nil or mission.storageSystem.getUnloadingStations == nil then
        return
    end
    local stations = mission.storageSystem:getUnloadingStations()
    if stations == nil then
        return
    end

    for _, station in pairs(stations) do
        if station ~= nil and station.isa ~= nil and SellingStation ~= nil and station:isa(SellingStation)
            and station.getTotalReceived ~= nil and station.acceptedFillTypes ~= nil then

            self:restoreStationPressureIfPending(station)

            for fillTypeIndex, isAccepted in pairs(station.acceptedFillTypes) do
                if isAccepted == true then
                    local callOk, result = pcall(station.getTotalReceived, station, fillTypeIndex)
                    if callOk and type(result) == "number" then
                        self.__lastReceivedByStationFillType[station] = self.__lastReceivedByStationFillType[station] or {}
                        local byFillType = self.__lastReceivedByStationFillType[station]
                        local lastReceived = byFillType[fillTypeIndex]

                        if lastReceived == nil then
                            byFillType[fillTypeIndex] = result
                            self:getStationRawPriceBase(station, fillTypeIndex)
                        elseif result > lastReceived then
                            local delta = result - lastReceived
                            byFillType[fillTypeIndex] = result
                            self:registerStationSale(station, fillTypeIndex, delta)
                        elseif result < lastReceived then
                            byFillType[fillTypeIndex] = result
                        end
                    end
                end
            end
        end
    end
end

function DynamicMarket:showLoadStockAlertOnce()
    if self.__hasShownLoadStockAlert == true then
        return
    end
    self.__hasShownLoadStockAlert = true
    self:showStockPriceAlert("periodUpdate")
end

function DynamicMarket:showMarketNotice(passName)
    if self.PLAYER_MARKET_NOTICES ~= true or tostring(passName or "") ~= "periodUpdate" then
        return
    end

    local marketKey = self.__lastSalesMarketKey or self:getMarketKey()
    if marketKey == nil or marketKey == self.__lastPlayerNoticeKey then
        return
    end

    local report = self.__marketDriverReport or {}
    local parts = {}
    local upText = self:formatNoticeMovement(report.strongestPositiveName, report.strongestPositiveFactor)
    local downText = self:formatNoticeMovement(report.strongestNegativeName, report.strongestNegativeFactor)
    if upText ~= nil then
        table.insert(parts, upText)
    end
    if downText ~= nil and downText ~= upText then
        table.insert(parts, downText)
    end

    local title = self:getLocalizedText("dm_notice_title", "Dynamischer Markt")
    local message = nil
    if #parts > 0 then
        message = table.concat(parts, ", ")
    else
        message = self:getLocalizedText("dm_notice_stable", "Warengruppen bleiben stabil.")
    end

    local text = title .. ": " .. message
    local mission = g_currentMission
    if mission ~= nil and mission.addIngameNotification ~= nil then
        local notificationType = 0
        if FSBaseMission ~= nil and FSBaseMission.INGAME_NOTIFICATION_OK ~= nil then
            notificationType = FSBaseMission.INGAME_NOTIFICATION_OK
        end
        mission:addIngameNotification(notificationType, text)
        self.__lastPlayerNoticeKey = marketKey
    end
end

function DynamicMarket:addSkippedName(stats, reason, fillType)
    if stats == nil or reason == nil then
        return
    end

    stats.skippedDetails = stats.skippedDetails or {}
    stats.skippedDetails[reason] = stats.skippedDetails[reason] or {}
    table.insert(stats.skippedDetails[reason], self:getFillTypeName(fillType))
end

function DynamicMarket:reportSkippedDetails(passName, stats)
    if not self.DIAGNOSTICS.skippedDetails or stats == nil or stats.skippedDetails == nil then
        return
    end

    local trackedReasons = {"noValidBasePrice", "unknownName", "excludedUtilityOrInternal"}
    for _, reason in ipairs(trackedReasons) do
        local names = stats.skippedDetails[reason]
        if names ~= nil and #names > 0 then
            table.sort(names)
            local maxNames = math.min(#names, self.DIAGNOSTICS.maxSkippedDetailNames)
            local out = {}
            for i = 1, maxNames do
                table.insert(out, names[i])
            end
            local suffix = #names > maxNames and string.format(",...(+%d more)", #names - maxNames) or ""
            Logging.info("%s skippedNames version=%s pass=%s reason=%s count=%d names=%s%s",
                self.LOG_PREFIX,
                self.VERSION,
                tostring(passName or "unknown"),
                tostring(reason),
                #names,
                table.concat(out, ","),
                suffix
            )
        end
    end
end


function DynamicMarket:reportFillType(action, fillType, groupName, groupReason, skipReason, oldCurve, newCurve)
    if not self.DIAGNOSTICS.everyFillType then
        return
    end

    local validFillType = fillType ~= nil and type(fillType) == "table"
    local name = self:getFillTypeName(fillType)
    local index = tostring(validFillType and fillType.index or "nil")
    local price = tonumber(validFillType and fillType.pricePerLiter or nil)
    local priceText = price ~= nil and string.format("%.6f", price) or "nil"
    local show = tostring(validFillType and fillType.showOnPriceTable == true or false)
    local existing = self:hasMeaningfulCurve(fillType) and "yes" or "no"

    Logging.info("%s report action=%s name=%s index=%s pricePerLiter=%s showOnPriceTable=%s group=%s groupSource=%s hadOwnCurve=%s oldCurve=%s newCurve=%s reason=%s",
        self.LOG_PREFIX,
        tostring(action),
        name,
        index,
        priceText,
        show,
        tostring(groupName or "none"),
        tostring(groupReason or "none"),
        existing,
        self:formatCurve(oldCurve) ~= "" and self:formatCurve(oldCurve) or "none",
        self:formatCurve(newCurve) ~= "" and self:formatCurve(newCurve) or "none",
        tostring(skipReason or "none")
    )
end

function DynamicMarket:applyToFillType(fillType, passName, stats)
    stats.total = stats.total + 1

    local groupName, groupReason = self:getGroup(fillType)
    local skipReason = self:getSkipReason(fillType, groupName)
    local oldCurve = self:copyCurve(self:getExistingCurve(fillType))
    local hadOwnCurve = self:hasMeaningfulCurve(fillType)

    if skipReason ~= nil then
        stats.skipped = stats.skipped + 1
        stats.skipCounts[skipReason] = (stats.skipCounts[skipReason] or 0) + 1
        self:addSkippedName(stats, skipReason, fillType)
        if skipReason == "noSafeCategory" then
            table.insert(stats.noSafeCategoryNames, self:getFillTypeName(fillType))
        end
        self:reportFillType("skipped", fillType, groupName, groupReason, skipReason, oldCurve, nil)
        return
    end

    local newCurve = nil
    if self.ENABLE_YEARLY_AVERAGE == true and self.USE_YEARLY_AVERAGE_AS_BASE_PRICE == true and self.YEARLY_AVERAGE_FLAT_BASEGAME_GRAPH == true then
        newCurve = self:buildYearlyAverageCurve(fillType)
    else
        newCurve = self:buildRestoredBaseGameCurve(fillType)
    end

    if newCurve == nil then
        stats.skipped = stats.skipped + 1
        stats.skipCounts.applyFailed = (stats.skipCounts.applyFailed or 0) + 1
        self:reportFillType("skipped", fillType, groupName, groupReason, "applyFailed", oldCurve, nil)
        return
    end

    stats.eligible = stats.eligible + 1

    if self.APPLY_CURVES and self:applyCurve(fillType, newCurve) then
        stats.applied = stats.applied + 1
        stats.groupCounts[groupName] = (stats.groupCounts[groupName] or 0) + 1
        if hadOwnCurve then
            stats.adjustedExisting = stats.adjustedExisting + 1
        else
            stats.createdNew = stats.createdNew + 1
        end
        fillType.dynamicMarketGroup = groupName
        fillType.dynamicMarketFactor = self:getMarketFactor(groupName)
        stats.marketCounts[groupName] = (stats.marketCounts[groupName] or 0) + 1
        table.insert(stats.changedNames, self:getFillTypeName(fillType))
        self:reportFillType("applied", fillType, groupName, groupReason, nil, oldCurve, newCurve)
    else
        stats.skipped = stats.skipped + 1
        stats.skipCounts.reportOnly = (stats.skipCounts.reportOnly or 0) + 1
        self:reportFillType("skipped", fillType, groupName, groupReason, "reportOnly", oldCurve, newCurve)
    end
end

function DynamicMarket:formatCounts(counts)
    local parts = {}
    for name, count in pairs(counts) do
        table.insert(parts, string.format("%s=%d", name, count))
    end
    table.sort(parts)
    return #parts > 0 and table.concat(parts, ",") or "none"
end

function DynamicMarket:applyAll(manager, passName)
    local fillTypes = self:getFillTypes(manager)
    if fillTypes == nil then
        if self.DIAGNOSTICS.debugLog then
            Logging.info("%s summary version=%s pass=%s total=0 eligible=0 applied=0 skipped=0 reason=noFillTypeTable", self.LOG_PREFIX, self.VERSION, tostring(passName or "unknown"))
        end
        return
    end

    self.__applyPass = self.__applyPass + 1

    local stats = {
        total = 0,
        eligible = 0,
        applied = 0,
        skipped = 0,
        adjustedExisting = 0,
        createdNew = 0,
        groupCounts = {},
        marketCounts = {},
        skipCounts = {},
        changedNames = {},
        noSafeCategoryNames = {},
        skippedDetails = {}
    }

    self:buildMarketFactors(stats)

    for _, fillType in ipairs(fillTypes) do
        self:applyToFillType(fillType, passName, stats)
    end

    if self.DIAGNOSTICS.debugLog then
        Logging.info("%s summary version=%s pass=%s passIndex=%d total=%d eligible=%d applied=%d adjustedExisting=%d createdNew=%d skipped=%d",
            self.LOG_PREFIX,
            self.VERSION,
            tostring(passName or "unknown"),
            self.__applyPass,
            stats.total,
            stats.eligible,
            stats.applied,
            stats.adjustedExisting,
            stats.createdNew,
            stats.skipped
        )
    end

    if self.DIAGNOSTICS.market then
        Logging.info("%s marketAffected pass=%s groups=%s mode=stationPriceTables saleHook=priceTable", self.LOG_PREFIX, tostring(passName or "unknown"), self:formatCounts(stats.marketCounts))
    end


    if self.DIAGNOSTICS.unsafeNames and #stats.noSafeCategoryNames > 0 then
        table.sort(stats.noSafeCategoryNames)
        local maxUnsafeNames = math.min(#stats.noSafeCategoryNames, self.DIAGNOSTICS.maxUnsafeNames)
        local names = {}
        for i = 1, maxUnsafeNames do
            table.insert(names, stats.noSafeCategoryNames[i])
        end
        local suffix = #stats.noSafeCategoryNames > maxUnsafeNames and string.format(",...(+%d more)", #stats.noSafeCategoryNames - maxUnsafeNames) or ""
        Logging.info("%s noSafeCategoryNames pass=%s count=%d names=%s%s", self.LOG_PREFIX, tostring(passName or "unknown"), #stats.noSafeCategoryNames, table.concat(names, ","), suffix)
    end

    self:reportSkippedDetails(passName, stats)
    self:applyMonthlyMarketToSellingStations(passName)

    if self.DIAGNOSTICS.changedNames and #stats.changedNames > 0 then
        table.sort(stats.changedNames)
        local maxNames = math.min(#stats.changedNames, self.DIAGNOSTICS.maxChangedNames)
        local names = {}
        for i = 1, maxNames do
            table.insert(names, stats.changedNames[i])
        end
        local suffix = #stats.changedNames > maxNames and string.format(",...(+%d more)", #stats.changedNames - maxNames) or ""
        Logging.info("%s changedFillTypes pass=%s names=%s%s", self.LOG_PREFIX, tostring(passName or "unknown"), table.concat(names, ","), suffix)
    end

    self:reportFinalStatus(passName)
    self:reportMarketWatch(passName)
end

function DynamicMarket:ensurePricesReadyForUi(passName)
    if g_fillTypeManager == nil or self:getFillTypes(g_fillTypeManager) == nil then
        return false
    end

    if self:getSellingStationCount() <= 0 then
        return false
    end

    if self.__finalApplied ~= true or self.__lastSaleMarketReport == nil or self.__lastSaleMarketReport.success ~= true then
        self:applyAll(g_fillTypeManager, passName or "uiReady")
        if self.__lastSaleMarketReport ~= nil and self.__lastSaleMarketReport.success == true then
            self.__finalApplied = true
            self:showLoadNoticesOnce()
            self:showLoadStockAlertOnce()
            return true
        end
        return false
    end

    return true
end

function DynamicMarket:reportMarketWatch(passName)
    local marketKey, period, year, _ = self:getMarketKey()
    if self.DIAGNOSTICS.debugLog then
        Logging.info("%s marketWatch version=%s pass=%s status=armed period=%d year=%d stationCount=%d checkIntervalMs=%d",
            self.LOG_PREFIX,
            self.VERSION,
            tostring(passName or "unknown"),
            tonumber(period) or 1,
            tonumber(year) or 1,
            tonumber(self.__lastSellingStationCount) or 0,
            tonumber(self.PERIOD_CHECK_INTERVAL_MS) or 0
        )
    end
    self.__lastObservedMarketKey = marketKey
end

function DynamicMarket:reportNameCandidates()
end

function DynamicMarket:reportFinalStatus(passName)
    if not self.DIAGNOSTICS.finalStatus then
        return
    end

    local report = self.__lastSaleMarketReport or {}
    Logging.info("%s FINAL status version=%s pass=%s saleMarketApplied=%s period=%d year=%d stations=%d adjusted=%d uniqueFillTypes=%d skipped=%d factorRange=%s reason=%s stationWatch=on model=regionalSupplyDemand seasonalSupply=yes",
        self.LOG_PREFIX,
        self.VERSION,
        tostring(passName or report.passName or "unknown"),
        report.success == true and "yes" or "no",
        tonumber(report.period) or self:getMissionPeriod(),
        tonumber(report.year) or self:getMissionYear(),
        tonumber(report.stations) or 0,
        tonumber(report.adjusted) or 0,
        tonumber(report.uniqueFillTypes) or 0,
        tonumber(report.skipped) or 0,
        self:formatFactorRange(report.minFactor or 1, report.maxFactor or 1),
        tostring(report.reason or "unknown")
    )
end





function DynamicMarket:fixInGameMenuPage(frame, pageName, uvs, predicateFunc)
    local inGameMenu = nil
    if g_gui ~= nil and type(g_gui.screenControllers) == "table" and InGameMenu ~= nil then
        inGameMenu = g_gui.screenControllers[InGameMenu]
    end
    if inGameMenu == nil or inGameMenu.pagingElement == nil or frame == nil then
        return false
    end
    if inGameMenu[pageName] ~= nil then
        return true
    end

    if inGameMenu.controlIDs ~= nil then
        inGameMenu.controlIDs[pageName] = nil
    end

    inGameMenu[pageName] = frame
    inGameMenu.pagingElement:addElement(inGameMenu[pageName])
    inGameMenu:exposeControlsAsFields(pageName)
    inGameMenu.pagingElement:updateAbsolutePosition()
    inGameMenu.pagingElement:updatePageMapping()

    local actualPosition = #inGameMenu.pagingElement.elements
    for i = 1, #inGameMenu.pagingElement.elements do
        if inGameMenu.pagingElement.elements[i] == inGameMenu[pageName] then
            actualPosition = i
            break
        end
    end

    inGameMenu:registerPage(inGameMenu[pageName], actualPosition, predicateFunc or function() return true end)
    inGameMenu:addPageTab(inGameMenu[pageName], Utils.getFilename("images/menuIcon.dds", self.MOD_DIR), GuiUtils.getUVs(uvs or {0,0,1024,1024}))
    inGameMenu:rebuildTabList()
    return true
end

function DynamicMarket:registerMenuPage()
    if self.__dynamicMarketMenuRegistered == true then
        return
    end
    if g_gui == nil or InGameMenu == nil or DynamicMarketMenuFrame == nil then
        return
    end

    g_gui:loadProfiles(self.MOD_DIR .. "gui/dynamicMarketProfiles.xml")

    if DynamicMarketStockLocationDialog ~= nil then
        g_gui:loadGui(self.MOD_DIR .. "gui/DynamicMarketStockLocationDialog.xml", "DynamicMarketStockLocationDialog", DynamicMarketStockLocationDialog.new())
    end

    local frame = DynamicMarketMenuFrame.new(g_i18n)
    g_gui:loadGui(self.MOD_DIR .. "gui/DynamicMarketMenuFrame.xml", "DynamicMarketMenuFrame", frame, true)
    if self:fixInGameMenuPage(frame, "pageDynamicMarket", {0,0,1024,1024}, function() return true end) then
        if frame.initialize ~= nil then
            frame:initialize()
        end
        self.__dynamicMarketMenuRegistered = true
    end
end

function DynamicMarket:getBaseGameEconomyValueForPeriod(fillType, period)
    local month = tonumber(period) or 1
    if fillType == nil or type(fillType) ~= "table" then
        return 1
    end

    if type(fillType.dynamicMarketBaseGameEconomicCurve) == "table" and fillType.dynamicMarketBaseGameEconomicCurve[month] ~= nil then
        return tonumber(fillType.dynamicMarketBaseGameEconomicCurve[month]) or 1
    end

    if type(fillType.dynamicMarketBaseGameFactors) == "table" and fillType.dynamicMarketBaseGameFactors[month] ~= nil then
        return tonumber(fillType.dynamicMarketBaseGameFactors[month]) or 1
    end

    if type(fillType.dynamicMarketBaseGameHistory) == "table" and fillType.dynamicMarketBaseGameHistory[month] ~= nil then
        local historyValue = tonumber(fillType.dynamicMarketBaseGameHistory[month])
        local pricePerLiter = tonumber(fillType.pricePerLiter)
        if historyValue ~= nil and pricePerLiter ~= nil and pricePerLiter > 0 then
            return historyValue / pricePerLiter
        end
        if historyValue ~= nil then
            return historyValue
        end
    end

    if type(fillType.economicCurve) == "table" then
        return tonumber(fillType.economicCurve[month]) or 1
    end

    if fillType.economy ~= nil and type(fillType.economy.factors) == "table" then
        return tonumber(fillType.economy.factors[month]) or 1
    end

    return 1
end

function DynamicMarket:getBestMonthForFillType(fillType)
    local bestMonth = 1
    local bestValue = -math.huge
    if fillType == nil then
        return bestMonth
    end

    for period = 1, 12 do
        local factor = 1
        factor = tonumber(self:getBaseGameEconomyValueForPeriod(fillType, period)) or 1
        local periodPrice = (tonumber(fillType.pricePerLiter) or 0) * factor
        if periodPrice > bestValue then
            bestValue = periodPrice
            bestMonth = period
        end
    end
    return bestMonth
end

function DynamicMarket:getMarketTrendText(groupName)
    local factor = self:getMarketFactor(groupName)
    return self:formatMarketPercent(factor)
end

function DynamicMarket:getTrendDirection(groupName)
    local factor = self:getMarketFactor(groupName)
    if factor > 1.005 then
        return "up"
    elseif factor < 0.995 then
        return "down"
    end
    return "stable"
end


function DynamicMarket:getPlaceableDisplayName(placeable)
    if placeable == nil then
        return "?"
    end
    if placeable.getName ~= nil then
        local ok, name = pcall(placeable.getName, placeable)
        if ok and name ~= nil and tostring(name) ~= "" then
            return tostring(name)
        end
    end
    if placeable.configFileName ~= nil then
        local fileName = tostring(placeable.configFileName)
        local baseName = fileName:match("([^/\\]+)%.xml$")
        if baseName ~= nil then
            return baseName
        end
    end
    return "?"
end

function DynamicMarket:getPlaceableMapHotspot(placeable)
    if placeable == nil or placeable.spec_hotspots == nil or type(placeable.spec_hotspots.mapHotspots) ~= "table" then
        return nil
    end
    for _, mapHotSpot in ipairs(placeable.spec_hotspots.mapHotspots) do
        if mapHotSpot.worldX ~= nil and mapHotSpot.worldZ ~= nil then
            return mapHotSpot
        end
    end
    return nil
end

function DynamicMarket:addStockLevel(stockLevels, fillTypeIndex, fillLevel, locations, locationName, locationHotspot)
    fillTypeIndex = tonumber(fillTypeIndex)
    fillLevel = tonumber(fillLevel) or 0
    if fillTypeIndex ~= nil and fillLevel > 0 then
        stockLevels[fillTypeIndex] = (stockLevels[fillTypeIndex] or 0) + fillLevel
        if locations ~= nil then
            local byName = locations[fillTypeIndex]
            if byName == nil then
                byName = {}
                locations[fillTypeIndex] = byName
            end
            local name = locationName or "?"
            local entry = byName[name]
            if entry == nil then
                entry = {amount = 0, hotspot = locationHotspot}
                byName[name] = entry
            end
            entry.amount = entry.amount + fillLevel
            if entry.hotspot == nil then
                entry.hotspot = locationHotspot
            end
        end
    end
end

function DynamicMarket:addStorageFillLevels(stockLevels, storage, locations, locationName, locationHotspot, excludeGroupName)
    if storage == nil or type(storage.fillLevels) ~= "table" then
        return
    end
    local mission = g_currentMission
    local farmId = mission ~= nil and mission.getFarmId ~= nil and mission:getFarmId() or nil
    if storage.ownerFarmId ~= nil and farmId ~= nil and storage.ownerFarmId ~= farmId then
        return
    end
    local excludeSet = excludeGroupName ~= nil and self.GROUPS[excludeGroupName] or nil
    for fillTypeIndex, fillLevel in pairs(storage.fillLevels) do
        local skip = false
        if excludeSet ~= nil then
            local fillType = self:getFillTypeByIndex(fillTypeIndex)
            if fillType ~= nil and fillType.name ~= nil and excludeSet[fillType.name] == true then
                skip = true
            end
        end
        if not skip then
            self:addStockLevel(stockLevels, fillTypeIndex, fillLevel, locations, locationName, locationHotspot)
        end
    end
end

function DynamicMarket:buildStockLocationList(byName)
    local list = {}
    if type(byName) ~= "table" then
        return list
    end
    for name, entry in pairs(byName) do
        table.insert(list, {name = name, amount = entry.amount, hotspot = entry.hotspot})
    end
    table.sort(list, function(a, b)
        return a.amount > b.amount
    end)
    return list
end

function DynamicMarket:getStockLevelsByFillType(collectLocations)
    local stockLevels = {}
    local locations = collectLocations == true and {} or nil
    local mission = g_currentMission
    local farmId = mission ~= nil and mission.getFarmId ~= nil and mission:getFarmId() or nil

    if mission ~= nil and mission.placeableSystem ~= nil and type(mission.placeableSystem.placeables) == "table" then
        for _, placeable in ipairs(mission.placeableSystem.placeables) do
            local ownerFarmId = placeable.ownerFarmId
            local belongsToFarm = farmId == nil or ownerFarmId == nil or ownerFarmId == farmId or ownerFarmId == 0
            if belongsToFarm then
                local placeableName = locations ~= nil and self:getPlaceableDisplayName(placeable) or nil
                local placeableHotspot = locations ~= nil and self:getPlaceableMapHotspot(placeable) or nil

                if placeable.spec_silo ~= nil then
                    if type(placeable.spec_silo.storages) == "table" then
                        for _, storage in ipairs(placeable.spec_silo.storages) do
                            self:addStorageFillLevels(stockLevels, storage, locations, placeableName, placeableHotspot)
                        end
                    elseif placeable.spec_silo.loadingStation ~= nil and placeable.spec_silo.loadingStation.getAllFillLevels ~= nil and farmId ~= nil then
                        for fillTypeIndex, fillLevel in pairs(placeable.spec_silo.loadingStation:getAllFillLevels(farmId) or {}) do
                            self:addStockLevel(stockLevels, fillTypeIndex, fillLevel, locations, placeableName, placeableHotspot)
                        end
                    end
                end

                if placeable.spec_siloExtension ~= nil then
                    self:addStorageFillLevels(stockLevels, placeable.spec_siloExtension.storage, locations, placeableName, placeableHotspot)
                end

                if placeable.spec_husbandry ~= nil then
                    self:addStorageFillLevels(stockLevels, placeable.spec_husbandry.storage, locations, placeableName, placeableHotspot, "forage")
                end

                if placeable.spec_manureHeap ~= nil and placeable.spec_manureHeap.manureHeap ~= nil and type(placeable.spec_manureHeap.manureHeap.fillLevels) == "table" then
                    for fillTypeIndex, fillLevel in pairs(placeable.spec_manureHeap.manureHeap.fillLevels) do
                        self:addStockLevel(stockLevels, fillTypeIndex, fillLevel, locations, placeableName, placeableHotspot)
                    end
                end
            end
        end
    end

    if mission ~= nil and mission.vehicleSystem ~= nil and type(mission.vehicleSystem.vehicles) == "table" then
        for _, vehicle in pairs(mission.vehicleSystem.vehicles) do
            local isPallet = vehicle ~= nil and (vehicle.isPallet == true or vehicle.typeName == "globalTransportPallet" or vehicle.typeName == "globalTransportPalletLiquids")
            if vehicle ~= nil and not isPallet and vehicle.getFillUnitFillLevel ~= nil and vehicle.getFillUnitFillType ~= nil
                and vehicle.spec_dischargeable ~= nil and type(vehicle.spec_dischargeable.fillUnitDischargeNodeMapping) == "table" then
                local ownerFarmId = vehicle.getOwnerFarmId ~= nil and vehicle:getOwnerFarmId() or nil
                local belongsToFarm = farmId == nil or ownerFarmId == nil or ownerFarmId == farmId or ownerFarmId == 0
                if belongsToFarm then
                    local vehicleName = locations ~= nil and (vehicle.getFullName ~= nil and vehicle:getFullName() or "?") or nil
                    local vehicleHotspot = locations ~= nil and vehicle.getMapHotspot ~= nil and vehicle:getMapHotspot() or nil
                    for fillUnitIndex, _ in pairs(vehicle.spec_dischargeable.fillUnitDischargeNodeMapping) do
                        local fillLevel = vehicle:getFillUnitFillLevel(fillUnitIndex)
                        local fillTypeIndex = vehicle:getFillUnitFillType(fillUnitIndex)
                        self:addStockLevel(stockLevels, fillTypeIndex, fillLevel, locations, vehicleName, vehicleHotspot)
                    end
                end
            end
        end
    end

    if self.INCLUDE_PRODUCTION_STOCK == true and mission ~= nil and mission.productionChainManager ~= nil and type(mission.productionChainManager.productionPoints) == "table" then
        for _, productionPoint in ipairs(mission.productionChainManager.productionPoints) do
            local isMine = farmId == nil or productionPoint.getOwnerFarmId == nil or productionPoint:getOwnerFarmId() == farmId
            if isMine and productionPoint.storage ~= nil then
                local productionName = locations ~= nil and (tostring(productionPoint.name or "") ~= "" and tostring(productionPoint.name) or self:getPlaceableDisplayName(productionPoint.owningPlaceable)) or nil
                local productionHotspot = locations ~= nil and self:getPlaceableMapHotspot(productionPoint.owningPlaceable) or nil
                if type(productionPoint.outputFillTypeIdsArray) == "table" and productionPoint.storage.getFillLevel ~= nil then
                    for _, fillTypeIndex in ipairs(productionPoint.outputFillTypeIdsArray) do
                        local fillLevel = productionPoint.storage:getFillLevel(fillTypeIndex)
                        self:addStockLevel(stockLevels, fillTypeIndex, fillLevel, locations, productionName, productionHotspot)
                    end
                end
            end
        end
    end

    if mission ~= nil and mission.vehicleSystem ~= nil and type(mission.vehicleSystem.vehicles) == "table" then
        for _, vehicle in ipairs(mission.vehicleSystem.vehicles) do
            if (farmId == nil or vehicle.ownerFarmId == farmId) and vehicle.spec_fillUnit ~= nil and type(vehicle.spec_fillUnit.fillUnits) == "table" then
                if vehicle.isPallet == true or vehicle.typeName == "globalTransportPallet" or vehicle.typeName == "globalTransportPalletLiquids" then
                    local vehicleName = locations ~= nil and self:getPlaceableDisplayName(vehicle) or nil
                    local vehicleHotspot = locations ~= nil and vehicle.mapHotspot or nil
                    for _, fillUnit in ipairs(vehicle.spec_fillUnit.fillUnits) do
                        self:addStockLevel(stockLevels, fillUnit.fillType, fillUnit.fillLevel, locations, vehicleName, vehicleHotspot)
                    end
                end
            end
        end
    end

    if mission ~= nil and mission.itemSystem ~= nil and type(mission.itemSystem.itemsToSave) == "table" then
        local baleName = locations ~= nil and self:getLocalizedText("dm_location_bale", "Bale") or nil
        for _, item in pairs(mission.itemSystem.itemsToSave) do
            local bale = item.item
            if bale ~= nil and bale.isa ~= nil and Bale ~= nil and bale:isa(Bale) and (farmId == nil or bale.ownerFarmId == farmId) then
                self:addStockLevel(stockLevels, bale.fillType, bale.fillLevel, locations, baleName)
            end
        end
    end

    return stockLevels, locations
end

function DynamicMarket:buildMarketOverviewRows()
    self:buildMarketFactors(nil)

    local rowsByFillType = {}
    local stockLevelsByFillType, stockLocationsByFillType = self:getStockLevelsByFillType(true)
    local mission = g_currentMission
    local storageSystem = mission ~= nil and mission.storageSystem or nil
    if storageSystem == nil or storageSystem.getUnloadingStations == nil then
        return {}
    end

    local stations = storageSystem:getUnloadingStations()
    if stations == nil then
        return {}
    end

    for _, station in pairs(stations) do
        if station ~= nil and station.isa ~= nil and station:isa(SellingStation) and not station.hideFromPricesMenu and station.acceptedFillTypes ~= nil then
            for fillTypeIndex, isAccepted in pairs(station.acceptedFillTypes) do
                if isAccepted == true and station.ownerFarmId ~= mission:getFarmId() then
                    local fillType = self:getFillTypeByIndex(fillTypeIndex)
                    local groupName = self:getGroup(fillType)
                    local skipReason = self:getSkipReason(fillType, groupName)
                    if fillType ~= nil and skipReason == nil then
                        local price = 0
                        if station.fillTypePrices ~= nil and station.fillTypePrices[fillTypeIndex] ~= nil then
                            price = (tonumber(station.fillTypePrices[fillTypeIndex]) or 0) * self:getEconomyPriceMultiplier()
                        elseif station.getEffectiveFillTypePrice ~= nil then
                            price = tonumber(station:getEffectiveFillTypePrice(fillTypeIndex)) or 0
                        end

                        local row = rowsByFillType[fillTypeIndex]
                        if row == nil then
                            row = {
                                index = fillTypeIndex,
                                title = tostring(fillType.title or fillType.name or fillTypeIndex),
                                name = tostring(fillType.name or fillTypeIndex),
                                hudOverlayFilename = fillType.hudOverlayFilename,
                                groupName = groupName,
                                groupTitle = self:getMarketGroupDisplayName(groupName),
                                marketFactor = self:getMarketFactor(groupName),
                                marketText = self:getMarketTrendText(groupName),
                                trendDirection = self:getTrendDirection(groupName),
                                bestPrice = 0,
                                currentBestPrice = 0,
                                stationBestPrice = 0,
                                bestStation = "",
                                stationPressureActive = false,
                                pressureAmount = 0,
                                pressureActive = false,
                                pressureRecovering = false,
                                pressureStationObject = nil,
                                pressureStationScale = 1,
                                bestMonth = self:getBestMonthForFillType(fillType),
                                bestMonthNumber = 1,
                                baseCurrentPrice = 0,
                                yearlyAveragePrice = 0,
                                priceTrend = 0,
                                sellPointCount = 0,
                                stockLevel = tonumber(stockLevelsByFillType[fillTypeIndex]) or 0,
                                stockLocations = self:buildStockLocationList(stockLocationsByFillType and stockLocationsByFillType[fillTypeIndex])
                            }
                            row.bestMonthNumber = tonumber(row.bestMonth) or 1
                            rowsByFillType[fillTypeIndex] = row
                        end

                        row.sellPointCount = row.sellPointCount + 1

                        local candidatePressureScale = self:getStationPressureScale(station, fillTypeIndex)
                        if candidatePressureScale < row.pressureStationScale then
                            row.pressureStationScale = candidatePressureScale
                            row.pressureStationObject = station
                        end

                        local neutralPrice, _, _ = self:getNeutralMarketPrice(fillType, fillTypeIndex, price, station)
                        local yearlyAverage = self:getBaseGameYearlyAveragePrice(fillType, station, fillTypeIndex, price)
                        local marketFactor = tonumber(row.marketFactor) or 1
                        local saleBasePrice = self:getSaleBasePrice(station, fillTypeIndex, fillType, price)
                        if self.ENABLE_YEARLY_AVERAGE == true and self.USE_YEARLY_AVERAGE_AS_BASE_PRICE == true and yearlyAverage ~= nil and yearlyAverage > 0 and neutralPrice ~= nil and neutralPrice > 0 then
                            row.yearlyAveragePrice = yearlyAverage
                            row.baseCurrentPrice = yearlyAverage
                            row.bestPrice = neutralPrice
                            row.currentBestPrice = neutralPrice
                        elseif neutralPrice ~= nil and neutralPrice > row.currentBestPrice then
                            row.currentBestPrice = neutralPrice
                            if saleBasePrice ~= nil and saleBasePrice > 0 then
                                row.baseCurrentPrice = saleBasePrice
                            elseif marketFactor ~= 0 then
                                row.baseCurrentPrice = neutralPrice / marketFactor
                            else
                                row.baseCurrentPrice = neutralPrice
                            end
                            row.bestPrice = neutralPrice
                        end

                        local stationComparePrice = self.__bestStationRawPriceByFillType ~= nil and tonumber(self.__bestStationRawPriceByFillType[fillTypeIndex]) or nil
                        local stationName = self.__bestStationNameByFillType ~= nil and tostring(self.__bestStationNameByFillType[fillTypeIndex] or "") or ""
                        local stationObject = self.__bestStationObjectByFillType ~= nil and self.__bestStationObjectByFillType[fillTypeIndex] or nil

                        if stationComparePrice == nil or stationComparePrice <= 0 then
                            stationComparePrice = self:getStationRawPriceBase(station, fillTypeIndex) or price
                            if station.getName ~= nil then
                                stationName = tostring(station:getName() or "")
                            end
                            stationObject = station
                        end

                        if stationComparePrice > row.stationBestPrice or (stationComparePrice == row.stationBestPrice and stationName ~= "" and (row.bestStation == "" or stationName < row.bestStation)) then
                            row.stationBestPrice = stationComparePrice
                            row.bestStation = stationName
                            row.bestStationObject = stationObject
                            row.stationPressureActive = self:getStationPressureScale(stationObject, fillTypeIndex) < 1
                            if stationObject ~= nil and stationObject.getCurrentPricingTrend ~= nil then
                                row.priceTrend = stationObject:getCurrentPricingTrend(fillTypeIndex)
                            else
                                row.priceTrend = 0
                            end
                        end
                    end
                end
            end
        end
    end

    for fillTypeIndex, row in pairs(rowsByFillType) do
        if row.bestStationObject ~= nil then
            local bestStation = row.bestStationObject
            local effectivePrice = nil
            if bestStation.getEffectiveFillTypePrice ~= nil then
                local callOk, result = pcall(bestStation.getEffectiveFillTypePrice, bestStation, fillTypeIndex)
                if callOk and type(result) == "number" and result > 0 then
                    effectivePrice = result
                end
            end

            if effectivePrice ~= nil then
                row.bestPrice = effectivePrice
                row.currentBestPrice = effectivePrice

                local pressureScale = self:getStationPressureScale(bestStation, fillTypeIndex)
                local priceWithoutPressure = effectivePrice
                if pressureScale ~= nil and pressureScale > 0 then
                    priceWithoutPressure = effectivePrice / pressureScale
                end

                local marketFactor = tonumber(row.marketFactor) or 1
                if marketFactor ~= 0 then
                    row.baseCurrentPrice = priceWithoutPressure / marketFactor
                else
                    row.baseCurrentPrice = priceWithoutPressure
                end
            elseif bestStation.fillTypePrices ~= nil and bestStation.fillTypePrices[fillTypeIndex] ~= nil then
                local displayPrice = tonumber(bestStation.fillTypePrices[fillTypeIndex])
                if displayPrice ~= nil and displayPrice > 0 then
                    displayPrice = displayPrice * self:getEconomyPriceMultiplier()
                    row.bestPrice = displayPrice
                    row.currentBestPrice = displayPrice
                end
            end

            local pressureStation = row.pressureStationObject or bestStation
            local pressureStationEffectivePrice = pressureStation == bestStation and effectivePrice or nil
            if pressureStationEffectivePrice == nil and pressureStation.getEffectiveFillTypePrice ~= nil then
                local callOk, result = pcall(pressureStation.getEffectiveFillTypePrice, pressureStation, fillTypeIndex)
                if callOk and type(result) == "number" and result > 0 then
                    pressureStationEffectivePrice = result
                end
            end

            if pressureStationEffectivePrice ~= nil then
                local pressureScale = self:getStationPressureScale(pressureStation, fillTypeIndex)
                local pressureStationPriceWithoutPressure = pressureStationEffectivePrice
                if pressureScale ~= nil and pressureScale > 0 then
                    pressureStationPriceWithoutPressure = pressureStationEffectivePrice / pressureScale
                end

                row.pressureAmount = pressureStationEffectivePrice - pressureStationPriceWithoutPressure
                row.pressureActive = row.pressureAmount < -0.0001
                row.pressureRecovering = self:isStationPressureRecovering(pressureStation, fillTypeIndex)
            end
        end
    end

    local rows = {}
    for _, row in pairs(rowsByFillType) do
        table.insert(rows, row)
    end
    table.sort(rows, function(a, b)
        return string.lower(tostring(a.title or "")) < string.lower(tostring(b.title or ""))
    end)
    return rows
end

function DynamicMarket:getPriceBaseMode()
    local mode = tonumber(self.priceBaseMode) or self.PRICE_BASE_YEAR_AVERAGE
    if mode ~= self.PRICE_BASE_NORMAL and mode ~= self.PRICE_BASE_YEAR_AVERAGE then
        mode = self.PRICE_BASE_YEAR_AVERAGE
    end
    return mode
end

function DynamicMarket:getDailyRecalcMode()
    local mode = tonumber(self.dailyRecalcMode) or self.DAILY_RECALC_DISABLED
    if mode ~= self.DAILY_RECALC_DISABLED and mode ~= self.DAILY_RECALC_ENABLED then
        mode = self.DAILY_RECALC_DISABLED
    end
    return mode
end

function DynamicMarket:setDailyRecalcMode(mode, passName)
    mode = tonumber(mode) or self.DAILY_RECALC_DISABLED
    if mode ~= self.DAILY_RECALC_DISABLED and mode ~= self.DAILY_RECALC_ENABLED then
        mode = self.DAILY_RECALC_DISABLED
    end

    local changed = self.dailyRecalcMode ~= mode
    self.dailyRecalcMode = mode

    if changed then
        self.__finalApplied = false
        self.__stableMs = 0
        self.__armedLogged = false
        self.__periodCheckMs = 0
        self.__marketKey = nil
        self.__marketFactors = {}
        self.__lastSalesMarketKey = nil
        self.__lastObservedMarketKey = nil
        self.__lastSaleMarketReport = nil

        if g_fillTypeManager ~= nil and self:getSellingStationCount() > 0 then
            self:applyAll(g_fillTypeManager, passName or "dailyRecalcSetting")
            if self.__lastSaleMarketReport ~= nil and self.__lastSaleMarketReport.success == true then
                self.__finalApplied = true
            end
        end
    end
end

function DynamicMarket:setPriceBaseMode(mode, passName)
    mode = tonumber(mode) or self.PRICE_BASE_YEAR_AVERAGE
    if mode ~= self.PRICE_BASE_NORMAL and mode ~= self.PRICE_BASE_YEAR_AVERAGE then
        mode = self.PRICE_BASE_YEAR_AVERAGE
    end

    local changed = self.priceBaseMode ~= mode
    self.priceBaseMode = mode
    self.USE_YEARLY_AVERAGE_AS_BASE_PRICE = mode == self.PRICE_BASE_YEAR_AVERAGE

    if changed then
        self.__finalApplied = false
        self.__stableMs = 0
        self.__armedLogged = false
        self.__marketKey = nil
        self.__marketFactors = {}
        self.__lastSalesMarketKey = nil
        self.__lastObservedMarketKey = nil
        self.__lastSaleMarketReport = nil

        if g_fillTypeManager ~= nil and self:getSellingStationCount() > 0 then
            self:applyAll(g_fillTypeManager, passName or "priceBaseSetting")
            if self.__lastSaleMarketReport ~= nil and self.__lastSaleMarketReport.success == true then
                self.__finalApplied = true
            end
        end
    end
end

function DynamicMarket:loadMap(name)
    self.__loadMapSeen = true
    self.__finalApplied = false
    self.__stableMs = 0
    self.__runtimeMs = 0
    self.__armedLogged = false
    self.__lastFillTypeCount = self:getFillTypeCount(g_fillTypeManager)
    self.__marketKey = nil
    self.__marketFactors = {}
    self.__lastSalesMarketKey = nil
    self.__lastObservedMarketKey = nil
    self.__lastSaleMarketReport = nil
    self.__lastSellingStationCount = 0
    self.__periodCheckMs = 0
    self.__lastPlayerNoticeKey = nil
    self.__lastStockAlertKey = nil
    self.__hasShownLoadNotice = false
    self.__hasShownLoadStockAlert = false
    self.__stationPressure = {}
    self.__lastReceivedByStationFillType = {}
    self:loadStationPressureFromSavegame()
    self:loadFavoritesFromSavegame()
    if self.settings ~= nil then
        self.settings:install()
        self.settings:loadSettings()
        self.settings:applyToModule(false)
        if self.settings.initializeSettingsOption ~= nil then
            self.settings:initializeSettingsOption()
        end
    end
    self:registerMenuPage()
    if self.DIAGNOSTICS.debugLog then
        Logging.info("%s armed version=%s initialFillTypes=%d mode=stableFinal", self.LOG_PREFIX, self.VERSION, self.__lastFillTypeCount)
    end
end

function DynamicMarket:update(dt)
    local delta = tonumber(dt) or 0

    self:decayStationPressure(delta)
    self:pollStationSales(delta)

    if self.__finalApplied then
        self.__periodCheckMs = (self.__periodCheckMs or 0) + delta
        if self.__periodCheckMs >= self.PERIOD_CHECK_INTERVAL_MS then
            self.__periodCheckMs = 0
            local marketKey, period, year, mapName = self:getMarketKey()
            if marketKey ~= nil and marketKey ~= self.__lastSalesMarketKey then
                if self.DIAGNOSTICS.debugLog then
                    Logging.info("%s periodChange version=%s oldKey=%s newKey=%s period=%d year=%d map=%s action=recalculateSalesMarket",
                        self.LOG_PREFIX,
                        self.VERSION,
                        tostring(self.__lastSalesMarketKey or self.__lastObservedMarketKey or "none"),
                        tostring(marketKey),
                        tonumber(period) or 1,
                        tonumber(year) or 1,
                        tostring(mapName or "unknownMap")
                    )
                end
                self.__marketKey = nil
                self.__marketFactors = {}
                self:applyMonthlyMarketToSellingStations("periodUpdate")
                self:reportFinalStatus("periodUpdate")
                self:reportMarketWatch("periodUpdate")
                self:showMarketNotice("periodUpdate")
                self:showStockPriceAlert("periodUpdate")
            elseif self.RECHECK_SALES_ON_STATION_COUNT_CHANGE == true then
                local stationCount = self:getSellingStationCount()
                if stationCount > 0 and stationCount ~= (tonumber(self.__lastSellingStationCount) or 0) then
                    if self.DIAGNOSTICS.debugLog then
                        Logging.info("%s stationChange version=%s oldStations=%d newStations=%d period=%d year=%d action=recalculateSalesMarket",
                            self.LOG_PREFIX,
                            self.VERSION,
                            tonumber(self.__lastSellingStationCount) or 0,
                            stationCount,
                            tonumber(period) or 1,
                            tonumber(year) or 1
                        )
                    end
                    self:applyMonthlyMarketToSellingStations("stationUpdate")
                    self:reportFinalStatus("stationUpdate")
                    self:reportMarketWatch("stationUpdate")
                end
            end
        end
        return
    end

    self.__runtimeMs = self.__runtimeMs + delta

    if g_fillTypeManager == nil or self:getFillTypes(g_fillTypeManager) == nil then
        return
    end

    if not self.__loadMapSeen then
        self.__loadMapSeen = true
        self.__stableMs = 0
        self.__lastFillTypeCount = self:getFillTypeCount(g_fillTypeManager)
        self.__marketKey = nil
        self.__marketFactors = {}
        self.__lastSalesMarketKey = nil
        self.__lastObservedMarketKey = nil
        self.__lastSaleMarketReport = nil
        self.__lastSellingStationCount = 0
        self.__periodCheckMs = 0
            self.__lastPlayerNoticeKey = nil
            self.__lastStockAlertKey = nil
        if self.DIAGNOSTICS.debugLog then
            Logging.info("%s armedFallback version=%s initialFillTypes=%d mode=stableFinal", self.LOG_PREFIX, self.VERSION, self.__lastFillTypeCount)
        end
        return
    end

    local currentCount = self:getFillTypeCount(g_fillTypeManager)
    local stationCount = self:getSellingStationCount()
    if currentCount ~= self.__lastFillTypeCount or stationCount <= 0 then
        self.__lastFillTypeCount = currentCount
        self.__stableMs = 0
        self.__armedLogged = false
        return
    end

    self.__stableMs = self.__stableMs + delta

    if not self.__armedLogged and currentCount > 0 and stationCount > 0 and self.__runtimeMs >= self.MIN_APPLY_DELAY_MS then
        self.__armedLogged = true
        if self.DIAGNOSTICS.debugLog then
            Logging.info("%s waitingReady version=%s fillTypes=%d stations=%d stableMs=%d requiredMs=%d", self.LOG_PREFIX, self.VERSION, currentCount, stationCount, self.__stableMs, self.STABLE_DELAY_MS)
        end
    end

    if self.__runtimeMs >= self.MIN_APPLY_DELAY_MS and self.__stableMs >= self.STABLE_DELAY_MS then
        self:applyAll(g_fillTypeManager, "initialReady")
        if self.__lastSaleMarketReport ~= nil and self.__lastSaleMarketReport.success == true then
            self.__finalApplied = true
            self:showLoadNoticesOnce()
            self:showLoadStockAlertOnce()
        else
            self.__stableMs = 0
            self.__armedLogged = false
        end
    end
end

function DynamicMarket:deleteMap()
    self.__loadMapSeen = false
    self.__finalApplied = false
    self.__stableMs = 0
    self.__runtimeMs = 0
    self.__lastFillTypeCount = -1
    self.__marketKey = nil
    self.__marketFactors = {}
    self.__lastSalesMarketKey = nil
    self.__lastObservedMarketKey = nil
    self.__lastSaleMarketReport = nil
    self.__lastSellingStationCount = 0
    self.__periodCheckMs = 0
    self.__lastPlayerNoticeKey = nil
    self.__lastStockAlertKey = nil
    self.__armedLogged = false
    self.__bestStationRawPriceByFillType = nil
    self.__bestStationNameByFillType = nil
    self.__bestStationObjectByFillType = nil
    self.__stationCountByFillType = nil
    self.__uiPriceRefreshToken = 0
end

DynamicMarket.settings = DynamicMarketSettings.new(DynamicMarket)
DynamicMarket.settings:install()

addModEventListener(DynamicMarket)
