-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                     "SylingTracker.Core.StatusBar"                    ""
-- ========================================================================= --
class "StatusBar"(function(_ENV)
  inherit "Scorpio.UI.StatusBar"
  -----------------------------------------------------------------------------
  --                               Handlers                                  --
  -----------------------------------------------------------------------------
  function OnEnterHandler(self)
    self.Mouseover = true 
  end

  function OnLeaveHandler(self)
    self.Mouseover = false
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  __Observable__()
  property "Mouseover" {
    type = Boolean,
    default = false
  }
  -----------------------------------------------------------------------------
  --                              Constructors                               --
  -----------------------------------------------------------------------------
  __Template__ {}
  function __ctor(self)
    self.OnEnter = self.OnEnter + OnEnterHandler
    self.OnLeave = self.OnLeave + OnLeaveHandler
  end
end)