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


function GetAchievementsTracked()
  return C_ContentTracking.GetTrackedIDs(_G.Enum.ContentTrackingType.Achievement)
end

function HasAchievements()
  return #GetAchievementsTracked() > 0
end

__Arguments__ { Number }
function OpenAchievement(achievementID)

    -- Narcissus addon support
    if NarciAchievementOptions and NarciAchievementOptions.UseAsDefault then
      if Narci_AchievementFrame then
          Narci_AchievementFrame:LocateAchievement(achievementID, true);
      else
          Narci.LoadAchievementPanel(achievementID, true);
      end
    else 
      if not AchievementFrame then
        AchievementFrame_LoadUI()
      end

      if not AchievementFrame:IsShown() then
        AchievementFrame_ToggleAchievementFrame()
        AchievementFrame_SelectAchievement(achievementID)
      else
        if AchievementFrameAchievements.selection ~= achievementID then
          AchievementFrame_SelectAchievement(achievementID)
        else
          AchievementFrame_ToggleAchievementFrame()
        end
      end
    end
end

-- Export as utils functions
Utils.GetAchievementsTracked                 = GetAchievementsTracked
Utils.HasAchievements                        = HasAchievements
Utils.OpenAchievement                        = OpenAchievement

