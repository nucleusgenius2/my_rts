function widget:GetInfo()
    return {
        name    = "NG Cheat menu units",
        desc    = "Chili-меню для создания юнитов по клику",
        author  = "nucleus_genius",
        date    = "2025",
        license = "GNU GPL v2",
        layer   = 0,
        enabled = true,
       handler = true,
    }
end

local Chili
local window
local isVisible = false
local selectedTeamID = Spring.GetLocalTeamID()
local teamCombo

-- Определение числа колонок
local numColumns = 6  -- Число колонок в меню

function widget:Initialize()
        Spring.Echo("7777")
    if not WG.Chili then
        Spring.Echo("Chili UI не загружен.")
        widgetHandler:RemoveWidget()
        return
    end

    Chili = WG.Chili
    local screen0 = Chili.Screen0

    window = Chili.Window:New{
        x = '20%',
        y = '20%',
        width = 820,
        height = 540,
        caption = "Создание юнитов",
        parent = screen0,
        draggable = true,
        resizable = true,
        visible = false,
    }

   window:SetVisibility(false) -- по умолчанию скрыто

    -- Список команд
    local teamItems = {}
    local teamMap = {}

    for _, teamID in ipairs(Spring.GetTeamList()) do
        local _, leader = Spring.GetTeamInfo(teamID)
        local name = select(1, Spring.GetPlayerInfo(leader)) or "unknown"
        local label = string.format("Team %d (%s)", teamID, name)
        table.insert(teamItems, label)
        teamMap[#teamItems] = teamID
    end

    teamCombo = Chili.ComboBox:New{
        x = 10,
        y = 10,
        width = 300,
        height = 30,
        items = teamItems,
        selected = 1,
        OnSelect = {
            function(_, index)
                selectedTeamID = teamMap[index]
                Spring.Echo("Выбрана команда: " .. tostring(selectedTeamID))
            end
        },
        parent = window,
    }

    local scroll = Chili.ScrollPanel:New{
        x = 0,
        y = 50,
        right = 0,
        bottom = 0,
        padding = {5, 5, 5, 5},
        parent = window,
    }

    local count = 0
    local buttonWidth = 120
    local buttonHeight = 170 -- высота картинки с отступом
    local x_offset = 40  -- Начальный отступ по оси X
    local y_offset = 0   -- Начальный отступ по оси Y
    local maxHeight = 540 -- Максимальная высота окна

    for unitName, unitDef in pairs(UnitDefNames) do
        local unitDefID = unitDef.id

        local icon = Chili.Image:New{
            file = "#" .. unitDefID,
            width = 100,
            height = 100,
            keepAspect = true,
            minHeight = 100,
            maxHeight = 80,
        }

        local label = Chili.Label:New{
            caption = unitDef.humanName or unitName,
            width = "100%",
            height = 84,
            align = "center",
              valign = "bottom",
            font = {
                size = 10,
                outline = true,
            },
        }

        local content = Chili.StackPanel:New{
            orientation = "vertical",
            width = "100%",
            height = "100%",
            children = {icon, label},
        }

        -- Вычисляем координаты для каждой кнопки
        local button = Chili.Button:New{
            caption = "",
            width = buttonWidth,
            height = buttonHeight,
            minHeight = 150,
            maxHeight = 150,
            autosize = false,  -- Отключаем авто-изменение размеров
            tooltip = unitDef.humanName,
            x = x_offset,
            y = y_offset,
            children = {content},
            OnClick = {
                function()
                    local mx, my = Spring.GetMouseState()
                    local type, coords = Spring.TraceScreenRay(mx, my, true)
                    if type == "ground" and coords then
                        local x, y, z = coords[1], coords[2], coords[3]
                        Spring.SendLuaRulesMsg(string.format("spawnunit|%s|%d|%d|%d|%d", unitName, x, y, z, selectedTeamID))
                    else
                        Spring.Echo("Невозможно определить координаты.")
                    end
                end
            },
        }

        -- Обновляем отступы для следующей кнопки
        count = count + 1

        -- Расчёт координат для кнопок
        -- Увеличиваем `x_offset` на ширину кнопки для следующей колонки
        if count % numColumns == 0 then
            x_offset = 40  -- Если колонка заполнена, возвращаемся в начало
            y_offset = y_offset + buttonHeight  -- Переходим на новую строку
        else
            x_offset = x_offset + buttonWidth  -- Переходим на следующую колонку
        end

        -- Если кнопки выходят за пределы окна, уменьшаем отступ по оси Y
        if y_offset + buttonHeight > maxHeight then
            Spring.Echo("Слишком много кнопок! Требуется увеличить высоту окна.")
        end

        scroll:AddChild(button)
    end

    Spring.Echo("Юнитов загружено в меню: " .. count)
end

function widget:KeyPress(key, mods, isRepeat)
    -- Проверяем, что нажата клавиша 1 и модификатор Shift
       if key == 49 and mods.shift and not isRepeat then
        Spring.Echo("444")

        isVisible = not isVisible
        if window then
            window:SetVisibility(isVisible)
            Spring.Echo("Окно Unit Spawner " .. (isVisible and "показано" or "скрыто"))
        end
        return true
    end
end


function widget:Shutdown()
    if window then
        window:Dispose()
    end
end
