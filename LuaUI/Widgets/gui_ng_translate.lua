function widget:GetInfo()
  return {
    name    = "gui_mywidget",
    desc    = "Пример с i18n",
    author  = "ты",
    date    = "2025",
    license = "GPLv3",
    layer   = 0,
    enabled = true,
  }
end

local tr

function widget:Initialize()
  tr = WG.initializeTranslation(widget:GetInfo().name, function()
    tr = WG.Translate("mywidget") -- обновить tr при смене языка
    updateTexts()
  end)

  tr = WG.Translate("mywidget")
  updateTexts()
end

function updateTexts()
  Spring.Echo(tr("pause"), tr("exit_game"))
end
