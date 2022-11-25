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
local BLZ_OPTIONS_FILE = [[Interface\AddOns\SylingTracker_Options\Media\BLZ_Options]]

__Widget__()
class "SUI.TabButton" (function(_ENV)
  inherit "Button"
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  function GetAdaptedTextures(self)
    if self.Selected then
      return self.SelectedLeftTexture, self.SelectedRightTexture, self.SelectedMiddleTexture
    end

    if self:IsMouseOver() then 
      return self.OverLeftTexture, self.OverRightTexture, self.OverMiddleTexture
    end

    return self.UpLeftTexture, self.UpRightTexture, self.UpMiddleTexture
  end

  function UpdateTextures(self)
    local leftTexture, rightTexture, middleTexture = self:GetAdaptedTextures()
    Style[self].LeftBGTexture = leftTexture
    Style[self].RightBGTexture = rightTexture
    Style[self].MiddleBGTexture = middleTexture
  end

  function UpdateState(self)
    self:UpdateTextures()

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

  function OnRelease(self)
    self.Selected = nil
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
    type = Table,
    default = {
      file = BLZ_OPTIONS_FILE,
      width = 7,
      height = 23,
      texCoords = { left = 0.58984375, right = 0.5966796875, top = 0.0234375, bottom = 0.0458984375},
    }
  }

  property "UpMiddleTexture" {
    type = Table,
    default = {
      file = BLZ_OPTIONS_FILE,
      height = 23,
      texCoords = { left = 0.58984375, right = 0.5908203125, top = 0.099609375, bottom = 0.1220703125},
    }
  }

  property "UpRightTexture" {
    type = Table,
    default = {
      file = BLZ_OPTIONS_FILE,
      width = 7,
      height = 23,
      texCoords = { left = 0.58984375, right = 0.5966796875, top = 0.0751953125, bottom = 0.09765625},
    }
  }

  property "OverLeftTexture" { 
    type = Table,
    default = {
      file = BLZ_OPTIONS_FILE,
      width = 7,
      height = 23,
      texCoords = { left = 0.58984375, right = 0.5966796875, top = 0.0234375, bottom = 0.0458984375},
    }
  }

  property "OverMiddleTexture" {
    type = Table,
    default = {
      file = BLZ_OPTIONS_FILE,
      height = 23,
      texCoords = { left = 0.58984375, right = 0.5908203125, top = 0.099609375, bottom = 0.1220703125},
    }
  }

  property "OverRightTexture" {
    type = Table,
    default = {
      file = BLZ_OPTIONS_FILE,
      width = 7,
      height = 23,
      texCoords = { left = 0.58984375, right = 0.5966796875, top = 0.0751953125, bottom = 0.09765625},
    }
  }

  property "SelectedLeftTexture" {
    type = Table,
    default = {
      file = BLZ_OPTIONS_FILE,
      width = 7,
      height = 26,
      texCoords = { left = 0.58984375, right = 0.5966796875, top = 0.0478515625, bottom = 0.0732421875},
    }
  }
  
  property "SelectedMiddleTexture" {
    type = Table,
    default = {
      file = BLZ_OPTIONS_FILE,
      height = 26,
      texCoords = { left = 0.5927734375, right = 0.59375, top = 0.099609375, bottom = 0.125},
    }
  }

  property "SelectedRightTexture" {
    type = Table,
    default = {
      file = BLZ_OPTIONS_FILE,
      width = 7,
      height = 26,
      texCoords = { left = 0.5986328125, right = 0.60546875, top = 0.0234375, bottom = 0.048828125},
    }
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
    self.OnEnter = self.OnEnter + function() self:UpdateTextures() end 
    self.OnLeave = self.OnLeave + function() self:UpdateTextures() end
    self.OnEnable = self.OnEnable + function() self:UpdateTextures() end 
    self.OnDisable = self.OnDisable + function() self:UpdateTextures() end
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

    if pageInfo.onAcquire then 
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