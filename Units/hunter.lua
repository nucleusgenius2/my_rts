local unitName  =  "hunter"

local unitDef  =  {
--Внутренние настройки
    BuildPic = "Hunter.png",
    Category = "TANK SMALL NOTAIR NOTSUB",
    ObjectName = "tank_1.dae",
    --ObjectName = "SciFi_tank_1.s3o",

    name = "Охотник 2",
    Side = "Vroomers",
    TEDClass = "Vech",
    UnitName = "Охотник",
    script = "hunterscript.lua",
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
	explodeAs = [[SmallExplosion]],
	selfDestructAs = [[SmallExplosion]],
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
    maxAcc = 0.35,
    BrakeRate = 0.1,
    FootprintX = 2,
    FootprintZ = 2,
    MaxSlope = 45,
    MaxVelocity = 3.2,
    MaxWaterDepth = 5,
    MovementClass = "custom",
    TurnRate = 2250,


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
    collisionVolumeOffsets    =  "0 -5 0",
    collisionVolumeScales     =  "15.5 10 40",
    collisionVolumeType       =  "box",


    --Оружие и связанное с ним
    NoChaseCategory = "AIR",

    weapons = {
        [1]={name = "MachineGun",
               turret = true
        },
    },
   tracktype = "huntertrack",
    customParams = {
        techlevel = 2,
        modelradius = 20,

        --гусеницы
         normaltex = "hunter_normal.png",
         trackshader = 'trackShader',
         tankvel = 1.0,
         turnrate = 0.0,
         trackwidth = 0.1 --процент от верха текстуры
    }
}

return lowerkeys({ [unitName]  =  unitDef })
