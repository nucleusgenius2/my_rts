local weaponName = "TMDLaser"
weaponDef = {
	--weaponType              = "Cannon",
	weaponType              = "BeamLaser", -- лазер сбивает лучше

	name                    = "TMD Laser Interceptor",

	interceptor             = 1,
	coverage                = 800,
	--stockpile               = true, --ломало сбитие снарядов
	stockpileTime           = 1.5,
	--commandfire             = true,
	commandfire             = false,
	canAttackGround         = false,

	range                   = 800,
	reloadtime              = 2.6,
	turret                  = true,
	tolerance               = 5000,

	accuracy                = 1000,
	areaOfEffect            = 50,
	explosionGenerator      = [[custom:hlthit]],

	projectiles             = 1,

	damage = {
		default = 10000,
	},

	soundStart              = [[Weapons/Heavylaser]],
	soundStartVolume        = 4,
	soundHit                = [[Weapons/Laserhit]],
	soundHitVolume          = 4,

	customParams = {
		canintercepttype = "missile",
	},
}

return lowerkeys({[weaponName] = weaponDef})
