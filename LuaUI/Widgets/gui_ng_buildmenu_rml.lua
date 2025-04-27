-- LuaUI/Widgets/gui_ng_buildmenu_rml.lua
widget = widget or {}

function widget:GetInfo()
    return {
        name = "selected units",
        desc = "This widget is responsible for handling dynamic interactions with Rml contexts.",
        author = "nucleus_genius",
        date = "2025",
        license = "GNU GPL, v2 or later",
        layer = 0,
        enabled = true
    }
end

local opened = false
local tries = 0
local doc, unitlist

function widget:Initialize()
    Spring.Echo("BuildMenuRml: Widget загружен и инициализирован!")
    self:SelectionChanged(Spring.GetSelectedUnits())
end

function widget:Update()
    if opened then return end

    if RmlUi and RmlUi.GetContext and RmlUi.GetContext("shared") then
        Spring.Echo("BuildMenuRml: Открываю окно напрямую через RmlUi!")
        local ctx = RmlUi.GetContext("shared")

        if ctx.OpenDocument then
            doc = ctx:OpenDocument(LUAUI_DIRNAME .. "widgets_rml/buildmenu.rml")
        elseif ctx.LoadDocument then
            doc = ctx:LoadDocument(LUAUI_DIRNAME .. "widgets_rml/buildmenu.rml")
        elseif ctx.LoadRml then
            doc = ctx:LoadRml(LUAUI_DIRNAME .. "widgets_rml/buildmenu.rml")
        else
            Spring.Echo("Контекст не умеет открывать документы ни одним известным методом!")
        end

        if doc then
            Spring.Echo("BuildMenuRml: Документ открыт!")
            doc:Show()
            unitlist = doc:GetElementById("unitlist")
            if unitlist then
                Spring.Echo("unitlist: запуск")
                unitlist.inner_rml = "<div style='color:red;font-size:64px;'>ПОПАЛО!</div>"
            else
                Spring.Echo("unitlist: не найден!")
            end
        else
            Spring.Echo("BuildMenuRml: Документ не открыт!")
        end
        opened = true
    else
        tries = tries + 1
        Spring.Echo("BuildMenuRml: Жду контекста, попытка "..tries)
        if tries > 50 then opened = true end
    end
end

function widget:SelectionChanged(selectedUnits)
    Spring.Echo("SelectionChanged! units: " .. #selectedUnits)
    if not unitlist then
        Spring.Echo("нет выбранных юнитов!")
        return
    end

    if #selectedUnits == 0 then
        unitlist.inner_rml = "<div style='color:orange;font-size:32px; font-family:FreeSans;'>Ничего не выбрано</div>"
        self:HideMenu()
        return
    end

    -- Берём первого выбранного юнита (обычно для билд-меню этого достаточно)
    local unitID = selectedUnits[1]
    local unitDefID = Spring.GetUnitDefID(unitID)
    if not unitDefID then
        unitlist.inner_rml = "<div style='color:red;'>Ошибка: unitDefID не найден</div>"
        return
    end

    local udef = UnitDefs[unitDefID]
    if not udef or not udef.buildOptions or #udef.buildOptions == 0 then
        unitlist.inner_rml = "<div style='color:#fff; font-size:24px; font-family:FreeSans;'>Этот юнит ничего не может строить</div>"
        return
    end

    -- Формируем список построек
    local html = "<div style='font-family:FreeSans;'>"
    html = html .. "<b>Может строить:</b><ul>"
    for _, buildDefID in ipairs(udef.buildOptions) do
        local buildDef = UnitDefs[buildDefID]
        html = html .. "<li>" .. (buildDef and buildDef.humanName or ("unitDefID: "..buildDefID)) .. "</li>"
    end
    html = html .. "</ul></div>"

    unitlist.inner_rml = html
end
