widget = widget or {}

function widget:GetInfo()
  return {
    name    = "TestRmlWindow",
    desc    = "Shows simple RmlUI window on game start",
    author  = "chatgpt",
    date    = "2025",
    license = "GPLv3",
    layer   = 50,
    enabled = true,
  }
end

local opened = false
local tries = 0
local doc

-- Вот тут делаем глобальную функцию!
_G.ShowTestBlock = function(event)
    Spring.Echo("ShowTestBlock вызван Rocket напрямую!")
    if doc then
        local el = doc:GetElementById("testblock")
        if el then
            if el.style.display == "none" then
                el.style.display = "block"
            else
                el.style.display = "none"
            end
        end
    end
end

function widget:Initialize()
    Spring.Echo("инит тест")

    if RmlUi and RmlUi.AddLuaEventFunction then
        RmlUi.AddLuaEventFunction("ShowTestBlock", _G.ShowTestBlock)
    end

    if opened then return end

    local ctx = RmlUi and RmlUi.GetContext and RmlUi.GetContext("shared")
    if ctx then
        Spring.Echo("TestRmlWindow: контекст найден, пробую открыть buildmenu.rml")
        if ctx.OpenDocument then
            doc = ctx:OpenDocument(LUAUI_DIRNAME .. "widgets_rml/tets.rml")
        elseif ctx.LoadDocument then
            doc = ctx:LoadDocument(LUAUI_DIRNAME .. "widgets_rml/tets.rml")
        elseif ctx.LoadRml then
            doc = ctx:LoadRml(LUAUI_DIRNAME .. "widgets_rml/tets.rml")
        end

        if doc then
            doc:Show()
            Spring.Echo("TestRmlWindow: buildmenu.rml открыт!")
        else
            Spring.Echo("TestRmlWindow: не могу открыть buildmenu.rml!")
        end
        opened = true
    else
        tries = tries + 1
        Spring.Echo("TestRmlWindow: жду контекста, попытка " .. tries)
        if tries > 50 then opened = true end
    end
end

-- остальные функции, если нужны...
