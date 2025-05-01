function gadget:GetInfo()
    return {
        name    = "NG cheat menu",
        desc    = "Создание юнитов по команде от UI",
        author  = "nucleus_genius",
        date    = "2025",
        license = "GPLv2",
        layer   = 0,
        enabled = true,
    }
end

if not gadgetHandler:IsSyncedCode() then return end

function gadget:Initialize()
    Spring.Echo("[Spawn Gadget] Инициализирован")
end

function gadget:RecvLuaMsg(msg, playerID)
    if msg:sub(1, 9) == "spawnunit" then
        local parts = {}
        for part in msg:gmatch("[^|]+") do
            table.insert(parts, part)
        end

        local unitName = parts[2]
        local x = tonumber(parts[3])
        local y = tonumber(parts[4])
        local z = tonumber(parts[5])
        local teamID = tonumber(parts[6])

        if unitName and x and y and z and teamID then
            local unitID = Spring.CreateUnit(unitName, x, y, z, 0, teamID)
            if unitID then
                Spring.Echo(string.format("[Spawn Gadget] Создан юнит %s (ID %d) для команды %d", unitName, unitID, teamID))
            else
                Spring.Echo("[Spawn Gadget] Ошибка при создании юнита.")
            end
        else
            Spring.Echo("[Spawn Gadget] Неверные параметры: " .. msg)
        end
    end
end
