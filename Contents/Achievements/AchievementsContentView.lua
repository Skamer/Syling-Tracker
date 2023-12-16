-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling             "SylingTracker.Contents.AchievementContentView"           ""
-- ========================================================================= -
export {
  FromUISetting                       = API.FromUISetting,
  GenerateUISettings                  = API.GenerateUISettings,
}

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
--                              UI Settings                                  --
-------------------------------------------------------------------------------
GenerateUISettings("achievements", "content")
-------------------------------------------------------------------------------
--                              Observables                                  --
-------------------------------------------------------------------------------
function FromAchievementsLocation()
  return FromUISetting("achievements.showHeader"):Map(function(visible)
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
  [AchievementsContentView] = {
    Header = {
      visible                         = FromUISetting("achievements.showHeader"),
      showBackground                  = FromUISetting("achievements.header.showBackground"),
      showBorder                      = FromUISetting("achievements.header.showBorder"),
      backdropColor                   = FromUISetting("achievements.header.backgroundColor"),
      backdropBorderColor             = FromUISetting("achievements.header.borderColor"),
      borderSize                      = FromUISetting("achievements.header.borderSize"),

      Label = {
        mediaFont                     = FromUISetting("achievements.header.label.mediaFont"),
        textColor                     = FromUISetting("achievements.header.label.textColor"),
        justifyH                      = FromUISetting("achievements.header.label.justifyH"),
        justifyV                      = FromUISetting("achievements.header.label.justifyV"),
        textTransform                 = FromUISetting("achievements.header.label.textTransform"),
      }
    },

    [AchievementsContentView.Achievements] = {
      location                        = FromAchievementsLocation()
    }
  }
})