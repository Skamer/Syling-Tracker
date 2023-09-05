-- ========================================================================= --
--                              EskaTracker 2                                --
--           https://www.curseforge.com/wow/addons/eskatracker-2             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/EskaTracker2                  --
--                                                                           --
-- ========================================================================= --
Syling                 "SylingTracker.Contents.ActivityView"                 ""
-- ========================================================================= --
export {
  FromUIProperty            = Wow.FromUIProperty,  
}

__UIElement__()
class "ActivityView" (function(_ENV)
  inherit "Frame" extend "IView"
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  function OnViewUpdate(self, data, ...)
    if data.objectives then 
      Style[self].Objectives.visible = true 
      local objectivesView = self:GetPropertyChild("Objectives")

      objectivesView:UpdateView(data.objectives, ...)
    end

    self.ActivityName = data.name
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  __Observable__()
  property "ActivityName" {
    type = String,
    default = ""
  }
  -----------------------------------------------------------------------------
  --                              Constructors                               --
  -----------------------------------------------------------------------------
  __Template__ {
    Name = FontString
  }
  function __ctor(self) end
end)

-- Optional Children for QuestView 
__ChildProperty__(ActivityView, "Objectives")
class(tostring(ActivityView) .. ".Objectives") { ObjectiveListView }


__UIElement__()
class "ActivityListView" { ListView }
-------------------------------------------------------------------------------
--                                Styles                                     --
-------------------------------------------------------------------------------
Style.UpdateSkin("Default", {
  [ActivityView] = {
    autoAdjustHeight = true, 

    backdrop = { 
      bgFile = [[Interface\AddOns\SylingTracker\Media\Textures\LinearGradient]],
    },
    backdropColor = { r = 35/255, g = 40/255, b = 46/255, a = 0.73},
    
    Name = {
      text = FromUIProperty("ActivityName"),
      justifyV = "MIDDLE",
      mediaFont = FontType("DejaVuSansCondensed Bold", 10),
      location = {
        Anchor("TOP"),
        Anchor("LEFT"),
        Anchor("RIGHT")
      }
    },

    [ActivityView.Objectives] = {
      spacing = 5,

      location = {
        Anchor("TOPLEFT", 0, -5, "Name", "BOTTOMLEFT"),
        Anchor("TOPRIGHT", 0, -5, "Name", "BOTTOMRIGHT")
      }
    }
  },

  [ActivityListView] = {
    viewClass = ActivityView,
    indexed = false
  }
})