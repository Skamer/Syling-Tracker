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
  GetTasksTable                       = GetTasksTable,

  -- Import ColorMixin to avoid an error when calling C_MajorFactions.GetMajorFactionData
  -- because this one doesn't find the mixin in some environment.
  ColorMixin                          = ColorMixin
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

local TOOLTIP_ICONS_INFO = {
  ["money"] = { width = 16, height = 16, file = "Interface/Icons/XP_Icon" },
  ["xp"] = { width = 16, height = 16, file = "Interface/Icons/XP_Icon"},
  ["title"] = { width = 16, height = 16, file = "Interface/Icons/INV_Misc_Note_02"}
}

function CreateQuestXPRewardMarkup(amount)
  local xpPercent = (amount * 100) / UnitXPMax('player')

  return CreateTextureMarkup("Interface/Icons/XP_Icon", 64, 64, 20, 16, 0.1, 0.9, 0.2, 0.8) .. format(" %i (%.2f%%)", amount, xpPercent)
end

function CreateQuestMoneyRewardMarkup(money, separateThousands, checkGoldThreshold)
  return CreateTextureMarkup("Interface/Icons/inv_misc_coin_01", 64, 64, 16, 16, 0.1, 0.9, 0.1, 0.9).. GetMoneyString(money, separateThousands, checkGoldThreshold)
end

function CreateQuestHonorRewardMarkup(honor)
  local icon 
  if UnitFactionGroup("player") == PLAYER_FACTION_GROUP[0] then 
    icon = "Interface\\Icons\\PVPCurrency-Honor-Horde"
  else 
    icon = "Interface\\Icons\\PVPCurrency-Honor-Alliance"
  end 

  return CreateTextureMarkup(icon, 64, 64, 20, 16, 0.1, 0.9, 0.2, 0.8) .. HONOR .. " x " .. honor
end

function CreateQuestSkillPointRewardMarkup(skillIcon, skillName, skillPoints)
  return CreateTextureMarkup(skillIcon or QUESTION_MARK_ICON, 64, 64, 16, 16, 0.1, 0.9, 0.1, 0.9) .. " " .. format(BONUS_SKILLPOINTS_TOOLTIP, skillPoints, skillName)
end

local MAJOR_FACTION_REPUTATION_REWARD_ICON_FORMAT = [[Interface\Icons\UI_MajorFaction_%s]]
function CreateQuestMajorFactionRepRewardMarkup(factionID, amount)
  -- IMPORTANT: ColorMixin must be imported to avoid an error when calling C_MajorFactions.GetMajorFactionData
  -- from some environment.
  local majorFactionData = C_MajorFactions.GetMajorFactionData(factionID)
  local majorFactionIcon = MAJOR_FACTION_REPUTATION_REWARD_ICON_FORMAT:format(majorFactionData.textureKit)

  return CreateTextureMarkup(majorFactionIcon, 64, 64, 16, 16, 0.1, 0.9, 0.1, 0.9) .. " " .. QUEST_REPUTATION_REWARD_TITLE:format(majorFactionData.name) .. " x " .. AbbreviateNumbers(amount)
end

function CreateQuestCurrencyRewardMarkup(texture, name, amount)
  texture = texture or QUESTION_MARK_ICON

  if amount > 1 then 
    return CreateTextureMarkup(texture, 64, 64, 16, 16, 0.1, 0.9, 0.1, 0.9) .. " " .. name .. " x " .. amount
  else 
    return CreateTextureMarkup(texture, 64, 64, 16, 16, 0.1, 0.9, 0.1, 0.9) .. " " .. name
  end
end

function CreateQuestChoiceRewardMarkup(index, texture, name, amount)
  texture = texture or QUESTION_MARK_ICON

  local indexAtlas = "services-number-"..index
  local markup = CreateAtlasMarkup(indexAtlas, 20, 22) .. CreateTextureMarkup(texture, 64, 64, 16, 16, 0.1, 0.9, 0.1, 0.9) .. " " .. name

  if amount > 1 then 
    markup = markup .. " x " .. amount
  end

  return markup
end

function IsQuestHasRewardsData(questID)
  local hasData = HaveQuestRewardData(questID)

  if hasData then 
    return hasData 
  end 

  local previousQuestID = C_QuestLog.GetSelectedQuest()
  C_QuestLog.SetSelectedQuest(questID)
  local numQuestChoices = GetNumQuestLogChoices(questID, true)

  if numQuestChoices > 0 then
    -- the name may be "" so we need to ignore it and have more luck the next time
    local lootType = GetQuestLogChoiceInfoLootType(1)
    if lootType == 0 then -- LOOT_LIST_ITEM
      local name = GetQuestLogChoiceInfo(1)
      if name == "" then
          hasData = false
      end
    elseif lootType == 1 then -- LOOT_LIST_CURRENCY
      local currencyInfo = C_QuestLog.GetQuestRewardCurrencyInfo(questID, 1, true)
      if currencyInfo.name == "" then
          hasData = false
      end
    end
    
    hasData = true 
  end

  C_QuestLog.SetSelectedQuest(previousQuestID)

  return hasData
end

__Arguments__ { Any, Number }
function AddQuestRewardsToTooltip(tooltip, questID)
  local previousQuestID = C_QuestLog.GetSelectedQuest()
  C_QuestLog.SetSelectedQuest(questID)

  local xp = GetQuestLogRewardXP(questID)
  local money = GetQuestLogRewardMoney(questID)
  local numQuestRewards = GetNumQuestLogRewards(questID)
  local numQuestChoices = GetNumQuestLogChoices(questID, true)
  local currencyRewards = C_QuestInfoSystem.GetQuestRewardCurrencies(questID) or {};
  local skillName, skillIcon, skillPoints = GetQuestLogRewardSkillPoints()
  local artifactXP, artifactCategory = GetQuestLogRewardArtifactXP()
  local honor = GetQuestLogRewardHonor()
  local playerTitle = GetQuestLogRewardTitle()
  local hasWarModeBonus = C_QuestLog.QuestHasWarModeBonus(questID)
  local majorFactionRepRewards = C_QuestLog.GetQuestLogMajorFactionReputationRewards(questID)

  local rewardItemPrefix = "   "

  
  if numQuestRewards > 0 or numQuestChoices > 0 or money > 0 or xp > 0 or honor > 0 or majorFactionRepRewards then
    tooltip:AddLine("\n")
    tooltip:AddLine("Rewards:")

    -- XP and money
    if xp > 0 and money > 0 then 
      tooltip:AddDoubleLine(
        rewardItemPrefix .. CreateQuestXPRewardMarkup(xp),
        CreateQuestMoneyRewardMarkup(money, false, true),
        1, 1, 1, 1, 1, 1
      )
    elseif xp > 0 then 
      tooltip:AddLine(rewardItemPrefix .. CreateQuestXPRewardMarkup(xp), 1, 1, 1, 1, 1, 1)
    elseif money > 0 then 
      tooltip:AddDoubleLine(
        " ",
        CreateQuestMoneyRewardMarkup(money, false, true),
        1, 1, 1, 1, 1, 1
      )
    end

    if numQuestRewards > 0 or numQuestChoices > 0 or honor > 0 or majorFactionRepRewards then 
      tooltip:AddLine("\n")
    end

    -- Skill points rewards 
    if skillPoints then 
      tooltip:AddLine(rewardItemPrefix .. CreateQuestSkillPointRewardMarkup(skillIcon, skillName, skillPoints), 1, 1, 1)
    end

    for i = 1, numQuestRewards do 
      local name, texture, numItems, quality, isUsable, itemID, itemLevel, questRewardContextFlags = GetQuestLogRewardInfo(i)
      local color = ITEM_QUALITY_COLORS[quality]
      tooltip:AddLine(rewardItemPrefix .. CreateQuestCurrencyRewardMarkup(texture, name, numItems), color.r, color.g, color.b)
    end

    -- Currency 
    for i, currencyReward in ipairs(currencyRewards) do 
	    -- Overrides the currency's display data with currency container display data if needed
	    local name, texture, amount, quality = CurrencyContainerUtil.GetCurrencyContainerInfo(currencyReward.currencyID, currencyReward.totalRewardAmount, currencyReward.name, currencyReward.texture, currencyReward.quality)
      local currencyColor = GetColorForCurrencyReward(currencyReward.currencyID, amount)
      tooltip:AddLine(rewardItemPrefix .. CreateQuestCurrencyRewardMarkup(texture, name, amount), currencyColor.r, currencyColor.g, currencyColor.b)
    end

    -- Major Faction Reputation Rewards
    if majorFactionRepRewards then 
      for i, rewardInfo in ipairs(majorFactionRepRewards) do
        tooltip:AddLine(rewardItemPrefix .. CreateQuestMajorFactionRepRewardMarkup(rewardInfo.factionID, rewardInfo.rewardAmount), 1, 1, 1)
      end
    end

    -- Honor
    if honor > 0 then 
      tooltip:AddLine(rewardItemPrefix .. CreateQuestHonorRewardMarkup(honor), 1, 1, 1)
    end

    -- Choices
    if numQuestChoices > 0 then
      if numQuestChoices == 1 then 
        tooltip:AddLine(rewardItemPrefix .. REWARD_ITEMS_ONLY)
      else 
        tooltip:AddLine(rewardItemPrefix .. REWARD_CHOOSE)
      end
      for i = 1, numQuestChoices do 
        local lootType = GetQuestLogChoiceInfoLootType(i)
    
        if lootType == 0 then -- LOOT_LIST_ITEM
          local name, texture, numItems, quality, isUsable, itemID, itemLevel, questRewardContextFlags = GetQuestLogChoiceInfo(i)
          local color = ITEM_QUALITY_COLORS[quality]

          local text = ""
          if numQuestChoices == 1 then 
            text = CreateQuestCurrencyRewardMarkup(texture, name, numItems)
          else 
            text = CreateQuestChoiceRewardMarkup(i, texture, name, numItems)
          end

          tooltip:AddLine(rewardItemPrefix .. rewardItemPrefix  .. text, color.r, color.g, color.b)
        elseif lootType == 1 then -- LOOT_LIST_CURRENCY
          local isChoice = true
          local currencyInfo = C_QuestLog.GetQuestRewardCurrencyInfo(questID, i, isChoice)
          local name, texture, amount, quality = CurrencyContainerUtil.GetCurrencyContainerInfo(currencyInfo.currencyID, currencyInfo.totalRewardAmount, currencyInfo.name, currencyInfo.texture, currencyInfo.quality);
          local color = ITEM_QUALITY_COLORS[quality]


          local text = ""
          if numQuestChoices == 1 then 
            text = CreateQuestCurrencyRewardMarkup(texture, name, amount)
          else 
            text = CreateQuestChoiceRewardMarkup(i, texture, name, amount)
          end

          tooltip:AddLine(rewardItemPrefix .. rewardItemPrefix  ..  text, color.r, color.g, color.b)
        end 
      end
    end
  end

  C_QuestLog.SetSelectedQuest(previousQuestID)
end

Utils.GetQuestPOINumber = GetQuestPOINumber
Utils.AddQuestRewardsToTooltip = AddQuestRewardsToTooltip
Utils.IsQuestHasRewardsData = IsQuestHasRewardsData