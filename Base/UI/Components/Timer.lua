-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                 "SylingTracker.UI.Timer"                              ""
-- ========================================================================= --
export {
  RegisterUISetting                   = API.RegisterUISetting,
  FromUISetting                       = API.FromUISetting,
  GetFrameByType                      = Wow.GetFrameByType,
  FromUIProperty                      = Wow.FromUIProperty
}

__UIElement__()
class "Timer" (function(_ENV)
  inherit "Frame"
  -----------------------------------------------------------------------------
  --                               Handlers                                  --
  -----------------------------------------------------------------------------
  local function OnUpdateHandler(self, elapsed)
    if not self.Paused then 
      self.ElapsedTime = GetTime() - self.StartTime - self.PausedElapsedTime
    else
      self.PausedElapsedTime = self.PausedElapsedTime + elapsed 
    end
  end

  local function OnTimeSettingsChangedHandler(self, new, old, prop)
    -- If the timer is not started or no full timer info, don't continue
    if self.Started and self.StartTime > 0 and self.Duration > 0 then
      self.OnUpdate = OnUpdateHandler
    else
      self.OnUpdate = nil
    end
  end
  -----------------------------------------------------------------------------
  --                                Methods                                  --
  -----------------------------------------------------------------------------
  function Start(self)
    self.Started = true 
  end

  function Stop(self)
    self.Started = false 
  end

  function Pause(self)
    self.Paused = true 
  end

  function Resume(self)
    self.Paused = false
  end

  function Reset(self)
    self.Duration = nil
    self.StartTime = nil
    self.Started = nil 
    self.Paused = nil 
    self.PausedElapsedTime = nil
    self.ElapsedTime = nil
  end

  function OnRelease(self)
    self:Reset()
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  property "StartTime" {
    type = Number,
    default = 0,
    handler = OnTimeSettingsChangedHandler,
  }

  property "Duration" {
    type = Number,
    default = 10,
    handler = OnTimeSettingsChangedHandler,
    event = "OnDurationChanged"
  }

  property "ShowRemainingTime" {
    type = Boolean,
    default = false, 
  }

  property "Started" {
    type = Boolean,
    handler = OnTimeSettingsChangedHandler,
    default = false
  }

  property "Paused" {
    type = Boolean,
    default = false
  }

  --- Contains the time elapsed while the timer is paused, will be used to compute
  --- the true elapsed time.
  property "PausedElapsedTime" {
    type = Number,
    default = 0
  }

  __Observable__()
  property "ElapsedTime" {
    type = Number,
    default = 0,
    event = "OnElapsedTimeChanged"
  }
  -----------------------------------------------------------------------------
  --                            Constructors                                 --
  -----------------------------------------------------------------------------
  __Template__ {
    Text = FontString
  }
  function __ctor(self) end 
end)
-------------------------------------------------------------------------------
--                              UI Settings                                  --
-------------------------------------------------------------------------------
RegisterUISetting("timer.showRemainingTime", false)
-------------------------------------------------------------------------------
--                              Observables                                  --
-------------------------------------------------------------------------------
function FromText()
  return GetFrameByType(Timer, FromUIProperty("ElapsedTime")):Map(function(timer)
        local clock = timer.ShowRemainingTime 
                      and SecondsToClock(max(0, timer.Duration - timer.ElapsedTime)) 
                      or SecondsToClock(timer.ElapsedTime)

        local yellowPercentStart = 0.66
        local redPercentStart = 0.33
        local remainingTimePercent = max(1 - (timer.ElapsedTime / timer.Duration), 0)

        if remainingTimePercent > yellowPercentStart then 
          return clock 
        elseif remainingTimePercent > redPercentStart then 
          local blueOffset = (remainingTimePercent - redPercentStart) / (redPercentStart / yellowPercentStart)
          return Color(1, 1, blueOffset) .. clock
        end

        local greenOffset = remainingTimePercent / redPercentStart
        return Color(1, greenOffset, 0) .. clock         
      end)
end
-------------------------------------------------------------------------------
--                                Styles                                     --
-------------------------------------------------------------------------------
Style.UpdateSkin("Default", {
  [Timer] = {
    height                            = 25,
    showRemainingTime                 = FromUISetting("timer.showRemainingTime"),
  
    Text = {
      text                            = FromText(),
      textColor                       = Color.WHITE,
      setAllPoints                    = true
    }
  }
})

