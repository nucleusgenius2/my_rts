function widget:GetInfo()
	return {
		name = "NG SaveGame",
		desc = "Нужен для сохранения игр",
        author  = "nucleus genius",
		date = "2025",
		license = "All rights reserved; no commercial use",
		layer = 0,
		enabled = true,
	}
end

local SAVE_DIR = "Saves"

local function trim(str)
	return str:match '^()%s*$' and '' or str:match '^%s*(.*%S)'
end

local function SaveGame(filename, description, requireOverwrite)
	local success, err = pcall(function()
		Spring.CreateDir(SAVE_DIR)
		filename = (filename and trim(filename)) or "save_autogen"
		local path = SAVE_DIR .. "/" .. filename .. ".lua"
		local saveData = {}

		saveData.date = os.date('*t')
		saveData.description = description or "No description"
		saveData.gameName = Game.gameName
		saveData.gameVersion = Game.gameVersion
		saveData.map = Game.mapName
		saveData.playerName = select(1, Spring.GetPlayerInfo(Spring.GetMyPlayerID(), false))
		saveData.gameframe = Spring.GetGameFrame()

		-- Save table to file
		table.save(saveData, path)

		-- Tell engine to save game
		if requireOverwrite then
			Spring.SendCommands("save " .. filename .. " -y")
		else
			Spring.SendCommands("save " .. filename)
		end

		Spring.Echo("[SaveGameWidget] Saved game to:", path)
	end)

	if not success then
		Spring.Echo("[SaveGameWidget] Error saving game:", err)
	end
end

function widget:Initialize()
	WG.savegame = {
		SaveGame = SaveGame
	}
	Spring.Echo("[SaveGameWidget] Initialized. Use WG.savegame.SaveGame(...) to save.")
end

function widget:Shutdown()
	WG.savegame = nil
end
