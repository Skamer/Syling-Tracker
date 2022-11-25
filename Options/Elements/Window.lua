-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                "SylingTracker.Options.Elements.Window"                ""
-- ========================================================================= --
local WINDOW_SLICES = [[Interface\AlliedRaces\AlliedRacesUnlockingFramePart2]]
local RED_BUTTON_FILE = [[Interface\AddOns\SylingTracker_Options\Media\BLZ_redbutton2x]]

__Widget__()
class "SUI.Window" (function(_ENV)
    inherit "Frame"
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
    function SetTitle(self, title)
      Style[self].Text.text = title
    end
  -----------------------------------------------------------------------------
  --                            Constructors                                 --
  -----------------------------------------------------------------------------
  __Template__ {
    CloseButton = UIPanelCloseButton,
    Text = FontString
  }
  function __ctor(self) end
end)
-------------------------------------------------------------------------------
--                                Styles                                     --
-------------------------------------------------------------------------------
Style.UpdateSkin("Default", {
  [SUI.Window] = {
    width = 601,
    height = 400,
    movable = true,

    TopLeftBGTexture = {
      height = 40,
      width = 40,
      file = WINDOW_SLICES,
      drawLayer = "OVERLAY",
      snapToPixelGrid = false,
      texelSnappingBias = 0,
      texCoords = { left = 0, right = 40/512, top = 0, bottom = 40/1024},
      location = {
        Anchor("TOPLEFT")
      }
    },
    TopRightBGTexture = {
      height = 40,
      width = 40,
      file = WINDOW_SLICES,
      drawLayer = "OVERLAY",
      snapToPixelGrid = false,
      texelSnappingBias = 0,
      texCoords = { left = 290/512, right = 330/512, top = 0, bottom = 40/1024},
      location = {
        Anchor("TOPRIGHT")
      }
    },
    BottomLeftBGTexture = {
      height = 40,
      width = 40,
      file = WINDOW_SLICES,
      drawLayer = "OVERLAY",
      snapToPixelGrid = false,
      texelSnappingBias = 0,      
      texCoords = { left =  0, right = 40/512, top = 550/1024, bottom = 590/1024},
      location = {
        Anchor("BOTTOMLEFT")
      }
    },
    BottomRightBGTexture = {
      height = 40,
      width = 40,
      file = WINDOW_SLICES,
      drawLayer = "OVERLAY",
      snapToPixelGrid = false,
      texelSnappingBias = 0,      
      texCoords = { left =  290/512, right = 330/512, top = 550/1024, bottom = 590/1024},
      location = {
        Anchor("BOTTOMRIGHT")
      }
    },
    TopBGTexture = {
      height = 40,
      file = WINDOW_SLICES,
      drawLayer = "OVERLAY",
      snapToPixelGrid = false,
      texelSnappingBias = 0,      
      texCoords = { left =  40/512, right = 290/512, top = 0, bottom = 40/1024},
      location = {
        Anchor("TOPLEFT", 0, 0, "TopLeftBGTexture", "TOPRIGHT"),
        Anchor("TOPRIGHT", 0, 0, "TopRightBGTexture", "TOPLEFT")
      }
    },
    BottomBGTexture = {
      height = 40,
      file = WINDOW_SLICES,
      drawLayer = "OVERLAY",
      snapToPixelGrid = false,
      texelSnappingBias = 0,   
      texCoords = { left =  40/512, right = 290/512, top = 550/1024, bottom = 590/1024},
      location = {
        Anchor("BOTTOMLEFT", 0, 0, "BottomLeftBGTexture", "BOTTOMRIGHT"),
        Anchor("BOTTOMRIGHT", 0, 0, "BottomRightBGTexture", "BOTTOMLEFT")
      }
    },
    LeftBGTexture = {
      width = 40,
      file = WINDOW_SLICES,
      drawLayer = "OVERLAY",
      snapToPixelGrid = false,
      texelSnappingBias = 0,      
      texCoords = { left =  0, right = 40/512, top = 40/1024, bottom = 550/1024},
      location = {
        Anchor("TOPLEFT", 0, 0, "TopLeftBGTexture", "BOTTOMLEFT"),
        Anchor("BOTTOMLEFT", 0, 0, "BottomLeftBGTexture", "TOPLEFT")
      }
    },
    RightBGTexture = {
      width = 40,
      file = WINDOW_SLICES,
      drawLayer = "OVERLAY",
      snapToPixelGrid = false,
      texelSnappingBias = 0,      
      texCoords = { left =  290/512, right = 330/512, top = 40/1024, bottom = 550/1024},
      location = {
        Anchor("TOPRIGHT", 0, 0, "TopRightBGTexture", "BOTTOMRIGHT"),
        Anchor("BOTTOMRIGHT", 0, 0, "BottomRightBGTexture", "TOPRIGHT")
      }
    },
    BackgroundTexture = {
      color = { r = 0.12156, g = 0.11764, b = 0.12941, a = 0.8},
      visible = true,
      location = {
        Anchor("TOPLEFT", 10, -10),
        Anchor("BOTTOMRIGHT", -10, 10)
      }
    },


    CloseButton = {
      size = Size(24, 24),
      location = {
        Anchor("TOPRIGHT", 5.6, 5)
      },

      NormalTexture = {
        --- RedButton-Exit
        file = RED_BUTTON_FILE,
        texCoords = { left =  0.15234375, right = 0.29296875, top = 0.0078125, bottom = 0.3046875},
        setAllPoints = true
      },
      PushedTexture = {
        ---  RedButton-exit-pressed
        file = RED_BUTTON_FILE,
        texCoords = { left =  0.15234375, right = 0.29296875, top = 0.6328125, bottom = 0.9296875},
        setAllPoints = true
      },
      HighlightTexture = {
        --- RedButton-Highlight
        file = RED_BUTTON_FILE,
        texCoords = { left =  0.59765625, right = 0.73828125, top = 0.0078125, bottom = 0.3046875},
        alphaMode = "ADD",
        setAllPoints = true
      },
      DisabledTexture = {
        --- RedButton-Exit-Disabled
        file = RED_BUTTON_FILE,
        texCoords = { left =  0.15234375, right = 0.29296875, top = 0.3203125, bottom = 0.6171875},
        setAllPoints = true
      }
    },

    Text = {
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