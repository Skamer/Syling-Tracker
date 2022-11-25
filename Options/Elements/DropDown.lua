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
local DROPDOWN_NICE_SLICES_FILE = [[Interface\AddOns\SylingTracker_Options\Media\BLZ_CharacterCreateDropdown]]
local DROPDOWN_FILE = [[Interface\AddOns\SylingTracker_Options\Media\BLZ_CharacterCreate]]

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
      --- charactercreate-customize-dropdownbox-hover
      Style[self].NormalTexture.file = DROPDOWN_FILE
      Style[self].NormalTexture.texCoords = { left = 0.36181640625, right = 0.50830078125, top = 0.24267578125, bottom = 0.27978515625}
    end


    self.OnLeave = self.OnLeave + function()
      ---charactercreate-customize-dropdownbox
      Style[self].NormalTexture.file = DROPDOWN_FILE
      Style[self].NormalTexture.texCoords = { left = 0.21435546875, right = 0.36083984375, top = 0.24267578125, bottom = 0.27978515625}
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

  local function OnPopoutEntrySelected(self, popout, entry)
    self:SelectEntry(entry:GetEntryData())

    self:OnEntrySelected(entry)
    self:ClosePopout()
  end
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

      popout.OnEntrySelected = popout.OnEntrySelected + self.OnPopoutEntrySelected

      self.popout = popout
    end

    return popout
  end

  function ShowPopout(self)
    local popout = self:AcquirePopout()
    popout:LinkEntries(self:GetEntries())
    popout:SelectEntry(self.SelectedEntry)
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

  __Arguments__ { Any }
  function SelectByValue(self, value)
    for i, e in self:GetEntries():GetIterator() do 
      if e.value and e.value == value then 
        self:SelectEntry(e)
        return 
      end
    end
  end

  __Arguments__ { String + Number}
  function SelectById(self, id)
    for i, e in self:GetEntries():GetIterator() do 
      if e.id and e.id == id then 
        self:SelectEntry(e)
        return 
      end 
    end
  end

  __Arguments__ { SUI.EntryData/nil }
  function SelectEntry(self, entry)
    Style[self].TogglePopoutButton.SelectedName.text = entry.text

    self.SelectedEntry = entry
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  property "SelectedEntry" {
    type = SUI.EntryData
  }
  -----------------------------------------------------------------------------
  --                            Constructors                                 --
  -----------------------------------------------------------------------------
  __Template__{
    TogglePopoutButton = SUI.DropDownPopoutButton
  }
  function __ctor(self)
    local toggleButton = self:GetChild("TogglePopoutButton")
    toggleButton.OnMouseDown = toggleButton.OnClick + function()
      self:TogglePopout()
    end

    self.OnPopoutEntrySelected = function(popout, entry) OnPopoutEntrySelected(self, popout, entry) end
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
      --- CharacterCreateDropdown-NineSlice-CornerTopLeft, true
      file = DROPDOWN_NICE_SLICES_FILE,
      width = 62,
      height = 52,
      texCoords = { left = 0.0009765625, right = 0.1220703125, top = 0.287109375, bottom = 0.490234375},      
      location = {
        Anchor("TOPLEFT", -30, 20)
      }
    },

    TopRightBGTexture = {
      --- CharacterCreateDropdown-NineSlice-CornerTopRight, true
      file = DROPDOWN_NICE_SLICES_FILE,
      width = 62,
      height = 52,
      texCoords = { left = 0.7939453125, right = 0.9150390625, top = 0.001953125, bottom = 0.205078125}, 
      location = {
        Anchor("TOPRIGHT", 30, 20)
      }
    },
    BottomLeftBGTexture = {
      --- CharacterCreateDropdown-NineSlice-CornerBottomLeft, true
      file = DROPDOWN_NICE_SLICES_FILE,
      width = 62,
      height = 72,
      texCoords = { left = 0.0009765625, right = 0.1220703125, top = 0.001953125, bottom = 0.283203125}, 
      location = {
        Anchor("BOTTOMLEFT", -30, -20)
      }
    },
    BottomRightBGTexture = {
      --- CharacterCreateDropdown-NineSlice-CornerBottomRight, true
      file = DROPDOWN_NICE_SLICES_FILE,
      width = 62,
      height = 72,
      texCoords = { left = 0.0009765625, right = 0.1220703125, top = 0.494140625, bottom = 0.775390625},
      location = {
        Anchor("BOTTOMRIGHT", 30, -20)
      }
    },
    TopBGTexture = {
      --- _CharacterCreateDropdown-NineSlice-EdgeTop, true
      file = DROPDOWN_NICE_SLICES_FILE,
      width = 216,
      height = 52,
      texCoords = { left = 0.3701171875, right = 0.7919921875, top = 0.287109375, bottom = 0.490234375},
      location = {
        Anchor("TOPLEFT", 0, 0, "TopLeftBGTexture", "TOPRIGHT"),
        Anchor("TOPRIGHT", 0, 0, "TopRightBGTexture", "TOPLEFT")
      }
    },
    BottomBGTexture = {
      --- _CharacterCreateDropdown-NineSlice-EdgeBottom, true
      file = DROPDOWN_NICE_SLICES_FILE,
      width = 216,
      height = 72,
      texCoords = { left = 0.3701171875, right = 0.7919921875, top = 0.001953125, bottom = 0.283203125},
      location = {
        Anchor("BOTTOMLEFT", 0, 0, "BottomLeftBGTexture", "BOTTOMRIGHT"),
        Anchor("BOTTOMRIGHT", 0, 0, "BottomRightBGTexture", "BOTTOMLEFT")
      }
    },
    LeftBGTexture = {
      --- !CharacterCreateDropdown-NineSlice-EdgeLeft, true
      file = DROPDOWN_NICE_SLICES_FILE,
      width = 62,
      height = 204,
      texCoords = { left = 0.2470703125, right = 0.3681640625, top = 0.001953125, bottom = 0.798828125},
      location = {
        Anchor("TOPLEFT", 0, 0, "TopLeftBGTexture", "BOTTOMLEFT"),
        Anchor("BOTTOMLEFT", 0, 0, "BottomLeftBGTexture", "TOPLEFT")
      }
    },
    RightBGTexture = {
      --- !CharacterCreateDropdown-NineSlice-EdgeRight, true
      file = DROPDOWN_NICE_SLICES_FILE,
      width = 62,
      height = 204,
      texCoords = { left = 0.1240234375, right = 0.2451171875, top = 0.001953125, bottom = 0.798828125},
      location = {
        Anchor("TOPRIGHT", 0, 0, "TopRightBGTexture", "BOTTOMRIGHT"),
        Anchor("BOTTOMRIGHT", 0, 0, "BottomRightBGTexture", "TOPRIGHT")
      }
    },
    BackgroundTexture = {
      --- CharacterCreateDropdown-NineSlice-Center", true
      file = DROPDOWN_NICE_SLICES_FILE,
      width = 1,
      height = 1,
      texCoords = { left = 0.0009765625, right = 0.001953125, top = 0.7792968, bottom = 0.78125},
      location = {
        Anchor("TOPLEFT", 0, 0, "TopLeftBGTexture", "BOTTOMRIGHT"),
        Anchor("BOTTOMRIGHT", 0, 0, "BottomRightBGTexture", "TOPLEFT")
      }
    },    
  },

      --   file = BLZ_MINIMAL_CHECKBOX_FILE,
      -- width = 30,
      -- height = 29,
      -- texCoords = { left = 0.015625, right = 0.484375, top = 0.015625, bottom = 0.46875},

  [SUI.DropDownPopoutButton] = {
    height = 38,

    NormalTexture = {
      -- atlas = AtlasType("charactercreate-customize-dropdownbox")
      file = DROPDOWN_FILE,
      texCoords = { left = 0.21435546875, right = 0.36083984375, top = 0.24267578125, bottom = 0.27978515625},
    },

    HighlightTexture = {
      -- atlas = AtlasType("charactercreate-customize-dropdownbox-open"),
      file = DROPDOWN_FILE,
      texCoords = { left = 0.50927734375, right = 0.65576171875, top = 0.24267578125, bottom = 0.27978515625},
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