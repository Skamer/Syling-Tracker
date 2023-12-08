-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                      "SylingTracker.Activities"                       ""
-- ========================================================================= --
_Active                             = false
-- ========================================================================= --
export {
  -- Adoon API 
  RegisterObservableContent           = API.RegisterObservableContent,

  -- Wow API & Utils
  GetTrackedPerksActivities           = C_PerksActivities.GetTrackedPerksActivities,
  GetPerksActivityInfo                = C_PerksActivities.GetPerksActivityInfo
}

ACTIVITIES_CONTENT_SUBJECT = RegisterObservableContent("activities", ActivitiesContentSubject)

-- Used for checking quicky if an activity is tracked
ACTIVITIES_CACHE = {}

__ActiveOnEvents__ "PLAYER_ENTERING_WORLD" "PERKS_ACTIVITIES_TRACKED_UPDATED" "PERKS_ACTIVITY_COMPLETED"
function BecomeActiveOn(self, event, ...)
  return #GetTrackedPerksActivities().trackedIDs > 0
end

function OnActive(self)
  self:LoadAndUpdateActivities()
end

function LoadAndUpdateActivities(self)
  wipe(ACTIVITIES_CACHE)

  local trackedActivities = GetTrackedPerksActivities().trackedIDs
  
  for _, activityID in ipairs(trackedActivities) do
    self:UpdateActivity(activityID)

    ACTIVITIES_CACHE[activityID] = true
  end

  -- We remove the activities are not tracked.
  for activityID in ACTIVITIES_CONTENT_SUBJECT:IterateActivities() do 
    if not ACTIVITIES_CACHE[activityID] then 
      ACTIVITIES_CONTENT_SUBJECT.activities[activityID] = nil
    end
  end
end

function UpdateActivity(self, activityID)
  local activityInfo = GetPerksActivityInfo(activityID)
  if not activityInfo then 
    return 
  end

  local activityData = ACTIVITIES_CONTENT_SUBJECT:AcquireActivity(activityID)
  activityData.activityID = activityID
  activityData.name = activityInfo.activityName
  activityData.isCompleted = activityInfo.completed
  activityData.description = activityInfo.description

  local requirements = activityInfo.requirementsList
  
  activityData:StartObjectivesCounter()
  for index, requirement in ipairs(requirements) do
    local text = requirement.requirementText
    local isCompleted = requirement.completed

    local objectiveData = activityData:AcquireObjective()
    objectiveData.text = text 
    objectiveData.isCompleted = isCompleted
  end
  activityData:StopObjectivesCounter()
end

__SystemEvent__()
function PERKS_ACTIVITIES_TRACKED_UPDATED()
  _M:LoadAndUpdateActivities()
end
-- ========================================================================= --
-- Debug Utils Tools
-- ========================================================================= --
DebugTools.TrackData(ACTIVITIES_CONTENT_SUBJECT, "Activities Content Subject")
