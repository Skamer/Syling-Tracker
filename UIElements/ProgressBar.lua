-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Scorpio               "SylingTracker.UIElements.ProgressBar"                 ""
-- ========================================================================= --
namespace                          "SLT"
-- ========================================================================= --
__Recyclable__ "SylingTracker_ProgressBar%d"
class "ProgressBar" (function(_ENV)
  inherit "StatusBar"

  function SetStatusBarTexture(self, val)
    super.SetStatusBarTexture(self, val, "BORDER", -7)
  end
  
  function OnRelease(self)
    self:SetParent()
    self:ClearAllPoints()
    self:Hide()
  end

  function OnAcquire(self)
    self:Show()
  end 

  -----------------------------------------------------------------------------
  --                            Constructors                                 --
  -----------------------------------------------------------------------------
  __Template__{
    Text = SLTFontString
  }
  function __ctor(self) end
end)

Style.UpdateSkin("Default", {
  [ProgressBar] = {
    width = 150,
    height = 24,
    backdrop = { 
      bgFile = [[Interface\AddOns\SylingTracker\Media\Textures\LinearGradient]],
      edgeFile = [[Interface\Buttons\WHITE8X8]],
      edgeSize = 3
    },
    backdropColor = { r = 0, g = 0, b = 0, a = 0.5},
    backdropBorderColor = { r = 0, g = 0, b = 0, a = 1 },
    statusBarColor = ColorType(0, 148/255, 1, 0.6),

    -- StatusBar Texture
    StatusBarTexture = {
      file = [[Interface\AddOns\SylingTracker\Media\Textures\LinearGradient]],
      location = {
        Anchor("TOPLEFT", 3, -3),
        Anchor("BOTTOMRIGHT", -3, 3)
      }
    },

    -- Text Child 
    Text = {
      setAllPoints = true,
      sharedMediaFont = FontType("PT Sans Bold Italic", 13),
      textColor = Color(1, 1, 1),
      justifyH = "CENTER",
      justifyV = "MIDDLE",
    }
  }
})

function OnLoad(self)
  -- local pg = ProgressBar("ProgressBar #1")
  -- pg:SetParent(UIParent)
  -- pg:SetMinMaxValues(0, 1)
  -- pg:SetValue(0.6)
  -- pg:SetPoint("CENTER", 0, 200)
end 