-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                 "SylingTracker.Contents.Collections"                  ""
-- ========================================================================= --
_Active                             = false
-- ========================================================================= --
export {
  -- Addon API
  RegisterObservableContent           = API.RegisterObservableContent, 
  
  -- Wow API & Utils
  AppearanceContentTrackingType       = _G.Enum.ContentTrackingType.Appearance,
  GetBestMapForTrackable              = C_ContentTracking.GetBestMapForTrackable,
  GetCurrentTrackingTarget            = C_ContentTracking.GetCurrentTrackingTarget,
  GetTrackedIDs                       = C_ContentTracking.GetTrackedIDs,
  GetObjectiveText                    = C_ContentTracking.GetObjectiveText,
  GetTitle                            = C_ContentTracking.GetTitle,
}

COLLECTIONS_CONTENT_SUBJECT = RegisterObservableContent("collections", CollectionsContentSubject)

__ActiveOnEvents__ "PLAYER_ENTERING_WORLD" "CONTENT_TRACKING_UPDATE"
function BecomeActiveOn(self)
  return #GetTrackedIDs(AppearanceContentTrackingType) > 0
end

function OnActive(self)
  if self:IsActivateByEvent("PLAYER_ENTERING_WORLD") then 
    COLLECTABLE_UPDATE()
  end
end

-- For the moment, only the appearance can be tracked. 
function UpdateCollectable(self, collectableType, collectableID)
  local targetType, targetID = GetCurrentTrackingTarget(collectableType, collectableID)
  if targetType then 
    local name = GetTitle(collectableType, collectableID)
    local trackingResult, uiMapID = GetBestMapForTrackable(collectableType, collectableID, true)

    local objectiveText = GetObjectiveText(targetType, targetID)

    local collectableData = COLLECTIONS_CONTENT_SUBJECT:AcquireCollectable(collectableID)
    collectableData.collectableID = collectableID
    collectableData.collectableType =collectableType
    collectableData.name = name 
    collectableData.uiMapID = uiMapID
    collectableData.targetType = targetType
    collectableData.targetID = targetID
    
    collectableData:StartObjectivesCounter()

    local objectiveData = collectableData:AcquireObjective()
    objectiveData.text = objectiveText

    collectableData:StopObjectivesCounter()
  end
end

__SystemEvent__()
function CONTENT_TRACKING_UPDATE(contentType, id, isTracked)
  if not (contentType == AppearanceContentTrackingType) then 
    return 
  end

  if isTracked then 
    _M:UpdateCollectable(contentType, id)
  else
    COLLECTIONS_CONTENT_SUBJECT.collections[id] = nil
  end
end

__SystemEvent__ "CONTENT_TRACKING_LIST_UPDATE" "TRACKING_TARGET_INFO_UPDATE" "TRACKABLE_INFO_UPDATE"
function COLLECTABLE_UPDATE()
  local trackedAppearances = GetTrackedIDs(AppearanceContentTrackingType)
  for _, appearanceID in ipairs(trackedAppearances) do 
    _M:UpdateCollectable(AppearanceContentTrackingType, appearanceID)
  end
end
-- ========================================================================= --
-- Debug Utils Tools
-- ========================================================================= --
DebugTools.TrackData(COLLECTIONS_CONTENT_SUBJECT, "Collections Content Subject")