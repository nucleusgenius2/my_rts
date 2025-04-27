if not RmlUi then
    return
end

function widget:GetInfo()
    return {
        name = "TestRmlWindowModel",
        desc = "Shows simple RmlUI window with BAR-style model",
        author = "chatgpt",
        date = "2025",
        license = "GPLv3",
        layer = 50,
        enabled = true,
    }
end

local document
local main_model_name = "model"
local init_model = {
    testblockVisible = false,
    message = "Hello, find my text in the data model!",
}

function widget:Initialize()
    widget.rmlContext = RmlUi.GetContext("shared")
    widget.dm_handle = widget.rmlContext:OpenDataModel(main_model_name, init_model)
    if not widget.dm_handle then
        Spring.Echo("RmlUi: Failed to open data model", main_model_name)
        return
    end
    document = widget.rmlContext:LoadDocument("luaui/widgets_rml/tets.rml", widget)
    if not document then
        Spring.Echo("Failed to load document")
        return
    end
    document:ReloadStyleSheet()
    document:Show()
end

_G.ShowTestBlock = function(event)
  Spring.Echo("обращение из кнопки")
    -- Используем переменную-флаг в этом скоупе
   -- widget.testblockVisible = not widget.testblockVisible
    --widget:OpenDoc(widget.testblockVisible)
        if widget.dm_handle then
            widget.dm_handle.testblockVisible = not widget.dm_handle.testblockVisible
        else
            Spring.Echo("Нет widget.dm_handle!")
        end
end
