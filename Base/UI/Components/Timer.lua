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
  RegisterUISetting = API.RegisterUISetting,
  FromUISetting     = API.FromUISetting,
  GetFrameByType    = Wow.GetFrameByType,
  FromUIProperty    = Wow.FromUIProperty
}

__UIElement__()
class "Timer" (function(_ENV)
  inherit "Frame"
  -----------------------------------------------------------------------------
  --                               Handlers                                  --
  -----------------------------------------------------------------------------
  local function OnUpdateHandler(self)
    self.ElapsedTime = GetTime() - self.StartTime
  end

  local function OnTimeSettingsHandler(self, new, old, prop)
    if (prop == "StartTime") and (new > 0 and self.Duration) then 
      self.OnUpdate = OnUpdateHandler
    elseif (prop == "Duration") and (new > 0 and self.StartTime) then 
      self.OnUpdate = OnUpdateHandler
    else 
      self.OnUpdate = nil 
    end
  end

  function OnRelease(self)
    super.OnRelease(self)

    self.Duration = nil
    self.StartTime = nil
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  property "StartTime" {
    type = Number,
    default = 0,
    handler = OnTimeSettingsHandler
  }

  property "Duration" {
    type = Number,
    default = 10,
    handler = OnTimeSettingsHandler
  }

  property "ShowRemainingTime" {
    type = Boolean,
    default = false, 
  }

  __Observable__()
  property "ElapsedTime" {
    type = Number,
    default = 0,
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
RegisterUISetting("timer.showRemainingTime", true)
-------------------------------------------------------------------------------
--                                Styles                                     --
-------------------------------------------------------------------------------
Style.UpdateSkin("Default", {
  [Timer] = {
    height = 25,
    showRemainingTime = FromUISetting("timer.showRemainingTime"),

    -- backdrop = { 
    --   bgFile              = [[Interface\Buttons\WHITE8X8]],
    --   edgeFile            = [[Interface\Buttons\WHITE8X8]],
    --   edgeSize            = 1
    -- },
    -- backdropColor         = { r = 1, g = 0, b = 0, a = 0},
    -- backdropBorderColor   = { r = 0.5, g = 0, b = 0, a = 1 },
  
    Text = {
      text = GetFrameByType(Timer, FromUIProperty("ElapsedTime")):Map(function(timer)
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
      end),
      textColor = Color.WHITE,
      setAllPoints = true
    }
  }
})