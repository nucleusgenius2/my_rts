local unitName  =  "stormcloud"

local unitDef  =  {
--Internal settings
BuildPic = "Stormcloud.png",
    Category = "AIR SMALL NOTSUB",
    ObjectName = "Stormcloud.s3o",
    name = "Stormcloud",
    Side = "Vroomers",
    TEDClass = "Vech",
    UnitName = "Stormcloud",
    script = "stormcloudscript.lua",
	icontype = "airriot",
--Unit limitations and properties
    Description = "Heavy Carpet Bomber.",
    MaxDamage = 2400,
    idleTime = 0,
    idleAutoHeal = 0,
    RadarDistance = 0,
    SightDistance = 720,
    SoundCategory = "TANK",
    Upright = 0,
	explodeAs = [[MediumAirExplosion]],
	selfDestructAs = [[MediumAirExplosion]],
   corpse = [[stormcloud_dead]],
--Energy and metal related
    BuildCostEnergy = 800,
    BuildCostMetal = 800,
    BuildTime = 800,
--Pathfinding and related
    maxAcc = 0.25,
    BrakeRate = 0.1,
    FootprintX = 3,
    FootprintZ = 3,
    MaxSlope = 45,
    speed = 102, --124
    MaxWaterDepth = 5,
    MovementClass = "Large Vechicle",
    TurnRate = 1700,

    
--Abilities
    Builder = 0,
    CanAttack = 1,
    CanGuard = 1,
    CanMove = 1,
    CanPatrol = 1,
    CanStop = 1,
    LeaveTracks = 0,
    Reclaimable = 1,
    canSelfDestruct = 1,
    repairable = 1,
	
--Aerial things
canFly = 1,
hoverAttack = 0,
cruiseAlt = 375, --375
turnradius = 20,


--Hitbox
collisionVolumeOffsets    =  "0 5 0",
collisionVolumeScales     =  "30 18 48",
collisionVolumeType       =  "box",

   
--Weapons and related
    BadTargetCategory = "AIR",
    NoChaseCategory = "AIR",
	
weapons = {
[1]={name  = "CarpetBombs",
	   onlyTargetCategory = [[TANK]],
        mainDir = "0 -1 0",
		maxAngleDif = 70,
	},
},


}

return lowerkeys({ [unitName]  =  unitDef })