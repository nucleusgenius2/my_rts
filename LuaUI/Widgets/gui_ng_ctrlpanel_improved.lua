function widget:GetInfo()
  return {
    name    = "NG ctrlpanel",
    desc    = "Fully hides engine CtrlPanel by shrinking and moving it off-screen",
    author  = "nucleus_genius",
    date    = "2025",
    license = "GNU GPL, v2 or later",
    layer   = 999,
    enabled = true,
    handler = true,
  }
end

function widget:Initialize()
  -- Пишем layout с нулевым размером и смещением
  local file = io.open("empty_ctrlpanel.txt", "w")
  file:write("xIcons 1\n")
  file:write("yIcons 1\n")
  file:write("xPos -2.0\n")          -- сильно левее экрана
  file:write("yPos -2.0\n")          -- сильно ниже экрана
  file:write("xIconSize 0.01\n")
  file:write("yIconSize 0.01\n")
  file:close()

  Spring.SendCommands("ctrlpanel empty_ctrlpanel.txt")
end

function widget:Shutdown()
  Spring.SendCommands({ "ctrlpanel " .. LUAUI_DIRNAME .. "ctrlpanel.txt" })
end
