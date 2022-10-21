-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                "SylingTracker_Options.Elements.Window"                ""
-- ========================================================================= --
class "SUI.Window" (function(_ENV)
    inherit "Frame"

    function SetTitle(self, title)
      Style[self].Text.text = title
    end

  __Template__ {
    CloseButton = UIPanelCloseButton,
    Text = FontString
  }
  function __ctor(self) end
end)

Style.UpdateSkin("Default", {
  [SUI.Window] = {
    width = 601,
    height = 400,
    movable = true,

    TopLeftBGTexture = {
      atlas = AtlasType("UI-Frame-Metal-CornerTopLeft", true),
      drawLayer = "OVERLAY",
      location = {
        Anchor("TOPLEFT", -4, 16)
      }
    },
    TopRightBGTexture = {
      atlas = AtlasType("UI-Frame-Metal-CornerTopRightDouble", true),
      drawLayer = "OVERLAY",
      location = {
        Anchor("TOPRIGHT", 4, 16)
      }
    },
    BottomLeftBGTexture = {
      atlas = AtlasType("UI-Frame-Metal-CornerBottomLeft", true),
      drawLayer = "OVERLAY",
      location = {
        Anchor("BOTTOMLEFT", -12, -3)
      }
    },
    BottomRightBGTexture = {
      atlas = AtlasType("UI-Frame-Metal-CornerBottomRight", true),
      drawLayer = "OVERLAY",
      location = {
        Anchor("BOTTOMRIGHT", 4, -3)
      }
    },
    TopBGTexture = {
      atlas = AtlasType("_UI-Frame-Metal-EdgeTop", true),
      drawLayer = "OVERLAY",
      location = {
        Anchor("TOPLEFT", 0, 0, "TopLeftBGTexture", "TOPRIGHT"),
        Anchor("TOPRIGHT", 0, 0, "TopRightBGTexture", "TOPLEFT")
      }
    },
    BottomBGTexture = {
      atlas = AtlasType("_UI-Frame-Metal-EdgeBottom", true),
      drawLayer = "OVERLAY",
      location = {
        Anchor("BOTTOMLEFT", 0, 0, "BottomLeftBGTexture", "BOTTOMRIGHT"),
        Anchor("BOTTOMRIGHT", 0, 0, "BottomRightBGTexture", "BOTTOMLEFT")
      }
    },
    LeftBGTexture = {
      atlas = AtlasType("!UI-Frame-Metal-EdgeLeft", true),
      drawLayer = "OVERLAY",
      location = {
        Anchor("TOPLEFT", -8, 0, "TopLeftBGTexture", "BOTTOMLEFT"),
        Anchor("BOTTOMLEFT", 0, 0, "BottomLeftBGTexture", "TOPLEFT")
      }
    },
    RightBGTexture = {
      atlas = AtlasType("!UI-Frame-Metal-EdgeRight", true),
      drawLayer = "OVERLAY",
      location = {
        Anchor("TOPRIGHT", 0, 0, "TopRightBGTexture", "BOTTOMRIGHT"),
        Anchor("BOTTOMRIGHT", 0, 0, "BottomRightBGTexture", "TOPRIGHT")
      }
    },
    BackgroundTexture = {
      color = ColorType(0, 0, 0, 0.8),
      location = {
        Anchor("TOPLEFT", 0, -20),
        Anchor("BOTTOMRIGHT")
      }
    },


    CloseButton = {
      size = Size(24, 24),
      location = {
        Anchor("TOPRIGHT", 5.6, 5)
      },

      NormalTexture = {
        atlas = AtlasType("RedButton-Exit"),
        setAllPoints = true
      },
      PushedTexture = {
        atlas = AtlasType("RedButton-exit-pressed"),
        setAllPoints = true
      },
      HighlightTexture = {
        atlas = AtlasType("RedButton-Highlight"),
        alphaMode = "ADD",
        setAllPoints = true
      },
      DisabledTexture = {
        atlas = AtlasType("RedButton-Exit-Disabled"),
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
      height = 20,
      enableMouse = true,
      location = {
        Anchor("TOP"),
        Anchor("LEFT"),
        Anchor("RIGHT")
      }
    }
  }
})