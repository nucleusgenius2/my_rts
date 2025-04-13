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
local window, quitButton,pauseButton
local isOpen = false


--получаем размер окна
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

  screen0 = Chili.Screen0

  window = Chili.Window:New{
    parent      = screen0,
    caption     = "Пауза",
    width       = 300,
    height      = 150,
    x           = x,
    y           = y,
    draggable   = false,
    resizable   = false,
    visible     = false,
    modal       = true,
    align="center";
  }

  window:SetVisibility(false) -- закрываем окно по умолчанию

  quitButton = Chili.Button:New{
    parent    = window,
    caption   = "Выйти из игры",
    x         = 40,
    y         = 60,
    width     = 200,
    height    = 40,
    OnClick   = { function()
      Spring.Echo("лог")
      Spring.SendCommands("quitforce")
      end
    },
  }

  pauseButton = Chili.Button:New{
    parent    = window,
    caption   = "Пауза",
    x         = 40,
    y         = 20,
    width     = 200,
    height    = 40,
    OnClick   = { function()
      Spring.SendCommands("pause")
      Spring.Echo("Пауза переключена")
    end },
  }

end

function widget:KeyPress(key, mods, isRepeat)
  if key == 27 then -- Esc кнопка
    isOpen = not isOpen
    
    if window then
      Spring.Echo("лог 2")
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
