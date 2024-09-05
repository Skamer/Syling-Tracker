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
  Tooltip                             = API.GetTooltip(),
}

__UIElement__()
class "ScenarioContentView" (function(_ENV)
  inherit "ContentView"
  -----------------------------------------------------------------------------
  --                               Handlers                                  --
  -----------------------------------------------------------------------------
  local function OnTopInfoEnter(self)
    local parent          = self:GetParent()
    local scenarioData    = parent.Data and parent.Data.scenario

    local scenarioName    = parent.ScenarioName
    local stageName       = parent.StageName
    local currentStage    = parent.CurrentStage
    local numStages       = parent.NumStages
    local description     = scenarioData and scenarioData.stepDescription

    Tooltip:SetOwner(self)
    if currentStage <= numStages then 
      GameTooltip_SetTitle(Tooltip, SCENARIO_STAGE_STATUS:format(currentStage, numStages))
      GameTooltip_AddNormalLine(Tooltip, stageName)
      GameTooltip_AddBlankLineToTooltip(Tooltip)
      GameTooltip_AddNormalLine(Tooltip, description)
      Tooltip:Show()
    end
  end

  local function OnTopInfoLeave(self)
    Tooltip:Hide()
  end
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


      local bonusObjectivesData = scenarioData.bonusObjectives
      if bonusObjectivesData then 
        Style[self].BonusObjectives.visible = true
        local bonusObjectives = self:GetPropertyChild("BonusObjectives")
        bonusObjectives:UpdateView(bonusObjectivesData, metadata)
      else
        Style[self].BonusObjectives = NIL
      end


    else 
      self.ScenarioName = nil
    end
  end

  function OnExpand(self)
    Style[self].TopScenarioInfo.visible = true 
    Style[self].Widgets.visible = true 
    Style[self].Objectives.visible = true

    if self:GetPropertyChild("BonusObjectives") then 
      Style[self].BonusObjectives.visible = true 
    end
  end

  function OnCollapse(self)
    Style[self].TopScenarioInfo.visible = false  
    Style[self].Widgets.visible = false 
    Style[self].Objectives.visible = false

    if self:GetPropertyChild("BonusObjectives") then 
      Style[self].BonusObjectives.visible = false
    end
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
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
  -----------------------------------------------------------------------------
  --                              Constructors                               --
  -----------------------------------------------------------------------------
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
  function __ctor(self) 
    local topInfo = self:GetChild("TopScenarioInfo")
    topInfo.OnEnter = topInfo.OnEnter + OnTopInfoEnter
    topInfo.OnLeave = topInfo.OnLeave + OnTopInfoLeave
  end 
end)

-- Optional Children for ScenarioContentView
__ChildProperty__(ScenarioContentView, "BonusObjectives")
class(tostring(ScenarioContentView) .. ".BonusObjectives") { ListViewWithHeaderText }
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
        drawLayer                     = "BACKGROUND",
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
    },

    [ScenarioContentView.BonusObjectives] = {
      autoAdjustHeight                = true,
      paddingTop                      = 5,
      paddingBottom                   = 5,
      viewClass                       = ObjectiveView,
      indexed                         = false,
      backdrop                        = { 
                                        bgFile = [[Interface\AddOns\SylingTracker\Media\Textures\LinearGradient]],
                                      },
      backdropColor                   = { r = 35/255, g = 40/255, b = 46/255, a = 0.73},

      HeaderText =  {
        mediaFont                     = FontType("PT Sans Narrow Bold", 14),
        text                          = "Bonus Objectives",
        textColor                     = Color.WHITE,
      },

      location                        = {
                                        Anchor("TOP", 0, -5, "Objectives", "BOTTOM"),
                                        Anchor("LEFT"),
                                        Anchor("RIGHT")        
                                      }
    }
  }
})

