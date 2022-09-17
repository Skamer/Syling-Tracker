-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling          "SylingTracker_Options.Elements.ExpandableSection"           ""
-- ========================================================================= --
class "SUI.ExpandableSection" (function(_ENV)
  inherit "Frame"

  __Template__ {
    Button = Button,
    {
      Button = {
        Text = FontString
      }
    }
  }
  function __ctor(self) end
end)

Style.UpdateSkin("Default", {
  [SUI.ExpandableSection] = {
    height = 25,
    width = 200,

    Button = {
      height = 30,
      location = {
        Anchor("TOPLEFT"),
        Anchor("TOPRIGHT", -20, 0)
      },

      LeftBGTexture = {
        atlas = AtlasType("Options_ListExpand_Left", true),
        drawLayer = "BACKGROUND",
        location = {
          Anchor("TOPLEFT")
        }
      },
      RightBGTexture = {
        atlas = AtlasType("Options_ListExpand_Right", true),
        drawLayer = "BACKGROUND",
        location = {
          Anchor("TOPRIGHT")
        }
      },
      MiddleBGTexture = {
        atlas = AtlasType("_Options_ListExpand_Middle", true),
        drawLayer = "BACKGROUND",
        location = {
          Anchor("TOPLEFT", 0, 0, "LeftBGTexture", "TOPRIGHT"),
          Anchor("TOPRIGHT", 0, 0, "RightBGTexture", "TOPLEFT")
        }
      },

      Text = {
        fontObject = GameFontNormal,
        drawLayer = "OVERLAY",
        justifyH = "CENTER",
        maxLines = 1,
        text = "Advanced",
        location = {
          Anchor("LEFT", 21, 2)
        }
      }
    },

  }
})