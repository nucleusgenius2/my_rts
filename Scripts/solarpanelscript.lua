-- Thanks ZK for making this work
-- Body
local Base = piece "Base"
local TrueBase = piece "TrueBase"
-- Pannels
local Pannel1 = piece "Pannel1"
local Pannel2 = piece "Pannel2"
local Pannel3 = piece "Pannel3"
local Pannel4 = piece "Pannel4"
local unitDefID = Spring.GetUnitDefID(unitID)

local function MakeE()
Spring.SetUnitResourcing(unitID,"cme",2)
end


local function StopMakeE()
Spring.SetUnitResourcing(unitID,"cme",0)
end

local function Defend()
	Turn(Pannel1, x_axis, math.rad(0), math.rad(60))
	Turn(Pannel2, x_axis, math.rad(0), math.rad(60))
	Turn(Pannel3, z_axis, math.rad(0), math.rad(60))
	Turn(Pannel4, z_axis, math.rad(0), math.rad(60))
Spring.SetUnitArmored(unitID, true)
Spring.SetUnitResourcing(unitID,"cme",0)
Sleep(15000)
	Turn(Pannel1, x_axis, math.rad(75), math.rad(60))
	Turn(Pannel2, x_axis, math.rad(-75), math.rad(60))
	Turn(Pannel3, z_axis, math.rad(-75), math.rad(60))
	Turn(Pannel4, z_axis, math.rad(75), math.rad(60))
Spring.SetUnitArmored(unitID, false)
Spring.SetUnitResourcing(unitID,"cme",2)
end



function script.Create()

end

function script.Activate ( ) 
	Turn(Pannel1, x_axis, math.rad(75), math.rad(60))
	Turn(Pannel2, x_axis, math.rad(-75), math.rad(60))
	Turn(Pannel3, z_axis, math.rad(-75), math.rad(60))
	Turn(Pannel4, z_axis, math.rad(75), math.rad(60))
Spring.SetUnitArmored(unitID, false)
StartThread(MakeE)

end

function script.Deactivate ( )
	Turn(Pannel1, x_axis, math.rad(0), math.rad(60))
	Turn(Pannel2, x_axis, math.rad(0), math.rad(60))
	Turn(Pannel3, z_axis, math.rad(0), math.rad(60))
	Turn(Pannel4, z_axis, math.rad(0), math.rad(60))
Spring.SetUnitArmored(unitID, true)
StartThread(StopMakeE)

end

function script.HitByWeapon()
StartThread(Defend)

end





---death animation
function script.Killed(recentDamage, maxHealth, corpsetype)
	Explode (TrueBase, SFX.SHATTER)
	local severity = recentDamage / maxHealth
	if severity <= 0.33 then
	return 1
	else
	return 2 
	end
end