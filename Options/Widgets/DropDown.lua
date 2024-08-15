-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling            "SylingTracker_Options.Widgets.DropDown"                   ""
-- ========================================================================= --
namespace               "SylingTracker.Options.Widgets"
-- ========================================================================= --
export {
  IterateMedia      = SylingTracker.API.IterateMedia,
  FetchFontObject   = SylingTracker.API.FetchFontObject,
  MediaType         = SylingTracker.MediaType
}

__Widget__()
class "DropDownPopout" { GridEntriesFauxScrollBox }

__Widget__()
class "DropDownPopoutButton" (function(ENV)
  inherit "PushButton"
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  function RefreshState(self)
    if self.Mouseover then 
      Style[self].Arrow.vertexColor = Color(1, 1, 0, 0.75)
      Style[self].Arrow.visible = true
    else
      Style[self].Arrow.vertexColor = self.__normalBorderColor
      Style[self].Arrow.visible = false
    end
  end
  -----------------------------------------------------------------------------
  --                            Constructors                                 --
  -----------------------------------------------------------------------------
  __Template__ {
    Arrow = Texture
  }
  function __ctor(self) end
end)

__Widget__()
class "DropDown" (function(_ENV)
  inherit "Frame" extend "IEntryProvider"
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
      popout = DropDownPopout.Acquire()

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

    if self.MediaType == "font" then
      Style[self].TogglePopoutButton.Text.text = Color.RED .. value
      Style[self].TogglePopoutButton.Text.fontObject = nil
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

    if self.MediaType == "font" then
      Style[self].TogglePopoutButton.Text.text = "|cffff0000 Font Not Found|r"
      Style[self].TogglePopoutButton.Text.fontObject = nil
    end
  end

  __Arguments__ { EntryData/nil }
  function SelectEntry(self, entry)
    Style[self].TogglePopoutButton.Text.text = entry.text

    if self.MediaType == "font" then
      local fontObject =  entry.styles.SelectionDetails.SelectionName.fontObject
      Style[self].TogglePopoutButton.Text.fontObject = fontObject
    end

    self.SelectedEntry = entry
  end

  __Arguments__ { MediaType/nil }
  function SetMediaType(self, mediaType)
    self.MediaType = mediaType

    local entries = Array[EntryData]()
    for id, file in IterateMedia(mediaType) do 
      local entryData = {}
      entryData.text  = id 
      entryData.value = id

      if mediaType == "font" then 
        entryData.styles = {
          SelectionDetails = {
            SelectionName = {
              fontObject = FetchFontObject(file, 12)
            }
          }
        }
      end

      entries:Insert(entryData)
    end

    self:SetEntries(entries)
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  property "SelectedEntry" {
    type = EntryData
  }

  property "MediaType" {
    type = String
  }
  -----------------------------------------------------------------------------
  --                            Constructors                                 --
  -----------------------------------------------------------------------------
  __Template__{
    TogglePopoutButton = DropDownPopoutButton
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
  [DropDownPopout] = {
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

  [DropDownPopoutButton] = {
    height = 26,

    Text = {
      setAllPoints = true,
      fontObject = GameFontNormal,
      justifyH = "CENTER",
      maxLines = 1,
    },

    Arrow = {
      visible = false,
      height = 10,
      width  = 22,
      drawLayer = "BORDER",
      file = [[Interface\Buttons\WHITE8X8]],
      vertexColor = { r = 0.35, g = 0.35, b = 0.35, a = 0.75 },

      location = {
        Anchor("TOP", 0, 1, nil, "BOTTOM")
      },

      maskTexture = {
        height = 10,
        width  = 22,
        atlas = AtlasType("helptip-arrow-mask"),
        location = {
          Anchor("TOP"),
        },
        hWrapMode = "CLAMPTOBLACKADDITIVE",
        vWrapMode = "CLAMPTOBLACKADDITIVE",
      }
    }
  },

  [DropDown] = {
    height = 26,
    width  = 150,
    TogglePopoutButton = {
      height = 26,
      location = {
        Anchor("LEFT"),
        Anchor("RIGHT")
      }
    },
  }
})