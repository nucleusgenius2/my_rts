-- тело и оружие
local Base = piece "Base"
local Body = piece "Body"
local Turret = piece "Turret"
local TurretMGun = piece "TurretMGun"
local Flare = piece "Flare"

aimSpeed = 4.0

-- эффекты
local huntermuzzleflash = SFX.CEG

-- сигналы
local SIG_AIM = 2

function script.Create()
end

local function RestoreAfterDelay()
    Sleep(2000)
    Turn(Turret, y_axis, 0, aimSpeed)
    Turn(TurretMGun, x_axis, 0, aimSpeed)
    WaitForTurn(Turret, y_axis)
    WaitForTurn(TurretMGun, x_axis)
end

---- Aim & Fire weapon
function script.AimFromWeapon1()
    return Turret
end

function script.QueryWeapon1()
    return Flare
end

function script.AimWeapon1(heading, pitch)
    Signal(SIG_AIM)
    SetSignalMask(SIG_AIM)
    Turn(Turret, y_axis, heading, aimSpeed)
    Turn(TurretMGun, x_axis, -pitch, aimSpeed)
    WaitForTurn(Turret, y_axis)
    StartThread(RestoreAfterDelay)
    return true
end

function script.FireWeapon1()
    EmitSfx(Flare, huntermuzzleflash)
end

--- death animation
function script.Killed(recentDamage, maxHealth, corpsetype)
    Explode(Body, SFX.SHATTER)
    local severity = recentDamage / maxHealth
    if severity <= 0.33 then
        return 1
    else
        return 2
    end
end
