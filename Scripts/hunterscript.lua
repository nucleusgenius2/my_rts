-----------------------------------------------------------------------
--  Hunter — unit-script (synced)
-----------------------------------------------------------------------
local Base        = piece "Base"
local Body        = piece "Body"
local Turret      = piece "Turret"
local TurretMGun  = piece "TurretMGun"
local Flare       = piece "Flare"

local AIM_SPEED     = 4.0      -- рад/с
local RESTORE_DELAY = 2000     -- мс
local SIG_AIM       = 1

-----------------------------------------------------------------------
--  Наведение и огонь
-----------------------------------------------------------------------
local function RestoreAfterDelay()
    Sleep(RESTORE_DELAY)
    Turn(Turret,      y_axis, 0, AIM_SPEED)
    Turn(TurretMGun,  x_axis, 0, AIM_SPEED)
end

function script.AimFromWeapon1()  return Turret end
function script.QueryWeapon1()    return Flare  end

function script.AimWeapon1(h, p)
    Signal(SIG_AIM);  SetSignalMask(SIG_AIM)
    Turn(Turret,     y_axis,  h, AIM_SPEED)
    Turn(TurretMGun, x_axis, -p, AIM_SPEED)
    WaitForTurn(Turret, y_axis)
    StartThread(RestoreAfterDelay)
    return true
end

function script.FireWeapon1()
    EmitSfx(Flare, 1024)       -- замените ID, если нужно
end

-----------------------------------------------------------------------
--  Гусеницы: шлём команды в unsynced-гаджет
-----------------------------------------------------------------------
function script.StartMoving()
    SendToUnsynced("hunter_track_start", unitID)
end

function script.StopMoving()
    SendToUnsynced("hunter_track_stop", unitID)
end

-----------------------------------------------------------------------
--  Гибель
-----------------------------------------------------------------------
function script.Killed(dmg, maxHealth)
    Explode(Body, SFX.SHATTER)
    return (dmg / maxHealth <= 0.33) and 1 or 2
end
