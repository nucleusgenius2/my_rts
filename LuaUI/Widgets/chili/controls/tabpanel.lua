--//=============================================================================

--- TabPanel module

--- TabPanel fields.
-- стили табов
-- @see layoutpanel.LayoutPanel
-- @table TabPanel
-- @tparam {tab1,tab2,...} tabs contained in the tab panel, each tab has a .name (string) and a .children field (table of Controls)(default {})
-- @tparam chili.Control currentTab currently visible tab
TabPanel = LayoutPanel:Inherit{
  classname     = "tabpanel",
  orientation   = "vertical",
  resizeItems   = false,
  itemPadding   = {1, 0, 0, 0},
  itemMargin    = {0, 0, 0, 0},
  barHeight     = 40,
  tabs          = {},
  currentTab    = {},
  OnTabChange   = {},
}

local this = TabPanel
local inherited = this.inherited

--//=============================================================================

function TabPanel:New(obj)
	obj = inherited.New(self,obj)
	
	obj:AddChild(
		TabBar:New {
			tabs = obj.tabs,
			x = 0,
			y = 0,
			right = 0,
			height = obj.barHeight,
			width = 250,
		}
	)
  
	obj.currentTab = Control:New {
		x = 0,
		y = obj.barHeight,
		right = 0,
		bottom = 0,
		padding = {0, 0, 0, 0},
	}
	obj:AddChild(obj.currentTab)
	obj.tabIndexMapping = {}
	for i=1, #obj.tabs do
		local tabName = obj.tabs[i].name
		--local tabFrame = Control:New {
		local tabFrame = Panel:New {
			x = 0,
			y = 0,
			right = 0,
			bottom = 0,
			padding = {0, 0, 0, 0},
			backgroundColor = {0.8, 0.8, 0.8, 1}, -- фон
			borderColor     = {1, 1, 1, 1},         -- обводка
			borderWidth     = 1,
			children = obj.tabs[i].children
		}
		
		obj.tabIndexMapping[tabName] = tabFrame
		obj.currentTab:AddChild(tabFrame)
		if i == 1 then
			obj.currentFrame = tabFrame
		else
			tabFrame:SetVisibility(false)
		end
	end
	obj.children[1].OnChange = { function(tabbar, tabname) obj:ChangeTab(tabname) end }
	return obj
end

function TabPanel:AddTab(tab, neverSwitchTab)
    local tabbar = self.children[1]
	local switchToTab = (#tabbar.children == 0) and not neverSwitchTab

    tabbar:AddChild(
        --TabBarItem:New{name = tab.name, caption = tab.caption or tab.name, defaultWidth = tabbar.minItemWidth, defaultHeight = tabbar.minItemHeight} --FIXME: implement an "Add Tab in TabBar too"
        TabBarItem:New{
            name = tab.name,
            caption = tab.caption or tab.name,
            defaultHeight = tabbar.minItemHeight
        }
    )
	local tabFrame = Panel:New {
        padding = {0, 0, 0, 0},
        x = 0,
        y = 0,
        right = 0,
        bottom = 0,
		backgroundColor = {0.2, 0.2, 0.2, 0.8}, -- фон
		borderColor     = {1, 1, 1, 1},         -- обводка
		borderWidth     = 1,
        children = tab.children
    }
    self.tabIndexMapping[tab.name] = tabFrame
    self.currentTab:AddChild(tabFrame)
    tabFrame:SetVisibility(false)
	if switchToTab then
		self:ChangeTab(tab.name)
	end
end

function TabPanel:RemoveTab(name)
    if self.currentFrame == self.tabIndexMapping[name] then
		self.currentFrame = nil
	end
    local tabbar = self.children[1]
    tabbar:Remove(name)
    self.currentTab:RemoveChild(self.tabIndexMapping[name])
    self.tabIndexMapping[name] = nil
end

function TabPanel:GetTab(tabname)
    if not tabname or not self.tabIndexMapping[tabname] then
		return false
	end
	return self.tabIndexMapping[tabname]
end


--//=============================================================================

function TabPanel:ChangeTab(tabname)
	if not tabname or not self.tabIndexMapping[tabname] then
		return
	end
	if self.currentFrame == self.tabIndexMapping[tabname] then
		return
	end
	if self.currentFrame then
		self.currentFrame:SetVisibility(false)
	end
	self.currentFrame = self.tabIndexMapping[tabname]
	self.currentFrame:SetVisibility(true)
	self:CallListeners(self.OnTabChange, tabname)
end
--//=============================================================================
