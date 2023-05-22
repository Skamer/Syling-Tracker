-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                "SylingTracker_Options.Widgets.Window"                 ""
-- ========================================================================= --
namespace               "SylingTracker.Options.Widgets"
-- ========================================================================= --
__Widget__()
class "Window" (function(_ENV)
  inherit "Frame"
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  function SetTitle(self, title)
    Style[self].Title.text = title
  end
  -----------------------------------------------------------------------------
  --                            Constructors                                 --
  -----------------------------------------------------------------------------
  __Template__ {
    CloseButton = UIPanelCloseButton,
    Title = FontString
  }
  function __ctor(self) end
end)
-------------------------------------------------------------------------------
--                                Styles                                     --
-------------------------------------------------------------------------------
Style.UpdateSkin("Default", {
  [Window] = {
    width = 601,
    height = 400,
    movable = true,

    backdrop = { 
      bgFile              = [[Interface\Buttons\WHITE8X8]],
      edgeFile            = [[Interface\Buttons\WHITE8X8]],
      edgeSize            = 1
    },

    backdropColor         = { r = 0, g = 0, b = 0, a = 0.5},
    backdropBorderColor   = { r = 0, g = 0, b = 0, a = 1 },    


    CloseButton = {
      location = {
        Anchor("TOPRIGHT", 5, 5)
      },
    },

    Title = {
      fontObject = GameFontNormal,
      drawLayer = "OVERLAY",
      wordWrap = false,
      location = {
        Anchor("TOP", 0, -5),
        Anchor("LEFT", 60, 0),
        Anchor("RIGHT", -60, 0)
      }
    },

    Mover = {
      height = 30,
      enableMouse = true,
      location = {
        Anchor("TOP"),
        Anchor("LEFT"),
        Anchor("RIGHT")
      }
    }

  }
})