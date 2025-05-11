widget = widget or {}

function widget:GetInfo()
    return {
        name = "NG unit menu",
        desc = "Юнит меню",
        author = "nucleus_genius",
        date = "2025",
        license = "All rights reserved; no commercial use",
        layer = 0,
        enabled = true,
    }
end

local prevSelection = {}
local doc
local main_model_name = "modelunit"
local dm_handle
local engineerTechLevel = 1
--языковые настройки
local SettingsManager = WG.SettingsManager
local currentLang = SettingsManager:Get("language")
tr = function(k) return WG.Translate("interface." .. k) end

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
                  local pic = unitDef.buildPic or ""
                  if not pic:lower():find("unitpics/") then
                       pic = "UnitPics/" .. pic
                  end

                  --получаем techlevel или по умолчанию 1
                  local techlevel = tonumber(unitDef.customParams and unitDef.customParams.techlevel) or 1


                  table.insert(result, {
                       id = cmd.id,
                       buildDefID = buildUnitDefID,
                       name = unitDef.humanName or ("Build " .. tostring(buildUnitDefID)),
                       tooltip = cmd.tooltip or "",
                       icon = "/" .. pic, -- важно: путь должен начинаться с "/", т.к. это VFS
                       params = cmd.params or {},
                       techlevel = techlevel,
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
         -- фильтр что это не постройка
        if cmd.id >= 0 and cmd.name and cmd.name ~= "" and not cmd.disabled and not cmd.hidden then
            local isState = #cmd.params > 1
            local stateLabels = isState and { unpack(cmd.params, 2) } or nil
            local stateIndex = isState and tonumber(cmd.params[1]) + 1 or nil

            local labelText = isState and stateLabels[stateIndex] or cmd.name

            table.insert(result, {
                id = cmd.id,
                name = cmd.name,
                tooltip = cmd.tooltip or "",
                icon = cmd.texture or "",
                params = cmd.params or {},
                isStateCommand = isState,
                stateIndex = stateIndex,
                stateLabels = stateLabels,
                stateLabelText = labelText,
            })
        end
    end

    return result
end

--выполнение команд юнитов
local function RunCommandFromRML(_, cmdID)
    local selected = Spring.GetSelectedUnits()
    if #selected == 0 then return end

    for _, unitID in ipairs(selected) do
        local cmdDescs = Spring.GetUnitCmdDescs(unitID)
        for _, cmd in ipairs(cmdDescs or {}) do
            if cmd.id == cmdID then
                if #cmd.params > 1 then
                    -- state-команда (команды  с тумблером, но уже уехали в другую функцию)
                    local cur = cmd.params[1]
                    local total = #cmd.params - 1
                    local nextState = (cur + 1) % total
                    Spring.GiveOrderToUnit(unitID, cmdID, { nextState }, {})
                else
                    -- обычная команда
                    Spring.SetActiveCommand(Spring.GetCmdDescIndex(cmdID))
                end
                break
            end
        end
    end


     if dm_handle then
         --id выбранного нит на стройку
         dm_handle.activeCommandID = cmdID
     end
end

--комады с тумблером
local function ToggleStateCommand(_, cmdID)
    local selected = Spring.GetSelectedUnits()
    if #selected == 0 then return end

    -- Подаём команду на смену состояния
    for _, unitID in ipairs(selected) do
        local cmdDescs = Spring.GetUnitCmdDescs(unitID)
        for _, cmd in ipairs(cmdDescs or {}) do
            if cmd.id == cmdID and #cmd.params > 1 then
                local cur = cmd.params[1]
                local total = #cmd.params - 1
                local nextState = (cur + 1) % total
                Spring.GiveOrderToUnit(unitID, cmdID, { nextState }, {})
                break
            end
        end
    end

    -- Ждём один кадр, чтобы `cmd.params` успели обновиться
    widget.waitingCmdUpdate = cmdID
end


--смена тех уровня
local function ChangeTexLevel(_, engineerTechLevel, selectedLevel)
    if engineerTechLevel >= selectedLevel then
         dm_handle.selectTechLevel = selectedLevel
    end

    dm_handle.selectTechLevel = selectedLevel -- пока что переключаем тех левел без проверок
end

--отправка данных для апгрейда в гаджет
local function CallUpgrade(_, upgradeKey)
    local msg = "upgrade|".. tostring(upgradeKey)
    Spring.SendLuaRulesMsg(msg)
end



-- Инициализируем модель
local init_model = {
    SelectUnitsByDefID = SelectUnitsByDefID,
    RunCommandFromRML = RunCommandFromRML,
    ChangeTexLevel = ChangeTexLevel,
    CallUpgrade = CallUpgrade,
    activeCommandID = -9999999, --здание которое выбрали для постройки
    testArray = {},
    unitCommands = {},
    buildCommands = {},
    hasBuilder = false, -- есть ли инженер
    show = false,
    ToggleStateCommand = ToggleStateCommand,
    engineerTechLevel = 1, -- тех левел инжа
    selectTechLevel = 0, -- тех левел который выбрали в меню дял отображения
    hasLaboratory = false,
    -- Получаем текущий язык из настроек
    currentLang = currentLang,
    helpTextAttack = tr("help_text_attack"),
    helpTextStop = tr("help_text_stop"),
    helpTextMove = tr("help_text_move"),
    helpTextPatrol = tr("help_text_patrol"),
    helpTextRepair = tr("help_text_repair"),
    helpTextReclaim = tr("help_text_reclaim"),
    helpTextGuard = tr("help_text_guard"),
    helpTextFight = tr("help_text_fight"),
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
    --получение выбранных юнитов
    local selectedUnits = Spring.GetSelectedUnits()

    -- показ юнит меню
    if dm_handle then
        if(#selectedUnits > 0) then
            document:Show()
        else
           document:Hide()
        end

    end

    if not sameSelection(selectedUnits, prevSelection) then
        prevSelection = {}
        for i = 1, #selectedUnits do
            prevSelection[i] = selectedUnits[i]
        end

        Spring.Echo("[SelectedUnitsRmlModel] SelectionChanged: " .. #selectedUnits .. " юнитов выбрано")

        if dm_handle then
            local unitGroups = {}
            local hasBuilder = false
            local hasLaboratory = false

            for _, unitID in ipairs(selectedUnits) do
                if Spring.ValidUnitID(unitID) then
                    local unitDefID = Spring.GetUnitDefID(unitID)
                    local unitDef = unitDefID and UnitDefs[unitDefID]
                    if unitDef then
                        if unitDef.isBuilder then
                            hasBuilder = true
                        end

                        -- сразу получаем уровень технологии у первого билдера
                        if engineerTechLevel == 1 and unitDef.customParams and unitDef.customParams.techlevel then
                            engineerTechLevel = tonumber(unitDef.customParams.techlevel) or 1
                        end

                        --проверка что это здание лаборатория
                        if unitDef.customParams and unitDef.customParams.laboratory then
                           hasLaboratory = true
                        end

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
            dm_handle.engineerTechLevel = engineerTechLevel
            dm_handle.hasLaboratory = hasLaboratory

             --локалиазция описаний
            dm_handle.currentLang = SettingsManager:Get("language")
            dm_handle.helpTextAttack = tr("help_text_attack")
            dm_handle.helpTextStop = tr("help_text_stop")
            dm_handle.helpTextMove = tr("help_text_move")
            dm_handle.helpTextPatrol = tr("help_text_patrol")
            dm_handle.helpTextRepair = tr("help_text_repair")
            dm_handle.helpTextReclaim = tr("help_text_reclaim")
            dm_handle.helpTextGuard = tr("help_text_guard")
            dm_handle.helpTextFight = tr("help_text_fight")



        else
            Spring.Echo("Нет widget.dm_handle!")
        end
    end



    -- для обновления тугловых команд
    if dm_handle then
         dm_handle.unitCommands = getGroupCommands(Spring.GetSelectedUnits())
    end

end

function widget:Shutdown()
    if document then document:Hide() end
end
