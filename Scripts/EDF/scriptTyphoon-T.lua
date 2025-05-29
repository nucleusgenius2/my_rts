-----------------------------------------------------------------------
--  Hunter — unit-script (synced)
-----------------------------------------------------------------------
local Body        = piece "Body"
local Base        = piece "Base"
local Turret      = piece "Turret"
local TurretMGun  = piece "TurretMGun"
local Flare       = piece "Flare_3"

local Wheel_1     = piece "Wheel_1"
local Wheel_2     = piece "Wheel_2"
local Wheel_3     = piece "Wheel_3"
local Wheel_4     = piece "Wheel_4"
local Wheel_5     = piece "Wheel_5"
local Wheel_6     = piece "Wheel_6"
local Wheel_7     = piece "Wheel_7"
local Wheel_8     = piece "Wheel_8"

local wheels = {
    Wheel_1, Wheel_2, Wheel_3, Wheel_4,
    Wheel_5, Wheel_6, Wheel_7, Wheel_8
}

local AIM_SPEED     = 0.5      -- скорость поворота башни
local RESTORE_DELAY = 2000     -- мс
local SIG_AIM       = 1
local SIG_TURN      = 2

-----------------------------------------------------------------------
--  Наведение и огонь
-----------------------------------------------------------------------

local function RestoreAfterDelay()
    Sleep(RESTORE_DELAY)
    Turn(Turret,      y_axis, 0, AIM_SPEED)
    Turn(TurretMGun,  x_axis, 0, AIM_SPEED)
end

function script.AimFromWeapon1()
    return Turret
end

function script.QueryWeapon1()
    return Flare
end

function script.AimWeapon1(heading, pitch)
    Signal(SIG_AIM)
    SetSignalMask(SIG_AIM)
    Turn(Turret,     y_axis,  heading, AIM_SPEED)
    Turn(TurretMGun, x_axis, -pitch,  AIM_SPEED)
    WaitForTurn(Turret, y_axis)
    StartThread(RestoreAfterDelay)
    return true
end

function script.FireWeapon1()
    EmitSfx(Flare, 1024)
end


-----------------------------------------------------------------------
--  Движение
-----------------------------------------------------------------------

function script.StartMoving()
    for _, wheel in ipairs(wheels) do
        Spin(wheel, x_axis, 10)
    end
end

function script.StopMoving()
    for _, wheel in ipairs(wheels) do
        StopSpin(wheel, x_axis)
    end
end


-----------------------------------------------------------------------
--  Гибель
-----------------------------------------------------------------------

function script.Killed(dmg, maxHealth)
    Explode(Body, SFX.SHATTER)
    return (dmg / maxHealth <= 0.33) and 1 or 2
end
