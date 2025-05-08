function gadget:GetInfo()
  return {
    name      = "unit_trackscroll",
    desc      = "Скроллинг текстуры гусениц",
    author    = "OpenAI",
    layer     = 0,
    enabled   = true
  }
end

if gadgetHandler:IsSyncedCode() then return end

-- Spring API
local spGetGameFrame = Spring.GetGameFrame
local spGetAllUnits = Spring.GetAllUnits
local spGetUnitDefID = Spring.GetUnitDefID
local spSetUnitNoDraw = Spring.SetUnitNoDraw
local Echo = Spring.Echo

-- GL
local glUseShader = gl.UseShader
local glGetUniformLocation = gl.GetUniformLocation
local glUniform = gl.Uniform
local glCreateShader = gl.CreateShader
local glDeleteShader = gl.DeleteShader
local glGetShaderLog = gl.GetShaderLog
local glTexture = gl.Texture
local glPushMatrix = gl.PushMatrix
local glPopMatrix = gl.PopMatrix
local glUnit = gl.Unit

-- Constants
local trackedUnitDefName = "hunter"
local trackTexture = "unittextures/hunter_tracks.png"
local scrollSpeed = 0.02

-- State
local shader
local trackOffsetLoc
local hunterUnitID
local hunterDefID

function gadget:Initialize()
  Echo("[TrackScroll] Инициализация...")

  local vs = VFS.LoadFile("Shaders/tanktracks.vert")
  local fs = VFS.LoadFile("Shaders/tanktracks.frag")

  if not vs or not fs then
    Echo("[TrackScroll] Ошибка загрузки шейдеров.")
    return
  end

  shader = glCreateShader({
    vertex = vs,
    fragment = fs,
    uniformInt = { tex0 = 0 },
    uniformFloat = { trackOffset = 0.0 },
  })

  if not shader then
    Echo("[TrackScroll] Не удалось скомпилировать шейдер:")
    Echo(glGetShaderLog())
    return
  end

  Echo("[TrackScroll] Шейдер создан успешно.")

  trackOffsetLoc = glGetUniformLocation(shader, "trackOffset")

  -- Находим UnitDefID по имени
  for defID, def in pairs(UnitDefs) do
    if def.name == trackedUnitDefName then
      hunterDefID = defID
      Echo("[TrackScroll] Найден UnitDefID: " .. hunterDefID)
      break
    end
  end

  if not hunterDefID then
    Echo("[TrackScroll] Не найден UnitDef с именем: " .. trackedUnitDefName)
    return
  end

  -- Находим и отключаем отрисовку всех таких юнитов
  for _, uid in ipairs(spGetAllUnits()) do
    if spGetUnitDefID(uid) == hunterDefID then
      hunterUnitID = uid
      spSetUnitNoDraw(uid, true)
      Echo("[TrackScroll] Отключена отрисовка юнита: " .. uid)
    end
  end
end

function gadget:UnitCreated(unitID, unitDefID)
  if unitDefID == hunterDefID then
    hunterUnitID = unitID
    spSetUnitNoDraw(unitID, true)
    Echo("[TrackScroll] UnitCreated: " .. unitID)
  end
end

function gadget:UnitDestroyed(unitID)
  if unitID == hunterUnitID then
    Echo("[TrackScroll] UnitDestroyed: " .. unitID)
    hunterUnitID = nil
  end
end

function gadget:DrawOpaqueUnits()
  if not hunterUnitID or not shader then return end

  local frame = spGetGameFrame()
  local offset = frame * scrollSpeed

  glUseShader(shader)
  glUniform(trackOffsetLoc, offset)
  Echo("[TrackScroll] Frame: " .. frame .. " Offset: " .. offset)

  glTexture(0, trackTexture)
  Echo("[TrackScroll] Текстура: " .. trackTexture)

  glPushMatrix()
    glUnit(hunterUnitID, true)
  glPopMatrix()

  glTexture(0, false)
  glUseShader(0)
end

function gadget:Shutdown()
  Echo("[TrackScroll] Удаление шейдера")
  if shader then
    glDeleteShader(shader)
  end
end
