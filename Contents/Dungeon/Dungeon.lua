-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                    "SylingTracker.Dungeon"                            ""
-- ========================================================================= --
namespace                          "SLT"
-- ========================================================================= --
RegisterContentType = API.RegisterContentType
RegisterModel = API.RegisterModel
-- ========================================================================= --
IsInInstance                        = IsInInstance
IsInScenario                        = C_Scenario.IsInScenario
GetInfo                             = C_Scenario.GetInfo
GetStepInfo                         = C_Scenario.GetStepInfo
GetCriteriaInfo                     = C_Scenario.GetCriteriaInfo
GetActiveKeystoneInfo               = C_ChallengeMode.GetActiveKeystoneInfo
GetCurrentInstance                  = Utils.Instance.GetCurrentInstance
-- ========================================================================= --
_DungeonModel = RegisterModel(Model, "dungeon-data")
-- ========================================================================= --
RegisterContentType({
  ID = "dungeon",
  DisplayName = "Dungeon",
  Description = "Display the dungeon and its objectives",
  DefaultOrder = 20,
  DefaultModel = _DungeonModel,
  DefaultViewClass = DungeonContentView,
  Events = { "PLAYER_ENTERING_WORLD", "CHALLENGE_MODE_START", "SCENARIO_UPDATE", "ZONE_CHANGE"},
  Status = function()
    local inInstance, type = IsInInstance() 
    return inInstance and (type == "party") and IsInScenario() and GetActiveKeystoneInfo() == 0
  end 
})


function OnEnable()
  Update()
end


__Async__()
__SystemEvent__ "SCENARIO_CRITERIA_UPDATE" "CRITERIA_COMPLETE" "SCENARIO_UPDATE"
function Update()
  local name, _, numObjectives = C_Scenario.GetStepInfo()

  local dungeonData = {
    name = name,
    numObjectives = numObjectives
  }
  if numObjectives > 0 then 
    local objectivesData = {}

    for index = 1, numObjectives do 
      local description, criteriaType, completed, quantity, totalQuantity,
      flags, assetID, quantityString, criteriaID, duration, elapsed,
      failed, isWeightProgress = GetCriteriaInfo(index)

      local data = {
        text = description,
        isCompleted = completed
      }

      if isWeightProgress then 
        data.hasProgressBar = true
        data.progress = progress
        data.minProgress = 0
        data.maxProgress = 100
        data.progressText = PERCENTAGE_STRING:format(progress)
      else 
        data.hasProgressBar = nil 
      end

      objectivesData[index] = data 
    end

    dungeonData.objectives = objectivesData
  end
  
  _DungeonModel:AddData(dungeonData, "dungeon")
  _DungeonModel:Flush()
end


__Async__()
__SystemEvent__ "UPDATE_INSTANCE_INFO"
function UpdateDungeonIcon(self)
  local currentInstance = GetCurrentInstance()
  if currentInstance then 
    local texture = select(6, EJ_GetInstanceInfo(currentInstance))
    _DungeonModel:AddData({ icon = texture}, "dungeon")
    _DungeonModel:Flush()
  end
end
-- ========================================================================= --
-- Debug Utils Tools
-- ========================================================================= --
if ViragDevTool_AddData then 
  ViragDevTool_AddData(_DungeonModel, "SLT Dungeon Model")
end
