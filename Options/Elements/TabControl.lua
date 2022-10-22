-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling              "SylingTracker.Options.Elements.TabControl"              ""
-- ========================================================================= --
__Widget__()
class "SUI.TabButton" (function(_ENV)
  inherit "Button"
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  function GetAtlas(self)
    if self.Selected then
      return self.SelectedLeftTexture, self.SelectedRightTexture, self.SelectedMiddleTexture
    end

    if self:IsMouseOver() then 
      return self.OverLeftTexture, self.OverRightTexture, self.OverMiddleTexture
    end

    return self.UpLeftTexture, self.UpRightTexture, self.UpMiddleTexture
  end

  function UpdateAtlas(self)
    local leftAtlas, rightAtlas, middleAtlas = self:GetAtlas()
    Style[self].LeftBGTexture.atlas = leftAtlas
    Style[self].RightBGTexture.atlas = rightAtlas
    Style[self].MiddleBGTexture.atlas = middleAtlas
  end

  function UpdateState(self)
    self:UpdateAtlas()

    local text = self:GetChild("Text")
    if self.Selected then
      text:SetPoint("BOTTOM", 0, 6)
      text:SetFontObject("GameFontHighlightSmall")
    else 
      text:SetPoint("BOTTOM", 0, 4)
      text:SetFontObject("GameFontNormalSmall")
    end 
  end

  __Arguments__ { String/"" }
  function SetText(self, text)
    Style[self].Text.text = text
    
    -- Update the width based on the text width
    local text = self:GetChild("Text")
    Style[self].width = text:GetStringWidth() + 40
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  property "Selected" {
    type      = Boolean,
    default   = false,
    handler   = function(self) self:UpdateState() end 
  }

  property "UpLeftTexture" {
    type    = AtlasType,
    default = AtlasType("Options_Tab_Left", true)
  }

  property "UpMiddleTexture" {
    type    = AtlasType,
    default = AtlasType("Options_Tab_Middle", true)
  }

  property "UpRightTexture" {
    type    = AtlasType,
    default = AtlasType("Options_Tab_Right", true)
  }

  property "OverLeftTexture" { 
    type    = AtlasType,
    default = AtlasType("Options_Tab_Left", true)
  }

  property "OverMiddleTexture" {
    type    = AtlasType,
    default = AtlasType("Options_Tab_Middle", true)
  }

  property "OverRightTexture" {
    type    = AtlasType,
    default = AtlasType("Options_Tab_Right", true)
  }

  property "SelectedLeftTexture" {
    type    = AtlasType,
    default = AtlasType("Options_Tab_Active_Left", true)
  }

  property "SelectedMiddleTexture" {
    type    = AtlasType,
    default = AtlasType("Options_Tab_Active_Middle", true)
  }

  property "SelectedRightTexture" {
    type    = AtlasType,
    default = AtlasType("Options_Tab_Active_Right", true)
  }
  -----------------------------------------------------------------------------
  --                            Constructors                                 --
  -----------------------------------------------------------------------------
  __Template__{
    Text = FontString
  }
  function __ctor(self)
    -- We need to instant apply style for having a valid text width
    self:InstantApplyStyle()

    local text = self:GetChild("Text")
    Style[self].width = text:GetStringWidth() + 40

    self:UpdateState()

    -- Bind handlers
    self.OnEnter = self.OnEnter + function() self:UpdateAtlas() end 
    self.OnLeave = self.OnLeave + function() self:UpdateAtlas() end
    self.OnEnable = self.OnEnable + function() self:UpdateAtlas() end 
    self.OnDisable = self.OnDisable + function() self:UpdateAtlas() end
    self.OnClick = self.OnClick + function() self.Selected = true end
  end
end)

struct "SUI.TabPageInfo" {
  { name = "name", type = String},
  { name = "onAcquire", type = Function},
  { name = "OnRelease", type = Function},
}


__Widget__()
class "SUI.TabControl" (function(_ENV)
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
    local tabButton = SUI.TabButton.Acquire()
    tabButton:SetParent(self:GetHeader())

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

  __Arguments__ { SUI.TabPageInfo }
  function AddTabPage(self, pageInfo)
    local index = self.PagesInfo.Count + 1
    local tabButton = self:AcquireTabButton()
    tabButton:SetText(pageInfo.name)

    self.PagesInfo:Insert(pageInfo)

    self.TabButtons[index] = tabButton
  end

  function BuildHeader(self)
    local previousTabButton
    for index, pageInfo in self.PagesInfo:GetIterator() do 
      local tabButton = self.TabButtons[index]
      tabButton:ClearAllPoints()
      if index == 1 then 
        tabButton:SetPoint("LEFT")
      else
        tabButton:SetPoint("LEFT", previousTabButton, "RIGHT", 10, 0)
      end 
      previousTabButton = tabButton
    end
  end

  function Refresh(self)
    self:BuildHeader()
  end

  __Arguments__ { Number/0 }
  function SelectTab(self, index)
    if self.SelectedIndex == index then 
      return 
    end 

    local pageInfo = self.PagesInfo[index]

    if not pageInfo then 
      return 
    end

    local previousPageInfo = self.PagesInfo[self.SelectedIndex]
    if previousPageInfo and previousPageInfo.onRelease then 
      previousPageInfo.onRelease(self)
    end

    local previousTabButton = self.TabButtons[self.SelectedIndex]
    if previousTabButton then 
      previousTabButton.Selected = false
    end

    if pageInfo.onAcquire then 
      pageInfo.onAcquire(self)
    end

    self.SelectedIndex = index
  end

  function OnRelease(self)
    local pageInfo = self.PagesInfo[self.SelectedIndex]
    if pageInfo and pageInfo.onRelease then 
      pageInfo.OnRelease(self)
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
    default = function() return Array[SUI.TabPageInfo]() end 
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
  [SUI.TabButton] = {
    height =  37,
    width = 100,

    LeftBGTexture = {
      location = {
        Anchor("BOTTOMLEFT")
      }
    },
    RightBGTexture = {
      location = {
        Anchor("BOTTOMRIGHT")
      }
    },
    MiddleBGTexture = {
      location = {
        Anchor("TOPLEFT", 0, 0, "LeftBGTexture", "TOPRIGHT"),
        Anchor("TOPRIGHT", 0, 0, "RightBGTexture", "TOPLEFT")
      }
    },

    Text = {
      fontObject = GameFontNormalSmall
    }
  },
  [SUI.TabControl] = {
    layoutManager = Layout.VerticalLayoutManager(true, true),
    paddingTop = 50,

    Header = {
      height = 37,
      location = {
        Anchor("TOPLEFT"),
        Anchor("TOPRIGHT")
      }
    }
  }
})