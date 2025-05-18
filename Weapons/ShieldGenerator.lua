local weaponName = "ShieldGenerator"
local weaponDef = {
  name = "Plasma Shield",
  weaponType = "Shield",

  --damage = {
   -- default = 100,
  --},

  shield = {
    alpha = 0.35,
    badColor = {1, 0.2, 0.2},
    goodColor = {0.2, 1, 0.2},
    power = 5000,                -- сколько дамага может поглотить
    powerRegen = 50,            -- восстановление в секунду
    powerRegenEnergy = 100,     -- энергия на восстановление
    radius = 300,               -- радиус щита
    repulser = true,            -- отталкивает снаряды
    smart = true,               -- только от опасных
    visible = true,             -- видно ли купол
    visibleRepulse = true,      -- видно ли отражение
    --interceptedByShieldType = 1,
    intercepttype = 479,
    exteriorShield = true,      -- рисовать снаружи

  },

  shieldRepulser = true,
}
return lowerkeys({ [weaponName] = weaponDef })
