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

  __Template__ {
    TopScenarioInfo = Frame,
    Objectives = ObjectiveListView,
    {
      TopScenarioInfo = {
        ScenarioName = FontString,
        ScenarioIcon = Texture,
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
    TopScenarioInfo = {
      backdrop = {
        bgFile = [[Interface\Buttons\WHITE8X8]],
        edgeFile  = [[Interface\Buttons\WHITE8X8]],
        edgeSize  = 1
      },
      backdropColor       = { r = 0, g = 0, b = 0, a = 0.65}, -- 87
      backdropBorderColor = { r = 35/255, g = 40/255, b = 46/255, a = 0.73},
      height = 48,
      
      location = {
        Anchor("TOP", 0, 0, "Header", "BOTTOM"),
        Anchor("LEFT"),
        Anchor("RIGHT")
      },

      ScenarioIcon = {
        atlas = AtlasType("groupfinder-background-scenarios"),
        texCoords = { left = 0.1,  right = 0.9, top = 0.1, bottom = 0.9 } ,
        vertexColor = { r = 1, g = 1, b = 1, a = 0.5 },
        height = 44,
        location = {
          Anchor("LEFT", 1, 0),
          Anchor("RIGHT", -1, 0)
        }
      },

      ScenarioName = {
        text = FromUIProperty("ScenarioName"),
        fontObject = Game18Font,
        textColor = { r = 1, g = 0.914, b = 0.682},
        location = {
          Anchor("LEFT", 5, 0),
          Anchor("TOP"),
          Anchor("BOTTOM"),
          Anchor("RIGHT")
        }
      }
    },

    Objectives = {
      autoAdjustHeight = true, 
      backdrop = { 
        bgFile = [[Interface\AddOns\SylingTracker\Media\Textures\LinearGradient]],
      },
      backdropColor = { r = 35/255, g = 40/255, b = 46/255, a = 0.73},

      location = {
        Anchor("TOP", 0, 0, "TopScenarioInfo", "BOTTOM"),
        Anchor("LEFT"),
        Anchor("RIGHT")
      }      
    }
  }
})

