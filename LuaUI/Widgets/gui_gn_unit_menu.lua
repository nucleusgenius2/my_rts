widget = widget or {}

function widget:GetInfo()
    return {
        name = "Selected Units RML Model",
        desc = "Uses a data model for unit selections with RmlUi",
        author = "nucleus_genius & chatgpt",
        date = "2025",
        license = "GNU GPL, v2 or later",
        layer = 0,
        enabled = true,
    }
end

local function BuildUnit(_, currentBuilder, buildDefID)
    Spring.Echo("build ---" .. buildDefID)

    if currentBuilder then
        Spring.Echo("currentBuilder: ", currentBuilder)
    else
        Spring.Echo("currentBuilder is nil!")
    end
end

local prevSelection = {}
local doc, unitlist
local main_model_name = "modelunit"
local init_model = {
    message = "тестовое сообщение",
    testArray = {},
    hasBuilder = false,
    show = false,
    testblockVisible = false,
}
local dm_handle

function widget:Initialize()
    widget.rmlContext = RmlUi.GetContext("shared")
    dm_handle = widget.rmlContext:OpenDataModel(main_model_name, init_model)
    if not dm_handle then
        Spring.Echo("RmlUi: Failed to open data model", main_model_name)
        return
    end
    document = widget.rmlContext:LoadDocument("luaui/widgets_rml/unit_menu.rml", widget)
    if not document then
        Spring.Echo("Failed to load document")
        return
    end
    document:Show()
end

function widget:HideMenu()
    if doc then
        -- doc:Hide()
    end
end

local function sameSelection(a, b)
    if #a ~= #b then return false end
    for i = 1, #a do
        if a[i] ~= b[i] then return false end
    end
    return true
end

function widget:Update()
    local selectedUnits = Spring.GetSelectedUnits()

    if not sameSelection(selectedUnits, prevSelection) then
        prevSelection = {}
        for i = 1, #selectedUnits do
            prevSelection[i] = selectedUnits[i]
        end

        Spring.Echo("[SelectedUnitsRmlModel] SelectionChanged: " .. #selectedUnits .. " юнитов выбрано")

        if dm_handle then
            local unitGroups = {}
            local hasBuilder = false

            for _, unitID in ipairs(selectedUnits) do
                if Spring.ValidUnitID(unitID) then
                    local unitDefID = Spring.GetUnitDefID(unitID)
                    local unitDef = unitDefID and UnitDefs[unitDefID]
                    if unitDef then
                        if unitDef.isBuilder then
                            hasBuilder = true
                        end
                        unitGroups[unitDefID] = (unitGroups[unitDefID] or 0) + 1
                    end
                end
            end

            local rmlData = {}
            local index = 0
            for unitDefID, count in pairs(unitGroups) do
                local unitDef = UnitDefs[unitDefID]
                if unitDef then
                    rmlData[index] = {
                        name = unitDef.humanName or ("UnitDef " .. unitDefID),
                        icon = "UnitPics/Cleaver.png", -- можно заменить на unitpics/.. если заработает
                        id = tostring(unitDefID),
                        count = count,
                        builderID = "N/A"
                    }
                    index = index + 1
                end
            end

            dm_handle.testArray = rmlData
            dm_handle.hasBuilder = hasBuilder
            Spring.Echo("[SelectedUnitsRmlModel] Отправлены данные в RML: " .. tostring(index) .. " типов юнитов")
        else
            Spring.Echo("Нет widget.dm_handle!")
        end
    end
end

_G.ShowTestBlock2 = function(event)
    Spring.Echo("button message")
    if dm_handle then
        dm_handle.message = "т3333333333333333"
        dm_handle.testblockVisible = not dm_handle.testblockVisible
        dm_handle.testArray = {
            { name = "22222", value = 1 },
            { name = "3333", value = 2 },
            { name = "4444", value = 3 },
        }
    else
        Spring.Echo("Нет widget.dm_handle!")
    end
end
