local unitName  =  "ArmoredPlantTech2Edf"

local unitDef  =  {
    --Internal settings
    BuildPic = "Factory.png",
    Category = "TANK SMALL NOTAIR NOTSUB",
    ObjectName = "EDF/buildings/ArmoredPlant.dae",
    name = "Ground Factory2",
    Side = "Vroomers",
    TEDClass = "Building",
    UnitName = "Ground Factory",
    script = "EDF/buildings/scriptArmoredPlantTech2Edf.lua",
	corpse = [[groundfactory_dead]],
	icontype = "buildinglandfactory",
    --Unit limitations and properties
    Description = "Makes ground units.",
    MaxDamage = 3500,
    idleTime = 0,
    idleAutoHeal = 0,
    RadarDistance = 0,
    SightDistance = 600,
    SoundCategory = "Building",
    Upright = 1,
	maxWaterDepth = 4,
	sfxtypes             = {
        explosionGenerators = {
            [[custom:buildermuzzleflash]],
        },
    },
    --Energy and metal related
    BuildCostEnergy = 750,
    BuildCostMetal = 750,
    Buildtime = 750, 
    --Size and Abilites
    MaxSlope = 33,

   -- FootprintX = 14,
   -- FootprintZ = 12,

    FootprintX = 8,
   FootprintZ = 11,

    canSelfDestruct = 1,
    repairable = 1,
   -- CanMove = 1,
    CanPatrol = 0,
    --Building
    Builder = true,
    canBeAssisted = true,
    canAssist = false,
    ShowNanoSpray = true,
    CanBeAssisted = true,
    canCapture = false,
    canResurrect = false,
    canReclaim = false,
    canRepair = true,
    canRestore = false,
    workerTime = 10,
    buildoptions =
    {
        [[constructor]],
        [[stunburst]],
        [[hunter]],
        [[pointer]],
        [[picket]],
        [[cleaver]],
        [[ravager]],
        [[panther]],
        [[mangonel]],
	},
	--Hitbox
    collisionVolumeOffsets    =  "0 0 -7.5",
    collisionVolumeScales     =  "170 98 175",
    collisionVolumeType       =  "box",
	YardMap = "oooooooo oooooooo oyyyyyyo oyyyyyyo oyyyyyyo oyyyyyyo oyyyyyyo oyyyyyyo oyyyyyyo oyyyyyyo yyyyyyyy",
   -- YardMap = "oooooooooooooo oooooooooooooo oyyyyyyyyyyyyo oyyyyyyyyyyyyo oyyyyyyyyyyyyo oyyyyyyyyyyyyo oyyyyyyyyyyyyo oyyyyyyyyyyyyo oyyyyyyyyyyyyo oyyyyyyyyyyyyo oyyyyyyyyyyyyo yyyyyyyyyyyyyy",


    --Weapons and related
	explodeAs = [[FactoryExplosion]],
	selfDestructAs = [[FactoryExplosion]],

}

return lowerkeys({ [unitName]  =  unitDef })
