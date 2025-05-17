local weaponName = "TMDLaser"
local weaponDef = {
	name                    = "TMD Laser Interceptor",
	weaponType              = "Cannon",          -- важно: Cannon, не BeamLaser!
	interceptor             = 1,
	coverage                = 1000,
	stockpile               = true,
	stockpileTime           = 2,
	commandfire             = true,
	canAttackGround         = false,

	range                   = 1000,
	reloadtime              = 1.5,
	turret                  = true,
	accuracy                = 1000,

	projectiles             = 1,
	soundStart              = "Weapons/Heavylaser",
	explosionGenerator      = [[custom:intercept]],

	damage = {
		default = 10000,
	},

	customParams = {
		canintercepttype = "missile",
	},
}

return lowerkeys({ [weaponName] = weaponDef })
