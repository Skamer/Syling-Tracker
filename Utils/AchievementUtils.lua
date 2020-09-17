-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Scorpio                "SylingTracker.AchievementUtils"                      ""
-- ========================================================================= --
namespace                          "SLT"
-- ========================================================================= --
GetTrackedAchievements = GetTrackedAchievements

class "Utils" (function(_ENV)

  class "Achievement" (function(_ENV)
  
    __Static__() function HasAchievements()
      local achievements = GetTrackedAchievements()
      if achievements ~= nil then 
        return true 
      else 
        return false
      end
    end
  end)
end)