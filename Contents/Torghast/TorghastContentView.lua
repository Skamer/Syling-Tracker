-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                        "SylingTracker.Torghast.ContentView"           ""
-- ========================================================================= --
namespace                          "SLT"
-- ========================================================================= --
-- Iterator helper for ignoring the children are used for backdrop, and avoiding
-- they are taken as account for their parent height
local IterateFrameChildren  = Utils.IterateFrameChildren
-- ========================================================================= --
__Recyclable__ "SylingTracker_TorghastContentView"
class "TorghastContentView" (function(_ENV)
  inherit "ContentView"


  -----------------------------------------------------------------------------
  --                            Constructors                                 --
  -----------------------------------------------------------------------------
  __Template__{
    {
      Content = {
        TopInfo = Frame,
        {
          TopInfo = {
            Level = SLTFontString,
            Fanstasm = Frame,
            RemainingDeath = Frame,
            {
              Fanstasm = {
                IconTex = Texture,
                TextFS  = SLTFontString
              },
              RemainingDeath = {
                IconTex = Texture,
                TextFS = SLTFontString
              }
            }
          }
        }
      }
    }
  }
  function __ctor(self)


  end
end)
-------------------------------------------------------------------------------
--                                Styles                                     --
-------------------------------------------------------------------------------
Style.UpdateSkin("Default", {
  [TorghastContentView] = {
    Header = {
      IconBadge = {
        Icon = {
          atlas = AtlasType("poi-torghast")
        }
      },
      Label = {
        text = "Torghast"
      }
    },

    Content = {
      TopInfo = {
        height = 28,
        backdrop = {
          bgFile = [[Interface\AddOns\SylingTracker\Media\Textures\LinearGradient]]
        },

        backdropColor = { r = 0.1, g = 0.1, b = 0.1, a = 0.7},
        location = {
          Anchor("TOP"),
          Anchor("LEFT"),
          Anchor("RIGHT")
        },

        -- Level 
        Level = {
          height = 24,
          sharedMediaFont = FontType("PT Sans Narrow Bold", 13),
          text = "Level 14",
          textTransform   = "UPPERCASE",
          location = {
            Anchor("TOP"),
            Anchor("LEFT", 5, 0),
          }
        },

        Fanstasm = {
          height = 24,
          width = 60,
          location = {
            Anchor("TOP")
          },

          IconTex = {
            height = 16,
            width = 16,
            fileID = 3743737,

            location = {
              Anchor("LEFT")
            }
          },

          TextFS = {
            text = "19585",
            sharedMediaFont = FontType("PT Sans Caption Bold", 11),
            justifyH = "LEFT",
            location = {
              Anchor("LEFT", 5, 0, "IconTex", "RIGHT"),
              Anchor("RIGHT")
            }
          }
        },

        RemainingDeath = {
          height = 24,
          width  = 50,
          location = {
            Anchor("TOP"),
            Anchor("RIGHT", -5, 0)
          },

          IconTex = {
            height = 16,
            width  = 16,
            fileID = 3450602,

            location = {
              Anchor("LEFT")
            }
          },

          TextFS = {
            text = "15",
            sharedMediaFont = FontType("PT Sans Caption Bold", 11),
            justifyH = "LEFT",
            location = {
              Anchor("LEFT", 5, 0, "IconTex", "RIGHT"),
              Anchor("RIGHT")
            }
          }
        }
      }
    }
  }
})