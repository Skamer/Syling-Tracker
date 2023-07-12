-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                 "SylingTracker.AchievementUtils"                      ""
-- ========================================================================= --
namespace                          "SLT"
-- ========================================================================= --
GetTrackedAchievements = function()
  return C_ContentTracking.GetTrackedIDs(_G.Enum.ContentTrackingType.Achievement)
end

class "Utils" (function(_ENV)

  class "Achievement" (function(_ENV)
  
    __Static__() function HasAchievements()
      local achievements = GetTrackedAchievements()
      if #achievements > 0 then 
        return true 
      else 
        return false
      end
    end
  end)
end)
