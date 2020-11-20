-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                    "SylingTracker.UI.HelperWindow"                    ""
-- ========================================================================= --
namespace                             "SLT"
-- ========================================================================= --
export {
  FetchFontObject                     = Fonts.FetchFontObject
}
-- ========================================================================= --
local DESCRIPTION_TEXT_FORMAT = "Wowhead may help you to find your way for completing this %s"
local ACHIEVEMENT_TEXT = "achievement"
local QUEST_TEXT = "quest"
local WOWHEAD_LINK_FORMAT = "https://www.wowhead.com/%s=%i"
-- ========================================================================= --
-- @TODO: Move "SLTEditBox" in a its own file or a better place.
-- ========================================================================= --
class "SLTEditBox" (function(_ENV)
  inherit "EditBox"
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  function SetSharedMediaFont(self, font)
    local _, fontHeight, flags = self:GetFont()
    if font.outline then 
      if font.outline == "NORMAL" then 
        flags = "OUTLINE"
      elseif font.outline == "THICK" then 
        flags = "THICKOUTLINE"
      end 
    end

    if font.monochrome then 
      if flags then 
        flags = flags..",MONOCHROME"
      else
        flags = "MONOCHROME"
      end
    end

    if font.height then 
      fontHeight = font.height
    end

    local ft = _LibSharedMedia:Fetch("font", font.font)

    return self:SetFontObject(FetchFontObject(ft, fontHeight or 10, flags))
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  property "SharedMediaFont" {
    type = FontType,
    handler = function(self, font) self:SetSharedMediaFont(font) end
  }

end)
-- ========================================================================= --
class "HelperWindow" (function(_ENV)
  inherit "Frame"
  -----------------------------------------------------------------------------
  --                               Handlers                                  --
  -----------------------------------------------------------------------------
  local function OnFocusGain(self)
    self:HighlightText()
  end
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  __Arguments__ { Number }
  function SetID(self, id)
    self.ID = id
  end

  __Arguments__ { String }
  function SetType(self, type)
    self.Type = type
  end

  function UpdateText(self)
    if self.Type == "quest" then 
      Style[self].Description.text = DESCRIPTION_TEXT_FORMAT:format(QUEST_TEXT)
      Style[self].LinkBox.text = WOWHEAD_LINK_FORMAT:format("quest", self.ID)
    elseif self.Type == "achievement" then 
       Style[self].Description.text = DESCRIPTION_TEXT_FORMAT:format(ACHIEVEMENT_TEXT)
       Style[self].LinkBox.text = WOWHEAD_LINK_FORMAT:format("achievement", self.ID)
    end
  end
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  property "ID " {
    type = Number
  }

  property "Type" {
    type = String
  }
  -----------------------------------------------------------------------------
  --                            Constructors                                 --
  -----------------------------------------------------------------------------
  __Template__{
    CloseButton = Button,
    HeaderText = SLTFontString,
    Description = SLTFontString,
    CopyHelpText = SLTFontString,
    LinkBox = SLTEditBox
  }
  function __ctor(self)
    HelperFrameInstance = self 
    local linkBox = self:GetChild("LinkBox")
    linkBox.OnEditFocusGained = OnFocusGain

    local closeButton = self:GetChild("CloseButton")
    closeButton.OnClick = function() self:Hide() end
  end

end)
-- ========================================================================= --
--                                Styles                                     --
-- ========================================================================= --
Style.UpdateSkin("Default", {
  [HelperWindow] = {
    width = 600,
    height = 175,
    backdrop = {
      bgFile = [[Interface\AddOns\SylingTracker\Media\Textures\Window-Background.blp]]
    },

    CloseButton = {
      width = 24,
      height = 24,
      registerForClicks = { "LeftButtonDown" },
      
      NormalTexture = {
        file = [[Interface\AddOns\SylingTracker\Media\Textures\Icons\close]],
        vertexColor = { r = 1, g = 0, b = 0, a = 0.5},
        setAllPoints = true,
      },
      HighlightTexture = {
        file = [[Interface\AddOns\SylingTracker\Media\Textures\Icons\close]],
        vertexColor = { r = 1, g = 0, b = 0, a = 0.15},
        setAllPoints = true,
      },
      
      location = {
        Anchor("TOPRIGHT", -5, -5)
      }
    },

    HeaderText = {
      height = 24,
      text = "Need Help ?",
      sharedMediaFont = FontType("PT Sans Narrow Bold", 16),
      textColor = Color(0, 0.9, 0.9, 0.9),
      justifyH = "CENTER",
      location = {
        Anchor("TOP", 0, -10),
      }
    },

    Description = {
      height = 24,
      sharedMediaFont = FontType("PT Sans Narrow Bold", 14),
      textColor = Color(0.75, 0.75, 0.75, 0.9),
      justifyH = "CENTER",
      location = {
        Anchor("TOP", 0, -50),
      }
    },

    CopyHelpText = {
      height = 24,
      text = "Ctrl + C to copy",
      sharedMediaFont = FontType("PT Sans Narrow Bold", 13),
      textColor = Color(0.9, 0.37, 0, 0.9),
      justifyH = "CENTER",
      location = {
        Anchor("BOTTOM", 0, 5, "LinkBox", "TOP"),
      }
    },

    LinkBox = {
      height = 36,
      backdrop = {
        bgFile = [[Interface\Buttons\WHITE8X8]]
      },
      backdropColor = { r = 255/255, g = 255/255, b = 255/255, a = 0.07 },
      sharedMediaFont = FontType("PT Sans Narrow Bold", 15),
      textColor = Color(0.9, 195/255, 0, 0.9),
      textInsets = Inset(10, 0, 5, 5),
      autoFocus = false,
      location = {
        Anchor("LEFT", 20),
        Anchor("RIGHT", -20),
        Anchor("BOTTOM", 0, 20)
      }
    }
  }
})
-- ========================================================================= --
local HelperWindowObj = HelperWindow("SylingTracker_HelperWindow", UIParent)
HelperWindowObj:Hide()
HelperWindowObj:SetPoint("CENTER")
-- ========================================================================= --
-- Enchance the API
-- ========================================================================= --
class "API" (function(_ENV)
  
  __Arguments__{ String, Number }
  __Static__() function ShowHelperWindow(type, id)

    HelperWindowObj:SetType(type)
    HelperWindowObj:SetID(id)
    HelperWindowObj:UpdateText()
    HelperWindowObj:Show()
  end

  __Static__() function HideHelperWindow()
    HelperWindowObj:Hide()
  end
end)