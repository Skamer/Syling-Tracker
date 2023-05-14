-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                     "SylingTracker.UI.ProgressBar"                    ""
-- ========================================================================= --
__UIElement__()
class "ProgressBar" (function(_ENV)
  inherit "StatusBar"

  __Template__{
    Text = FontString
  }
  function __ctor(self) end 
end)
-------------------------------------------------------------------------------
--                                Styles                                     --
-------------------------------------------------------------------------------
Style.UpdateSkin("Default", {
  [ProgressBar] = {
    height = 20,
    
    backdrop = { 
      bgFile              = [[Interface\Buttons\WHITE8X8]],
      edgeFile            = [[Interface\Buttons\WHITE8X8]],
      edgeSize            = 1
    },
    backdropColor         = { r = 0, g = 0, b = 0, a = 0.5},
    backdropBorderColor   = { r = 0, g = 0, b = 0, a = 1 },
    
    StatusBarTexture = {
      file                = [[Interface\AddOns\SylingTracker\Media\Textures\LinearGradient]],
      drawLayer           = "BACKGROUND"
    },
    statusBarColor        = { r = 0, g = 148/255, b = 1, a = 0.6},

    Text = {
      text = "100%",
      setAllPoints        = true,
      mediaFont           = FontType("PT Sans Bold Italic", 12),
      textColor           = Color.WHITE,
      justifyH            = "CENTER",
      justifyV            = "MIDDLE",
    }
  }
})