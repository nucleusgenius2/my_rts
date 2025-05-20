function gadget:GetInfo()
	return {
		name    = "Special Stealth Cloak",
		desc    = "Автоклоак юнитов с customParams.special_stealth = 1",
		author  = "nucleus_genius",
		date    = "2025",
		license = "MIT",
		layer   = 0,
		enabled = true,
	}
end

if not gadgetHandler:IsSyncedCode() then
	return
end

local SpringSetUnitCloak     = Spring.SetUnitCloak
local SpringGiveOrderToUnit  = Spring.GiveOrderToUnit
local SpringGetAllUnits      = Spring.GetAllUnits
local SpringGetUnitDefID     = Spring.GetUnitDefID
local SpringGetUnitTeam      = Spring.GetUnitTeam
local UnitDefs               = UnitDefs

-- Параметры маскировки
local CLOAK_MODE = 2         -- 2 = маскировка без decloak от вражеских юнитов (но с энергозатратами)
local DECLOAK_SETTING = true -- true = использовать decloakDistance из UnitDef

local function UnitHasSpecialStealth(unitDefID)
	local ud = UnitDefs[unitDefID]
	if not ud or not ud.customParams then return false end
	return tonumber(ud.customParams.special_stealth) == 1
end

function gadget:UnitCreated(unitID, unitDefID, unitTeam)
	if UnitHasSpecialStealth(unitDefID) then
		SpringSetUnitCloak(unitID, CLOAK_MODE, DECLOAK_SETTING)
		SpringGiveOrderToUnit(unitID, CMD.CLOAK, {1}, {}) -- активируем клоак
	end
end

function gadget:Initialize()
	for _, unitID in ipairs(SpringGetAllUnits()) do
		local unitDefID = SpringGetUnitDefID(unitID)
		local unitTeam = SpringGetUnitTeam(unitID)
		gadget:UnitCreated(unitID, unitDefID, unitTeam)
	end
end
