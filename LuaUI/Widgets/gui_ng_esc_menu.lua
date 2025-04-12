function widget:GetInfo()
  return {
    name      = "Pause Menu Modal",
    desc      = "Показывает модальное окно при нажатии Esc, с кнопкой выхода из игры",
    author    = "ChatGPT + ты",
    date      = "2025-04-12",
    license   = "GPLv3",
    layer     = 0,
    enabled   = true,
  }
end

local Chili
local screen0
local window, quitButton
local isOpen = false

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
    x           = "center",
    y           = "center",
    draggable   = false,
    resizable   = false,
    visible     = false,
    modal       = true,
  }

  quitButton = Chili.Button:New{
    parent    = window,
    caption   = "Выйти из игры",
    x         = "center",
    y         = 60,
    width     = 200,
    height    = 40,
    OnClick   = { function()
      Spring.Echo("exit game")
      Spring.SendCommands("quit") end 
    },
  }
end

function widget:KeyPress(key, mods, isRepeat)
  if key == 27 then -- Esc
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
