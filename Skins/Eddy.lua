-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                    "SylingTracker.Skins.Eddy"                         ""
-- ========================================================================= --
export {
  FromUIProperty = Wow.FromUIProperty,
  GetFrameByType = Wow.GetFrameByType
}

if not IsRetail() then 
  return 
end

API.RegisterCustomSkin("Eddy", {
  [KeystoneTimer] = {
    inherit = "default",

    Text = {
      mediaFont = FontType("PT Sans Narrow Bold", 25),
      justifyH = "LEFT",
      location = {
        Anchor("TOP", 0, -3),
        Anchor("LEFT", 10, 0),
        Anchor("RIGHT", -10, 0)
      }
    },

    TimerBar = {
      height = 15,
      location = {
        Anchor("TOP", 0, -8, "Text", "BOTTOM"),
        Anchor("LEFT", 10, 0),
        Anchor("RIGHT", -10, 0)
      }      
    },

    Label = {
      text = GetFrameByType(KeystoneTimer, FromUIProperty("ElapsedTime")):Map(function(timer)
        if timer.ElapsedTime > timer.Duration then 
          return "+" .. SecondsToClock(timer.ElapsedTime - timer.Duration)
        else
          return SecondsToClock(timer.Duration - timer.ElapsedTime)
        end
      end),
      textColor = GetFrameByType(KeystoneTimer, FromUIProperty("ElapsedTime")):Map(function(timer)
        if timer.ElapsedTime > timer.Duration then 
          return Color.RED 
        end 

        return Color.GREEN
      end),
      location = {
        Anchor("LEFT", 0, 0, "TwoChestLine", "RIGHT"),
        Anchor("RIGHT", -2, 0, "TimerBar", "RIGHT"),
        Anchor("TOP", 0, 0, "TimerBar", "TOP"),
        Anchor("BOTTOM", 0, 0, "TimerBar", "BOTTOM"),
      }
    },

    ThreeChestTimer = {
      location = {
        Anchor("RIGHT", -2, 0, "ThreeChestLine", "LEFT")
      }
    },
    TwoChestTimer = {
      location = {
        Anchor("RIGHT", -2, 0, "TwoChestLine", "LEFT")
      }
    }
  },

  [KeystoneEnemyForces] = {
    inherit = "default",
    Text = {
      visible = false
    },
    
    Progress = {
      location = {
        Anchor("TOP"),
        Anchor("LEFT"),
        Anchor("RIGHT")
      }
    }
  },

  [KeystoneContentView] = {
    inherit = "default",

    DeathCounter = {
      location = {
        Anchor("TOPRIGHT", -5, -58)
      }
    },

    Content = {
      EnemyForces = {
        location = {
          Anchor("TOP", 0, -8, "TimerInfo", "BOTTOM"),
          Anchor("LEFT", 10, 0),
          Anchor("RIGHT", -10, 0)
        }
      },
  
      Objectives = {
        location = {
          Anchor("TOP", 0, -5, "EnemyForces", "BOTTOM"),
          Anchor("LEFT"),
          Anchor("RIGHT")
        }
      }
    }
  },
})