local unitName  =  "laboratory"

local unitDef  =  {
    --Internal settings
    BuildPic = "Fusion Reactor.png",
    Category = "TANK SMALL NOTAIR NOTSUB",
    ObjectName = "Fusion Reactor.s3o",
    name = "Laboratory UEF",
    Side = "Vroomers",
    TEDClass = "Building",
    UnitName = "Laboratory",
    script = "fusionreactorscript.lua",
	corpse = [[fusionreactor_dead]],
	icontype = "buildingenergy",
    --Unit limitations and properties
    Description = "Advanced energy generator (35E).",
    MaxDamage = 2500,
    idleTime = 0,
    idleAutoHeal = 0,
    RadarDistance = 0,
    SightDistance = 450,
    SoundCategory = "Building",
    Upright = 0,
	maxWaterDepth = 400,
    --Energy and metal related
    BuildCostEnergy = 175,
    BuildCostMetal = 175,
    Buildtime = 175,
    energyMake = 35, 

    --Size and Abilites
    MaxSlope = 33,
    FootprintX = 5,
    FootprintZ = 7,
    canSelfDestruct = 1,
    repairable = 1,
    CanMove = 0,
    CanPatrol = 0,
	

   --Hitbox
   collisionVolumeOffsets    =  "0 0 0",
   collisionVolumeScales     =  "68 103 102",
   collisionVolumeType       =  "box",
   YardMap = "oooo oooo oooo oooo",
   --Weapons and related
   explodeAs = [[FusionExplosion]],
   selfDestructAs = [[FusionExplosion]],



}

return lowerkeys({ [unitName]  =  unitDef })
