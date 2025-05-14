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

local blueprintFile = LUAUI_DIRNAME .. "NgBluePrint.lua"
local blueprints = {}
local maxBlueprints = 20

local Chili, screen0
local saveWindow
local pendingBlueprintIndex = nil

--------------------------------------------------------------------------------
-- Загрузка / сохранение
--------------------------------------------------------------------------------

local function LoadBlueprints()
  local success, result = pcall(VFS.Include, blueprintFile)
  if success and type(result) == "table" then
    blueprints = result
  else
    blueprints = {}
  end
end

local function SaveBlueprints()
  local file = io.open(blueprintFile, "w")
  if not file then
    Spring.Echo("[Blueprint Builder] Не удалось открыть файл для записи.")
    return
  end

  file:write("return {\n")
  for _, bp in ipairs(blueprints) do
    file:write(string.format(
      "  { name = %q, techLevel = %d, icon = %q, buildings = {\n",
      bp.name or "Unnamed",
      tonumber(bp.techLevel) or 1,
      bp.icon or "default"
    ))
    for _, b in ipairs(bp.buildings) do
      file:write(string.format("    { defID = %d, x = %.1f, y = %.1f, z = %.1f },\n", b.defID, b.x, b.y, b.z))
    end
    file:write("  }},\n")
  end
  file:write("}\n")
  file:close()
end

--------------------------------------------------------------------------------
-- Сохранение шаблона
--------------------------------------------------------------------------------

local function SaveBlueprintWithName(name)
    if #name > 8 then
      Spring.Echo("[Blueprint Builder] Название обрезано до 7 символов: " .. string.sub(name, 1, 7))
      name = string.sub(name, 1, 8)
    end-- ограничение имени шаблона до 7 символов

  local units = Spring.GetTeamUnits(Spring.GetMyTeamID())
  local buildings = {}

  local maxMetalCost = 0
  local maxTechLevel = 1
  local icon = ""

  for _, unitID in ipairs(units) do
    if Spring.ValidUnitID(unitID) and not Spring.GetUnitIsDead(unitID) then
      local defID = Spring.GetUnitDefID(unitID)
      local unitDef = UnitDefs[defID]
      if unitDef and unitDef.isBuilding then
        local x, y, z = Spring.GetUnitPosition(unitID)
        table.insert(buildings, {defID = defID, x = x, y = y, z = z})

        if unitDef.metalCost > maxMetalCost then
          maxMetalCost = unitDef.metalCost

          local pic = unitDef.buildPic or ""
          if not pic:lower():find("unitpics/") then
            pic = "/unitpics/" .. pic
          end
          icon = pic
        end

        local tech = unitDef.customParams and tonumber(unitDef.customParams.techlevel) or 1
        if tech > maxTechLevel then
          maxTechLevel = tech
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

  table.insert(blueprints, {
    name = name,
    techLevel = maxTechLevel,
    icon = icon,
    buildings = buildings
  })

  SaveBlueprints()
end

local function OpenSaveBlueprintWindow()
  if saveWindow then saveWindow:Dispose() end

  saveWindow = Chili.Window:New{
    x = '40%',
    y = '40%',
    width = 300,
    height = 150,
    caption = "Сохранить шаблон",
    parent = screen0,
    draggable = true,
    resizable = false,
  }

  local editBox = Chili.EditBox:New{
    text = "Шаблон " .. (#blueprints + 1),
    width = "100%",
    height = 30,
    parent = saveWindow,
  }

  local saveBtn = Chili.Button:New{
    caption = "Сохранить",
    width = "100%",
    height = 40,
    y = 40,
    parent = saveWindow,
    OnClick = {
      function()
        SaveBlueprintWithName(editBox.text)
        saveWindow:Dispose()
        saveWindow = nil
      end
    }
  }
end

--------------------------------------------------------------------------------
-- Построение шаблона
--------------------------------------------------------------------------------

local function DoPlaceBlueprint(index, baseX, baseZ)
  local bp = blueprints[index]
  if not bp then return end

  local buildings = bp.buildings
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

local function StartPlacement(index)
  Spring.Echo("[Blueprint Builder] Режим планирования активен для шаблона:", index)
  pendingBlueprintIndex = tonumber(index)
end

local function DeleteBlueprint(index)
  if not blueprints[index] then return end
  table.remove(blueprints, index)
  SaveBlueprints()
  Spring.Echo("[Blueprint Builder] Шаблон удалён:", index)
end

function widget:MousePress(x, y, button)
  if pendingBlueprintIndex then
    local mx, my = Spring.GetMouseState()
    local type, pos = Spring.TraceScreenRay(mx, my, true, true)
    if type == "ground" and pos then
      DoPlaceBlueprint(pendingBlueprintIndex, pos[1], pos[3])
      pendingBlueprintIndex = nil
      return true
    end
  end
end

--------------------------------------------------------------------------------
-- Init
--------------------------------------------------------------------------------

function widget:Initialize()
  LoadBlueprints()
  Spring.Echo("[Blueprint Builder] blueprints count:", #blueprints)

  Chili = WG.Chili
  if not Chili then
    Spring.Echo("[Blueprint Builder] Требуется Chili UI")
    widgetHandler:RemoveWidget()
    return
  end
  screen0 = Chili.Screen0

  WG.BlueprintBuilder = {
    StartPlacement = StartPlacement,
    SaveNewBlueprint = OpenSaveBlueprintWindow,
    DeleteBlueprint = DeleteBlueprint,
    GetBlueprintList = function() return blueprints end,
  }
end

function widget:KeyPress(key, mods, isRepeat)
  if isRepeat then return end

  if key == string.byte("n") and mods.shift then
    if saveWindow then
      saveWindow:Dispose()
      saveWindow = nil
    else
      OpenSaveBlueprintWindow()
    end
  end
end
