-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                  "SylingTracker.Utils.Quests"                         ""
-- ========================================================================= --
export {
  GetQuestTagInfo                      = C_QuestLog.GetQuestTagInfo,
  EnumQuestTag                        = _G.Enum.QuestTag,
  IsWorldQuest                        = QuestUtils_IsQuestWorldQuest,
  GetTaskInfo                         = GetTaskInfo,
  GetTasksTable                       = GetTasksTable
}

__Arguments__ { Number, Number/nil } 
__Static__() function Utils.IsDungeonQuest(questID, questTag)
  if not questTag then 
    questTag = C_QuestLog.GetQuestTagInfo(questID)
  end

  if questTag and questTag.tagID == EnumQuestTag.Dungeon then 
    return true 
  end

  return false 
end

__Arguments__ { Number, Number/nil }
__Static__() function Utils.IsRaidQuest(questID, questTag)
  if not questTag then 
    questTag = C_QuestLog.GetQuestTagInfo(questID)
  end

  if questTag and questTag.tagID == EnumQuestTag.Raid then 
    return true 
  end

  return false 
end


__Static__() function Utils.HasWorldQuests()
  local tasks = GetTasksTable()
  for _, questID in ipairs(tasks) do 
    local isInArea = GetTaskInfo(questID)
    if IsWorldQuest(questID) and isInArea then 
      return true 
    end 
  end
  
  return false
end

__Static__() function Utils.HasTasks(self)
  local tasks = GetTasksTable()
  for _, questID in ipairs(tasks) do 
    local isInArea = GetTaskInfo(questID)
    if not IsWorldQuest(questID) and isInArea then 
      return true 
    end 
  end
  
  return false
end


__Arguments__ { Number }
function GetQuestPOINumber(questID)
  -- local poiButton = ObjectiveTrackerFrame.BlocksFrame:FindButtonByQuestID(questID) or QuestScrollFrame.Contents:FindButtonByQuestID(questID)
  local poiButton = QuestScrollFrame.Contents:FindButtonByQuestID(questID)
  return  poiButton and poiButton.index
end


__Arguments__ { Any, Number }
function AddQuestToTooltip(tooltip, questID)
  local questLink = GetQuestLink(questID)

  if not questLink then 
    return 
  end

  tooltip:SetHyperlink(questLink)
  
  -- TODO: Implement the rewards and others 
  --
  -- local previousQuestID = C_QuestLog.GetSelectedQuest()
  -- C_QuestLog.SetSelectedQuest(questID)
  --
  -- local numQuestRewards = GetNumQuestLogRewards()
  -- local numQuestChoices = GetNumQuestLogChoices(questID, true)
  -- local money = GetQuestLogRewardMoney()
  -- local skillName, skillIcon, skillPoints = GetQuestLogRewardSkillPoints()
  -- local xp = GetQuestLogRewardXP()
  -- local artifactXP, artifactCategory = GetQuestLogRewardArtifactXP()
  -- local honor = GetQuestLogRewardHonor()
  -- local playerTitle = GetQuestLogRewardTitle()
  -- local hasWarModeBonus = C_QuestLog.QuestHasWarModeBonus(questID)
  -- local majorFactionRepRewards = C_QuestLog.GetQuestLogMajorFactionReputationRewards(questID)

  -- tooltip:AddLine("Rewards:")

  -- for i = 0, numQuestChoices do 
  --   local lootType = GetQuestLogChoiceInfoLootType(i)

  --   if lootType == 0 then -- LOOT_LIST_ITEM
  --     local name, texture, numItems, quality, isUsable, itemID, itemLevel, questRewardContextFlags = GetQuestItemInfo(index)
  --     tooltip:AddLine(name)

  --   elseif lootType == 1 then -- -- LOOT_LIST_CURRENCY
  --     local isChoice = true
  --     local currencyInfo = C_QuestLog.GetQuestRewardCurrencyInfo(questID, i, isChoice)
  --     local name, texture, amount, quality = CurrencyContainerUtil.GetCurrencyContainerInfo(currencyInfo.currencyID, currencyInfo.totalRewardAmount, currencyInfo.name, currencyInfo.texture, currencyInfo.quality);

  --     tooltip:AddLine(name)
  --   end 
  -- end

  -- if numQuestRewards > 0 or money > 0 or xp > 0 or honor > 0 or majorFactionRepRewards then 
  --   if xp > 0 then 
  --     tooltip:AddLine("xp:"..xp)
  --   end 

  --   if money > 0 then
  --     local separateThousands = false;
  --     local checkGoldThreshold = true;

  --     tooltip:AddLine("money:"..GetMoneyString(money, separateThousands, checkGoldThreshold))
  --   end
  -- end

  -- C_QuestLog.SetSelectedQuest(previousQuestID)
end



Utils.GetQuestPOINumber = GetQuestPOINumber
Utils.AddQuestToTooltip = AddQuestToTooltip