widgets = widgets or {}

-- Временный глобальный контейнер
widget = nil
VFS.Include(LUAUI_DIRNAME .. "Widgets/gui_ng_buildmenu_rml.lua")
if widget then
    table.insert(widgets, widget)
    widget = nil  -- Очень важно сбросить!
end

-- ...инклудь другие виджеты по той же схеме...

-- Создаём handler, если нет
widgetHandler = widgetHandler or {}
widgetHandler.widgets = widgets

-- Для отслеживания выделения
local prevSelection = {}

local function sameSelection(a, b)
    if #a ~= #b then return false end
    for i = 1, #a do
        if a[i] ~= b[i] then return false end
    end
    return true
end

function widgetHandler:SelectionChanged(selection)
    for _, w in ipairs(self.widgets) do
        if type(w.SelectionChanged) == "function" then
            w:SelectionChanged(selection)
        end
    end
end

function widgetHandler:Update()
    -- Проверяем, изменилось ли выделение
    local selection = Spring.GetSelectedUnits()
    if not sameSelection(selection, prevSelection) then
        self:SelectionChanged(selection)
        -- Копируем текущее выделение
        prevSelection = {}
        for i = 1, #selection do
            prevSelection[i] = selection[i]
        end
    end

    -- Вызываем Update во всех виджетах
    for _, w in ipairs(self.widgets) do
        if type(w.Update) == "function" then
            w:Update()
        end
    end
end

function widgetHandler:Initialize()
    for _, w in ipairs(self.widgets) do
        if type(w.Initialize) == "function" then
            w:Initialize()
        end
    end
end

-- Вызывай widgetHandler:Initialize() при старте (например, из main.lua или вручную)
-- И вызывай widgetHandler:Update() каждый кадр, например из game update цикла
