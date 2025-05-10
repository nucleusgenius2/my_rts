function widget:GetInfo()
  return {
    name      = "Graphics Settings Menu",
    desc      = "Chili UI меню для настройки графики (BAR)",
    author    = "nucleus genius",
    date      = "2025-05-09",
    license   = "GNU GPL v2",
    layer     = 0,
    enabled   = true,
    handler   = true,
  }
end

local Chili, screen0
local window
local isVisible = false
local delayedCommands = {}

local configVars = {
  { key = "LuaShaders",      name = "Lua Shaders (требуется перезапуск)",     type = "bool" },
  { key = "MSAALevel",       name = "MSAA Уровень (перезапуск)",              type = "number" },
  { key = "GroundDetail",    name = "Детализация земли",                      type = "number" },
  { key = "ShadowMapSize",   name = "Размер карты теней (перезапуск)",        type = "number" },
  { key = "Shadows",         name = "Тени",                                   type = "bool" },
  { key = "SSAO",            name = "SSAO (окклюзия)",                         type = "bool" },
  { key = "UsePBO",          name = "PBO (только для чтения)",                type = "readonly" },
  { key = "Fullscreen", name = "Полноэкранный режим", type = "bool" },
  { key = "AllowDeferredMapRendering", name = "Deferred Map Rendering",       type = "bool" },
}

local function ToggleWindow()
  isVisible = not isVisible
  if isVisible then
    window:Show()
  else
    window:Hide()
  end
end

function widget:Initialize()
  if not WG.Chili then
    Spring.Echo("Chili UI не загружен")
    widgetHandler:RemoveWidget()
    return
  end

  Chili = WG.Chili
  screen0 = Chili.Screen0

  local controls = {}

  for i, var in ipairs(configVars) do
    local label = Chili.Label:New{
      caption = var.name,
      width = "40%",
      x = 10,
      y = 10 + 30 * (i - 1),
    }

    local input
    local current = Spring.GetConfigInt(var.key, 1)

    if var.type == "bool" then
      input = Chili.Checkbox:New{
        checked = current == 1,
        x = "50%",
        width = 100,
        y = 10 + 30 * (i - 1),
        OnChange = { function(_, state)
          local val = state and 1 or 0
          Spring.SetConfigInt(var.key, val)

          if var.key == "Shadows" then
            table.insert(delayedCommands, val == 1 and "shadows 1" or "shadows 0")
          elseif var.key == "SSAO" then
            table.insert(delayedCommands, val == 1 and "ssao 1" or "ssao 0")
          elseif var.key == "LuaShaders" then
            Spring.Echo("LuaShaders вступит в силу после перезапуска игры")
          elseif var.key == "AllowDeferredMapRendering" then
            Spring.Echo("Deferred Rendering применяется при следующем запуске карты")
          end
        end },
      }

    elseif var.type == "readonly" then
      input = Chili.Label:New{
        caption = current == 1 and "Включено" or "Выключено",
        x = "50%",
        width = 100,
        y = 10 + 30 * (i - 1),
        font = { size = 12 },
      }

    else -- number
      input = Chili.TextBox:New{
        text = tostring(current),
        x = "50%",
        width = 100,
        y = 10 + 30 * (i - 1),
        backgroundColor = {0,0,0,0.2},
        OnTextInput = { function(obj, val)
          local num = tonumber(val)
          if num then
            Spring.SetConfigInt(var.key, num)

            if var.key == "GroundDetail" then
              table.insert(delayedCommands, "GroundDetail " .. num)
            elseif var.key == "ShadowMapSize" then
              Spring.Echo("ShadowMapSize вступит в силу после перезапуска")
            elseif var.key == "MSAALevel" then
              Spring.Echo("MSAALevel применяется только при запуске игры")
            end
          end
        end },
      }
    end

    controls[#controls+1] = label
    controls[#controls+1] = input
  end

  window = Chili.Window:New{
    parent = screen0,
    x = "30%",
    y = "20%",
    width = 500,
    height = 40 + 30 * #configVars,
    caption = "Настройки графики",
    resizable = false,
    draggable = true,
    visible = false,
    children = controls,
  }
end

function widget:KeyPress(key, mods, isRepeat)
  -- Shift + 2 (keycode for '2' is 50)
  if key == 50 and mods.shift and not isRepeat then
    ToggleWindow()
    return true
  end
end

function widget:Update()
  if #delayedCommands > 0 then
    for _, cmd in ipairs(delayedCommands) do
      Spring.SendCommands(cmd)
    end
    delayedCommands = {}
  end
end
