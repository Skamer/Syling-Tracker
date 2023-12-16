-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                 "SylingTracker.Features.HelperWindow"                 ""
-- ========================================================================= --
DESCRIPTION_TEXT_FORMAT = "Wowhead may help you to find your way for completing this %s"
ACHIEVEMENT_TEXT        = "achievement"
QUEST_TEXT              = "quest"
WOWHEAD_LINK_FORMAT     = "https://www.wowhead.com/wotlk/%s=%i"
-- ========================================================================= --
__UIElement__()
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
    self.id = id 
  end

  __Arguments__ { String }
  function SetType(self, type)
    self.Type = type 
  end

  function UpdateText(self)
    if self.Type == "quest" then 
      Style[self].DescriptionText.text = DESCRIPTION_TEXT_FORMAT:format(QUEST_TEXT)
      Style[self].LinkBox.text = WOWHEAD_LINK_FORMAT:format("quest", self.id)
    elseif self.Type == "achievement" then 
       Style[self].DescriptionText.text = DESCRIPTION_TEXT_FORMAT:format(ACHIEVEMENT_TEXT)
       Style[self].LinkBox.text = WOWHEAD_LINK_FORMAT:format("achievement", self.id)
    end
  end
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  property "id " {
    type = Number
  }

  property "Type" {
    type = String
  }
  -----------------------------------------------------------------------------
  --                            Constructors                                 --
  -----------------------------------------------------------------------------
  __Template__ {
    CloseButton = Button,
    HeaderText = FontString,
    DescriptionText = FontString,
    CopyHelpText = FontString,
    LinkBox = EditBox,
  }
  function __ctor(self)
    local linkBox = self:GetChild("LinkBox")
    linkBox.OnEditFocusGained = OnFocusGain

    local closeButton = self:GetChild("CloseButton")
    closeButton.OnClick = function() self:Hide() end 
  end
end)
-------------------------------------------------------------------------------
--                                Styles                                     --
-------------------------------------------------------------------------------
Style.UpdateSkin("Default", {
  [HelperWindow] = {
    width   = 600,
    height  = 175,
    
    backdrop = {
      bgFile = [[Interface\AddOns\SylingTracker\Media\Textures\LinearGradient]],
      edgeFile            = [[Interface\Buttons\WHITE8X8]],
      edgeSize            = 1   
    },
    backdropColor       = { r = 0.1, g = 0.1, b = 0.1, a = 0.8},
    backdropBorderColor = { r = 0.1, g = 0.1, b = 0.1, a = 0.95},

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
      textColor = Color(0, 0.9, 0.9, 0.9),
      justifyH = "CENTER",
      location = {
        Anchor("TOP", 0, -10),
      }
    },

    DescriptionText = {
      height = 24,
      textColor = Color(0.75, 0.75, 0.75, 0.9),
      justifyH = "CENTER",
      location = {
        Anchor("TOP", 0, -50),
      }
    },

    CopyHelpText = {
      height = 24,
      text = "Ctrl + C to copy",
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
      fontObject = Game18Font,
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
-------------------------------------------------------------------------------
--                                   API                                     --
-------------------------------------------------------------------------------
HELPER_WINDOW = HelperWindow("SylingTracker_HelperWindow", UIParent)
HELPER_WINDOW:Hide()
HELPER_WINDOW:SetPoint("CENTER")

__Arguments__ { String, Number }
__Static__() function API.ShowHelperWindow(type, id)
  HELPER_WINDOW:SetType(type)
  HELPER_WINDOW:SetID(id)
  HELPER_WINDOW:UpdateText()
  HELPER_WINDOW:Show()
end

__Static__() function API.HideHelperWindow()
  HELPER_WINDOW:Hide()
end
