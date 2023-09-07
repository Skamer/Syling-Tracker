-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                  "SylingTracker.Achievements"                         ""
-- ========================================================================= --
import                              "SLT"
-- ========================================================================= --
_Active                             = false 
-- ========================================================================= --
RegisterContentType = API.RegisterContentType
RegisterModel       = API.RegisterModel
-- ========================================================================= --
_AchievementModel = RegisterModel(AchievementModel, "achievements-data")
-- ========================================================================= --
CreateTextureMarkup                 = CreateTextureMarkup
AchievementContentTrackingType      = _G.Enum.ContentTrackingType.Achievement
HasAchievements                     = Utils.Achievement.HasAchievements
GetAchievementInfo                  = GetAchievementInfo
GetAchievementNumCriteria           = GetAchievementNumCriteria
IsAchievementEligible               = IsAchievementEligible
-- ========================================================================= --
-- Register the achievements content type
-- ========================================================================= --
_AchievementsIconTextureMarkup = CreateTextureMarkup([[Interface\ACHIEVEMENTFRAME\UI-ACHIEVEMENT-SHIELDS]], 128, 128, 16, 16, 0, 64/128, 0, 64/128)
RegisterContentType({
  ID = "achievements",
  Name = "Achievements",
  DisplayName = _AchievementsIconTextureMarkup.." Achievements",
  Description = "Display the achievements tracked",
  DefaultOrder = 80,
  DefaultModel = _AchievementModel,
  DefaultViewClass = AchievementsContentView,
  Events = { "CONTENT_TRACKING_UPDATE", "PLAYER_ENTERING_WORLD" },
  Status = function() return HasAchievements() end
})
-- ========================================================================= --
_AchievementsCache = {}
_ReadyForFetching  = false
-- ========================================================================= --
__ActiveOnEvents__ "PLAYER_ENTERING_WORLD" "TRACKED_ACHIEVEMENT_LIST_CHANGED" "CONTENT_TRACKING_UPDATE"
function ActivateOn(self, event)
  if event == "PLAYER_ENTERING_WORLD" then 
    _ReadyForFetching = true 
  end

  return HasAchievements()
end
-- ========================================================================= --
function OnActive(self)
  -- NOTE: This seems the first time the player enters in the game, the achievements
  -- details may be incorrect and missing. The workaround is to wait the 
  -- PLAYER_ENTERING_WORLD event which will set _ReadyForFetching to true for 
  -- saying it's ready for fetching the information.
  if _ReadyForFetching then 
    self:LoadAchievements()
  end
end

function OnInactive(self)
  _AchievementModel:ClearData()

  -- Clear the cache 
  wipe(_AchievementsCache)
end
-- ========================================================================= --
__SystemEvent__()
function CONTENT_TRACKING_LIST_UPDATE()
  _M:UpdateAllAchievements()
end

__SystemEvent__()
function PLAYER_ENTERING_WORLD()
  _ReadyForFetching = true
  
  -- The information are now ready to be fetched, so we can load achievements
  _M:LoadAchievements()
end

__SystemEvent__()
function CONTENT_TRACKING_UPDATE(contentType, achievementID, isAdded)
  if not contentType == AchievementContentTrackingType then 
    return 
  end

  if not _ReadyForFetching then 
    return 
  end

  -- NOTE: When an achievement has failed, TRACKED_ACHIEVEMENT_LIST_CHANGED is triggered with
  -- achievementID and isAdded having a nil value
  if achievementID then
    if isAdded then 
      _AchievementsCache[achievementID] = true
      _M:UpdateAchievement(achievementID)
    else
      _AchievementModel:RemoveAchievementData(achievementID)
      _AchievementsCache[achievementID] = nil 
    end

    _AchievementModel:Flush() 
  else
    -- NOTE: When an anchievement has failed, achievementID and isAdded have a nil value.
    -- We must update all for the achievement eligibility is correctly updated.
    -- Infortunnaly we don't know which achievement has an eligibility change.
    _M:UpdateAllAchievements()
  end
end


function LoadAchievements(self)
  local trackedAchievements = C_ContentTracking.GetTrackedIDs(_G.Enum.ContentTrackingType.Achievement)
  for i = 1, #trackedAchievements do 
    local achievementID = trackedAchievements[i]
    CONTENT_TRACKING_UPDATE(AchievementContentTrackingType, achievementID, true)
  end
end

function UpdateAllAchievements(self)
  for achievementID in pairs(_AchievementsCache) do 
    self:UpdateAchievement(achievementID)
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

      if bit.band(flags, EVALUATION_TREE_FLAG_PROGRESS_BAR) == EVALUATION_TREE_FLAG_PROGRESS_BAR then 
        data.text = description
        data.hasProgressBar = true
        data.progress = quantity
        data.minProgress = 0
        data.maxProgress = totalQuantity 
        data.progressText = format("%i / %i", quantity, totalQuantity)
      end 

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
  ViragDevTool_AddData(_AchievementModel, "SLT Achievement Model")
end