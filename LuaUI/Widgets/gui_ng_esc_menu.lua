function widget:GetInfo()
  return {
    name      = "Pause Menu Modal",
    desc      = "Показывает модальное окно при нажатии Esc, с кнопкой выхода из игры и настройками",
    author    = "nucleus genius",
    date      = "2025-04-12",
    license   = "GPLv3",
    layer     = 0,
    enabled   = true,
  }
end

local Chili
local screen0
local window, quitButton, pauseButton, settingsButton
local settingsWindow, tabPanel, languageSelect
local isOpen = false
local currentLang = "en"
local tr = function(key) return key end  -- fallback

local vsx, vsy = Spring.GetViewGeometry()
local x = vsx / 2 - 150
local y = vsy / 2 - 150

local languages = {
  { key = "en", name = "English" },
  { key = "ru", name = "Русский" },
}

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

   --глобальное подлючение
  tr = function(k) return WG.Translate("interface." .. k) end
  screen0 = Chili.Screen0

  window = Chili.Window:New{
    parent    = screen0,
    caption   = tr("menu"),
    width     = 300,
    height    = 240,
    x         = x,
    y         = y,
    draggable = false,
    resizable = false,
    visible   = false,
    modal     = true,
    align     = "center",
  }

  window:SetVisibility(false) -- по умолчанию скрыто

  --кнопка паузы
  pauseButton = Chili.Button:New{
    parent  = window,
    caption = tr("pause"),
    x       = 40,
    y       = 20,
    width   = 200,
    height  = 40,
    OnClick = { function() Spring.SendCommands("pause") end }
  }

  --кнопка выхода из игры
  quitButton = Chili.Button:New{
    parent  = window,
    caption = tr("exit_game"),
    x       = 40,
    y       = 70,
    width   = 200,
    height  = 40,
    OnClick = { function() Spring.SendCommands("quitforce") end }
  }

  --кнопка настроек
  settingsButton = Chili.Button:New{
    parent  = window,
    caption = tr("settings"),
    x       = 40,
    y       = 120,
    width   = 200,
    height  = 40,
    OnClick = {
      function()
        if settingsWindow then
          window:SetVisibility(false)
          settingsWindow:SetVisibility(true)
        end
      end
    }
  }

  -- окно настроек
  settingsWindow = Chili.Window:New{
    parent    = screen0,
    caption   = tr("settings"),
    width     = 500,
    height    = 300,
    x         = vsx / 2 - 200,
    y         = vsy / 2 - 150,
    draggable = true,
    resizable = false,
    visible   = false,
    modal     = true,
  }

  settingsWindow:SetVisibility(false) -- окно настроек скрыто по умолчанию

  -- вкладка интерфейс
  local interfaceTab = Chili.Control:New{
    width  = "100%",
    height = "100%",
  }

  local langNames = {}
  local selectedIndex = 0
  for i, lang in ipairs(languages) do
    table.insert(langNames, lang.name)
    if lang.key == currentLang then
      selectedIndex = i - 1
    end
  end

    languageSelect = Chili.ComboBox:New{
      parent    = interfaceTab,
      x         = 20,
      y         = 20,
      width     = 200,
      height    = 30,
      items     = langNames,
      selected  = selectedIndex,
      OnSelect  = {
        function(_, selectedIndex)
          -- Логируем выбранный индекс
          Spring.Echo("Индекс выбранного языка: " .. selectedIndex)

          -- Проверяем, есть ли язык с этим индексом (без +1)
          local lang = languages[selectedIndex]  -- Индекс без +1, так как у вас правильная индексация
          if lang then
            Spring.Echo("Выбран язык: " .. lang.key)
            currentLang = lang.key
            WG.lang(currentLang)
            Spring.Echo("Текущий язык: " .. currentLang)
          else
            Spring.Echo("Ошибка: не удалось найти язык с индексом " .. selectedIndex)
          end
        end
      }
    }

  -- панель с вкладками (добавляем сразу)
  tabPanel = Chili.TabPanel:New{
    parent  = settingsWindow,
    width   = "100%",
    height  = "100%",
    tabs    = {
      {
        name = "interface",
        caption = tr("interface_tab") or "Интерфейс",
        children = { interfaceTab },

      },
    },
  }


  -- обновление языка
  WG.InitializeTranslation(function()
    tr = function(k) return WG.Translate("interface." .. k) end

    if window then window.caption = tr("menu") end
    if pauseButton then pauseButton.caption = tr("pause") end
    if quitButton then quitButton.caption = tr("exit_game") end
    if settingsButton then settingsButton.caption = tr("settings") end
    if settingsWindow then settingsWindow.caption = tr("settings") end
    -- tab caption обновится автоматически, если TabPanel реализует перерисовку
    -- Обновляем локализацию caption для вкладок
    if tabPanel and tabPanel.tabs then
        for i, tab in ipairs(tabPanel.tabs) do
            if tab.name == "interface" then
                -- Ищем объект вкладки в TabPanel и обновляем caption
                local tabBarItem = tabPanel.children[1].children[i]  -- Получаем TabBarItem
                if tabBarItem then
                    tabBarItem.caption = tr("interface_tab") or "Интерфейс"  -- Обновляем название вкладки
                    --Spring.Echo("Обновили вкладку " .. tab.name)
                end
            end
        end
    end

    -- Принудительно перерисовать TabPanel, чтобы изменения вступили в силу
    if tabPanel then
      tabPanel:Invalidate()  -- Перерисовываем TabPanel
    end

  end, widget:GetInfo().name)
end

function widget:KeyPress(key, mods, isRepeat)
  if key == 27 then -- Esc
    isOpen = not isOpen
    if window then window:SetVisibility(isOpen) end
    if settingsWindow then settingsWindow:SetVisibility(false) end
    return true
  end
end

function widget:Shutdown()
  if window then window:Dispose() end
  if settingsWindow then settingsWindow:Dispose() end
end
