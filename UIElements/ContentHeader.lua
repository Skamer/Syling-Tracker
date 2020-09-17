-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Scorpio                 "SylingTracker.UIElements.ContentHeader"             ""
-- ========================================================================= --
namespace                           "SLT"
-- ========================================================================= --
class "ContentHeader" (function(_ENV)
  inherit "Button"

  __Template__ {
    IconBadge = IconBadge,
    Label = SLTFontString
  }
  function __ctor(self) end
end)

Style.UpdateSkin("Default", {
  [ContentHeader] = { 
    height = 32,
    backdrop = {
      bgFile = [[Interface\AddOns\SylingTracker\Media\Textures\LinearGradient]],
      edgeFile = [[Interface\Buttons\WHITE8X8]],
      edgeSize = 1
    },
    backdropColor = { r = 18/255, g = 20/255, b = 23/255, a = 0.87},
    backdropBorderColor = { r = 0, g = 0, b = 0, a = 1},

    IconBadge = {
      backdrop = {
        bgFile = [[Interface\AddOns\SylingTracker\Media\Textures\LinearGradient]]
      },
      backdropColor = { r = 0.25, g = 0.25, b = 0.25, a = 0.85},
      location = {
        Anchor("LEFT", 6, 0)
      }
    },

    Label = {
      -- font = FontType([[Interface\AddOns\EskaTracker2\Media\Fonts\PTSans-Narrow-Bold.ttf]], 16),
      sharedMediaFont = FontType("PT Sans Narrow Bold", 16),
      textColor = Color(0.18, 0.71, 1),
      justifyH = "CENTER",
      justifyV = "MIDDLE",
      location = {
        Anchor("TOP"),
        Anchor("LEFT", 0, 0, "IconBadge", "RIGHT"),
        Anchor("RIGHT"),
        Anchor("BOTTOM")
      }
    }
  }
})