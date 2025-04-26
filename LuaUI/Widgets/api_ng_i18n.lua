function widget:GetInfo()
  return {
    name      = "NG i18n",
    desc      = "Internationalization library for Spring",
    author    = "gajop banana_Ai",
    date      = "WIP",
    license   = "GPLv2",
    version   = "0.1",
    layer     = -math.huge,
    enabled   = true,
    api       = true,
    alwaysStart = true,
  }
end

Spring.Utilities = Spring.Utilities or {}
Spring.Utilities.json = VFS.Include("LuaRules/Utilities/json.lua", nil)

local i18n = VFS.Include("LuaUI/i18nlib/i18n/init.lua", nil)
if not i18n then
  Spring.Echo("Ошибка: Не удалось загрузить модуль i18n.")
  return
end

Spring.Echo("i18n модуль загружен успешно.")

local langValue = "en"
local langListeners = {}

local translationExtras = {}

local translations = {
  interface = true,
}

local function addListener(l, widgetName)
  if l and type(l) == "function" then
    local okay, err = pcall(l)
    if okay then
      langListeners[widgetName] = l
    else
      Spring.Echo("i18n API subscribe failed: " .. widgetName .. "\nCause: " .. err)
    end
  end
end

local function loadLocale(i18n, database, locale)
  local path = "LuaUi/configs/lang/" .. database .. "." .. locale .. ".json"
  if VFS.FileExists(path, VFS.RAW_FIRST) then
    local json = Spring.Utilities.json
    local lang = json.decode(VFS.LoadFile(path, VFS.RAW_FIRST))
    local t = {}
    t[locale] = lang
    i18n.load(t)
    return true
  else
    Spring.Echo("Не удалось найти файл перевода: " .. tostring(path))
  end
  return false
end

local function fireLangChange()
  for db, trans in pairs(translations) do
    if type(trans) == "table" and not trans.locales[langValue] then
      local extras = translationExtras[db]
      if extras then
        for i = 1, #extras do
          loadLocale(trans.i18n, extras[i], langValue)
        end
      end
      loadLocale(trans.i18n, db, langValue)
      trans.locales[langValue] = true
    end
    if type(trans) == "table" then
      trans.i18n.setLocale(langValue)
    end
  end

  for w, f in pairs(langListeners) do
    local okay, err = pcall(f, langValue)
    if not okay then
      Spring.Echo("i18n API update failed: " .. w .. "\nCause: " .. err)
      langListeners[w] = nil
    end
  end
end

local function lang(newLang)
  if not newLang then
    return langValue
  elseif langValue ~= newLang then
    langValue = newLang
    fireLangChange()
  end
end

local function initializeTranslation(database)
  Spring.Echo("Инициализация базы: " .. tostring(database))

  local trans = {
    i18n = i18n,
    locales = { en = true },
  }

  loadLocale(trans.i18n, database, "en")

  local extras = translationExtras[database]
  if extras then
    for i = 1, #extras do
      loadLocale(trans.i18n, extras[i], "en")
    end
  end

  return trans
end

local function shutdownTranslation(widget_name)
  langListeners[widget_name] = nil
end

local function Translate(dbKey, text, data, opts)
  Spring.Echo("Ключ который передается ", dbKey)

  local baseName, key = string.match(dbKey, "([%w_]+)%.(.+)")
  if not baseName or not key then
    Spring.Echo("Ошибка: Невозможно разобрать ключ перевода: " .. tostring(dbKey))
    return text
  end

  local db = translations[baseName]
  if db and db.i18n then
    local translatedText = db.i18n(key, data, opts)
    if translatedText then
      return translatedText
    else
      Spring.Echo("Ошибка: Не найден перевод для ключа: " .. key .. " в базе: " .. baseName)
    end
  else
    Spring.Echo("Ошибка: Не найдено данных для базы: " .. baseName)
  end

  return text
end

-- Инициализация всех баз — избегаем мутации таблицы во время итерации
do
  local keys = {}
  for db, _ in pairs(translations) do
    table.insert(keys, db)
  end
  for _, db in ipairs(keys) do
    translations[db] = initializeTranslation(db)
  end
end

WG.lang = lang
WG.InitializeTranslation = function(cb, widgetName)
  addListener(cb, widgetName)
end
WG.ShutdownTranslation = shutdownTranslation
WG.Translate = Translate
