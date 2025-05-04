--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--  file:    gui_ctrlpanel_modified.lua
--  Modifications by Adonai_Jr
--  Tnx for Meltrax iceUI who inspired this menu (and some code)
--
--  based heavily on BA layout
--  see the original for credits authors
--
--  Copyright (C) 2009.
--  Licensed under the terms of the GNU GPL, v2 or later.
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- CtrlPanel Improved with Tier Switching
-- CtrlPanel Improved with Tier Switching
-- CtrlPanel Improved with Tier Filtering via WG
-- CtrlPanel Improved with WG tech tier filtering and adaptive layout
-- CtrlPanel Improved with WG tech tier filtering and full adaptive layout
-- CtrlPanel Improved with WG tech tier filtering added to original layout
function widget:GetInfo()
  return {
    name      = "NG CtrlPanel Improved",
    desc      = "Custom build menu",
    author    = "nucleus genius, Adonai_Jr, modified",
    date      = "2025",
    license   = "GNU GPL, v2 or later",
    layer     = 0,
    handler   = true,
    enabled   = false
  }
end

include("colors.h.lua")

local langSuffix = Spring.GetConfigString('Language', 'fr')
local l10nName = 'L10N/commands_' .. langSuffix .. '.lua'
local success, translations = pcall(VFS.Include, l10nName)
if not success then translations = nil end

local FrameTex = "bitmaps/BuildMenuThings/frame_slate_128x96.png"
local FrameScale = "&0.099x0.132&"
local PageNumTex = "bitmaps/BuildMenuThings/circularthingy.tga"

if true then
  FrameTex = ""
  PageNumTex = ""
end

local PageNumCmd = {
  name     = "1",
  iconname = PageNumTex,
  tooltip  = "Active Page Number\n(click to toggle buildiconsfirst)",
  actions  = { "buildiconsfirst", "firstmenu" }
}

local commonConfig = {
  "outlinefont 1",
  "dropShadows 1",
  "useOptionLEDs 1",
  "textureAlpha 0.75",
  "frameAlpha 0.30",
  "selectGaps 1",
  "selectThrough 1",
  "xPos 0.6",
  "xSelectionPos 0.45",
  "ySelectionPos 0.11",
  "prevPageSlot auto",
  "deadIconSlot none",
  "nextPageSlot auto",
  "textBorder 0.002",
  "iconBorder 0.0015",
  "frameBorder 0.0015"
}

local config = {}
local function CustomLayoutHandler(xIcons, yIcons, cmdCount, commands)
  widgetHandler.commands = commands
  widgetHandler:CommandsChanged()

  if cmdCount <= 0 then
    return "", xIcons, yIcons, {}, {}, {}, {}, {}, {}, {}, {}
  end

  local tierToShow = WG.techTier or 1
  local menuName = ''
  local removeCmds, customCmds, onlyTexCmds = {}, widgetHandler.customCommands, {}
  local reTexCmds, reNamedCmds, reTooltipCmds, reParamsCmds, iconList = {}, {}, {}, {}, {}

  local ipp = xIcons * yIcons
  local activePage = Spring.GetActivePage()

  -- Разделяем экран на 2 логические области:
  local halfX = math.floor(xIcons / 2)  -- Левая часть — команды
  local rightStart = halfX             -- Правая часть — стройки

  local commandPos = 0
  local buildPos = 0

  -- Иконки навигации (только для стройки)
  local prevCmd, nextCmd = cmdCount - 1, cmdCount - 0
  local prevPos, nextPos = ipp - xIcons, ipp - 1
  if prevCmd >= 1 then reTexCmds[prevCmd] = FrameTex end
  if nextCmd >= 1 then reTexCmds[nextCmd] = FrameTex end

  local pageNumCmd = -1
  local pageNumPos = math.floor((prevPos + nextPos) / 2)
  if xIcons > 2 then
    local color = (commands[1].id < 0) and GreenStr or RedStr
    PageNumCmd.name = color .. '   ' .. (activePage + 1) .. '   '
    table.insert(customCmds, PageNumCmd)
    pageNumCmd = cmdCount + 1
  end

  for cmdSlot = 1, (cmdCount - 2) do
    local cmd = commands[cmdSlot]
    if cmd and not cmd.hidden then
      if cmd.id < 0 then
        -- build-команды (юниты)
        local unitDefID = -cmd.id
        local ud = UnitDefs[unitDefID]
        local tech = tonumber(ud and ud.customParams and ud.customParams.techlevel) or 1

        if tech == tierToShow then
          local col = buildPos % (xIcons - rightStart)
          local row = math.floor(buildPos / (xIcons - rightStart))
          local gridPos = rightStart + col + row * xIcons

          iconList[gridPos] = cmdSlot
          buildPos = buildPos + 1

          -- Навигация
          if row == 0 and col == 0 then
            iconList[prevPos] = prevCmd
            iconList[nextPos] = nextCmd
            if pageNumCmd > 0 then
              iconList[pageNumPos] = pageNumCmd
            end
          end

          if translations then
            local trans = translations[cmd.id]
            if trans then
              reTooltipCmds[cmdSlot] = trans.desc
              if not trans.params then
                if cmd.id ~= CMD.STOCKPILE then
                  reNamedCmds[cmdSlot] = trans.name
                end
              else
                local num = tonumber(cmd.params[1])
                if num then
                  num = num + 1
                  cmd.params[num] = trans.params[num]
                  reParamsCmds[cmdSlot] = cmd.params
                end
              end
            end
          end
        end
      elseif cmd.id >= 0 or cmd.type ~= CMDTYPE.ICON_BUILDING then
        -- обычные команды (двигаться, атаковать и т.п.)
        local col = commandPos % halfX
        local row = math.floor(commandPos / halfX)
        local gridPos = col + row * xIcons

        iconList[gridPos] = cmdSlot
        commandPos = commandPos + 1
      end
    end
  end

  return menuName, xIcons, yIcons,
         removeCmds, customCmds,
         onlyTexCmds, reTexCmds,
         reNamedCmds, reTooltipCmds, reParamsCmds,
         iconList
end


function widget:Initialize()
  widgetHandler:DisableWidget("Red Build/Order Menu")
  --тех уровень
  WG.techTier = 2

  local X, Y = Spring.GetViewGeometry()
  local ix = tonumber(Spring.GetConfigInt("XTA_MenuIconsX"))
  local iy = tonumber(Spring.GetConfigInt("XTA_MenuIconsY"))

    --адаптивность
  if (X == 800 and Y == 600) then
    config = {ix and "xIcons ".. ix or "xIcons 5", iy and "yIcons ".. iy or "yIcons 2", "xIconSize 0.044", "yIconSize 0.0586", "yPos 0.01" }
  elseif (X == 1024 and Y == 768) then
    config = {ix and "xIcons ".. ix or "xIcons 5", iy and "yIcons ".. iy or "yIcons 2", "xIconSize 0.0435", "yIconSize 0.0580", "yPos 0.01"}
  elseif (X == 1152 and Y == 864) then
    config = {ix and "xIcons ".. ix or "xIcons 5", iy and "yIcons ".. iy or "yIcons 2", "xIconSize 0.0435", "yIconSize 0.0580", "yPos 0.01"}
  elseif (X == 1280 and Y == 800) then
    config = {ix and "xIcons ".. ix or "xIcons 5", iy and "yIcons ".. iy or "yIcons 2", "xIconSize 0.036", "yIconSize 0.0576", "yPos 0.01"}
  elseif (X == 1280 and Y == 960) then
    config = {ix and "xIcons ".. ix or "xIcons 5", iy and "yIcons ".. iy or "yIcons 2", "xIconSize 0.041", "yIconSize 0.0546", "yPos 0.01"}
  elseif (X == 1280 and Y == 1024) then
    config = {ix and "xIcons ".. ix or "xIcons 8", iy and "yIcons ".. iy or "yIcons 2", "xIconSize 0.055", "yIconSize 0.056", "yPos 0.02"}
  elseif (X == 1440 and Y == 900) then
    config = {ix and "xIcons ".. ix or "xIcons 8", iy and "yIcons ".. iy or "yIcons 2", "xIconSize 0.035", "yIconSize 0.056", "yPos 0.01"}
  elseif (X == 1600 and Y == 1200) then
    config = {ix and "xIcons ".. ix or "xIcons 8", iy and "yIcons ".. iy or "yIcons 2", "xIconSize 0.042", "yIconSize 0.056", "yPos 0.01"}
  elseif (X == 1680 and Y == 1050) then
    config = {ix and "xIcons ".. ix or "xIcons 8", iy and "yIcons ".. iy or "yIcons 2", "xIconSize 0.035", "yIconSize 0.056", "yPos 0.01"}
  elseif (X == 1920 and Y == 1080) then
    config = {ix and "xIcons ".. ix or "xIcons 8", iy and "yIcons ".. iy or "yIcons 2", "xIconSize 0.035", "yIconSize 0.056", "yPos 0.01"}
  elseif (X == 1920 and Y == 1200) then
    config = {ix and "xIcons ".. ix or "xIcons 8", iy and "yIcons ".. iy or "yIcons 2", "xIconSize 0.035", "yIconSize 0.056", "yPos 0.01"}
  else
    Spring.Echo("Control Panel Widget doesn't support your " ..X.. "x" ..Y.. " resolution.")
    Spring.Echo("Call back your default Layout.")
    widget:Shutdown()
    return
  end

  local xi = tonumber(config[1]:sub(8))
  local xis = X * tonumber(config[3]:sub(11))
  local ib = X * tonumber("0.0015")
  local fb = X * tonumber("0.0015")
  local sizeX = xi * xis + 2 * xi * ib + 2 * fb
  WG.buildmenuX = sizeX

  local file = io.open('ctrlpanelImp.txt', 'w')
  for _, v in ipairs(commonConfig) do file:write(v .. '\n') end
  for _, v in ipairs(config) do file:write(v .. '\n') end
  file:close()

  Spring.SendCommands('ctrlpanel ctrlpanelImp.txt')
  widgetHandler:ConfigLayoutHandler(CustomLayoutHandler)
end

function widget:Shutdown()
  Spring.SendCommands({"ctrlpanel " .. LUAUI_DIRNAME .. "ctrlpanel.txt"})
  widgetHandler:ConfigLayoutHandler(true)
end


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--function widget:DrawScreen()
	--if hideGUI then return end
	--DrawBackground()
--end

 --function DrawBackground()
	 --local y1 = 95
	 --local y2 = 1024
	 --local x1 = 2
	 --local x2 = WG.buildmenuX
	-- gl.Color(0,0,0,0.1)                              -- draws background rectangle
	-- gl.Rect(x1,y1,x2,y2)
	-- gl.Color(0,0,0,0.2)
	-- gl.Rect(x1-1,y1-1,x1,y2+1)
	-- gl.Rect(x2-1,y1-1,x2,y2+1)
	-- gl.Rect(x1-1,y1-1,x2+1,y1)
	-- gl.Rect(x1-1,y2-1,x2+1,y2)
	-- gl.Color(1,1,1,1)
 --end

