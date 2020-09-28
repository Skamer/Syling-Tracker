-- ========================================================================= --
--                              EskaTracker 2                                --
--           https://www.curseforge.com/wow/addons/eskatracker-2             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/EskaTracker2                  --
--                                                                           --
-- ========================================================================= --
Syling                      "SylingTracker.UI.ITimer"                        ""
-- ========================================================================= --
namespace                          "SLT"
-- ========================================================================= --
interface "ITimer" (function(_ENV)
  require "Frame"
  -----------------------------------------------------------------------------
  --                               Handlers                                  --
  -----------------------------------------------------------------------------
  local function OnUpdateHandler(self)
    self:OnTimerUpdate(GetTime() - self.StartTime)
  end
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  function OnTimerUpdate(self, elapsedTime) end

  function Start(self)
    self.OnUpdate = self.OnUpdate + OnUpdateHandler
  end

  function Stop(self)
    self.OnUpdate = self.OnUpdate - OnUpdateHandler
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  property "StartTime" {
    type = Number
  }

  property "TimeSinceBase" {
    type = Number,
    default = 0
  }
end)