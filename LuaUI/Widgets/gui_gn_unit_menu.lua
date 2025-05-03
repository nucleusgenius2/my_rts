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

local prevSelection = {}
local doc
local main_model_name = "modelunit"
local dm_handle



--функция которая выбирает юнитов
local function SelectUnitsByDefID(_, unitDefID)
    local realID = tonumber(unitDefID)
    if not realID then
        Spring.Echo("Invalid unitDefID passed from RML, raw value:", unitDefID)
        return
    end

    local allUnits = Spring.GetTeamUnits(Spring.GetMyTeamID())
    local toSelect = {}

    for _, unitID in ipairs(allUnits) do
        if Spring.GetUnitDefID(unitID) == realID then
            table.insert(toSelect, unitID)
        end
    end

    Spring.SelectUnitArray(toSelect)
end


--получить строительные команды юнита
local function getBuildCommands(selectedUnits)
    local result = {}
    if #selectedUnits == 0 then return result end

    local unitID = selectedUnits[1]
    local cmds = Spring.GetUnitCmdDescs(unitID)
    if not cmds then return result end

    for _, cmd in ipairs(cmds) do
        -- Это команда строительства, если ID < 0
        if cmd.id < 0 and not cmd.disabled and not cmd.hidden then
            local buildUnitDefID = -cmd.id
            local unitDef = UnitDefs[buildUnitDefID]

            if unitDef then
                table.insert(result, {
                    id = cmd.id,
                    buildDefID = buildUnitDefID,
                    name = unitDef.humanName or ("Build " .. tostring(buildUnitDefID)),
                    tooltip = cmd.tooltip or "",
                    icon = "#" .. buildUnitDefID,  -- это встроенное buildpic отображение
                    params = cmd.params or {},
                })
            end
        end
    end

    return result
end


--получения списка команд юнита за исключением строительства
local function getGroupCommands(selectedUnits)
    local result = {}
    if #selectedUnits == 0 then return result end

    local unitID = selectedUnits[1]
    local cmds = Spring.GetUnitCmdDescs(unitID)
    if not cmds then return result end

    for _, cmd in ipairs(cmds) do
        -- фильтруем только НЕ постройки:
        if cmd.id >= 0 and cmd.name and cmd.name ~= "" and not cmd.disabled and not cmd.hidden then
            table.insert(result, {
                id = cmd.id,
                name = cmd.name,
                tooltip = cmd.tooltip or "",
                icon = cmd.texture or "",
                params = cmd.params or {},
            })
        end
    end

    return result
end

--выполнение команд юнитов
local function RunCommandFromRML(_, cmdID)
     local selected = Spring.GetSelectedUnits()
     if #selected == 0 then return end

     local index = Spring.GetCmdDescIndex(cmdID)
     if not index then
         Spring.Echo("[RML] Command ID not found in CmdDesc:", cmdID)
         return
     end

     -- Просто активируем команду — курсор сменится, игрок укажет точку
     Spring.SetActiveCommand(index)

     Spring.Echo("[RML] Activated cursor for command ID:", cmdID)
 end


-- 👇 Инициализируем модель
local init_model = {
    SelectUnitsByDefID = SelectUnitsByDefID,
    RunCommandFromRML = RunCommandFromRML,

    message = "тестовое сообщение",
    testArray = {},
    unitCommands = {},
    buildCommands = {},
    hasBuilder = false,
    show = false,
    testblockVisible = false,
}

function widget:Initialize()
   widgetHandler:ConfigLayoutHandler(widget)
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
    document:ReloadStyleSheet()
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
                        if unitDef.isBuilder then hasBuilder = true end
                        unitGroups[unitDefID] = (unitGroups[unitDefID] or 0) + 1
                    end
                end
            end

            local rmlData = {}
            local index = 1
            for unitDefID, count in pairs(unitGroups) do
                local unitDef = UnitDefs[unitDefID]
                if unitDef then
                    local iconUnit = "/UnitPics/" .. unitDef.name .. ".png"
                    rmlData[index] = {
                        name = unitDef.humanName or ("UnitDef " .. unitDefID),
                        icon = iconUnit,
                        id = unitDefID,
                        count = count,
                        builderID = "N/A"
                    }
                    index = index + 1
                end
            end

            dm_handle.testArray = rmlData
            dm_handle.hasBuilder = hasBuilder
            dm_handle.unitCommands = getGroupCommands(selectedUnits)
            dm_handle.buildCommands = getBuildCommands(selectedUnits)
        else
            Spring.Echo("Нет widget.dm_handle!")
        end
    end
end

function widget:Shutdown()
    if document then document:Hide() end
end

-- Пример ручного триггера через LuaCall
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
