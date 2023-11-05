-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                      "SylingTracker.Achievements"                     ""
-- ========================================================================= --
_Active                             = false
-- ========================================================================= --
export {
  -- Addon API
  RegisterObservableContent           = API.RegisterObservableContent, 

  -- Wow API & Utils
  AchievementContentTrackingType      = _G.Enum.ContentTrackingType.Achievement,
  GetAchievementInfo                  = GetAchievementInfo,
  GetAchievementNumCriteria           = GetAchievementNumCriteria,
  GetAchievementCategory              = GetAchievementCategory,
  GetAchievementCriteriaInfo          = GetAchievementCriteriaInfo,
  GetAchievementsTracked              = Utils.GetAchievementsTracked,
  HasAchievements                     = Utils.HasAchievements,
  IsAchievementEligible               = IsAchievementEligible,
}

ACHIEVEMENTS_CONTENT_SUBJECT = RegisterObservableContent("achievements", AchievementsContentSubject)

__ActiveOnEvents__ "PLAYER_ENTERING_WORLD" "TRACKED_ACHIEVEMENT_LIST_CHANGED" "CONTENT_TRACKING_UPDATE"
function BecomeActiveOn(self, event)
  return HasAchievements()
end

function OnActive(self)
  if self:IsActivateByEvent("PLAYER_ENTERING_WORLD") then 
    CONTENT_TRACKING_LIST_UPDATE()
  end
end

function UpdateAchievement(self, achievementID)
  local _, name, points, completed, month, day, year, description, flags, icon,
  rewardText, isGuild, wasEarnedByMe, earnedBy = GetAchievementInfo(achievementID)

  local numObjectives = GetAchievementNumCriteria(achievementID)
  local failed = IsAchievementEligible(achievementID)

  local achievementData = ACHIEVEMENTS_CONTENT_SUBJECT:AcquireAchievement(achievementID)
  achievementData.achievementID = achievementID
  achievementData.title = name 
  achievementData.name = name
  achievementData.numObjectives = numObjectives
  achievementData.points = points 
  achievementData.isFailed = failed
  achievementData.isCompleted = completed
  achievementData.month = month
  achievementData.day = day
  achievementData.year = year 
  achievementData.description = description
  achievementData.flags = flags 
  achievementData.icon = icon 
  achievementData.rewardText = rewardText
  achievementData.isGuild = isGuild
  achievementData.wasEarnedByMe = wasEarnedByMe
  achievementData.earnedBy = earnedBy

  achievementData:StartObjectivesCounter()
  if numObjectives > 0 then
    for index = 1, numObjectives do 
      local criteriaString, criteriaType, criteriaCompleted, quantity, 
      totalQuantity, name, flags, assetID, quantityString, criteriaID, 
      eligible, duration, elapsed = GetAchievementCriteriaInfo(achievementID, index)
      
      local objectiveData = achievementData:AcquireObjective()
      objectiveData.isFailed = not eligible
      objectiveData.isCompleted = criteriaCompleted

      if bit.band(flags, EVALUATION_TREE_FLAG_PROGRESS_BAR) == EVALUATION_TREE_FLAG_PROGRESS_BAR then
        objectiveData.text = description
        objectiveData.hasProgress = true 
        objectiveData.progress = quantity
        objectiveData.minProgress = 0
        objectiveData.maxProgress = totalQuantity
        objectiveData.progressText = format("%i / %i", quantity, totalQuantity)
      else 
        objectiveData.text = criteriaString
        objectiveData.hasProgress = nil 
        objectiveData.progress = nil 
        objectiveData.minProgress = nil
        objectiveData.maxProgress = nil
        objectiveData.progressText = nil
      end
    end
  end
  achievementData:StopObjectivesCounter()
end

__SystemEvent__()
function CONTENT_TRACKING_UPDATE(contentType, id, isTracked)
  if not (contentType == AchievementContentTrackingType) then 
    return 
  end

  if isTracked then 
    _M:UpdateAchievement(id)
  else
    ACHIEVEMENTS_CONTENT_SUBJECT.achievements[id] = nil
  end
end

__SystemEvent__()
function CONTENT_TRACKING_LIST_UPDATE()
  local trackedAchievements = GetAchievementsTracked()
  for _, achievementID in ipairs(trackedAchievements) do 
    _M:UpdateAchievement(achievementID)
  end
end
-- ========================================================================= --
-- Debug Utils Tools
-- ========================================================================= --
DebugTools.TrackData(ACHIEVEMENTS_CONTENT_SUBJECT, "Achievements Content Subject")