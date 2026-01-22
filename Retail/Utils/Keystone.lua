-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                  "SylingTracker.Utils.Keystone"                       ""
-- ========================================================================= --
-- Use the addon 'MythicDungeonTools' for getting the enemy counts.
local MDT                             = _G.MDT
local ENEMIES_PULL_COUNT              = 0
local ENEMIES_PULL                    = {}

__Arguments__ { Number }
function GetEnemyCount(npcID)
  if not MDT then 
    return 0
  end

  local count = MDT:GetEnemyForces(npcID)

  return count or 0
end

function GetEnemyPullCount()
  return ENEMIES_PULL_COUNT
end

function CalculatePullCount()
  local total = 0
  for guid, value in pairs(ENEMIES_PULL) do 
    if value ~= "DEAD" then 
      total = total + value
    end
  end

  local oldValue = ENEMIES_PULL_COUNT


  ENEMIES_PULL_COUNT = total

  if total ~= oldValue then 
    _M:FireSystemEvent("SylingTracker_ENEMY_PULL_COUNT_CHANGED", total, oldValue)
  end
end

-- Export Utils functions 
Utils.GetEnemyCount                   = GetEnemyCount
Utils.GetEnemyPullCount               = GetEnemyPullCount
-------------------------------------------------------------------------------
--                                Module                                     --
-------------------------------------------------------------------------------
-- __SystemEvent__()
-- function COMBAT_LOG_EVENT_UNFILTERED()
--   local _, subEvent, _, _, _, _, _, destGUID = CombatLogGetCurrentEventInfo()

--   if subEvent == "UNIT_DIED" then
--     if destGUID and ENEMIES_PULL[destGUID] then 
--       ENEMIES_PULL[destGUID] = "DEAD"
--       CalculatePullCount()
--     end
--   end
-- end

__SystemEvent__()
function UNIT_THREAT_LIST_UPDATE(...)
  if InCombatLockdown() then 
    local unit = ...
    if unit and UnitExists(unit) then 
      local guid = UnitGUID(unit)
      if guid and not ENEMIES_PULL[guid] then
        local npcID = select(6, strsplit("-", guid))
        
        if npcID then 
          local enemyCount = Utils.GetEnemyCount(tonumber(npcID))
          ENEMIES_PULL[guid] = enemyCount

          CalculatePullCount()
        end
      end
    end
  end
end

__SystemEvent__ "PLAYER_REGEN_ENABLED" "PLAYER_DEAD"
function ResetEnemiesPull()
  for key, _ in pairs(ENEMIES_PULL) do 
    ENEMIES_PULL[key] = nil
  end

  CalculatePullCount()
end