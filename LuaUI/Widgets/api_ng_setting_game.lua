function widget:GetInfo()
  return {
    name      = "settingsManager",
    desc      = "Сохранение настроек в файл",
    author    = "nucleus genius",
    date      = "WIP",
    license   = "GPLv2",
    enabled   = true,
    api       = true,
  }
end

local SettingsManager = {}

-- Путь к файлу настроек (обновляем путь на LuaUI/GameOptions.lua)
SettingsManager.configFile = LUAUI_DIRNAME .. "GameOptions.lua"

-- Структура настроек по умолчанию
SettingsManager.defaultSettings = {
    language = "en",
    resolution = { 1920, 1080 },
    fullscreen = true,
}

-- Текущие настройки
SettingsManager.settings = {}

-- Функция для загрузки настроек из файла
function SettingsManager:LoadSettings()
    local path = self.configFile
   -- Spring.Echo("path setting: " .. path)

    local success, result = pcall(VFS.Include, path)
    if success and type(result) == "table" then
        self.settings = result


        Spring.Echo("Lang serring: " .. self.settings.language)
    else
        Spring.Echo("Ошибка загрузки файла настроек: " .. tostring(result))
        self.settings = self.defaultSettings
    end
end

function SettingsManager:SaveSettings()
    local path = self.configFile
    local file = io.open(path, "w")
    if file then
        file:write("return {\n")
        for key, value in pairs(self.settings) do
            -- Экранируем строки в кавычки
            if type(value) == "table" then
                file:write(string.format("    %s = {%s},\n", key, table.concat(value, ", ")))
            else
                file:write(string.format("    %s = '%s',\n", key, tostring(value)))  -- Экранируем строки
            end
        end
        file:write("}\n")
        file:close()
        Spring.Echo("Настройки сохранены.")
    else
        Spring.Echo("Не удалось открыть файл для записи.")
    end
end


-- Функция для получения значения настройки
function SettingsManager:Get(key)
    return self.settings[key] or self.defaultSettings[key]
end

-- Функция для изменения значения настройки
function SettingsManager:Set(key, value)
    self.settings[key] = value
    self:SaveSettings()
end

-- Экспортируем SettingsManager в глобальную таблицу WG
WG.SettingsManager = SettingsManager  -- Здесь вы экспортируете объект SettingsManager

return SettingsManager
