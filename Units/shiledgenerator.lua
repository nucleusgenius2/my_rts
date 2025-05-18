local unitName = "shieldgenerator"

local unitDef = {
  name = "Shield Generator",
  description = "Shield Generator",
  objectName = "Solar Pannel2.s3o",
  script = "solarpanelscript.lua",
  buildCostEnergy = 300,
  buildCostMetal = 200,
  buildTime = 300,
  maxDamage = 1500,
  sightDistance = 400,
  footprintX = 4,
  footprintZ = 4,
  yardMap = "oooo oooo oooo oooo",
  canSelfDestruct = true,
  onOffable = true,
  activateWhenBuilt = true,
  upright = true,
  category = "TANK SMALL NOTAIR NOTSUB",
  explodeAs = "MediumBuildingExplosion",
  selfDestructAs = "MediumBuildingExplosion",

weapons = {
  [1] = {
    def = "ShieldGenerator",
  },
},
  customParams = {
    techlevel = 2,
    shield_radius = 300,
    shield_power = 5000,
    shield_radius = 300,
  },
}

return lowerkeys({ [unitName] = unitDef })
