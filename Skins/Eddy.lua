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

Style.RegisterSkin("Eddy", {
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

    Text = {
      location = {
        Anchor("TOP"),
        Anchor("LEFT"),
        Anchor("RIGHT")
      }
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

    TopDungeonInfo = {
      DungeonIcon = {
        location = {
          Anchor("LEFT", 1, 0),
          Anchor("RIGHT", -1, 0)
        }        
      },

      location = {
        Anchor("TOP"),
        Anchor("LEFT"),
        Anchor("RIGHT")
      },

      Level = {
        location = {
          Anchor("TOPLEFT", 5, -5),        
        }
      },

      Affixes = {
        location = {
          Anchor("TOPLEFT", 0, -5, "Level", "BOTTOMLEFT"),
        }        
      },

      DungeonName = {
        location = {
          Anchor("LEFT", 70, 0),
          Anchor("TOP"),
          Anchor("BOTTOM"),
          Anchor("RIGHT")
        }        
      }
    },

    Content = {
      TimerInfo = {
        location = {
          Anchor("TOP", 0, -5),
          Anchor("LEFT"),
          Anchor("RIGHT")
        }        
      },

      EnemyBar = {
        id = 2,
        marginTop = 8,
        location = {
          Anchor("TOP", 0, -8, "TimerInfo", "BOTTOM"),
          Anchor("LEFT", 10, 0),
          Anchor("RIGHT", -10, 0)
        }
      },
  
      Objectives = {
        id = 3,
        location = {
          Anchor("TOP", 0, -5, "EnemyBar", "BOTTOM"),
          Anchor("LEFT"),
          Anchor("RIGHT")
        }
      },

      location = {
        Anchor("TOP", 0, -5, "TopDungeonInfo", "BOTTOM"),
        Anchor("LEFT"),
        Anchor("RIGHT")
      }
    }
  },
})