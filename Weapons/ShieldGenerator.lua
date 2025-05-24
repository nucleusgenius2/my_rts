local weaponName = "ShieldGenerator"
local weaponDef = {
  name = "Plasma Shield",
  --weaponType = "Shield",
    weaponType              = [[Shield]],

  damage = {
    default = 100,
  },

  shield = {
    --shieldStartingPower = 5000,
    alpha = 0.35,
    badColor = {1, 0.2, 0.2},
    goodColor = {0.2, 1, 0.2},
    power = 5000,                -- сколько дамага может поглотить
    powerRegen = 150,            -- восстановление в секунду
   -- powerRegenEnergy = 100,     -- энергия на восстановление
    radius = 300,               -- радиус щита
    repulser = false,            -- отталкивает снаряды
    smart = true,               -- только от опасных
    visible = true,             -- видно ли купол
    visibleRepulse = true,      -- видно ли отражение
    interceptedByShieldType = 1,
    ---intercepttype = 479,
    intercepttype = 1,
    shieldInterceptType  = 3,
    exteriorShield = true,      -- рисовать снаружи
    shieldRadius = 300,
    shieldStartingPower = 5000,
    shieldRepulser          = false,
  },

}
return lowerkeys({ [weaponName] = weaponDef })
