-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                "SylingTracker_Options.Widgets.Button"                 ""
-- ========================================================================= --
namespace               "SylingTracker.Options.Widgets"
-- ========================================================================= --

__Widget__()
class "PushButton" (function(_ENV)
  inherit "Button"
  -----------------------------------------------------------------------------
  --                               Handlers                                  --
  -----------------------------------------------------------------------------
  local function RefreshState(self)
    if self.Mouseover then 
      Style[self].backdropBorderColor = Color(1, 1, 0, 0.75)
    else
      Style[self].backdropBorderColor = self.__normalBorderColor
    end
  end
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  __Arguments__ { String/""}
  function SetText(self, text)
    Style[self].Text.text = text
  end

  function OnRelease(self)
    self:SetID(0)
    self:Hide()
    self:ClearAllPoints()
    self:SetParent(nil)

    self.Mouseover = nil
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  property "Mouseover" {
    type = Boolean,
    default = false,
    handler = function(self, new)
      if new then 
        self.__normalBorderColor = Style[self].backdropBorderColor
      end

      RefreshState(self)

      if not new then 
        self.__normalBorderColor = nil 
      end
    end
  }
  -----------------------------------------------------------------------------
  --                            Constructors                                 --
  -----------------------------------------------------------------------------
  __Template__ {
    Text = FontString
  }
  function __ctor(self)
    self.OnEnter = self.OnEnter + function() self.Mouseover = true end 
    self.OnLeave = self.OnLeave + function() self.Mouseover = false end

    RefreshState(self)
  end
end)

__Widget__()
class "DangerPushButton" { PushButton }

__Widget__()
class "SuccessPushButton" { PushButton }
-------------------------------------------------------------------------------
--                                Styles                                     --
-------------------------------------------------------------------------------
Style.UpdateSkin("Default", {
  [PushButton] = {
    size = Size(150, 26),

    marginTop = 10,

    backdrop = {
      bgFile = [[Interface\AddOns\SylingTracker\Media\Textures\LinearGradient]],
      edgeFile            = [[Interface\Buttons\WHITE8X8]],
      edgeSize            = 1   
    },
    backdropColor       = { r = 0.35, g = 0.35, b = 0.35, a = 0.5},
    backdropBorderColor = { r = 0.35, g = 0.35, b = 0.35, a = 0.75},
  
    Text = {
      setAllPoints = true,
      fontObject = GameFontNormal,
      justifyH = "CENTER",
      maxLines = 1,
      textColor = ColorType(1, 1, 1)
    }
  },

  [DangerPushButton] = {   
    backdropColor       = { r = 0.65, g = 0, b = 0, a = 0.5},
    backdropBorderColor = { r = 0.65, g = 0, b = 0, a = 0.75},    
  },
  [SuccessPushButton] = {
  
    backdropColor       = { r = 0, g = 0.65, b = 0, a = 0.5},
    backdropBorderColor = { r = 0, g = 0.65, b = 0, a = 0.75},    
  },
})