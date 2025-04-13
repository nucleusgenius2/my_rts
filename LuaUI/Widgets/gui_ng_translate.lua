function widget:GetInfo()
return {
    name = "gui_mywidget",
    desc = "Пример с i18n",
    author = "ты",
    date = "2025",
    license = "GPLv3",
    layer = 0,
    enabled = true,
}
end

local tr
local strPause, strExit

function widget:Initialize()
tr = WG.InitializeTranslation(widget:GetInfo().name, function()
strPause = WG.Translate("mywidget", "pause")
strExit = WG.Translate("mywidget", "exit_game")
end)

strPause = WG.Translate("mywidget", "pause")
strExit = WG.Translate("mywidget", "exit_game")

Spring.Echo(strPause, strExit) -- Пример вывода
end
