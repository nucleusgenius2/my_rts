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

 weapons             = {

    {
      def                = [[THUD_WEAPON]],
      badTargetCategory  = [[FIXEDWING]],
      onlyTargetCategory = [[FIXEDWING LAND SINK TURRET SHIP SWIM FLOAT GUNSHIP HOVER]],
    },

    {
      def = [[SHIELD]],
    },

  },

  weaponDefs          = {

    SHIELD      = {
      name                    = [[Energy Shield]],

      damage                  = {
        default = 10,
      },

      exteriorShield          = true,
      shieldAlpha             = 0.2,
      shieldBadColor          = [[1 0.1 0.1 1]],
      shieldGoodColor         = [[0.1 0.1 1 1]],
      shieldInterceptType     = 3,
      shieldPower             = 1200,
      shieldPowerRegen        = 13,
      shieldPowerRegenEnergy  = 0,
      shieldRadius            = 300,
      shieldRepulser          = false,
      shieldStartingPower     = 1200,
      smartShield             = true,
      visibleShield           = false,
      visibleShieldRepulse    = false,
      weaponType              = [[Shield]],
    },

    THUD_WEAPON = {
      name                    = [[Light Plasma Cannon]],
      areaOfEffect            = 36,
      cegTag                  = [[light_plasma_trail]],
      craterBoost             = 0,
      craterMult              = 0,

      customParams        = {
        light_camera_height = 1400,
        light_color = [[0.80 0.54 0.23]],
        light_radius = 200,
      },

      damage                  = {
        default = 170,
        planes  = 170,
      },

      explosionGenerator      = [[custom:MARY_SUE]],
      impulseBoost            = 0,
      impulseFactor           = 0.4,
      interceptedByShieldType = 1,
      range                   = 280,
      reloadtime              = 4,
      soundHit                = [[explosion/ex_med5]],
      soundStart              = [[weapon/cannon/cannon_fire5]],
      turret                  = true,
      weaponType              = [[Cannon]],
      weaponVelocity          = 210,
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
