-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling             "SylingTracker.Contents.ActivitiesContentView"            ""
-- ========================================================================= -
export {
  FromUISetting                       = API.FromUISetting,
  GenerateUISettings                  = API.GenerateUISettings,
}

__UIElement__()
class "ActivitiesContentView" (function(_ENV)
  inherit "ContentView"
  -----------------------------------------------------------------------------
  --                                Methods                                  --
  -----------------------------------------------------------------------------
  function OnViewUpdate(self, data, metadata)
    super.OnViewUpdate(self, data, metadata)

    if data and data.activities then
      Style[self].Activities.visible = self.Expanded
      local activitiesListView = self:GetPropertyChild("Activities")
      activitiesListView:UpdateView(data.activities, metadata)
    else
      Style[self].Activities = NIL 
    end
  end

  function OnExpand(self)
    if self:GetPropertyChild("Activities") then 
      Style[self].Activities.visible = true 
    end
  end

  function OnCollapse(self)
    if self:GetPropertyChild("Activities") then 
      Style[self].Activities.visible = false 
    end
  end
end)

__ChildProperty__(ActivitiesContentView, "Activities")
__UIElement__() class(tostring(ActivitiesContentView) .. ".Activities") { ActivityListView }
-------------------------------------------------------------------------------
--                              UI Settings                                  --
-------------------------------------------------------------------------------
GenerateUISettings("activities", "content")
-------------------------------------------------------------------------------
--                              Observables                                  --
-------------------------------------------------------------------------------
function FromRecipesLocation()
  return FromUISetting("activities.showHeader"):Map(function(visible)
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
  [ActivitiesContentView] = {
    Header = {
      visible                         = FromUISetting("activities.showHeader"),
      showBackground                  = FromUISetting("activities.header.showBackground"),
      showBorder                      = FromUISetting("activities.header.showBorder"),
      backdropColor                   = FromUISetting("activities.header.backgroundColor"),
      backdropBorderColor             = FromUISetting("activities.header.borderColor"),
      borderSize                      = FromUISetting("activities.header.borderSize"),

      Label = {
        mediaFont                     = FromUISetting("activities.header.label.mediaFont"),
        textColor                     = FromUISetting("activities.header.label.textColor"),
        justifyH                      = FromUISetting("activities.header.label.justifyH"),
        justifyV                      = FromUISetting("activities.header.label.justifyV"),
        textTransform                 = FromUISetting("activities.header.label.textTransform"),
      }
    },

    [ActivitiesContentView.Activities] = {
      location                        = FromRecipesLocation()
    }
  }
})