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
  local function OnUpdateHandler(self, deltaSeconds)
    self.TimeSinceBase = self.TimeSinceBase + deltaSeconds
    self:OnTimerUpdate(math.floor(self.BaseTime + self.TimeSinceBase))
  end
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  function OnTimerUpdate(self, elapsedTime) end

  function StartTimer(self)
    self.OnUpdate = self.OnUpdate + OnUpdateHandler
  end

  function StopTimer(self)
    self.OnUpdate = self.OnUpdate - OnUpdateHandler
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  property "BaseTime" {
    type = Number
  }

  property "TimeSinceBase" {
    type = Number,
    default = 0
  }

  property "Update"
end)