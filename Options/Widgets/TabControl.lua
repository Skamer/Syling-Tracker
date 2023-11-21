-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling              "SylingTracker_Options.Widgets.TabControl"               ""
-- ========================================================================= --
namespace               "SylingTracker.Options.Widgets"
-- ========================================================================= --
__Widget__()
class "TabButton" (function(_ENV)
  inherit "Button"
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  function UpdateState(self)
    if self.Selected then 
      Style[self].BottomBGTexture.vertexColor = Color.ORANGE
      Style[self].BottomBGTexture.height = 2
    elseif self.Mouseover then 
      Style[self].BottomBGTexture.vertexColor = { r = 1, g = 1, b = 1 }
      Style[self].BottomBGTexture.height = 1
    else
      Style[self].BottomBGTexture.vertexColor = { r = 0.5, g = 0.5, b = 0.5 }
      Style[self].BottomBGTexture.height = 1
    end
  end

  __Arguments__ { String/"" }
  function SetText(self, text)
    Style[self].Text.text = text
    
    -- Update the width based on the text width
    local text = self:GetChild("Text")
    Style[self].width = text:GetStringWidth() + 60
  end

  function OnRelease(self)
    self:SetID(0)
    self:Hide()
    self:ClearAllPoints()
    self:SetParent(nil)

    self.Selected = nil 
    self.Mouseover = nil

    self:UpdateState()
  end

  function OnAcquire(self)
    self:UpdateState()
    self:Show()
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  property "Selected" {
    type      = Boolean,
    default   = false,
    handler   = function(self) self:UpdateState() end
  }

  property "Mouseover" {
    type = Boolean,
    default = false, 
    handler = function(self) self:UpdateState() end
  }

  -----------------------------------------------------------------------------
  --                            Constructors                                 --
  -----------------------------------------------------------------------------
  __Template__{
    Text = FontString
  }
  function __ctor(self)
    self:InstantApplyStyle()

    local text = self:GetChild("Text")
    Style[self].width = text:GetStringWidth() + 60

    -- Bind handlers 
    self.OnEnter = self.OnEnter + function() self.Mouseover = true end 
    self.OnLeave = self.OnLeave + function() self.Mouseover = false  end 
    self.OnEnable = self.OnEnable + function() self:UpdateState() end 
    self.OnDisable = self.OnDisable + function() self:UpdateState() end 
    self.OnClick = self.OnClick + function() self.Selected = true end 
  end

end)


struct "TabPageInfo" {
  { name = "name", type = String},
  { name = "onAcquire", type = Function},
  { name = "OnRelease", type = Function},  
}

__Widget__()
class "TabControl" (function(_ENV)
  inherit "Frame"
  -----------------------------------------------------------------------------
  --                               Handlers                                  --
  -----------------------------------------------------------------------------
  local function OnTabButtonClick(self, tabButton)
    local pageIndex = self:GetIndexByTabButton(tabButton)
    self:SelectTab(pageIndex)
  end
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  function GetHeader(self)
    return self:GetChild("Header")
  end

  function AcquireTabButton(self)
    local tabButton = TabButton.Acquire()
    tabButton:SetParent(self:GetHeader())
    tabButton:InstantApplyStyle()

    tabButton.OnClick = tabButton.OnClick + self.OnTabButtonClick

    return tabButton
  end

  __Arguments__ { Frame }
  function GetIndexByTabButton(self, tabButton)
    for i, o in pairs(self.TabButtons) do 
      if o == tabButton then 
        return i
      end
    end
  end

  __Arguments__ { TabPageInfo }
  function AddTabPage(self, pageInfo)
    local index = self.PagesInfo.Count + 1
    local tabButton = self:AcquireTabButton()
    tabButton:SetText(pageInfo.name)

    self.PagesInfo:Insert(pageInfo)

    self.TabButtons[index] = tabButton
  end

  function BuildHeader(self)
    local previousTabButton
    local width = 0
    for index, pageInfo in self.PagesInfo:GetIterator() do 
      local tabButton = self.TabButtons[index]
      tabButton:ClearAllPoints()
      if index == 1 then 
        tabButton:SetPoint("LEFT")
      else
        tabButton:SetPoint("LEFT", previousTabButton, "RIGHT", 0, 0)
      end 
      previousTabButton = tabButton
      width = width + tabButton:GetWidth()
    end

    self:GetHeader():SetWidth(width)
  end

  function Refresh(self)
    self:BuildHeader()
  end
  
  __Arguments__ { Number/0}
  function SelectTab(self, index)
    if self.SelectedIndex == index then 
      return
    end 

    local tabButton = self.TabButtons[index]
    local previousTabButton = self.TabButtons[self.SelectedIndex]

    if tabButton then 
      tabButton.Selected = true 
    end

    if previousTabButton then 
      previousTabButton.Selected = false 
    end 

    local pageInfo = self.PagesInfo[index]
    local previousPageInfo = self.PagesInfo[self.SelectedIndex]

    if previousPageInfo and previousPageInfo.onRelease then 
      previousPageInfo.onRelease(self)
    end

    if pageInfo and pageInfo.onAcquire then 
      pageInfo.onAcquire(self)
    end

    self.SelectedIndex = index
  end


  function OnRelease(self)
    local pageInfo = self.PagesInfo[self.SelectedIndex]
    if pageInfo and pageInfo.onRelease then 
      pageInfo.onRelease(self)
    end

    for index, tabButton in pairs(self.TabButtons) do 
      tabButton:Release()
      self.TabButtons[index] = nil 
    end

    self.PagesInfo:Clear()

    self:Hide()
    self:SetParent()
    self:ClearAllPoints()

    self.SelectedIndex = nil
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  property "SelectedIndex" {
    type = Number,
    default = 0
  }

  property "PagesInfo" {
    set = false,
    default = function() return Array[TabPageInfo]() end 
  }

  property "TabButtons" {
    set = false,
    default = function() return Toolset.newtable(false, true) end
  }
  -----------------------------------------------------------------------------
  --                            Constructors                                 --
  -----------------------------------------------------------------------------
  __Template__ {
    Header = Frame
  }
  function __ctor(self)
    self.OnTabButtonClick = function(button) OnTabButtonClick(self, button) end 

    -- We need to set the height to "1" for the auto layout works
    self:SetHeight(1)
  end
end)
-------------------------------------------------------------------------------
--                                Styles                                     --
-------------------------------------------------------------------------------
Style.UpdateSkin("Default", {
  [TabButton] = {
    height = 37,
    width = 100,

    Text = {
      setAllPoints = true,
      fontObject = GameFontNormalSmall
    },

     BottomBGTexture = {
      file = "Interface\\Buttons\\WHITE8X8",
      drawLayer = "BORDER",
      location = {
        Anchor("BOTTOMLEFT"),
        Anchor("BOTTOMRIGHT")
      }
     }
  },

  [TabControl] = {
    layoutManager = Layout.VerticalLayoutManager(true, true),
    paddingTop = 50,
    width = 550,

    Header = {
      height = 37,
      location = {
        Anchor("TOPLEFT"),
        Anchor("TOPRIGHT")
      }
    }
  }
})