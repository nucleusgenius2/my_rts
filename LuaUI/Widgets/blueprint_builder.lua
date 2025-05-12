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

local blueprintFile = LUAUI_DIRNAME .. "Configs/blueprint_data.lua"
local blueprints = {}

--------------------------------------------------------------------------------
-- Вспомогательные функции
--------------------------------------------------------------------------------

local function SaveToFile()
  local file = io.open(blueprintFile, "w")
  if file then
    file:write("return " .. Spring.Utilities.TableToString(blueprints) .. "\n")
    file:close()
    Spring.Echo("[Blueprint Builder] Шаблоны сохранены.")
  else
    Spring.Echo("[Blueprint Builder] Не удалось сохранить шаблон.")
  end
end

local function LoadFromFile()
  if VFS.FileExists(blueprintFile) then
    blueprints = VFS.Include(blueprintFile)
    Spring.Echo("[Blueprint Builder] Шаблоны загружены.")
  end
end

local function GetMouseWorldPosition()
  local mx, my = Spring.GetMouseState()
  local type, p = Spring.TraceScreenRay(mx, my, true, true)
  if type == "ground" and p then
    return p[1], p[3]
  end
end

--------------------------------------------------------------------------------
-- Основные функции
--------------------------------------------------------------------------------

local function SaveBlueprint(name)
  local units = Spring.GetTeamUnits(Spring.GetMyTeamID())
  local blueprint = {}

  for _, unitID in ipairs(units) do
    if Spring.ValidUnitID(unitID) and not Spring.GetUnitIsDead(unitID) then
      local defID = Spring.GetUnitDefID(unitID)
      local unitDef = UnitDefs[defID]
      if unitDef and unitDef.isBuilding then
        local x, y, z = Spring.GetUnitPosition(unitID)
        if x and y and z then
          table.insert(blueprint, {defID = defID, x = x, y = y, z = z})
        end
      end
    end
  end

  if #blueprint > 0 then
    blueprints[name] = blueprint
    SaveToFile()
    Spring.Echo("[Blueprint Builder] Шаблон '" .. name .. "' сохранён. Всего зданий: " .. #blueprint)
  else
    Spring.Echo("[Blueprint Builder] Нет зданий для сохранения.")
  end
end

local function PlaceBlueprint(name)
  local blueprint = blueprints[name]
  if not blueprint then
    Spring.Echo("[Blueprint Builder] Шаблон '" .. name .. "' не найден.")
    return
  end

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

  -- Центр шаблона
  local originX, originZ = 0, 0
  for _, unit in ipairs(blueprint) do
    originX = originX + unit.x
    originZ = originZ + unit.z
  end
  originX = originX / #blueprint
  originZ = originZ / #blueprint

  -- Постройка
  for _, unit in ipairs(blueprint) do
    local relX = unit.x - originX
    local relZ = unit.z - originZ
    local x = baseX + relX
    local z = baseZ + relZ
    local defID = unit.defID

    local cmdIndex = cmdDescMap[defID]
    if cmdIndex then
      Spring.SetActiveCommand(cmdIndex)
      Spring.GiveOrder(-defID, {x, 0, z}, {"shift"})
    else
      Spring.Echo("[Blueprint Builder] Не найдено: " .. defID)
    end
  end
end

--------------------------------------------------------------------------------
-- Интерфейс
--------------------------------------------------------------------------------

function widget:Initialize()
  LoadFromFile()
end

function widget:KeyPress(key, mods, isRepeat)
  if isRepeat then return end
  if key == string.byte("s") then
    SaveBlueprint("default")
  elseif key == string.byte("b") then
    PlaceBlueprint("default")
  end
end
