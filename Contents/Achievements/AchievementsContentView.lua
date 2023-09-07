-- ========================================================================= --
--                              EskaTracker 2                                --
--           https://www.curseforge.com/wow/addons/eskatracker-2             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/EskaTracker2                  --
--                                                                           --
-- ========================================================================= --
Syling             "SylingTracker.Contents.AchievementContentView"           ""
-- ========================================================================= -
__UIElement__()
class "AchievementsContentView" (function(_ENV)
  inherit "ContentView"
  -----------------------------------------------------------------------------
  --                                Methods                                  --
  -----------------------------------------------------------------------------
  function OnViewUpdate(self, data, metadata)
    super.OnViewUpdate(self, data, metadata)

    if data and data.achievements then
      Style[self].Achievements.visible = self.Expanded
      local achievementsListView = self:GetPropertyChild("Achievements")
      achievementsListView:UpdateView(data.achievements, metadata)
    else
      Style[self].Achievements = NIL 
    end
  end

  function OnExpand(self)
    if self:GetPropertyChild("Achievements") then 
      Style[self].Achievements.visible = true 
    end
  end

  function OnCollapse(self)
    if self:GetPropertyChild("Achievements") then 
      Style[self].Achievements.visible = false 
    end
  end
end)

__ChildProperty__(AchievementsContentView, "Achievements")
__UIElement__() class(tostring(AchievementsContentView) .. ".Achievements") { AchievementListView }
-------------------------------------------------------------------------------
--                                Styles                                     --
-------------------------------------------------------------------------------
Style.UpdateSkin("Default", {
  [AchievementsContentView] = {
    [AchievementsContentView.Achievements] = {
      location = {
        Anchor("TOP", 0, -10, "Header", "BOTTOM"),
        Anchor("LEFT"),
        Anchor("RIGHT")
      }
    }
  }
})