function widget:GetInfo()
  return {
    name      = "Pause Menu Modal",
    desc      = "Показывает модальное окно при нажатии Esc, с кнопкой выхода из игры",
    author    = "nucleus genius",
    date      = "2025-04-12",
    license   = "GPLv3",
    layer     = 0,
    enabled   = true,
  }
end

local Chili
local screen0
local window, quitButton, pauseButton, languageButton
local isOpen = false
local currentLang = "en"  -- Начальный язык

-- Получаем размер окна
local vsx, vsy = Spring.GetViewGeometry()
local x = vsx / 2 - 150
local y = vsy / 2 - 150

function widget:Initialize()
  Chili = WG.Chili
  if not Chili then
    Spring.Echo("Chili GUI не найден. Виджет 'Pause Menu Modal' отключён.")
    widgetHandler:RemoveWidget()
    return
  end

  -- Инициализируем перевод
  tr = WG.Translate  -- Используем функцию перевода

  screen0 = Chili.Screen0

  -- Создаем окно
  window = Chili.Window:New{
    parent      = screen0,
    caption     = tr("interface.menu"),  -- Переводим заголовок
    width       = 300,
    height      = 150,
    x           = x,
    y           = y,
    draggable   = false,
    resizable   = false,
    visible     = false,
    modal       = true,
    align       = "center",
  }

  window:SetVisibility(false)  -- Закрываем окно по умолчанию

  -- Кнопка выхода
  quitButton = Chili.Button:New{
    parent    = window,
    caption   = tr("interface.exit_game"),  -- Переводим текст кнопки
    x         = 40,
    y         = 60,
    width     = 200,
    height    = 40,
    OnClick   = { function()
      Spring.SendCommands("quitforce")
    end }
  }

  -- Кнопка паузы
  pauseButton = Chili.Button:New{
    parent    = window,
    caption   = tr("interface.pause"),  -- Переводим текст кнопки
    x         = 40,
    y         = 20,
    width     = 200,
    height    = 40,
    OnClick   = { function()
      Spring.SendCommands("pause")
    end }
  }

  -- Кнопка смены языка
  languageButton = Chili.Button:New{
    parent    = window,
    caption   = tr("interface.change_language"),  -- Переводим текст кнопки
    x         = 40,
    y         = 100,  -- Размещаем кнопку под другими кнопками
    width     = 200,
    height    = 40,
    OnClick   = { function()
      -- Сменить язык
      currentLang = (currentLang == "en") and "ru" or "en"  -- Переключение между английским и русским
      WG.lang(currentLang)  -- Изменяем язык
      -- Мы не вызываем updateTexts, потому что перевод обновится автоматически
    end }
  }
end

-- Обработка нажатия клавиш
function widget:KeyPress(key, mods, isRepeat)
  if key == 27 then  -- Esc
    isOpen = not isOpen
    if window then
      window:SetVisibility(isOpen)
    end
    return true
  end
end

function widget:Shutdown()
  if window then
    window:Dispose()
  end
end
