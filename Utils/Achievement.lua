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
  GetContentTrackedID = C_ContentTracking.GetTrackedIDs
}


__Static__() function Utils.GetAchievementsTracked()
  return C_ContentTracking.GetTrackedIDs(_G.Enum.ContentTrackingType.Achievement)
end

__Static__() function Utils.HasAchievements()
  return #Utils.GetAchievementsTracked() > 0
end