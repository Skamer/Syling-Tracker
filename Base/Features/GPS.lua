-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                 "SylingTracker.Features.GPS"                          ""
-- ========================================================================= --
export {
    RegisterSetting = API.RegisterSetting,
    GetSetting      = API.GetSetting
}

TomTom = TomTom

ENABLE_TOMTOM = false

function GetQuestLocation(questID)
    local mapID = GetQuestUiMapID(questID)
    local questsOnMap = C_QuestLog.GetQuestsOnMap(mapID)
    local x, y 

    for i, info in ipairs(questsOnMap) do 
        if info.questID == questID then 
            x = info.x 
            y = info.y
            break 
        end
    end

    return x, y, mapID, false
end

function GetQuestWaypointLocation(questID)
    local mapID, x, y = C_QuestLog.GetNextWaypoint(questID)
    local isWaypoint = true

    if not mapID then 
        x, y, mapID, isWaypoint = GetQuestLocation(questID)
    end

    return x, y, mapID, isWaypoint
end

WAYPOINT_TOMTOM_UID = nil

function SetGPSToQuest(questID)
    if not questID then 
        if WAYPOINT_TOMTOM_UID then 
            TomTom:RemoveWaypoint(WAYPOINT_TOMTOM_UID)
        end
        return
    end

    local x, y, mapID, isWaypoint = GetQuestWaypointLocation(questID)

    if WAYPOINT_TOMTOM_UID then 
        TomTom:RemoveWaypoint(WAYPOINT_TOMTOM_UID)
    end

    if not x or not y or not mapID then 
        return 
    end


    local title = C_QuestLog.GetTitleForQuestID(questID)

    if isWaypoint then
        local waypointText = C_QuestLog.GetNextWaypointText(questID)
        if waypointText then 
            title = title .. "\n" .. waypointText
        end
    end


    WAYPOINT_TOMTOM_UID = TomTom:AddWaypoint(mapID, x, y, {
        title = title,
        silent = true, 
        world = false, 
        minimap = false, 
        crazy = true, 
        persistent = false,
        arrivaldistance = isWaypoint and 4 or nil
    })
end

TRACKED_QUEST_ID = nil

__SystemEvent__()
function SUPER_TRACKING_CHANGED()
    if not ENABLE_TOMTOM then 
        return 
    end

    local questID = C_SuperTrack.GetSuperTrackedQuestID()
    TRACKED_QUEST_ID = questID

    SetGPSToQuest(questID)
end

__SystemEvent__()
function PLAYER_ENTERING_WORLD()
    if not ENABLE_TOMTOM then 
        return 
    end

    SUPER_TRACKING_CHANGED()
end

__SystemEvent__ "WAYPOINT_UPDATE"
function UpdateWaypoint()
    if not ENABLE_TOMTOM then 
        return 
    end

    if TRACKED_QUEST_ID then
        SetGPSToQuest(TRACKED_QUEST_ID)
    end
end

function OnLoad(self)
    RegisterSetting("enableTomTom", false, function(enable) ENABLE_TOMTOM = enable end)
end

function OnEnable(self)
    ENABLE_TOMTOM = GetSetting("enableTomTom") and TomTom
end