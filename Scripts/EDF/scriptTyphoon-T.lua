-----------------------------------------------------------------------
--  Hunter — unit-script (synced)
-----------------------------------------------------------------------
local Body        = piece "Body"
local Base        = piece "Base"
local Turret      = piece "Turret"
local TurretMGun  = piece "TurretMGun"
local Flare       = piece "Flare_3"

local AIM_SPEED     = 4.0      -- рад/с
local RESTORE_DELAY = 2000     -- мс
local SIG_AIM       = 1

-----------------------------------------------------------------------
--  Наведение и огонь
-----------------------------------------------------------------------
local function RestoreAfterDelay()
    Spring.Echo("[Hunter] RestoreAfterDelay started")
    Sleep(RESTORE_DELAY)
    Spring.Echo("[Hunter] Restoring turret angles")
    Turn(Turret,      y_axis, 0, AIM_SPEED)
    Turn(TurretMGun,  x_axis, 0, AIM_SPEED)
end

function script.AimFromWeapon1()
    Spring.Echo("[Hunter] AimFromWeapon1 called")
    return Turret
end

function script.Create()
    Spring.Echo("[Hunter] script.Create() called")
    -- Лог всех объектов
    Spring.Echo("[Hunter] Piece Check:")
    Spring.Echo("  Base       =", tostring(Base))
    Spring.Echo("  Body       =", tostring(Body))
    Spring.Echo("  Turret     =", tostring(Turret))
    Spring.Echo("  TurretMGun =", tostring(TurretMGun))
    Spring.Echo("  Flare_3    =", tostring(Flare))
end


function script.QueryWeapon1()
    Spring.Echo("[Hunter] QueryWeapon1 called")
    return Flare
end

function script.AimWeapon1(heading, pitch)
    Spring.Echo(string.format("[Hunter] AimWeapon1: heading=%.2f pitch=%.2f", heading, pitch))
    Signal(SIG_AIM)
    SetSignalMask(SIG_AIM)
    Turn(Turret,     y_axis,  heading, AIM_SPEED)
    Turn(TurretMGun, x_axis, -pitch,  AIM_SPEED)
    WaitForTurn(Turret, y_axis)
    StartThread(RestoreAfterDelay)
    return true
end

function script.FireWeapon1()
    Spring.Echo("[Hunter] FireWeapon1 called")
    EmitSfx(Flare, 1024)
end

-----------------------------------------------------------------------
--  Гибель
-----------------------------------------------------------------------
function script.Killed(dmg, maxHealth)
    Spring.Echo(string.format("[Hunter] Killed: dmg=%.1f, max=%.1f", dmg, maxHealth))
    Explode(Body, SFX.SHATTER)
    return (dmg / maxHealth <= 0.33) and 1 or 2
end
