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
  FromUIProperty                      = Wow.FromUIProperty,
  FromBackdrop                        = Frame.FromBackdrop,
  FromUISetting                       = API.FromUISetting,
  RegisterUISetting                   = API.RegisterUISetting,
  GenerateUISettings                  = API.GenerateUISettings,
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
--                              UI Settings                                  --
-------------------------------------------------------------------------------
GenerateUISettings("scenario", "content", function(generatedSettings)
  -- We ovveride the default value as we want by default the header wasn't show for 
  -- scenario
  if generatedSettings["scenario.showHeader"] then 
    generatedSettings["scenario.showHeader"].default = false
  end
end)

RegisterUISetting("scenario.name.mediaFont", FontType("DejaVuSansCondensed Bold", 14))
RegisterUISetting("scenario.name.textTransform", "NONE")
RegisterUISetting("scenario.name.textColor", Color(1, 0.914, 0.682))
RegisterUISetting("scenario.topInfo.showBackground", false)
RegisterUISetting("scenario.topInfo.showBorder", true)
RegisterUISetting("scenario.topInfo.backgroundColor", Color(35/255, 40/255, 46/255, 0.73))
RegisterUISetting("scenario.topInfo.borderColor", Color(0, 0, 0, 0.4))
RegisterUISetting("scenario.topInfo.borderSize", 1)
RegisterUISetting("scenario.stageName.mediaFont", FontType("PT Sans Narrow Bold", 14))
RegisterUISetting("scenario.stageName.textTransform", "NONE")
RegisterUISetting("scenario.stageCounter.mediaFont", FontType("PT Sans Narrow Bold", 14))
RegisterUISetting("scenario.stageCounter.textTransform", "NONE")
-------------------------------------------------------------------------------
--                              Observables                                  --
-------------------------------------------------------------------------------
function FromTopInfoLocation()
  return FromUISetting("scenario.showHeader"):Map(function(visible)
    if visible then 
      return {
        Anchor("TOP", 0, -10, "Header", "BOTTOM"),
        Anchor("LEFT"),
        Anchor("RIGHT")        
      }
    end

    return {
        Anchor("TOP"),
        Anchor("LEFT"),
        Anchor("RIGHT")
    }
  end)
end
-------------------------------------------------------------------------------
--                                Styles                                     --
-------------------------------------------------------------------------------
Style.UpdateSkin("Default", {
  [ScenarioContentView] = {
    Header = {
      visible                         = FromUISetting("scenario.showHeader"),
      showBackground                  = FromUISetting("scenario.header.showBackground"),
      showBorder                      = FromUISetting("scenario.header.showBorder"),
      backdropColor                   = FromUISetting("scenario.header.backgroundColor"),
      backdropBorderColor             = FromUISetting("scenario.header.borderColor"),
      borderSize                      = FromUISetting("scenario.header.borderSize"),

      Label = {
        mediaFont                     = FromUISetting("scenario.header.label.mediaFont"),
        textColor                     = FromUISetting("scenario.header.label.textColor"),
        justifyH                      = FromUISetting("scenario.header.label.justifyH"),
        justifyV                      = FromUISetting("scenario.header.label.justifyV"),
        textTransform                 = FromUISetting("scenario.header.label.textTransform"),
      }
    },

    TopScenarioInfo = {
      backdrop                        = FromBackdrop(),
      showBackground                  = FromUISetting("scenario.topInfo.showBackground"),
      showBorder                      = FromUISetting("scenario.topInfo.showBorder"),
      backdropColor                   = FromUISetting("scenario.topInfo.backgroundColor"),
      backdropBorderColor             = FromUISetting("scenario.topInfo.borderColor"),
      borderSize                      = FromUISetting("scenario.topInfo.borderSize"),
      height                          = 54,
      location                        = FromTopInfoLocation(),

      ScenarioIcon = {
        atlas                         = AtlasType("groupfinder-background-scenarios"), -- 615222
        texCoords                     = { left = 0.1,  right = 0.9, top = 0.1, bottom = 0.9 } ,
        setAllPoints                  = true,
      },

      ScenarioName = {
        text                          = FromUIProperty("ScenarioName"),
        mediaFont                     = FromUISetting("scenario.name.mediaFont"),
        textTransform                 = FromUISetting("scenario.name.textTransform"),
        textColor                     = FromUISetting("scenario.name.textColor"),
        location                      = {
                                        Anchor("LEFT", 5, 0),
                                        Anchor("TOP"),
                                        Anchor("BOTTOM", 0, 0, nil, "CENTER"),
                                        Anchor("RIGHT")
                                      }
      },

      StageCounter = {
        visible                       = FromUIProperty("WidgetSetID"):Map(function(id) return not id end),
        text                          = FromUIProperty("CurrentStage", "NumStages"):Map(function(currentStage, numStages) return currentStage .. "/" .. numStages end),
        justifyH                      = "LEFT",
        mediaFont                     = FromUISetting("scenario.stageCounter.mediaFont"),
        location                      = {
                                        Anchor("TOP", 0, 0, nil, "CENTER"),
                                        Anchor("LEFT"),
                                        Anchor("RIGHT"),
                                        Anchor("BOTTOM", 0, 5)
                                      }
      },

      StageName = {
        text                          = FromUIProperty("StageName"),
        justifyH                      = "CENTER",
        mediaFont                     = FromUISetting("scenario.stageName.mediaFont"),
        textTransform                 = FromUISetting("scenario.stageName.textTransform"),
        location                      = {
                                        Anchor("TOP", 0, 0, nil, "CENTER"),
                                        Anchor("LEFT"),
                                        Anchor("RIGHT"),
                                        Anchor("BOTTOM", 0, 5)
                                      }
      }
    },

    Objectives = {
      autoAdjustHeight                = true,
      paddingTop                      = 5,
      paddingBottom                   = 5,
      backdrop                        = { 
                                        bgFile = [[Interface\AddOns\SylingTracker\Media\Textures\LinearGradient]],
                                      },
      backdropColor                   = { r = 35/255, g = 40/255, b = 46/255, a = 0.73},

      location                        = {
                                        Anchor("TOP", 0, -5, "TopScenarioInfo", "BOTTOM"),
                                        Anchor("LEFT"),
                                        Anchor("RIGHT")
                                      }      
    },

    Widgets = {
      visible                         = FromUIProperty("WidgetSetID"):Map(function(id) return id and id > 0 or false end),
      widgetSetID                     = FromUIProperty("WidgetSetID"),
      location                        = {
                                        Anchor("TOP", 0, 0, "Objectives", "BOTTOM"),
                                        Anchor("LEFT"),
                                        Anchor("RIGHT")        
                                      }
    }
  }
})

