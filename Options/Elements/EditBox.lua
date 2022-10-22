-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling            "SylingTracker.Options.Elements.EditBox"                   ""
-- ========================================================================= --
__Widget__()
class "SUI.EditBox" (function(_ENV)
  -- As we are in the SUI namespace, we need to use the full path of Scorpio
  -- EditBox for avoiding a overflow.
  inherit "Scorpio.UI.EditBox"
  -----------------------------------------------------------------------------
  --                            Constructors                                 --
  -----------------------------------------------------------------------------
  __Template__{
    Instructions = FontString
  }
  function __ctor(self) 
    self.OnTextChanged = self.OnTextChanged + function()
      local instructions = self:GetChild("Instructions")
      instructions:SetShown(self:GetText() == "")
    end

    self.OnTextSet = self.OnTextSet + function()
      self:SetCursorPosition(0)
    end
  end
end)
-------------------------------------------------------------------------------
--                                Styles                                     --
-------------------------------------------------------------------------------
Style.UpdateSkin("Default", {
  [SUI.EditBox] = {
    size = Size(280, 26),
    autoFocus = false,
    fontObject = ChatFontNormal,
    textInsets = Inset(10, 0, 5, 5),
    historyLines = 1,

    LeftBGTexture = {
      atlas = AtlasType("common-search-border-left", false),
      size = Size(8, 24),
      drawLayer = "BACKGROUND",
      location = {
        Anchor("LEFT", -5, 0)
      }
    },
    RightBGTexture = {
      size = Size(8, 24),
      atlas = AtlasType("common-search-border-right", false),
      drawLayer = "BACKGROUND",
      location = {
        Anchor("RIGHT")
      }
    },
    MiddleBGTexture = {
      size = Size(10, 24),
      atlas = AtlasType("common-search-border-middle", false),
      drawLayer = "BACKGROUND",
      location = {
        Anchor("LEFT", 0, 0, "LeftBGTexture", "RIGHT"),
        Anchor("RIGHT", 0, 0, "RightBGTexture", "LEFT")
      }
    },

    Instructions = {
      fontObject = GameFontDisableSmall,
      textColor = { r = 0.35, g = 0.35, b = 0.35},
      justifyH = "LEFT",
      justifyV = "MIDDLE",
      drawLayer = "BACKGROUND",
      location = {
        Anchor("TOP"),
        Anchor("LEFT", 10, 0),
        Anchor("RIGHT"),
        Anchor("BOTTOM")
      }
    }
  }
})