widget = widget or {}

function widget:GetInfo()
    return {
        name = "NG unit menu",
        desc = "Юнит меню",
        author = "nucleus_genius",
        date = "2025",
        license = "All rights reserved; no commercial use",
        layer = 1,
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
local showTemplate = false
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

--вызов блюе принта
local function CallBluePrint(_, index)
  index = index + 1
    --Spring.Echo("[CallBluePrint] PlaceBlueprint:", index, type(index))
  if WG.BlueprintBuilder and WG.BlueprintBuilder.StartPlacement then
    WG.BlueprintBuilder.StartPlacement(index)
  else
    Spring.Echo("[CallBluePrint] Не удалось вызвать шаблон, WG.BlueprintBuilder не найден")
  end
end

--показ и скрытие списка шаблонов
local function CallShowTemplate()
    if dm_handle.showTemplate then
        dm_handle.showTemplate = false
    else
        dm_handle.showTemplate = true
    end
end

--удаление шаблонов
local function CallDeleteBluePrint(_, index)
   index = index + 1
   if WG.BlueprintBuilder and WG.BlueprintBuilder.DeleteBlueprint then
       Spring.Echo("удаление")
       WG.BlueprintBuilder.DeleteBlueprint(index)

       local blueprints = WG.BlueprintBuilder.GetBlueprintList()
       if #blueprints > 0 then
           dm_handle.bluePrints = blueprints
       end
   end
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
    selectTechLevel = 1, -- тех левел который выбрали в меню для отображения
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
    helpTextHoldFire = tr("help_text_hold_fire"),
    helpTextReturnFire = tr("help_text_return_fire"),
    helpTextFireAtWill = tr("help_text_fire_at_will"),
    helpTextFireState = tr("help_text_fire_state"),
    helpTextMoveState = tr("help_text_move_state"),
    helpTextRepeatState = tr("help_text_repeat_state"),
    helpTextHoldPos = tr("help_text_hold_pos"),
    helpTextManeuver = tr("help_text_maneuver"),
    helpTextRoam = tr("help_text_roam"),
    helpTextRepeatOff = tr("help_text_repeat_off"),
    helpTextRepeatOn = tr("help_text_repeat_on"),
    menuTextUnitInfo = tr("unit_menu_text_unit_info"),
    helpTextMass = tr("main_text_mass"),
    helpTextEnergy = tr("main_text_energy"),
    helpTextBuildTime = tr("main_text_build_time"),

    bluePrints = {},
    CallBluePrint = CallBluePrint,
    CallShowTemplate = CallShowTemplate,
    CallDeleteBluePrint = CallDeleteBluePrint,
    showTemplate = false,
    hasNonBuilder = false,
    singleUnitInfo = {
        name = "",
        description = "",
        hp = 0,
        cost = {
            metal = 0,
            energy = 0,
            buildTime = 0,
        },
        customParams = {},
        weapons = {},
    },
    oneUnitSelect = false
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

        --инфа если один юнит выбранн
        if #selectedUnits == 1 then


            local unitID = selectedUnits[1]
            local unitDefID = Spring.GetUnitDefID(unitID)
            local unitDef = unitDefID and UnitDefs[unitDefID]


           if unitDef then

               dm_handle.singleUnitInfo = {
                   name = unitDef.name or unitDef.UnitName,
                   description = unitDef.description or unitDef.Description,
                   mass = unitDef.customParams.mass,
                   energy  = unitDef.customParams.energy,
                   buildtime = unitDef.customParams.buildtime,
                   weapons = weapons,
               }
                --выбран только один юнит
                dm_handle.oneUnitSelect = true
           end
        else
            dm_handle.oneUnitSelect = false
            dm_handle.singleUnitInfo = {} -- сбрасываем если не один юнит
        end


        Spring.Echo("[SelectedUnitsRmlModel] SelectionChanged: " .. #selectedUnits .. " юнитов выбрано")

        if dm_handle then
            local unitGroups = {}
            local hasBuilder = false
            local hasLaboratory = false
            local hasNonBuilder = false

            for _, unitID in ipairs(selectedUnits) do
                if Spring.ValidUnitID(unitID) then
                    local unitDefID = Spring.GetUnitDefID(unitID)
                    local unitDef = unitDefID and UnitDefs[unitDefID]
                    if unitDef then
                        if unitDef.isBuilder then
                            hasBuilder = true
                        else
                            --для ui чтобы удобнее было
                            dm_handle.showTemplate = false
                            hasNonBuilder = true
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
            dm_handle.hasNonBuilder = hasNonBuilder

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
            dm_handle.helpTextHoldFire = tr("help_text_hold_fire")
            dm_handle.helpTextReturnFire = tr("help_text_return_fire")
            dm_handle.helpTextFireAtWill = tr("help_text_fire_at_will")
            dm_handle.helpTextFireState = tr("help_text_fire_state")
            dm_handle.helpTextMoveState = tr("help_text_move_state")
            dm_handle.helpTextRepeatState = tr("help_text_repeat_state")

            dm_handle.helpTextHoldPos = tr("help_text_hold_pos")
            dm_handle.helpTextManeuver = tr("help_text_maneuver")
            dm_handle.helpTextRoam = tr("help_text_roam")
            dm_handle.helpTextRepeatOff = tr("help_text_repeat_off")
            dm_handle.helpTextRepeatOn = tr("help_text_repeat_on")
            dm_handle.menuTextUnitInfo = tr("unit_menu_text_unit_info")

            dm_handle.helpTextMass = tr("main_text_mass")
            dm_handle.helpTextEnergy = tr("main_text_energy")
            dm_handle.helpTextBuildTime = tr("main_text_build_time")



            local blueprints = WG.BlueprintBuilder.GetBlueprintList()
            if #blueprints > 0 then
              dm_handle.bluePrints = blueprints
            end

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
