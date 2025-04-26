--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--  file:    gui_fancy_teamplatter.lua
--  brief:   Draws transparent smoothed donuts under friendly and enemy units
--  author:  Dave Rodgers (orig. TeamPlatter edited by TradeMark)
--
--  Copyright (C) 2007.
--  Licensed under the terms of the GNU GPL, v2 or later.
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function widget:GetInfo()
   return {
      name      = "NG Unit select circle",
      desc      = "Draws transparent smoothed donuts under friendly and enemy units (using teamcolor)",
      author    = "nucleus genius",
      date      = "12.04.2025",
      license   = "GNU GPL, v2 or later",
      layer     = 5,
      enabled   = true  --  loaded by default?
   }
end

--------------------------------------------------------------------------------
-- Config
--------------------------------------------------------------------------------

local drawWithHiddenGUI    = false   -- keep widget enabled when graphical user interface is hidden (when pressing F5)
local circleSize           = 2.7     -- Общий масштаб круга (множитель от радиуса юнита)
local circleDivs           = 64      -- Количество сегментов круга (12 = восьмиугольник, 64 = почти круглая линия)
local circleOpacity        = 1.0     -- Прозрачность круга (1.0 = полностью непрозрачный, 0 = полностью прозрачный)
local innerSize            = 1.3     -- Внутренний радиус круга (1.0 = совпадает с circleSize)
local outerSize            = 1.5     -- Внешний радиус круга. 1.0 = без внешнего градиента (чёткая линия)
local circleLineWidth      = 4       -- Толщина линии круга (по умолчанию 2)

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

-- Automatically generated local definitions

local GL_ONE               = GL.ONE
local GL_ONE_MINUS_SRC_ALPHA = GL.ONE_MINUS_SRC_ALPHA
local GL_SRC_ALPHA         = GL.SRC_ALPHA
local glBlending           = gl.Blending
local glBeginEnd           = gl.BeginEnd
local glColor              = gl.Color
local glCreateList         = gl.CreateList
local glDeleteList         = gl.DeleteList
local glDepthTest          = gl.DepthTest
local glDrawListAtUnit     = gl.DrawListAtUnit
local glPolygonOffset      = gl.PolygonOffset
local glVertex             = gl.Vertex
local glLineWidth          = gl.LineWidth -- Используем для изменения толщины линии
local spGetTeamColor       = Spring.GetTeamColor
local spGetUnitDefDimensions = Spring.GetUnitDefDimensions
local spGetUnitDefID       = Spring.GetUnitDefID
local spIsUnitSelected     = Spring.IsUnitSelected
local spGetTeamList        = Spring.GetTeamList
local spGetVisibleUnits    = Spring.GetVisibleUnits
local spIsGUIHidden        = Spring.IsGUIHidden
local spGetUnitTeam        = Spring.GetUnitTeam
local myTeamID             = Spring.GetLocalTeamID()

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local realRadii            = {}
local circlePolys          = {}

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

-- Creating polygons:
function widget:Initialize()
   Spring.LoadCmdColorsConfig('unitBox  0 0 0 0') --отключение дефолтного выделения из движка

   local teamList = spGetTeamList()
   local numberOfTeams = #teamList

   for teamListIndex = 1, #teamList do
      local teamID = teamList[teamListIndex]
      local r, g, b, a = spGetTeamColor(teamID)

      circlePolys[teamID] = glCreateList(function()
         glBlending(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
         glColor(r, g, b, circleOpacity)

         -- Устанавливаем толщину линии с помощью glLineWidth
         glLineWidth(circleLineWidth)

         -- Draw circle using GL.LINE_LOOP (this will create a strict line circle)
         glBeginEnd(GL.LINE_LOOP, function()
            local radstep = (2.0 * math.pi) / circleDivs
            for i = 1, circleDivs do
               local angle = i * radstep
               glVertex(math.sin(angle), 0, math.cos(angle))
            end
         end)
      end)
   end
end

function widget:Shutdown()
   --glDeleteList(circlePolys)
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

-- Retrieving radius:
local function GetUnitDefRealRadius(udid)
   local radius = realRadii[udid]
   if (radius) then
      return radius
   end
   local ud = UnitDefs[udid]
   if (ud == nil) then
      return nil
   end
   realRadii[udid] = circleSize * (ud.xsize^2 + ud.zsize^2)^0.5
   if ud.customParams and ud.customParams.selection_scale then
      local factor = (tonumber(ud.customParams.selection_scale) or 1)
      realRadii[udid] = realRadii[udid] * factor
   end
   return realRadii[udid]
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

-- Drawing:
function widget:DrawWorldPreUnit()
   if not drawWithHiddenGUI then
      if spIsGUIHidden() then return end
   end

   glDepthTest(false)
   glPolygonOffset(-100, -2)

   -- Получаем список только выбранных юнитов (будем рисовать донаты только под ними)
   local selectedUnits = Spring.GetSelectedUnits()
   if #selectedUnits > 0 then
      for i = 1, #selectedUnits do
         local unitID = selectedUnits[i]
         local teamID = spGetUnitTeam(unitID)
         if circlePolys[teamID] ~= nil then
            local unitDefIDValue = spGetUnitDefID(unitID)
            if (unitDefIDValue) then
               local radius = GetUnitDefRealRadius(unitDefIDValue)
               if (radius) then
                  -- Рисуем круг только с внутренним радиусом, не увеличиваем внешний радиус
                  glDrawListAtUnit(unitID, circlePolys[teamID], false, radius * innerSize, 1.0, radius * innerSize)
               end
            end
         end
      end
   end

   glPolygonOffset(false)
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
