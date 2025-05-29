local unitName  =  "Typhoon-T"

local unitDef  =  {
    --Внутренние настройки
    BuildPic = "Hunter.png",
    Category = "TANK SMALL NOTAIR NOTSUB",
    ObjectName = "EDF/Typhoon-T.dae",

    name = "Тайфун-Т",
    Side = "Vroomers",
    TEDClass = "Vech",
    UnitName = "Охотник",
    script = "EDF/scriptTyphoon-T.lua",
	icontype = "raider",
    --Ограничения и свойства блока
    BuildTime = 1280,
    Description = "Быстрый юнит рейдер.",
    MaxDamage = 320,
    idleTime = 300,
    idleAutoHeal = 5,
    RadarDistance = 0,
    SightDistance = 560,
    SoundCategory = "TANK",
    Upright = 0,
	explodeAs = [[SmallExplosion]], -- взрыв после смерти юнита
	selfDestructAs = [[SmallExplosion]], -- взрыв после самоуничтожения
	sfxtypes = {
	    explosionGenerators = {
	        [[custom:huntermuzzleflash]],
	    },
    },
    corpse = [[hunter_dead]],
    --Энергетика и металлы
    BuildCostEnergy = 75,
    BuildCostMetal = 75,
    BuildTime = 75,
    --Поиск пути и связанные с ним
    --maxAcc = 0.20, --ускорение
    maxAcc = 0.03572, --ускорение
    maxDec = 0.07144, -- макс торможение
    BrakeRate = 0.35,
    FootprintX = 6, --область выделения юнита
    FootprintZ = 6,
    MaxSlope = 20, -- макс угол на который можно заехать
    MaxVelocity = 2.3, --макс скорость движения
    MaxWaterDepth = 5,
    MovementClass = "size-2-4",

    TurnRate = 500, --скорость поворота

    usePieceCollisionVolumes = true, -- коллизицию считать по модели

    crushable = false, -- есть в баре

    --Способности
    Builder = 0,
    CanAttack = 1,
    CanGuard = 1,
    CanMove = 1,
    CanPatrol = 1,
    CanStop = 1,
    LeaveTracks = 1,
    Reclaimable = 1,
    canSelfDestruct = 1,
    repairable = 1,


    --Hitbox
    collisionVolumeOffsets    =  "0 0 -2",
    collisionvolumescales = "40 20 75", --2 значение ширина, последнее длинна
    collisionVolumeType       =  "box",


    --Оружие и связанное с ним
    NoChaseCategory = "AIR",

    weapons = {
        [1]={
          name = "Typhoon-TWeapon",
            turret = true
        },
    },
    --для следов
    tracktype = "huntertrack",
    trackOffset            = 0,
    trackStrength          = 8,
    trackStretch           = 1,
    trackWidth             = 30,
   -- turnRate               = 1920,


    customParams = {
        techlevel = 2,
        modelradius = 20,

        minattackrange = 200,

        --для меню
        mass = 75,
        energy = 75,
        buildtime = 75,

    }
}

return lowerkeys({ [unitName]  =  unitDef })
