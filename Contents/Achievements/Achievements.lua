-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Scorpio                 "SylingTracker.Achievements"                         ""
-- ========================================================================= --
import                          "SLT"
-- ========================================================================= --
RegisterContentType = API.RegisterContentType
RegisterModel       = API.RegisterModel

HasAchievements = Utils.Achievement.HasAchievements

_AchievementModel = RegisterModel(AchievementModel, "achievements-data")


-- ========================================================================= --
-- Register the achievements content type
-- ========================================================================= --
RegisterContentType({
  ID = "achievements",
  DisplayName = "Achievements",
  Description = "Display the achievements tracked",
  DefaultOrder = 10,
  DefaultModel = _AchievementModel,
  DefaultViewClass = AchievementsContentView,
  Events = { "TRACKED_ACHIEVEMENT_LIST_CHANGED", "PLAYER_ENTERING_WORLD" },
  Status = function() return HasAchievements() end
})
-- ========================================================================= --
GetAchievementInfo                  = GetAchievementInfo
GetAchievementNumCriteria           = GetAchievementNumCriteria
IsAchievementEligible               = IsAchievementEligible
-- ========================================================================= --
_AchievementCache = {}

function OnEnable(self)
  self:LoadAchievements()
end

__SystemEvent__()
function TRACKED_ACHIEVEMENT_UPDATE(achievementID)
  _M:UpdateAchievement(achievementID)
  _AchievementModel:Flush()
end

__SystemEvent__()
function TRACKED_ACHIEVEMENT_LIST_CHANGED(achievementID, isAdded)
  if isAdded then 
    _M:UpdateAchievement(achievementID)
    _AchievementModel:Flush()
  else 
    _AchievementModel:RemoveAchievementData(achievementID)
    _AchievementModel:Flush()
  end 
end

function LoadAchievements(self)
  local trackedAchievements = { GetTrackedAchievements() }
  for i = 1, #trackedAchievements do
    local achievementID = trackedAchievements[i]
    _M:UpdateAchievement(achievementID)
  end
  _AchievementModel:Flush()
end

function UpdateAchievement(self, achievementID)
  local _, name, points, completed, month, day, year, description, flags, icon,
  rewardText, isGuild, wasEarnedByMe, earnedBy = GetAchievementInfo(achievementID)

  local numObjectives = GetAchievementNumCriteria(achievementID)
  local failed = IsAchievementEligible(achievementID)

  local achievementData = {
    achievementID = achievementID,
    title = name, 
    name  = name,
    numObjectives = numObjectives,
    points = points, 
    failed = failed,
    completed = completed,
    month = month, 
    day = day, 
    year = year, 
    description = description,
    flags = flags, 
    icon = icon, 
    rewardText = rewardText,
    isGuild = isGuild,
    wasEarnedByMe = wasEarnedByMe,
    earnedBy = earnedBy
  }

  if numObjectives > 0 then 
    local objectivesData = {}
    for index = 1, numObjectives do 
      local criteriaString, criteriaType, criteriaCompleted, quantity, 
      totalQuantity, name, flags, assetID, quantityString, criteriaID, 
      eligible, duration, elapsed = GetAchievementCriteriaInfo(achievementID, index)

      local data = {
        text = criteriaString,
        failed = not eligible,
        isCompleted = criteriaCompleted
      }

      objectivesData[index] = data
    end

    achievementData.objectives = objectivesData
  end

  _AchievementModel:AddAchievementData(achievementID, achievementData)
end

-- ========================================================================= --
-- Debug Utils Tools
-- ========================================================================= --
if ViragDevTool_AddData then 
  ViragDevTool_AddData(_AchievementModel, "AchievementModel")
end