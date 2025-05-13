function widget:GetInfo()
  return {
    name      = "Blueprint Builder",
    desc      = "Сохраняет и размещает шаблоны зданий под курсором",
    author    = "nucleus_genius",
    date      = "2025-05-13",
    license   = "GPLv2",
    layer     = 0,
    enabled   = true,
  }
end

local maxBlueprints = 20
local blueprintFile = LUAUI_DIRNAME .. "NgBluePrint.lua"
local blueprints = {}

local Chili, screen0
local window

--------------------------------------------------------------------------------
-- Загрузка / сохранение
--------------------------------------------------------------------------------

local function LoadBlueprints()
  local success, result = pcall(VFS.Include, blueprintFile)
  if success and type(result) == "table" then
    blueprints = result
    Spring.Echo("[Blueprint Builder] Загружено шаблонов: " .. tostring(#blueprints))
  else
    blueprints = {}
    Spring.Echo("[Blueprint Builder] Не удалось загрузить шаблоны.")
  end
end

local function SaveBlueprints()
  local file = io.open(blueprintFile, "w")
  if not file then
    Spring.Echo("[Blueprint Builder] Не удалось открыть файл для записи.")
    return
  end

  file:write("return {\n")
  for _, blueprint in ipairs(blueprints) do
    file:write(string.format("  { name = %q, buildings = {\n", blueprint.name))
    for _, b in ipairs(blueprint.buildings) do
      file:write(string.format("    { defID = %d, x = %.1f, y = %.1f, z = %.1f },\n", b.defID, b.x, b.y, b.z))
    end
    file:write("  }},\n")
  end
  file:write("}\n")
  file:close()
  Spring.Echo("[Blueprint Builder] Шаблоны сохранены.")
end

--------------------------------------------------------------------------------
-- Получение позиции мыши
--------------------------------------------------------------------------------

local function GetMouseWorldPosition()
  local mx, my = Spring.GetMouseState()
  local type, p = Spring.TraceScreenRay(mx, my, true, true)
  if type == "ground" and p then
    return p[1], p[3]
  end
end

--------------------------------------------------------------------------------
-- Сохранение и размещение
--------------------------------------------------------------------------------

local function SaveBlueprint(name)
  local units = Spring.GetTeamUnits(Spring.GetMyTeamID())
  local buildings = {}

  for _, unitID in ipairs(units) do
    if Spring.ValidUnitID(unitID) and not Spring.GetUnitIsDead(unitID) then
      local defID = Spring.GetUnitDefID(unitID)
      local unitDef = UnitDefs[defID]
      if unitDef and unitDef.isBuilding then
        local x, y, z = Spring.GetUnitPosition(unitID)
        if x and y and z then
          table.insert(buildings, {defID = defID, x = x, y = y, z = z})
        end
      end
    end
  end

  if #buildings == 0 then
    Spring.Echo("[Blueprint Builder] Нет зданий для сохранения.")
    return
  end

  if #blueprints >= maxBlueprints then
    table.remove(blueprints, 1)
  end

  table.insert(blueprints, {name = name, buildings = buildings})
  SaveBlueprints()
  Spring.Echo(string.format("[Blueprint Builder] Сохранён '%s' (%d зданий)", name, #buildings))
end

local function PlaceBlueprint(index)
  local bp = blueprints[index]
  if not bp then return end

  local buildings = bp.buildings
  local baseX, baseZ = GetMouseWorldPosition()
  if not baseX or not baseZ then
    Spring.Echo("[Blueprint Builder] Не удалось определить позицию курсора.")
    return
  end

  local selected = Spring.GetSelectedUnits()
  if #selected == 0 then
    Spring.Echo("[Blueprint Builder] Выберите строителя.")
    return
  end

  local builderID = selected[1]
  local cmds = Spring.GetUnitCmdDescs(builderID)
  local cmdDescMap = {}
  for _, cmd in ipairs(cmds or {}) do
    if cmd.id < 0 then
      cmdDescMap[-cmd.id] = Spring.GetCmdDescIndex(cmd.id)
    end
  end

  local originX, originZ = 0, 0
  for _, unit in ipairs(buildings) do
    originX = originX + unit.x
    originZ = originZ + unit.z
  end
  originX = originX / #buildings
  originZ = originZ / #buildings

  for _, unit in ipairs(buildings) do
    local relX = unit.x - originX
    local relZ = unit.z - originZ
    local x = baseX + relX
    local z = baseZ + relZ
    local defID = unit.defID

    local cmdIndex = cmdDescMap[defID]
    if cmdIndex then
      Spring.SetActiveCommand(cmdIndex)
      Spring.GiveOrder(-defID, {x, 0, z}, {"shift"})
    end
  end
end

--------------------------------------------------------------------------------
-- Chili окно
--------------------------------------------------------------------------------

local function ToggleWindow()
  if window then
    window:Dispose()
    window = nil
    return
  end

  window = Chili.Window:New{
    x = '30%',
    y = '30%',
    width = 400,
    height = 300,
    caption = "Шаблоны построек",
    parent = screen0,
    draggable = true,
    resizable = false,
  }

  local stack = Chili.StackPanel:New{
    orientation = "vertical",
    width = "100%",
    height = "100%",
    padding = {5,5,5,5},
    itemMargin = {2,2,2,2},
    parent = window,
  }

  for i, bp in ipairs(blueprints) do
    local btn = Chili.Button:New{
      caption = string.format("%d. %s (%d зданий)", i, bp.name, #bp.buildings),
      width = "100%",
      height = 30,
      OnClick = { function() PlaceBlueprint(i) end },
    }
    stack:AddChild(btn)
  end
end

--------------------------------------------------------------------------------
-- Инициализация
--------------------------------------------------------------------------------

function widget:Initialize()
  LoadBlueprints()
  Chili = WG.Chili
  if not Chili then
    Spring.Echo("[Blueprint Builder] Требуется Chili UI")
    widgetHandler:RemoveWidget()
    return
  end
  screen0 = Chili.Screen0
end

--------------------------------------------------------------------------------
-- Клавиши
--------------------------------------------------------------------------------

function widget:KeyPress(key, mods, isRepeat)
  if isRepeat then return end
  if key == string.byte("s") then
    SaveBlueprint("Шаблон " .. (#blueprints + 1))
  elseif key == string.byte("b") and mods.shift then
    ToggleWindow()
  elseif key == string.byte("b") then
    PlaceBlueprint(#blueprints) -- последний
  end
end
