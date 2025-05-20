function gadget:GetInfo()
	return {
		name    = "Special Stealth Cloak",
		desc    = "Автоклоак юнитов с customParams.special_stealth = 1 и снятие клоака при уроне",
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
local SpringGetGameFrame     = Spring.GetGameFrame
local UnitDefs               = UnitDefs

local CLOAK_MODE = 4 --уровень невидимости, в движке их 4
local DECLOAK_SETTING = true
local UNCLOAK_DURATION = 150  -- 5 секунд при 30 fps

local stealthUnits = {}  -- [unitID] = {defID, teamID}
local recloakFrame = {}  -- [unitID] = frameNumber

local function UnitHasSpecialStealth(unitDefID)
	local ud = UnitDefs[unitDefID]
	if not ud or not ud.customParams then return false end
	return tonumber(ud.customParams.special_stealth) == 1
end

function gadget:UnitCreated(unitID, unitDefID, unitTeam)
	if UnitHasSpecialStealth(unitDefID) then
		stealthUnits[unitID] = {unitDefID, unitTeam}
		SpringSetUnitCloak(unitID, CLOAK_MODE, DECLOAK_SETTING)
		SpringGiveOrderToUnit(unitID, CMD.CLOAK, {1}, {})
	end
end

function gadget:UnitDestroyed(unitID)
	stealthUnits[unitID] = nil
	recloakFrame[unitID] = nil
end

function gadget:Initialize()
	for _, unitID in ipairs(SpringGetAllUnits()) do
		local unitDefID = SpringGetUnitDefID(unitID)
		local unitTeam = SpringGetUnitTeam(unitID)
		gadget:UnitCreated(unitID, unitDefID, unitTeam)
	end
end

function gadget:UnitDamaged(unitID, unitDefID, unitTeam)
	if stealthUnits[unitID] then
		SpringSetUnitCloak(unitID, 0, DECLOAK_SETTING)
		recloakFrame[unitID] = SpringGetGameFrame() + UNCLOAK_DURATION
	end
end

function gadget:GameFrame(frame)
	for unitID, targetFrame in pairs(recloakFrame) do
		if frame >= targetFrame then
			SpringSetUnitCloak(unitID, CLOAK_MODE, DECLOAK_SETTING)
			SpringGiveOrderToUnit(unitID, CMD.CLOAK, {1}, {})
			recloakFrame[unitID] = nil
		end
	end
end
