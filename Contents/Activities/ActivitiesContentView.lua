-- ========================================================================= --
--                              EskaTracker 2                                --
--           https://www.curseforge.com/wow/addons/eskatracker-2             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/EskaTracker2                  --
--                                                                           --
-- ========================================================================= --
Syling             "SylingTracker.Contents.ActivitiesContentView"            ""
-- ========================================================================= -
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
--                                Styles                                     --
-------------------------------------------------------------------------------
Style.UpdateSkin("Default", {
  [ActivitiesContentView] = {
    [ActivitiesContentView.Activities] = {
      location = {
        Anchor("TOP", 0, -10, "Header", "BOTTOM"),
        Anchor("LEFT"),
        Anchor("RIGHT")
      }
    }
  }
})