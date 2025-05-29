-- Body
local Base = piece "Base"
local TrueBase = piece "TrueBase"
local Constructor = piece "ConstructorEndLeft"
local ConstructorMuzzle = piece "ConstructorMuzzleLeft"
local FlareLeft = piece "FlareLeft"
local FlareRight = piece "FlareRight"
local BuildSpot = piece "BuildSpot"
aimSpeed = 3.0
local buildermuzzleflash = SFX.CEG
local isbuilding = true

local ConstructorBaseRight = piece "ConstructorBaseRight"
local ConstructorMidRight = piece "ConstructorMidRight"
local ConstructorEndRight = piece "ConstructorEndRight"
local ConstructorMuzzleRight = piece "ConstructorMuzzleRight"

local ConstructorBaseLeft = piece "ConstructorBaseLeft"
local ConstructorMidLeft  = piece "ConstructorMidLeft"
local ConstructorEndLeft  = piece "ConstructorEndLeft"
local ConstructorMuzzleLeft  = piece "ConstructorMuzzleLeft"

local Van_1 = piece "Van_1"
local Van_2 = piece "Van_2"
local Van_3 = piece "Van_3"


Spring.SetUnitNanoPieces(unitID, { FlareLeft, FlareRight }) --эффекты постройки

local function Building()
    local t = 0
    while isbuilding do
        -- Вращение основания по кругу (вокруг y)
        --Turn(ConstructorBase, z_axis, math.rad(t % 360), math.rad(60))
        Turn(ConstructorBaseRight, z_axis, -80, math.rad(60))
        Turn(ConstructorBaseLeft, z_axis, 80, math.rad(60))

        -- Плечо вперёд-назад (по z)
        local midZ = math.rad(7 * math.sin(t / 20))
        Turn(ConstructorMidRight, x_axis, midZ, math.rad(20))
        Turn(ConstructorMidLeft, x_axis, midZ, math.rad(20))

        -- Локоть вверх-вниз (по x)
        local minDeg = 41  -- минимальный угол (нижняя граница)
        local maxDeg = 50   -- максимальный угол (верхняя граница)

        local normalized = (math.sin(t / 15) + 1) / 2   -- нормализуем синус в [0, 1]
        local angleDeg = minDeg + (maxDeg - minDeg) * normalized
        local endX = -math.rad(angleDeg)                -- перевод в радианы

        Turn(ConstructorEndRight, x_axis, endX, math.rad(25))
        Turn(ConstructorEndLeft,  x_axis, endX, math.rad(25))

        -- Башня с лазером влево-вправо (по y)
        local muzzleY = math.rad(30 * math.sin(t / 18))
        Turn(ConstructorMuzzleRight, y_axis, muzzleY, math.rad(30))
        Turn(ConstructorMuzzleLeft, y_axis, muzzleY, math.rad(30))

        -- Строительный эффект
        EmitSfx(FlareRight, buildermuzzleflash)
        EmitSfx(FlareLeft, buildermuzzleflash)

        Sleep(100)
        t = t + 5
    end

    -- Возврат в исходное положение
    -- Возврат в исходное положение
    Turn(ConstructorBaseRight, z_axis, 0, math.rad(90))
    Turn(ConstructorBaseLeft, z_axis, 0, math.rad(90))

    Turn(ConstructorMidRight, x_axis, 0, math.rad(90))
    Turn(ConstructorMidLeft,  x_axis, 0, math.rad(90))

    Turn(ConstructorEndRight, x_axis, 0, math.rad(90))
    Turn(ConstructorEndLeft,  x_axis, 0, math.rad(90))

    Turn(ConstructorMuzzleRight, y_axis, 0, math.rad(90))
    Turn(ConstructorMuzzleLeft,  y_axis, 0, math.rad(90))
end


function script.Create()
    Spin(Van_1, z_axis, math.rad(16))
    Spin(Van_2, z_axis,  math.rad(16))
    Spin(Van_3, z_axis,  math.rad(16))
end

function script.QueryBuildInfo() 
	return BuildSpot
end

function script.QueryNanoPiece()
    local nano = nanoPieces[nanoNum]
    return nano
end

function script.Activate()
    SetUnitValue(COB.INBUILDSTANCE, 1)
    return 1
end

function script.Deactivate()
    SetUnitValue(COB.INBUILDSTANCE, 0)
    return 0
end

function script.StartBuilding(heading, pitch)
    isbuilding = true
	StartThread(Building)
end

function script.StopBuilding()
    isbuilding = false
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
