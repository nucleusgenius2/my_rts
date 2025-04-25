--Wiki: http://springrts.com/wiki/Sidedata.lua

-- Определение данных для фракций
local sidedata = {
    -- Первая фракция
    [1] = {
        name = "roomers",  -- Имя фракции
        startUnit = "commander",  -- Стартовый юнит для фракции
        sideName = "UEF",  -- Идентификатор фракции
        --startUnits = {"arm_com", "arm_laser", "arm_solar", "arm_veh_con"},  -- Стартовые юниты
        sideColor = {0.8, 0.3, 0.3},  -- Цвет для фракции
        description = "Фракция людей",  -- Описание фракции
    },
    -- Вторая фракция
    [2] = {
        name = "Core",  -- Имя фракции
        startUnit = "commander",  -- Стартовый юнит
        sideName = "CORE",  -- Идентификатор фракции
        --startUnits = {"cor_com", "cor_laser", "cor_solar", "cor_veh_con"},  -- Стартовые юниты
        sideColor = {0.3, 0.3, 0.8},  -- Цвет для фракции
        description = "The Core faction is known for its heavy armor and devastating weapons.",  -- Описание
    },
}

return sidedata
