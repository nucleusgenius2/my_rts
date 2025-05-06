function widget:GetInfo()
  return {
    name      = "Unit Scale Applier",
    desc      = "Автоматически применяет customParams.modelradius к юнитам",
    author    = "ChatGPT",
    date      = "2024",
    license   = "MIT",
    layer     = 0,
    enabled   = true,
  }
end

local SetUnitScale = Spring.SetUnitScale
local GetUnitDefID = Spring.GetUnitDefID

function ApplyScaleToUnit(unitID, unitDefID)
  local ud = UnitDefs[unitDefID]
  if ud and ud.customParams and ud.customParams.modelradius then
    local scale = tonumber(ud.customParams.modelradius)
    if scale and scale ~= 1 then
      SetUnitScale(unitID, scale, scale, scale)
    end
  end
end

function widget:UnitCreated(unitID, unitDefID, team)
  ApplyScaleToUnit(unitID, unitDefID)
end

function widget:Initialize()
  -- применим сразу ко всем существующим юнитам
  local allUnits = Spring.GetAllUnits()
  for _, unitID in ipairs(allUnits) do
    local unitDefID = GetUnitDefID(unitID)
    ApplyScaleToUnit(unitID, unitDefID)
  end
end
