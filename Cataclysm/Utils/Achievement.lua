-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                  "SylingTracker.Utils.Achievement"                    ""
-- ========================================================================= --
export {
  GetTrackedAchievements = GetTrackedAchievements
}

function HasAchievements()
  return GetTrackedAchievements() and true or false
end

-- Export as utils functions
Utils.HasAchievements                 = HasAchievements