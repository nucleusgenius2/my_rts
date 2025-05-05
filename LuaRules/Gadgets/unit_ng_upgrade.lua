function gadget:GetInfo()
    return {
        name = "NG Upgrade System",
        desc = "Applies HP upgrade to units if tech building exists",
        author = "nucleus genius",
        layer = 0,
        enabled = true,
    }
end

if not gadgetHandler:IsSyncedCode() then return end

local hpBoost = 500  -- Сколько HP добавлять
local requiredTechLevel = 2
local eligibleUpgradeKey = "hp_level_1"

local upgradedUnits = {}
local techReady = {} -- teamID -> true

-- Проверка, есть ли tech building у команды
local function CheckTechLabBuilt(teamID)
    if techReady[teamID] then return true end

    local units = Spring.GetTeamUnits(teamID)
    for _, unitID in ipairs(units) do
        local defID = Spring.GetUnitDefID(unitID)
        local def = UnitDefs[defID]
        local cp = def.customParams or {}
        if tonumber(cp.techlevel) == requiredTechLevel then
            techReady[teamID] = true
            return true
        end
    end
    return false
end

-- Применяем апгрейд
local function TryApplyUpgrade(unitID, unitDefID, teamID)
    if upgradedUnits[unitID] then return end

    local cp = UnitDefs[unitDefID].customParams or {}
    if cp[eligibleUpgradeKey] then
        if CheckTechLabBuilt(teamID) then
            local hp = Spring.GetUnitHealth(unitID)
            local maxHP = UnitDefs[unitDefID].health + hpBoost
            Spring.SetUnitMaxHealth(unitID, maxHP)
            Spring.SetUnitHealth(unitID, {health = hp + hpBoost})
            upgradedUnits[unitID] = true
        end
    end
end

function gadget:UnitCreated(unitID, unitDefID, teamID)
    TryApplyUpgrade(unitID, unitDefID, teamID)
end

function gadget:UnitFinished(unitID, unitDefID, teamID)
    TryApplyUpgrade(unitID, unitDefID, teamID)
end

function gadget:GameFrame(frame)
    -- Переходная проверка, если lab был построен после других юнитов
    for _, teamID in ipairs(Spring.GetTeamList()) do
        if CheckTechLabBuilt(teamID) then
            local units = Spring.GetTeamUnits(teamID)
            for _, unitID in ipairs(units) do
                if not upgradedUnits[unitID] then
                    local defID = Spring.GetUnitDefID(unitID)
                    TryApplyUpgrade(unitID, defID, teamID)
                end
            end
        end
    end
end
