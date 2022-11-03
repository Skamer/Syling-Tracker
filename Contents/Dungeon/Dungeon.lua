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
_Active                           = false 
-- ========================================================================= --
RegisterContentType               = API.RegisterContentType
RegisterModel                     = API.RegisterModel
-- ========================================================================= --
CreateAtlasMarkup                   = CreateAtlasMarkup
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
_DungeonIconMarkupAtlas = CreateAtlasMarkup("Dungeon", 16, 16)

RegisterContentType({
  ID = "dungeon",
  Name = "Dungeon",
  DisplayName = _DungeonIconMarkupAtlas.." Dungeon",
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
-- ========================================================================= --
__ActiveOnEvents__ "PLAYER_ENTERING_WORLD" "CHALLENGE_MODE_START" "SCENARIO_UPDATE" "ZONE_CHANGE"
function BecomeActiveOn(self)
  local inInstance, type = IsInInstance() 
  return inInstance and (type == "party") and IsInScenario() and GetActiveKeystoneInfo() == 0
end
-- ========================================================================= --
function OnActive(self)
  Update()
end

function OnInactive(self)
  _DungeonModel:ClearData()
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

      -- Revert the changes previously done as this cause all the dungeon to get
      -- a progress bar
      -- TODO: Need to find a better fix
      -- if isWeightProgress then 
      --   data.hasProgressBar = true
      --   data.progress = quantity
      --   data.minProgress = 0
      --   data.maxProgress = totalQuantity
      --   data.progressText = quantityString
      -- else 
      --   data.hasProgressBar = nil 
      -- end

      objectivesData[index] = data 
    end
    -- NOTE: We use SetData only for objectives to be sure the dungeon 
    -- doesn't keep the objectives data of previous stage.
    _DungeonModel:SetData(objectivesData, "dungeon", "objectives")
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
