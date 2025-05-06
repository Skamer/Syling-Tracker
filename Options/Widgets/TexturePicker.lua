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
local TEXTURE_POPUP = nil

__Widget__()
class "TexturePopup" (function(_ENV)
  inherit "Window"
  -----------------------------------------------------------------------------
  --                               Events                                    --
  -----------------------------------------------------------------------------
  event "OnTextureConfirmed"
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  function CloneMediaTexture(self)
    return self.MediaTexture and Toolset.clone(self.MediaTexture) or {}
  end

  function Reset(self)
    self.SourceType = nil
    self.MediaTexture = nil

    self:GetChild("SourceControl"):GetChild("DropDown"):SelectByValue("atlas")
    self:GetChild("AtlasControl"):GetChild("EditBox"):SetText("")
    self:GetChild("FileControl"):GetChild("EditBox"):SetText("")
    self:GetChild("ColorControl"):GetChild("ColorPicker"):SetColor()
  end

  function UpdateFromMediaTexture(self, mediaTexture)
    if not mediaTexture then 
      return 
    end

    local from = self.MediaTexture.from
    local value = self.MediaTexture.value

    self.SourceType = from

    self:GetChild("SourceControl"):GetChild("DropDown"):SelectByValue(self.SourceType)

    if self.SourceType == "atlas" then 
      self:GetChild("AtlasControl"):GetChild("EditBox"):SetText(value and value.name or "")
    elseif self.SourceType == "color" then 
      self:GetChild("FileControl"):GetChild("EditBox"):SetText(value)
    elseif self.SourceType == "file" then 
      self:GetChild("FileControl"):GetChild("EditBox"):SetText(value or "")
    end
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  __Observable__()
  property "MediaTexture" {
    type = SylingTracker.MediaTextureType
  }

  __Observable__()
  property "SourceType" {
    type = String,
    default = "atlas"
  }
  -----------------------------------------------------------------------------
  --                            Constructors                                 --
  -----------------------------------------------------------------------------
  __Template__ {
    SourceControl = Frame,
    AtlasControl = Frame,
    FileControl = Frame,
    ColorControl = Frame,
    PreviewTexture = SylingTracker.Texture,
    ConfirmButton = SuccessPushButton,
    {
      SourceControl = {
        Label = FontString,
        DropDown = DropDown
      },

      AtlasControl = {
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
      }
    }
  }
  function __ctor(self)
    self.cacheValues = {}

    local sourceDropDown = self:GetChild("SourceControl"):GetChild("DropDown")
    sourceDropDown:AddEntry( { text = "WoW Atlas", value = "atlas"})
    sourceDropDown:AddEntry( { text = "File", value = "file" })
    sourceDropDown:AddEntry( { text = "Color Square Texture", value = "color"})
    sourceDropDown:SelectByValue("atlas")

    local function OnSourceTypeEntrySelected(_, entry)
      local mediaTexture = self:CloneMediaTexture()
      local from = entry:GetEntryData().value

      self.SourceType = from

      mediaTexture.from = from
      mediaTexture.value = self.cacheValues[from]
      self.MediaTexture = mediaTexture
    end
    sourceDropDown:SetUserHandler("OnEntrySelected", OnSourceTypeEntrySelected)

    local atlasNameEditBox = self:GetChild("AtlasControl"):GetChild("EditBox")

    local function OnAtlasNameConfirmed()
      local atlasName = atlasNameEditBox:GetText()
      local mediaTexture = self:CloneMediaTexture()

      mediaTexture.from = self.SourceType
      mediaTexture.value = AtlasType(atlasName)
      self.cacheValues[self.SourceType] = mediaTexture.value

      self.MediaTexture = mediaTexture
    end

    atlasNameEditBox:SetUserHandler("OnEnterPressed", OnAtlasNameConfirmed)

    local fileEditBox = self:GetChild("FileControl"):GetChild("EditBox")

    local function OnFileConfirmed()
      local mediaTexture = self:CloneMediaTexture()
      local file = fileEditBox:GetText()

      mediaTexture.value = file
      self.cacheValues[self.SourceType] = mediaTexture.value

      self.MediaTexture = mediaTexture
    end
    fileEditBox:SetUserHandler("OnEnterPressed", OnFileConfirmed)


    local colorPicker = self:GetChild("ColorControl"):GetChild("ColorPicker")

    local function OnColorConfirmed(_, r, g, b, a)
      local mediaTexture = self:CloneMediaTexture()
      local color = { r = r, g = g, b = b, a = a }

      mediaTexture.value = color
      self.cacheValues[self.SourceType] = mediaTexture.value

      self.MediaTexture = mediaTexture
    end
    colorPicker:SetUserHandler("OnColorConfirmed", OnColorConfirmed)


    local confirmButton = self:GetChild("ConfirmButton")

    local function OnConfirm()
      self:OnTextureConfirmed(self.MediaTexture)
    end
    confirmButton:SetUserHandler("OnClick", OnConfirm)

  end
end)

__Widget__()
class "TexturePicker" (function(_ENV)
  inherit "PushButton"
  -----------------------------------------------------------------------------
  --                               Events                                    --
  -----------------------------------------------------------------------------
  event "OnTextureConfirmed"
  -----------------------------------------------------------------------------
  --                               Handlers                                  --
  -----------------------------------------------------------------------------
  local function OnClickHandler(self)

    if not TEXTURE_POPUP then 
      TEXTURE_POPUP = TexturePopup.Acquire()
      TEXTURE_POPUP:SetParent(UIParent)
      TEXTURE_POPUP:SetPoint("CENTER")
      TEXTURE_POPUP:SetFrameStrata("FULLSCREEN_DIALOG")
      TEXTURE_POPUP:SetTitle("Texture Picker")
      TEXTURE_POPUP:SetFrameLevel(self:GetFrameLevel() + 10)
      TEXTURE_POPUP:SetClampedToScreen(true)
      TEXTURE_POPUP.OnHide = TEXTURE_POPUP.OnHide + function()
        TEXTURE_POPUP:SetUserData("caller")
        TEXTURE_POPUP:Reset()
      end
    end 

    local caller = TEXTURE_POPUP:GetUserData("caller")

    if caller == self then
      TEXTURE_POPUP:Hide()
      return 
    end

    TEXTURE_POPUP:SetUserData("caller",  self)
    TEXTURE_POPUP:SetUserHandler("OnTextureConfirmed", function(_, ...) 
      self:OnTextureConfirmed(...) 
      TEXTURE_POPUP:Hide()
    end)
    TEXTURE_POPUP:Show()
  end
  -----------------------------------------------------------------------------
  --                            Constructors                                 --
  -----------------------------------------------------------------------------
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
  [TexturePopup] = {
    layoutManager = Layout.VerticalLayoutManager(),
    minResize = { width = 601, height = 400 },
    paddingTop = 50,
    paddingLeft = 10,

    SourceControl = {
      height = 35,
      id = 1, 

      Label = {
        fontObject = GameFontNormal,
        textColor = Color.WHITE, 
        justifyH = "LEFT", 
        text = "From", 
        location = { Anchor("LEFT"), Anchor("RIGHT", 0, 0, nil, "CENTER") }
      },

      DropDown = {
        location = { Anchor("LEFT", 0, 0, "Label", "RIGHT") }
      }
    },

    AtlasControl = {
      height = 35,
      id = 2,
      visible = Wow.FromUIProperty("SourceType"):Map(function(SourceType) return SourceType == "atlas" end),
      
      Label = {
        fontObject = GameFontNormal,
        textColor = Color.WHITE,
        justifyH = "LEFT",
        text = "Atlas Name",
        location = { Anchor("LEFT"), Anchor("RIGHT", 0, 0, nil, "CENTER") }
      },

      EditBox = {
        location = { Anchor("LEFT", 0, 0, "Label", "RIGHT") }
      }
    },

    FileControl = {
      height = 35,
      id = 2,
      visible = Wow.FromUIProperty("SourceType"):Map(function(SourceType) return SourceType == "file" end),

      Label = {
        fontObject = GameFontNormal,
        textColor = Color.WHITE,
        justifyH = "LEFT",
        text = "File",
        location = { Anchor("LEFT"), Anchor("RIGHT", 0, 0, nil, "CENTER") }
      },

      EditBox = {
        location = { Anchor("LEFT", 0, 0, "Label", "RIGHT") }
      }      
    },

    ColorControl = {
      height = 35,
      id = 2,
      visible = Wow.FromUIProperty("SourceType"):Map(function(SourceType) return SourceType == "color" end),

      Label = {
        fontObject = GameFontNormal,
        textColor = Color.WHITE,
        justifyH = "LEFT",
        text = "Color",
        location = { Anchor("LEFT"), Anchor("RIGHT", 0, 0, nil, "CENTER") }
      },

      ColorPicker = {
        location = { Anchor("LEFT", 0, 0, "Label", "RIGHT") }
      }
    },

    PreviewTexture = {
      height = 64,
      width = 64,
      mediaTexture = Wow.FromUIProperty("MediaTexture"),

      location = {
        Anchor("BOTTOM", 0, 50)
      }
    },

    ConfirmButton = {
      Text = {
        text = "Apply"
      },

      location = { Anchor("BOTTOM", 0, 10) }
    }
  },

  [TexturePicker] = {
    size = { width = 32, height = 26},
    
    Text = {
      visible = false
    },

    Texture = {
      mediaTexture = { from = "atlas", value = AtlasType("services-checkmark") },
      height = 16,
      width = 16,
      drawLayer = "OVERLAY",
      subLevel = 2,
      location = { Anchor("CENTER") }
    }
  }
})

-- function OnLoad(self)
--   local texturePicker = TexturePicker.Acquire()
--   texturePicker:SetParent(UIParent)
--   texturePicker:SetPoint("CENTER", 0, 200)
-- end