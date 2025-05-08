---------------------------------------------------------------
--  Unit_TankTracks_GL4  – прокрутка гусениц (UNSYNCED)
---------------------------------------------------------------
function widget:GetInfo()
  return {
    name      = "Unit_TankTracks_GL4",
    layer     = 0,
    enabled   = true,
  }
end

-- работаем только в unsynced
if Spring.GetSyncedCommands then  return  end

---------------------------------------------------------------
--  0. Таблица, в которую будем писать направления
WG.trackDir   = WG.trackDir   or {}   -- ⚠ гарантируем, что это TABLE
local trackDir = WG.trackDir          -- локальный псевдоним
local offset   = {}                   -- unitID → phase 0..1

---------------------------------------------------------------
--  1. список юнитов: unitDefID → направление (1 / -1)
local trackedDefs = {
  [UnitDefNames["hunter"].id] = 1,
}

---------------------------------------------------------------
--  2. компилируем шейдер
local vs = VFS.LoadFile("Shaders/tanktracks.vert")
local fs = VFS.LoadFile("Shaders/tanktracks.frag")
local shader = gl.CreateShader{ vertex = vs, fragment = fs,
                                uniformInt = { tex0 = 0 } }

if not shader then
  Spring.Echo("[TankTracks] shader compile error:")
  Spring.Echo(gl.GetShaderLog() or "no log")
  widgetHandler:RemoveWidget()
  return
end

---------------------------------------------------------------
--  3. шаблон LuaMaterial
local mat = {
  shader       = shader,
  texunits     = { [0] = "unittextures/hunter_tracks.png" },
  uniformFloat = { trackOffset = 0.0 },
}

---------------------------------------------------------------
--  4. навешиваем материал
function widget:UnitCreated(uID, uDefID)
  local dir = trackedDefs[uDefID]
  if dir then
    Spring.UnitRendering.SetUnitLuaMaterial(uID, "opaque", mat)
    trackDir[uID] = dir
    offset[uID]   = 0
  end
end

function widget:UnitDestroyed(uID)
  trackDir[uID] = nil
  offset[uID]   = nil
end

---------------------------------------------------------------
--  5. крутим UV (30 Гц)
local FPS       = 30
local frameStep = Game.gameSpeed / FPS
local SCALE     = 0.03      -- подберите под скорость юнита

function widget:GameFrame(f)
  if f % frameStep ~= 0 then return end
  for uID, dir in pairs(trackDir) do          -- WG.trackDir уже TABLE
    if Spring.ValidUnitID(uID) then
      local vx, _, vz = Spring.GetUnitVelocity(uID)
      local v  = math.sqrt(vx*vx + vz*vz)
      local ph = (offset[uID] + dir * v * SCALE / FPS) % 1
      offset[uID] = ph
      Spring.UnitRendering.SetMaterialUniform(
          uID, "opaque", "trackOffset", ph)
    else
      trackDir[uID] = nil
      offset[uID]   = nil
    end
  end
end

---------------------------------------------------------------
function widget:Shutdown()
  if shader then gl.DeleteShader(shader) end
end
