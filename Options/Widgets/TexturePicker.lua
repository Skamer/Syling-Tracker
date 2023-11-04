-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling            "SylingTracker_Options.Widgets.TexturePicker"              ""
-- ========================================================================= --
namespace               "SylingTracker.Options.Widgets"
-- ========================================================================= --


--[[
Source 
 - Wow Atlas 
 - SylingTracker Media Atlas 
 - File 
 - Color 

Color 
File: 

Atlas:

Atlas Name
use Atlas Size

OnTextureConfirmed
--]]

_TEXTURE_SOURCE_ENTRIES = Array[Widgets.EntryData]()

__Widget__()
class "MediaTexturePopup" (function(_ENV)
  inherit "Window"
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  function BuildWowAtlasControls(self)
    self:GetChild("FileControl"):SetID(0)
    self:GetChild("FileControl"):Hide()

    self:GetChild("MediaAtlasControl"):SetID(0)
    self:GetChild("MediaAtlasControl"):Hide()
    
    self:GetChild("AtlasControl"):SetID(2)
    self:GetChild("AtlasControl"):Show()

    self:GetChild("ColorControl"):SetID(0)
    self:GetChild("ColorControl"):Hide()
  end

  function BuildMediaAtlasControls(self)
    self:GetChild("AtlasControl"):SetID(0)
    self:GetChild("AtlasControl"):Hide()

    self:GetChild("FileControl"):SetID(0)
    self:GetChild("FileControl"):Hide()

    self:GetChild("MediaAtlasControl"):SetID(2)
    self:GetChild("MediaAtlasControl"):Show()

    self:GetChild("ColorControl"):SetID(0)
    self:GetChild("ColorControl"):Hide()
  end

  function BuildColorTextureControls(self)
    self:GetChild("MediaAtlasControl"):SetID(0)
    self:GetChild("MediaAtlasControl"):Hide()

    self:GetChild("AtlasControl"):SetID(0)
    self:GetChild("AtlasControl"):Hide()

    self:GetChild("FileControl"):SetID(0)
    self:GetChild("FileControl"):Hide()

    self:GetChild("ColorControl"):SetID(2)
    self:GetChild("ColorControl"):Show()
  end

  function BuildFileControls(self)
    self:GetChild("MediaAtlasControl"):SetID(0)
    self:GetChild("MediaAtlasControl"):Hide()

    self:GetChild("AtlasControl"):SetID(0)
    self:GetChild("AtlasControl"):Hide()

    self:GetChild("ColorControl"):SetID(0)
    self:GetChild("ColorControl"):Hide()

    self:GetChild("FileControl"):SetID(2)
    self:GetChild("FileControl"):Show()
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  property "SourceType" {
    type = String,
    default = "",
    handler = function(self, new, old)
      if new == "atlas" then 
        self:BuildWowAtlasControls()
      elseif new == "mediaAtlas" then 
        self:BuildMediaAtlasControls()
      elseif new == "file" then 
        self:BuildFileControls()
      elseif new == "color" then 
        self:BuildColorTextureControls()
      end
    end
  }

  property "MediaTexture" {
    type = SylingTracker.MediaTextureType,
    default = function(self, new, old)
      if new then 
        if new.atlas and not new.isMediaAtlas then 
          self.SourceType = "atlas" 
        elseif new.atlas then 
          self.SourceType = "mediaAtlas"
        elseif new.file then 
          self.SourceType = "file"
        elseif new.color then 
          self.SourceType = "color"
        end
        print("MediaTexture", new)
        Style[self].PreviewControl.Texture.mediaTexture = new
      end

    end
  }
  -----------------------------------------------------------------------------
  --                            Constructors                                 --
  -----------------------------------------------------------------------------
  __Template__ {
    SourceControl = Frame,
    AtlasControl = Frame,
    MediaAtlasControl = Frame,
    FileControl = Frame,
    ColorControl = Frame,
    PreviewControl = Frame,
    ConfirmButton = SuccessPushButton,
    {
      SourceControl = {
        Label     = FontString,
        DropDown  = DropDown
      },
      AtlasControl = {
        Label = FontString,
        EditBox = EditBox
      },
      MediaAtlasControl = {
        Label = FontString,
        EditBox = EditBox        
      },

      FileControl = {
        Label = FontString,
        EditBox = EditBox
      },

      ColorControl = {
        Label = FontString,
        ColorPicker = ColorPicker
      },

      PreviewControl = {
        Label = FontString,
        Texutre = SylingTracker.Texture
      }
    }
  }
  function __ctor(self)

    local function OnSourceEntrySelected(dropdown, entry)
      local data = entry:GetEntryData()
      self.SourceType = data.value
    end

    local sourceDropDown = self:GetChild("SourceControl"):GetChild("DropDown")
    sourceDropDown:AddEntry({ text = "Wow Atlas", value = "atlas"})
    sourceDropDown:AddEntry({ text = "SylingTracker Media Atlas", value = "mediaAtlas"})
    sourceDropDown:AddEntry({ text = "File", value = "file"})
    sourceDropDown:AddEntry({ text = "Color Texture", value = "color"})
    sourceDropDown:SetUserHandler("OnEntrySelected", OnSourceEntrySelected)
    sourceDropDown:SelectByValue("atlas")
  end
end)

__Widget__()
class "TexturePicker" (function(_ENV)
  inherit "PushButton"
  -----------------------------------------------------------------------------
  --                               Events                                    --
  -----------------------------------------------------------------------------
  event "OnTextureChanged"

  event "OnTextureConfirmed"
  -----------------------------------------------------------------------------
  --                               Handlers                                  --
  -----------------------------------------------------------------------------
  local function OnClickHandler(self)
    local texturePickerPopup = MediaTexturePopup.Acquire()
    texturePickerPopup:SetParent(UIParent)
    texturePickerPopup:SetPoint("CENTER")
    texturePickerPopup:SetFrameStrata("FULLSCREEN_DIALOG")
    texturePickerPopup:SetTitle("Texture Picker")
    texturePickerPopup:SetFrameLevel(self:GetFrameLevel() + 10)
    texturePickerPopup:SetClampedToScreen(true)

    texturePickerPopup.mediaTexture = Style[self].Texture.mediaTexture

  end
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  __Arguments__ { SylingTracker.MediaTextureType/nil }
  function SetMediaTexture(self, mediaTexture)
    Style[self].Texture.mediaTexture = mediaTexture
  end


  __Template__ {
    Texture = SylingTracker.Texture
  }
  function __ctor(self) 
    self.OnClick = self.OnClick + OnClickHandler
  end
end)
-------------------------------------------------------------------------------
--                                Styles                                     --
-------------------------------------------------------------------------------
Style.UpdateSkin("Default", {
  [MediaTexturePopup] = {
    backdropColor         = { r = 0.1, g = 0.1, b = 0.1, a = 0.95},
    backdropBorderColor   = { r = 0, g = 0, b = 0, a = 1 },
    layoutManager = Layout.VerticalLayoutManager(),
    minResize = { width = 601, height = 400 },
    paddingTop = 50,
    paddingLeft = 10,

    SourceControl = {
      height = 35,
      marginRight = 0,
      id = 1,
  
      Label = {
        fontObject = GameFontNormal,
        textColor = NORMAL_FONT_COLOR,
        justifyH = "LEFT",
        text = "Texture Source",
        wordWrap = false,
        location = {
          Anchor("LEFT"),
          Anchor("RIGHT", 0, 0, nil, "CENTER"),  
        }
      },
  
      DropDown = {
        location = {
          Anchor("LEFT", 0, 0, "Label", "RIGHT")
        }
      }
    },
    FileControl = {
      height = 35,
      marginRight = 0,
  
      Label = {
        fontObject = GameFontNormal,
        textColor = NORMAL_FONT_COLOR,
        justifyH = "LEFT",
        text = "File",
        wordWrap = false,
        location = {
          Anchor("LEFT"),
          Anchor("RIGHT", 0, 0, nil, "CENTER"),  
        }
      },
  
      EditBox = {
        location = {
          Anchor("LEFT", 0, 0, "Label", "RIGHT")
        }
      }
    },
    AtlasControl = {
      height = 35,
      marginRight = 0,
  
      Label = {
        fontObject = GameFontNormal,
        textColor = NORMAL_FONT_COLOR,
        justifyH = "LEFT",
        text = "Atlas Name",
        wordWrap = false,
        location = {
          Anchor("LEFT"),
          Anchor("RIGHT", 0, 0, nil, "CENTER"),  
        }
      },
  
      EditBox = {
        location = {
          Anchor("LEFT", 0, 0, "Label", "RIGHT")
        }
      }
    },
    MediaAtlasControl = {
      height = 35,
      marginRight = 0,
  
      Label = {
        fontObject = GameFontNormal,
        textColor = NORMAL_FONT_COLOR,
        justifyH = "LEFT",
        text = "Media Atlas Name",
        wordWrap = false,
        location = {
          Anchor("LEFT"),
          Anchor("RIGHT", 0, 0, nil, "CENTER"),  
        }
      },
  
      EditBox = {
        location = {
          Anchor("LEFT", 0, 0, "Label", "RIGHT")
        }
      }
    },

    ColorControl = {
      height = 35,
      marginRight = 0,

      Label = {
        fontObject = GameFontNormal,
        textColor = NORMAL_FONT_COLOR,
        justifyH = "LEFT",
        wordWrap = false,
        text = "Color",
        location = {
          Anchor("LEFT"),
          Anchor("RIGHT", 0, 0, nil, "CENTER"),  
        }
      },

      ColorPicker = {
        location = {
          Anchor("LEFT", -6, 0, nil, "CENTER")
        }
      }      
    },

    PreviewControl = {

      height = 175,

      location = {
        Anchor("LEFT"),
        Anchor("RIGHT"),
        Anchor("BOTTOM")
      },

      Label = {
        fontObject = GameFontHighlightLarge,
        justifyH = "CENTER",
        justifyV = "TOP",
        wordWrap = false,
        text = "Preview:",
        
        location = {
          Anchor("TOP"),
          Anchor("LEFT"),
          Anchor("RIGHT"),
          Anchor("BOTTOM", 0, 36)
        }
      },
    },

    ConfirmButton = {
      Text = {
        text = "Apply"
      },
      location = {
        Anchor("BOTTOM", 0, 10)
      }
    }
  },

  [TexturePicker] = {
    size = { width = 32, height = 26 },

    Text = {
      visible = false
    },

    Texture = {
      -- atlas = AtlasType("services-checkmark"),
      mediaTexture = { atlas = AtlasType("services-checkmark") },
      height = 16,
      width = 16,
      drawLayer = "OVERLAY",
      subLevel = 2,
      location = {
        Anchor("CENTER")
      }
    }
  }
})

function OnLoad(self)
  -- local mediaPopup = MediaTexturePopup.Acquire()
  -- mediaPopup:SetParent(UIParent)
  -- mediaPopup:SetPoint("CENTER")
  -- mediaPopup:SetFrameStrata("HIGH")
  -- mediaPopup:SetTitle("Texture Picker")


  -- local texturePicker = TexturePicker.Acquire()
  -- texturePicker:SetParent(UIParent)
  -- texturePicker:SetPoint("CENTER", 0, 200)
end