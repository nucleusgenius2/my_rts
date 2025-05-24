-- SpreadMoveQ.lua (распределение по прямоугольной области с масштабом под количество юнитов)
function widget:GetInfo()
  return {
    name    = "Spread Move Q",
    desc    = "Заменяет обычный Move на рассеянный Move по нажатию Q (по прямоугольной сетке)",
    author  = "ChatGPT",
    version = "1.3",
    layer   = 0,
    enabled = true,
  }
end

local active = false
local CMD_MOVE = CMD.MOVE

function widget:KeyPress(key, mods, isRepeat)
  if key == string.byte("q") then
    active = true
    return true
  end
end

function widget:KeyRelease(key)
  if key == string.byte("q") then
    active = false
    return true
  end
end

function widget:MousePress(x, y, button)
  if not active then return false end
  if button ~= 3 then return false end -- ПКМ

  local _, center = Spring.TraceScreenRay(x, y, true)
  if not center then return false end

  local selUnits = Spring.GetSelectedUnits()
  local n = #selUnits
  if n == 0 then return false end

  -- Размер сетки под количество юнитов
  local columns = math.ceil(math.sqrt(n))
  local spacing = 140
  local rows = math.ceil(n / columns)

  local startX = center[1] - (columns - 1) * spacing / 2
  local startZ = center[3] - (rows - 1) * spacing / 2

  for i, unitID in ipairs(selUnits) do
    local col = (i - 1) % columns
    local row = math.floor((i - 1) / columns)

    local tx = math.floor(startX + col * spacing)
    local tz = math.floor(startZ + row * spacing)
    local ty = Spring.GetGroundHeight(tx, tz)

    Spring.GiveOrderToUnit(unitID, CMD_MOVE, {tx, ty, tz}, {})
  end

  return true
end
