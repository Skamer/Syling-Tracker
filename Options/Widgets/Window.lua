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

  local function OnCloseButtonEnter(self)
    Style[self].BackgroundTexture.vertexColor = {  r = 1, g = 0, b = 0, a = 0.75}
  end

  local function OnCloseButtonLeave(self)
    Style[self].BackgroundTexture.vertexColor = {  r = 1, g = 1, b = 1, a = 0.3 }
  end
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  function SetTitle(self, title)
    Style[self].Header.Title.text = title
  end
  -----------------------------------------------------------------------------
  --                            Constructors                                 --
  -----------------------------------------------------------------------------
  __Template__ {
    Header = Frame,
    Title = FontString,
    {
      Header = {
        Title = FontString,
        CloseButton = Button,
      }
    }
  }
  function __ctor(self) 
    local header = self:GetChild("Header")
    local closeButton = header:GetChild("CloseButton")

    closeButton.OnEnter = closeButton.OnEnter + OnCloseButtonEnter
    closeButton.OnLeave = closeButton.OnLeave + OnCloseButtonLeave

    closeButton.OnClick = closeButton.OnClick + function() self:Hide() end
  end
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
      bgFile              = [[Interface\AddOns\SylingTracker_Options\Media\background]],
      edgeFile            = [[Interface\Buttons\WHITE8X8]],
      edgeSize            = 1
    },

    backdropBorderColor   = { r = 54/255, g = 56/255, b = 62/255, a = 1 },    

    Header = {
      height = 40,
      location = {
        Anchor("TOP"),
        Anchor("LEFT", 1, 0),
        Anchor("RIGHT", -1, 0)
      },

      Title = {
        fontObject = GameFontNormal,
        text = "Syling Tracker - Optionss",
        drawLayer = "OVERLAY",
        wordWrap = false,
        SetAllPoints = true,
        justifyH = "CENTER",
        justifyV = "MIDDLE"
      },

      CloseButton = {
        height = 16,
        width = 16,

        BackgroundTexture = {
          height = 12,
          width = 12,
          file = [[Interface\AddOns\SylingTracker_Options\Media\close]],
          vertexColor = { r = 1, g = 1, b = 1, a = 0.3 },
          location = {
            Anchor("CENTER")
          }
        },
        location = {
          Anchor("RIGHT", -5, 0)
        }
      },
      
      BackgroundTexture = {
        SetAllPoints = true,
        color = { r = 0.5, g = 0.5, b = 0.5, a = 0.05}
      },

      BottomBGTexture = {
        height = 1,
        color = { r = 54/255, g = 56/255, b = 62/255 },
        location = {
          Anchor("BOTTOMLEFT"),
          Anchor("BOTTOMRIGHT")
        }
      }

    },
    
    Mover = {
      height = 40,
      enableMouse = true,
      location = {
        Anchor("TOP"),
        Anchor("LEFT"),
        Anchor("RIGHT")
      }
    }

  }
})