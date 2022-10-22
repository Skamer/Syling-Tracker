-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling          "SylingTracker.Options.Elements.DropDown"                    ""
-- ========================================================================= --
__Widget__()
class "SUI.DropDownPopout" { SUI.GridEntriesFauxScrollBox }

__Widget__()
class "SUI.DropDownPopoutButton" (function(_ENV)
  inherit "Button"
  -----------------------------------------------------------------------------
  --                            Constructors                                 --
  -----------------------------------------------------------------------------
  __Template__ {
    SelectedName = FontString
  }
  function __ctor(self)
    self.OnEnter = self.OnEnter + function()
      Style[self].NormalTexture.atlas = AtlasType("charactercreate-customize-dropdownbox-hover")
    end


    self.OnLeave = self.OnLeave + function()
        Style[self].NormalTexture.atlas = AtlasType("charactercreate-customize-dropdownbox")
    end  
  end
end)

__Widget__()
class "SUI.DropDown" (function(_ENV)
  inherit "Frame" extend "SUI.IEntryProvider"
  -----------------------------------------------------------------------------
  --                               Events                                    --
  -----------------------------------------------------------------------------
  event "OnEntrySelected"
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  function AcquirePopout(self)
    local popout = self.popout

    if not popout then 
      popout = SUI.DropDownPopout.Acquire()

      local toggleButton = self:GetChild("TogglePopoutButton")
      popout:InstantApplyStyle()
      popout:SetPoint("TOP", toggleButton, "BOTTOM", 0, 11)
      popout:SetParent(UIParent)
      popout:SetFrameStrata("FULLSCREEN_DIALOG")
      popout:SetToplevel(true)

      self.popout = popout
    end

    return popout
  end

  function ShowPopout(self)
    local popout = self:AcquirePopout()
    popout:LinkEntries(self:GetEntries())
    popout:Refresh()
    popout:Show()
  end

  function ClosePopout(self)
    local popout = self.popout
    if (popout) then
      popout:Hide()
    end
  end

  function ReleasePopout(self)
    self:ClosePopout()
  end

  function TogglePopout(self)
    local popout = self.popout
    if popout and popout:IsShown() then
      self:ClosePopout()
    else
      self:ShowPopout()
    end
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  __Template__{
    TogglePopoutButton = SUI.DropDownPopoutButton
  }
  function __ctor(self)
    local toggleButton = self:GetChild("TogglePopoutButton")
    toggleButton.OnMouseDown = toggleButton.OnClick + function()
      self:TogglePopout()
    end
  end

end)
-------------------------------------------------------------------------------
--                                Styles                                     --
-------------------------------------------------------------------------------
Style.UpdateSkin("Default", {
  [SUI.DropDownPopout] = {
    width = 230,
    ScrollBar = {
      location = {
        Anchor("TOP", 0, -5),
        Anchor("RIGHT", -10, 0),
        Anchor("BOTTOM", 0, 25)
      }
    },
    ScrollContent = {
      location = {
        Anchor("TOPLEFT", 10, -10),
        Anchor("RIGHT", -5, 0, "ScrollBar", "LEFT"),
        Anchor("BOTTOM")
      }
    },
    AutoHeightOffsetExtent = 40,
    
    TopLeftBGTexture = {
      atlas = AtlasType("CharacterCreateDropdown-NineSlice-CornerTopLeft", true),
      location = {
        Anchor("TOPLEFT", -30, 20)
      }
    },

    TopRightBGTexture = {
      atlas = AtlasType("CharacterCreateDropdown-NineSlice-CornerTopRight", true),
      location = {
        Anchor("TOPRIGHT", 30, 20)
      }
    },
    BottomLeftBGTexture = {
      atlas = AtlasType("CharacterCreateDropdown-NineSlice-CornerBottomLeft", true),
      location = {
        Anchor("BOTTOMLEFT", -30, -20)
      }
    },
    BottomRightBGTexture = {
      atlas = AtlasType("CharacterCreateDropdown-NineSlice-CornerBottomRight", true),
      location = {
        Anchor("BOTTOMRIGHT", 30, -20)
      }
    },
    TopBGTexture = {
      atlas = AtlasType("_CharacterCreateDropdown-NineSlice-EdgeTop", true),
      location = {
        Anchor("TOPLEFT", 0, 0, "TopLeftBGTexture", "TOPRIGHT"),
        Anchor("TOPRIGHT", 0, 0, "TopRightBGTexture", "TOPLEFT")
      }
    },
    BottomBGTexture = {
      atlas = AtlasType("_CharacterCreateDropdown-NineSlice-EdgeBottom", true),
      location = {
        Anchor("BOTTOMLEFT", 0, 0, "BottomLeftBGTexture", "BOTTOMRIGHT"),
        Anchor("BOTTOMRIGHT", 0, 0, "BottomRightBGTexture", "BOTTOMLEFT")
      }
    },
    LeftBGTexture = {
      atlas = AtlasType("!CharacterCreateDropdown-NineSlice-EdgeLeft", true),
      location = {
        Anchor("TOPLEFT", 0, 0, "TopLeftBGTexture", "BOTTOMLEFT"),
        Anchor("BOTTOMLEFT", 0, 0, "BottomLeftBGTexture", "TOPLEFT")
      }
    },
    RightBGTexture = {
      atlas = AtlasType("!CharacterCreateDropdown-NineSlice-EdgeRight", true),
      location = {
        Anchor("TOPRIGHT", 0, 0, "TopRightBGTexture", "BOTTOMRIGHT"),
        Anchor("BOTTOMRIGHT", 0, 0, "BottomRightBGTexture", "TOPRIGHT")
      }
    },
    BackgroundTexture = {
      atlas = AtlasType("CharacterCreateDropdown-NineSlice-Center", true),
      location = {
        Anchor("TOPLEFT", 0, 0, "TopLeftBGTexture", "BOTTOMRIGHT"),
        Anchor("BOTTOMRIGHT", 0, 0, "BottomRightBGTexture", "TOPLEFT")
      }
    },    
  },

  [SUI.DropDownPopoutButton] = {
    height = 38,

    NormalTexture = {
      atlas = AtlasType("charactercreate-customize-dropdownbox")
    },

    HighlightTexture = {
      atlas = AtlasType("charactercreate-customize-dropdownbox-open"),
      alphaMode = "ADD",
      alpha = 0
    },

    SelectedName = {
        height = 20,
        width = 225,
        setAllPoints = true,
        fontObject = GameFontNormal,
        justifyH = "CENTER",
        maxLines = 1,
        -- drawLayer = "OVERLAY",
        -- subLevel = 1,
        text = "Button",
    }    
  },

  [SUI.DropDown] = {
    size = Size(280, 26),
    TogglePopoutButton = {
      height = 38,
      location = {
        Anchor("LEFT"),
        Anchor("RIGHT")
      }
    },
  }
})