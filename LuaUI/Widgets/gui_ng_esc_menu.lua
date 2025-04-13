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
local tr = function(key) return key end  -- fallback
local currentLang = "en"

local vsx, vsy = Spring.GetViewGeometry()
local x = vsx / 2 - 150
local y = vsy / 2 - 150

function widget:Initialize()
  Chili = WG.Chili
  if not Chili then
    Spring.Echo("Chili GUI не найден.")
    widgetHandler:RemoveWidget()
    return
  end

  if not WG.Translate or not WG.lang or not WG.InitializeTranslation then
    Spring.Echo("i18n API не загружен.")
    widgetHandler:RemoveWidget()
    return
  end

  tr = function(k) return WG.Translate("interface." .. k) end

  screen0 = Chili.Screen0

  window = Chili.Window:New{
    parent    = screen0,
    caption   = tr("menu"),
    width     = 300,
    height    = 200,
    x         = x,
    y         = y,
    draggable = false,
    resizable = false,
    visible   = false,
    modal     = true,
    align     = "center",
  }

   window:SetVisibility(false) -- по умолчанию скрыто

  pauseButton = Chili.Button:New{
    parent  = window,
    caption = tr("pause"),
    x       = 40,
    y       = 20,
    width   = 200,
    height  = 40,
    OnClick = { function() Spring.SendCommands("pause") end }
  }

  quitButton = Chili.Button:New{
    parent  = window,
    caption = tr("exit_game"),
    x       = 40,
    y       = 70,
    width   = 200,
    height  = 40,
    OnClick = { function() Spring.SendCommands("quitforce") end }
  }

  languageButton = Chili.Button:New{
    parent  = window,
    caption = tr("change_language"),
    x       = 40,
    y       = 120,
    width   = 200,
    height  = 40,
    OnClick = {
      function()
        currentLang = (currentLang == "en") and "ru" or "en"
        WG.lang(currentLang) --  Автоматически вызовет обновление интерфейса (языка)
      end
    }
  }

  -- подписка на обновление языка
  WG.InitializeTranslation(function()
    tr = function(k) return WG.Translate("interface." .. k) end

    if window then window.caption = tr("menu") end
    if pauseButton then pauseButton.caption = tr("pause") end
    if quitButton then quitButton.caption = tr("exit_game") end
    if languageButton then languageButton.caption = tr("change_language") end
  end, widget:GetInfo().name)
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
  if window then window:Dispose() end
end
