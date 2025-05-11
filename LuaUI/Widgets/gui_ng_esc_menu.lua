function widget:GetInfo()
  return {
    name      = "NG Pause Menu Modal",
    desc      = "Показывает модальное окно при нажатии Esc, с кнопкой выхода из игры и настройками",
    author    = "nucleus genius",
    date      = "2025-04-12",
    license   = "All rights reserved; no commercial use",
    layer     = 0,
    enabled   = true,
  }
end

local Chili
local screen0
local window, quitButton, pauseButton, settingsButton, backButton, saveButton
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

   -- Подключаем виджет SettingsManager
  local SettingsManager = WG.SettingsManager

  -- Загрузка настроек
  SettingsManager:LoadSettings()

   -- Получаем текущий язык из настроек
  local currentLang = SettingsManager:Get("language")

   --глобальное подключение
  tr = function(k) return WG.Translate("interface." .. k) end

  --получение конфигураций графики
 local delayedCommands = {}
 local controls = {}
 local configVars = {
   --{ key = "LuaShaders",      name = "Lua Shaders (требуется перезапуск)",     type = "bool" },
   { key = "MSAALevel",       nameKey = "setting_msaa",                        type = "number" },
   { key = "GroundDetail",    nameKey = "land_detailing",                      type = "number" },
   { key = "ShadowMapSize",   nameKey = "setting_shadow_map_size",             type = "number" },
   { key = "Shadows",         nameKey = "setting_shadow",                      type = "bool" },
   --{ key = "SSAO",            name = "SSAO (окклюзия)",                      type = "bool" },
   --{ key = "UsePBO",          name = "PBO (только для чтения)",              type = "readonly" },
   { key = "Fullscreen",      nameKey = "setting_fullscreen",                  type = "bool" },
   --{ key = "AllowDeferredMapRendering", name = "Deferred Map Rendering",     type = "bool" },
 }

   --вкладка графика
   local graphicsTab = Chili.Control:New{
     width  = "100%",
     height = "100%",
   }

   local labels = {}
   for i, var in ipairs(configVars) do
     local label = Chili.Label:New{
       parent  = graphicsTab,
       --caption = var.name,
       caption = '',
       width   = "45%",
       x       = 20,
       y       = 10 + 35 * (i - 1),
     }
     labels[i] = label
     local current = Spring.GetConfigInt(var.key, 1)
     local input

     if var.type == "bool" then
       input = Chili.Checkbox:New{
       parent  = graphicsTab,
       checked = current == 1,
       x       = "55%",
       width   = 100,
       y       = 10 + 35 * (i - 1),
       OnChange = {
          function(_, state)
            local val = state and 1 or 0
            Spring.SetConfigInt(var.key, val)
            if var.key == "Shadows" then
               Spring.SendCommands(val == 1 and "shadows 1" or "shadows 0")
            elseif var.key == "SSAO" then
               Spring.SendCommands(val == 1 and "ssao 1" or "ssao 0")
            end
          end
       },
     }

     else -- number
       input = Chili.TextBox:New{
       parent = graphicsTab,
       text   = tostring(current),
       x      = "55%",
       width  = 100,
       y      = 10 + 35 * (i - 1),
       OnTextInput = {
         function(_, val)
            local num = tonumber(val)
            if num then
              Spring.SetConfigInt(var.key, num)
              if var.key == "GroundDetail" then
                table.insert(delayedCommands, "GroundDetail " .. num)
              end
            end
         end
       },
     }
      end
   end

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



   --кнопка настроек
   settingsButton = Chili.Button:New{
    parent  = window,
    caption = tr("settings"),
    x       = 40,
    y       = 70,
    width   = 200,
    height  = 40,
    textPadding = {0, 10},
    valign = "bottom",
    OnClick = {
      function()
        if settingsWindow then
          window:SetVisibility(false)
          settingsWindow:SetVisibility(true)
        end
      end
    }
   }



   -- кнопка сохранения игры (только для одиночной игры)
   if Spring.GetGameRulesParam("gameMode") ~= "multiplayer" and not Spring.IsReplay() then
    saveButton = Chili.Button:New{
      parent  = window,
      caption = tr("save_game") or "Сохранить игру",
      x       = 40,
      y       = 120,
      width   = 200,
      height  = 40,
      textPadding = {0, 10},
      valign = "bottom",
      OnClick = {
        function()

        local filename = "save_" .. os.date("%Y%m%d_%H%M%S")
        --стучим в виджет сейва
        WG.savegame.SaveGame(filename, "Мой тестовый сейв", true)

        end
      }
    }
   end



   --кнопка выхода из игры
   quitButton = Chili.Button:New{
      parent  = window,
      caption = tr("exit_game"),
      x       = 40,
      y       = 170,
      width   = 200,
      height  = 40,
      textPadding = {0, 10},
      valign = "bottom",

      OnClick = { function() Spring.SendCommands("quitforce") end }
   }

   -- окно настроек
   settingsWindow = Chili.Window:New{
    parent    = screen0,
    caption   = tr("settings"),
    width     = 500,
    height    = 340,
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
      selectedIndex = i
    end
  end

  -- вкладка звук
  local soundTab = Chili.Control:New{
    width  = "100%",
    height = "100%",
  }





  languageSelect = Chili.ComboBox:New{
      parent    = interfaceTab,
      x         = 20,
      y         = 20,
      width     = 200,
      height    = 30,
      itemHeight = 40,
      height    = 40,  -- Увеличиваем высоту самого селектора
      items     = langNames,
      selected  = selectedIndex,
      OnSelect  = {
        function(_, selectedIndex)
          -- Логируем выбранный индекс
          Spring.Echo("Индекс выбранного языка: " .. selectedIndex)

          -- Проверяем, есть ли язык с этим индексом
          local lang = languages[selectedIndex]  -- Индекс языка
          if lang then
            Spring.Echo("Выбран язык: " .. lang.key)
            currentLang = lang.key

            -- Устанавливаем новый язык в SettingsManager
            SettingsManager:Set("language", lang.key)
            -- Сохраняем настройки в файл
            SettingsManager:SaveSettings()

            WG.lang(currentLang)
            Spring.Echo("Текущий язык: " .. currentLang)
          else
            Spring.Echo("Ошибка: не удалось найти язык с индексом " .. selectedIndex)
          end
        end
      }
  }


   -- Кнопка "Назад" для возврата в основное меню из табов
   backButton = Chili.Button:New{
        parent  = settingsWindow,
        caption = tr("back_to_menu") or "Back to Menu 1",
        x       = 10,
        y       = 270,
        width   = 200,
        height  = 40,
        OnClick = {
          function()
            settingsWindow:SetVisibility(false)  -- Скрываем окно настроек
            window:SetVisibility(true)           -- Показываем основное окно
          end
        }
   }

   -- панель с вкладками (добавляем сразу)
   tabPanel = Chili.TabPanel:New{
   parent  = settingsWindow,
   width   = "100%",
   height  = "100%",
   tabs = {
      {
        name = "interface",
        caption = tr("interface_tab") or "Интерфейс",
        children = { interfaceTab },

      },
      {
        name = "sound",
        caption = tr("sound_tab") or "Звук",
        children = { soundTab },
      },
        {
          name = "graphics",
          caption = tr("graphics_tab") or "Графика",
          children = { graphicsTab }
        },
      },
   }


  -- обновление языка
  WG.InitializeTranslation(function()
    tr = function(k) return WG.Translate("interface." .. k) end

    for i, var in ipairs(configVars) do
      if labels[i] and var.nameKey then
        labels[i]:SetCaption(tr(var.nameKey))
      end
    end

    if window then window.caption = tr("menu") end
    if pauseButton then pauseButton.caption = tr("pause") end
    if quitButton then quitButton.caption = tr("exit_game") end
    if saveButton then saveButton.caption = tr("save_game") end
    if settingsButton then settingsButton.caption = tr("settings") end
    if settingsWindow then settingsWindow.caption = tr("settings") end

    if backButton then backButton.caption = tr("back_to_menu") end
    -- tab caption обновится автоматически, если TabPanel реализует перерисовку
    -- Обновляем локализацию caption для вкладок
    if tabPanel and tabPanel.tabs then
      for i, tab in ipairs(tabPanel.tabs) do
        local tabBarItem = tabPanel.children[1].children[i]
        if tabBarItem then
          local captionKey = tab.name .. "_tab"
          tabBarItem.caption = tr(captionKey) or tab.caption
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
