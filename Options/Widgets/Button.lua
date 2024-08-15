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
export {
  FromUIProperty   = Wow.FromUIProperty
}

__Widget__()
class "PushButton" (function(_ENV)
  inherit "Button"
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  __Abstract__() function RefreshState(self) end

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
  __Observable__()
  property "Mouseover" {
    type = Boolean,
    default = false,
    handler = function(self, new) self:RefreshState() end
  }

  property "MouseoverBorderColor" {
    type = Color,
    default = Color(1, 1, 0, 0.75)
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
  end

end)

__Widget__()
class "DangerPushButton" { PushButton }

__Widget__()
class "SuccessPushButton" { PushButton }
-------------------------------------------------------------------------------
--                              Observables                                  --
-------------------------------------------------------------------------------
__Arguments__ { ColorType/Color(0.35, 0.35, 0.35, 0.5), ColorType/Color(1, 1, 0, 0.75) }
function FromBorderColor(normalColor, mouseoverColor)
  if normalColor == mouseoverColor then 
    return Observable.Just(normalColor)
  end

  return FromUIProperty("Mouseover"):Map(function(mouseover)
    return mouseover and mouseoverColor or normalColor
  end)
end

PushButton.FromBorderColor = FromBorderColor
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
    backdropBorderColor = FromBorderColor(),
  
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
    backdropBorderColor = FromBorderColor({ r = 0.65, g = 0, b = 0, a = 0.75}),    
  },
  [SuccessPushButton] = {
  
    backdropColor       = { r = 0, g = 0.65, b = 0, a = 0.5},
    backdropBorderColor = FromBorderColor({ r = 0, g = 0.65, b = 0, a = 0.75}),    
  },
})

