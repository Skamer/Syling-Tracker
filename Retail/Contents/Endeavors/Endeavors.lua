-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                      "SylingTracker.Endeavors"                        ""
-- ========================================================================= --
_Active                             = false
-- ========================================================================= --
export {
  -- Adoon API 
  RegisterObservableContent           = API.RegisterObservableContent,

  -- Wow API & Utils
  GetTrackedInitiativeTasks           = C_NeighborhoodInitiative.GetTrackedInitiativeTasks,
  GetInitiativeTaskInfo               = C_NeighborhoodInitiative.GetInitiativeTaskInfo,
}

ENDEAVORS_CONTENT_SUBJECT = RegisterObservableContent("endeavors", EndeavorsContentSubject)

-- Used for checking quicky if an endeavor is tracked
ENDEAVORS_CACHE = {}

__ActiveOnEvents__ "PLAYER_ENTERING_WORLD" "INITIATIVE_TASKS_TRACKED_LIST_CHANGED" "INITIATIVE_TASK_COMPLETED" "INITIATIVE_TASKS_TRACKED_UPDATED"
function BecomeActiveOn(self, event, ...)
  return #GetTrackedInitiativeTasks().trackedIDs > 0
end

function OnActive(self)
  self:LoadAndUpdateEndeavors()
end

function LoadAndUpdateEndeavors(self)
  wipe(ENDEAVORS_CACHE)

  local trackedEndeavors = GetTrackedInitiativeTasks().trackedIDs
  
  for _, endeavorID in ipairs(trackedEndeavors) do
    self:UpdateEndeavor(endeavorID)

    ENDEAVORS_CACHE[endeavorID] = true
  end

  -- We remove the endeavors are not tracked.
  for endeavorID in ENDEAVORS_CONTENT_SUBJECT:IterateEndeavors() do 
    if not ENDEAVORS_CACHE[endeavorID] then 
      ENDEAVORS_CONTENT_SUBJECT.endeavors[endeavorID] = nil
    end
  end
end

function UpdateEndeavor(self, endeavorID)
  local endeavorInfo = GetInitiativeTaskInfo(endeavorID)
  if not endeavorInfo then 
    return 
  end

  local endeavorData = ENDEAVORS_CONTENT_SUBJECT:AcquireEndeavor(endeavorID)
  endeavorData.endeavorID = endeavorID
  endeavorData.name = endeavorInfo.taskName
  endeavorData.isCompleted = endeavorInfo.completed
  endeavorData.description = endeavorInfo.description

  local requirements = endeavorInfo.requirementsList
  
  endeavorData:StartObjectivesCounter()
  for index, requirement in ipairs(requirements) do
    local text = requirement.requirementText
    local isCompleted = requirement.completed

    local objectiveData = endeavorData:AcquireObjective()
    objectiveData.text = text 
    objectiveData.isCompleted = isCompleted
  end
  endeavorData:StopObjectivesCounter()
end

__SystemEvent__()
function INITIATIVE_TASKS_TRACKED_UPDATED()
  _M:LoadAndUpdateEndeavors()
end

__SystemEvent__()
function INITIATIVE_TASK_COMPLETED()
  _M:LoadAndUpdateEndeavors()
end

__SystemEvent__()
function INITIATIVE_TASKS_TRACKED_LIST_CHANGED()
  _M:LoadAndUpdateEndeavors()
end
-- ========================================================================= --
-- Debug Utils Tools
-- ========================================================================= --
DebugTools.TrackData(ENDEAVORS_CONTENT_SUBJECT, "Endeavors Content Subject")
