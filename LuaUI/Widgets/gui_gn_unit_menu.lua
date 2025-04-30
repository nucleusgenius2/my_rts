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

-- Для отслеживания выделения
local prevSelection = {}

local opened = false
local tries = 0
local doc, unitlist
local currentBuilder
local main_model_name = "modelunit"
local init_model = {
    testArray = {
            { name = "Item 1", value = 1 },
            { name = "Item 2", value = 2 },
            { name = "Item 3", value = 3 },
     },
    message = "тестовое сообщение",
    show = false,
    testblockVisible = false,

}
local dm_handle

if RmlUi and RmlUi.SetFunction then
      Spring.Echo("запрос на постройку")
    RmlUi.SetFunction("BuildUnit", function(_, buildDefID)
        if currentBuilder and buildDefID then
            local x, y, z = Spring.GetCameraPosition()
            Spring.GiveOrderToUnit(currentBuilder, -buildDefID, {x, y, z}, {"shift"})
            Spring.Echo("Build command issued for buildDefID:", buildDefID)
        end
    end)
end




--function widget:Initialize()
  -- Spring.Echo("SelectedUnitsRmlModel: Widget initialized!")
  -- self:TryOpenContext()
--end

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



  -- document:ReloadStyleSheet()
   document:Show()
end


function widget:HideMenu()
    if doc then
        --doc:Hide()
    end
end


local function sameSelection(a, b)
    if #a ~= #b then return false end
    for i = 1, #a do
        if a[i] ~= b[i] then return false end
    end
    return true
end

--выполняется ра в кадр
function widget:Update()


    local selectedUnits = Spring.GetSelectedUnits()

    if not sameSelection(selectedUnits, prevSelection) then
      Spring.Echo("1111119")
        -- Сохраняем выбор
        prevSelection = {}
        for i = 1, #selectedUnits do
            prevSelection[i] = selectedUnits[i]
        end

        Spring.Echo("[SelectedUnitsRmlModel] SelectionChanged: " .. #selectedUnits .. " юнитов выбрано")

        if dm_handle then
            -- Берём первого выбранного юнита как "билдера"
            local builderID = selectedUnits[1]
            currentBuilder = builderID

            local buildOptions = {}
            if builderID then
                local unitDefID = Spring.GetUnitDefID(builderID)
                local unitDef = UnitDefs[unitDefID]
                if unitDef and unitDef.buildOptions then
                    for i = 1, #unitDef.buildOptions do
                        local buildDefID = unitDef.buildOptions[i]
                        local buildDef = UnitDefs[buildDefID]
                        if buildDef then
                            table.insert(buildOptions, {
                                name = buildDef.humanName,
                                id = buildDefID,
                                icon = "#" .. buildDefID  -- стандарт для BAR
                            })
                        end
                    end
                end
            end

            -- Передаём в RML (до 10 элементов)
            dm_handle.message = tostring(#selectedUnits) .. " юнитов выбрано"
             dm_handle.testArray = {}


            -- Только если выбран хотя бы один юнит
            if #selectedUnits > 0 then
                local unitID = selectedUnits[1]
                local unitDefID = Spring.GetUnitDefID(unitID)
                local unitDef = unitDefID and UnitDefs[unitDefID]

                if unitDef and unitDef.buildOptions then
                    local buildOptions = {}

                    for _, buildDefID in ipairs(unitDef.buildOptions) do
                        local buildDef = UnitDefs[buildDefID]
                        if buildDef then
                            table.insert(buildOptions, {
                                name = buildDef.humanName or "???",
                                id = tostring(buildDefID), -- обязательно строка
                                icon = "#" .. tostring(buildDefID),
                            })
                        end
                    end

                    -- Передаём не более 10
                    for i = 1, math.min(10, #buildOptions) do
                        local key = tostring(i - 1) -- RML использует "0", "1", ...
                        dm_handle.testArray[key] = buildOptions[i]
                    end
                else
                    Spring.Echo("Выбранный юнит не строитель или buildOptions отсутствует")
                end
            else
                Spring.Echo("Нет выбранных юнитов")
            end

        else
            Spring.Echo("Нет widget.dm_handle!")
        end
    end
end




_G.ShowTestBlock2 = function(event)
  Spring.Echo("button message")
  Spring.Echo("обращение из кнопки")
    -- Используем переменную-флаг в этом скоупе
   -- widget.testblockVisible = not widget.testblockVisible
    --widget:OpenDoc(widget.testblockVisible)
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
