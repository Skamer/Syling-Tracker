-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                "SylingTracker.Contents.ScenarioContentView"           ""
-- ========================================================================= --
export {
  FromUIProperty = Wow.FromUIProperty
}

__UIElement__()
class "ScenarioContentView" (function(_ENV)
  inherit "ContentView"
  -----------------------------------------------------------------------------
  --                                Methods                                  --
  -----------------------------------------------------------------------------
  function OnViewUpdate(self, data, metadata)
    super.OnViewUpdate(self, data, metadata)

    local scenarioData = data and data.scenario

    if scenarioData then 
      self.ScenarioName = scenarioData.name
      self.StageName = scenarioData.stepName
      self.CurrentStage = scenarioData.currentStage
      self.NumStages = scenarioData.numStages
      self.WidgetSetID = scenarioData.widgetSetID

      local objectives = self:GetChild("Objectives")
      objectives:UpdateView(scenarioData.objectives, metadata)


    else 
      self.ScenarioName = nil
    end
  end

  __Observable__()
  property "ScenarioName" {
    type = String
  }

  __Observable__()
  property "StageName" {
    type = String
  }

  __Observable__()
  property "NumStages" {
    type = Number,
    default = 0
  }

  __Observable__()
  property "CurrentStage" {
    type = Number,
    default = 0
  }

  __Observable__()
  property "WidgetSetID" {
    type = Number
  }


  __Template__ {
    TopScenarioInfo = Frame,
    Widgets = UIWidgets,
    Objectives = ObjectiveListView,
    {
      TopScenarioInfo = {
        ScenarioName = FontString,
        ScenarioIcon = Texture,
        StageName = FontString,
        StageCounter = FontString,
      }
    }
  }
  function __ctor() end 
end)
-------------------------------------------------------------------------------
--                                Styles                                     --
-------------------------------------------------------------------------------
Style.UpdateSkin("Default", {
  [ScenarioContentView] = {
    Header = {
      visible = false
    },

    TopScenarioInfo = {
      backdrop                        = { edgeFile  = [[Interface\Buttons\WHITE8X8]], edgeSize  = 1 },
      backdropBorderColor             = Color(35/255, 40/255, 46/255, 0.73),
      height = 54,
      
      location                        = { Anchor("TOP"), Anchor("LEFT"), Anchor("RIGHT") },

      ScenarioIcon = {
        atlas = AtlasType("groupfinder-background-scenarios"), -- 615222
        -- fileID = 615222,
        texCoords = { left = 0.1,  right = 0.9, top = 0.1, bottom = 0.9 } ,
        setAllPoints = true,
        -- vertexColor = { r = 1, g = 1, b = 1, a = 0.5 },
        -- height = 48,
        -- location = {
        --   Anchor("LEFT", 1, 0),
        --   Anchor("RIGHT", -1, 0)
        -- }
      },

      ScenarioName = {
        text = FromUIProperty("ScenarioName"),
        fontObject = Game18Font,
        textColor = { r = 1, g = 0.914, b = 0.682},
        location = {
          Anchor("LEFT", 5, 0),
          Anchor("TOP"),
          Anchor("BOTTOM", 0, 0, nil, "CENTER"),
          Anchor("RIGHT")
        }
      },

      StageCounter = {
        -- text = "1/4",
        visible = FromUIProperty("WidgetSetID"):Map(function(id) return not id end),
        text = FromUIProperty("CurrentStage", "NumStages"):Map(function(currentStage, numStages) return currentStage .. "/" .. numStages end),
        justifyH = "RIGHT",
        location = {
          Anchor("TOP"),
          Anchor("LEFT", 1, 0),
          Anchor("RIGHT", -1, 0),
        }
      },

      StageName = {
        text = FromUIProperty("StageName"),
        justifyH = "CENTER",
        fontObject = GameFontNormal,
        location = {
          Anchor("TOP", 0, 0, nil, "CENTER"),
          Anchor("LEFT"),
          Anchor("RIGHT"),
          Anchor("BOTTOM", 0, 5)
        }
      }
    },

    Objectives = {
      autoAdjustHeight = true,
      paddingTop = 5,
      paddingBottom = 5,
      backdrop = { 
        bgFile = [[Interface\AddOns\SylingTracker\Media\Textures\LinearGradient]],
      },
      backdropColor = { r = 35/255, g = 40/255, b = 46/255, a = 0.73},

      location = {
        Anchor("TOP", 0, -5, "TopScenarioInfo", "BOTTOM"),
        Anchor("LEFT"),
        Anchor("RIGHT")
      }      
    },

    Widgets = {
      visible = FromUIProperty("WidgetSetID"):Map(function(id) return id and id > 0 or false end),
      widgetSetID = FromUIProperty("WidgetSetID"),
      location = {
        Anchor("TOP", 0, 0, "Objectives", "BOTTOM"),
        Anchor("LEFT"),
        Anchor("RIGHT")        
      }
    }
  }
})

