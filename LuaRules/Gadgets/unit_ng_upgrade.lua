function gadget:GetInfo()
    return {
        name = "NG Upgrade System",
        desc = "Applies upgrades per player when conditions met",
        author = "nucleus_genius",
        layer = 0,
        enabled = true,
    }
end

if not gadgetHandler:IsSyncedCode() then return end

-- === НАСТРОЙКИ ===
local hpBoost = 500
local eligibleUpgradeKey = "hp_level_1"
local requiredTechLevel = 2
local metalCost = 1
local energyCost = 2

-- === СОСТОЯНИЕ ===
local playerUpgrades = {}         -- [playerID][upgradeKey] = true
local playerTechReady = {}        -- [playerID] = true
local upgradedUnits = {}          -- [unitID] = true

-- === УТИЛИТЫ ===
local function GetPlayerTeam(playerID)
    local _, _, _, teamID = Spring.GetPlayerInfo(playerID, false)
    return teamID
end

-- Проверка наличия tech здания (единожды)
local function CheckPlayerHasTechBuilding(playerID)
    if playerTechReady[playerID] then return true end

    local teamID = GetPlayerTeam(playerID)
    local units = Spring.GetTeamUnits(teamID)
    for _, unitID in ipairs(units) do
        local defID = Spring.GetUnitDefID(unitID)
        local def = defID and UnitDefs[defID]
        if def and tonumber(def.customParams and def.customParams.techlevel) == requiredTechLevel then
            playerTechReady[playerID] = true
            return true
        end
    end
    return false
end

-- Применение апгрейда к конкретному юниту
local function TryApplyUpgrade(unitID, unitDefID, teamID)
    if upgradedUnits[unitID] then return end

    local cp = UnitDefs[unitDefID].customParams or {}
    if not cp[eligibleUpgradeKey] then return end

    local playerList = Spring.GetPlayerList(teamID, true)
    for _, playerID in ipairs(playerList) do
        if playerUpgrades[playerID] and playerUpgrades[playerID][eligibleUpgradeKey] then
            local hp = Spring.GetUnitHealth(unitID)
            local maxHP = UnitDefs[unitDefID].health + hpBoost
            Spring.SetUnitMaxHealth(unitID, maxHP)
            Spring.SetUnitHealth(unitID, { health = hp + hpBoost })
            upgradedUnits[unitID] = true
            break
        end
    end
end

-- === ПУБЛИЧНАЯ ТОЧКА ДЛЯ UI ===
function GG.UpgradeTechForPlayer(playerID, upgradeKey)
    local teamID = GetPlayerTeam(playerID)
    local metal, _, _, energy = Spring.GetTeamResources(teamID, "metal")

    if metal < metalCost or energy < energyCost then
        Spring.Echo("[Upgrade] Недостаточно ресурсов у игрока " .. playerID)
        return false
    end

    if not CheckPlayerHasTechBuilding(playerID) then
        Spring.Echo("[Upgrade] Нет нужного здания у игрока " .. playerID)
        return false
    end

    -- Списание ресурсов
    Spring.UseTeamResource(teamID, "metal", metalCost)
    Spring.UseTeamResource(teamID, "energy", energyCost)

    -- Отметим апгрейд
    playerUpgrades[playerID] = playerUpgrades[playerID] or {}
    playerUpgrades[playerID][upgradeKey] = true

    Spring.Echo("[Upgrade] Игрок " .. playerID .. " активировал улучшение: " .. upgradeKey)

    -- Применим к текущим юнитам
    local units = Spring.GetTeamUnits(teamID)
    for _, unitID in ipairs(units) do
        local defID = Spring.GetUnitDefID(unitID)
        TryApplyUpgrade(unitID, defID, teamID)
    end

    return true
end

-- === ВЫЗОВ ЧЕРЕЗ LUA MSG (из widget через SendLuaRulesMsg) ===
function gadget:RecvLuaMsg(msg, playerID)
    local prefix, upgradeKey = msg:match("^(%a+)|(.+)$")
    if prefix == "upgrade" and upgradeKey then
        GG.UpgradeTechForPlayer(playerID, upgradeKey)
    end
end

-- === СОБЫТИЯ ===
function gadget:UnitCreated(unitID, unitDefID, teamID)
    TryApplyUpgrade(unitID, unitDefID, teamID)
end

function gadget:UnitFinished(unitID, unitDefID, teamID)
    TryApplyUpgrade(unitID, unitDefID, teamID)
end

function gadget:UnitDestroyed(unitID)
    upgradedUnits[unitID] = nil
end
