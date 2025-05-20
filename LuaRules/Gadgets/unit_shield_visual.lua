function gadget:GetInfo()
  return {
    name = "NG Simple Shield Visual",
    desc = "Draws a shield using a display list sphere",
    author = "nucleus genius",
    layer = 1000,
    enabled = true,
  }
end

if gadgetHandler:IsSyncedCode() then return end

local shieldUnits = {}
local shieldSphereList

function gadget:Initialize()
  for _, unitID in ipairs(Spring.GetAllUnits()) do
    gadget:UnitCreated(unitID, Spring.GetUnitDefID(unitID))
  end

  shieldSphereList = gl.CreateList(function()
    gl.PushMatrix()
    gl.Translate(0, 0, 0)
    gl.Scale(1, 1, 1)
    gl.Shape(GL.TRIANGLE_FAN, {
      {v = {0, 1, 0}},
      {v = {1, 0, 0}},
      {v = {0.7, 0, 0.7}},
      {v = {0, 0, 1}},
      {v = {-0.7, 0, 0.7}},
      {v = {-1, 0, 0}},
      {v = {-0.7, 0, -0.7}},
      {v = {0, 0, -1}},
      {v = {0.7, 0, -0.7}},
      {v = {1, 0, 0}}, -- close the loop
    })
    gl.PopMatrix()
  end)
end

function gadget:Shutdown()
  if shieldSphereList then
    gl.DeleteList(shieldSphereList)
  end
end

function gadget:UnitCreated(unitID, unitDefID)
  local def = UnitDefs[unitDefID]
  if def and def.customParams and def.customParams.shield_radius then
    shieldUnits[unitID] = {
      radius = tonumber(def.customParams.shield_radius) or 300,
    }
  end
end

function gadget:UnitDestroyed(unitID)
  shieldUnits[unitID] = nil
end

function gadget:DrawWorldPreUnit()
  if not shieldSphereList then return end

  gl.DepthTest(true)
  gl.Color(0.2, 0.6, 1.0, 0.25)

  for unitID, data in pairs(shieldUnits) do
    local x, y, z = Spring.GetUnitPosition(unitID)
    if x then
      gl.PushMatrix()
      gl.Translate(x, y + 15, z)
      gl.Scale(data.radius, data.radius, data.radius)
      gl.CallList(shieldSphereList)
      gl.PopMatrix()
    end
  end

  gl.Color(1, 1, 1, 1)
  gl.DepthTest(false)
end
