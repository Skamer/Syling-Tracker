-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Scorpio                "SylingTracker.QuestUtils"                            ""
-- ========================================================================= --
namespace                          "SLT"
-- ========================================================================= --
IsOnShadowlands = Utils.IsOnShadowlands

class "Utils" (function(_ENV)
  
  class "Quest" (function(_ENV)
    -- Cross Support for 9.0 and 8.3 
    -- TODO: Need to remove that later when the prepatch hits live server
    __Static__() function GetNumQuestLogEntries_CrossSupport()
      if IsOnShadowlands() then 
        return C_QuestLog.GetNumQuestLogEntries() 
      else 
        return GetNumQuestLogEntries()
      end
    end

    __Static__() function GetInfo_CrossSupport(questLogIndex)
      if IsOnShadowlands() then 
        local data = C_QuestLog.GetInfo(questLogIndex)
        return data.title, data.questLogIndex, data.questID, data.campaignID,
        data.level, data.difficultyLevel, data.suggestedGroup, data.frequency,
        data.isHeader, data.isCollapsed, data.startEvent, data.isTask, data.isBounty,
        data.isStory, data.isScaling, data.isOnMap, data.hasLocalPOI, data.isHidden,
        data.isAutoComplete, data.overridesSortOrder, data.readyForTranslation
      end

       -- 8.3: The returned values are not in the same order compared to 9.0 replacement
      local title, level, suggestedGroup, isHeader, isCollapsed, isComplete,
      frequency, questID, startEvent, displayQuestID, isOnMap, hasLocalPOI,
      isTask, isBounty, isStory, isHidden = GetQuestLogTitle(questLogIndex)

      local campaignID, difficultyLevel, isScaling,
      isAutoComplete, overridesSortOrder,  readyForTranslation
      -- Need to find an alternative 

      return title, questLogIndex, questID, campaignID, level, difficultyLevel, 
      suggestedGroup, frequency, isHeader, isCollapsed, startEvent, isTask,
      isBounty, isStory, isScaling, isOnMap, hasLocalPOI, isHidden,
      isAutoComplete, overridesSortOrder, readyForTranslation
    end

    
    __Static__() function IsOnMap_CrossSupport(questID)
      

    end

    __Arguments__ { Number }
    __Static__() function GetQuestTagInfo_CrossSupport(questID)
      if IsOnShadowlands() then 
        return C_QuestLog.GetQuestTagInfo(questID)
      end

      return GetQuestTagInfo(questID)
    end 

    EnumQuestTag = _G.Enum.QuestTag 
    __Arguments__ { Number, Variable.Optional(Number) }
    __Static__() function IsDungeonQuest(questID, questTag)
      if not questTag then
        questTag = GetQuestTagInfo_CrossSupport(questID)
      end

      if questTag == EnumQuestTag.Dungeon then
        return true
      end

      return false
    end

    __Arguments__ { Number, Variable.Optional(Number) }
    __Static__() function IsRaidQuest(questID, questTag)
      if not questTag then
        questTag = GetQuestTagInfo_CrossSupport(questID)
      end

      if questTag == EnumQuestTag.Raid then
        return  true
      end

      return false
    end


    __Arguments__ { Number }
    __Static__() function IsLegendaryQuest_CrossSupport(questID)
      if IsOnShadowlands() then 
        return C_QuestLog.IsLegendaryQuest(questID)
      end 
      
      return false
    end
    
    
    __Arguments__ { Number }
    __Static__() function GetDistanceSqToQuest_CrossSupport(questID)
      if IsOnShadowlands() then 
        return C_QuestLog.GetDistanceSqToQuest(questID)
      end 

      local questLogIndex = GetQuestLogIndexByID(questID)
      return GetDistanceSqToQuest(questLogIndex)
    end

    __Arguments__ { Number }
    __Static__() function IsQuestBounty_CrossSupport(questID)
      if IsOnShadowlands() then 
        return C_QuestLog.IsQuestBounty(questID)
      end 

      return IsQuestBounty(questID)
    end
    
    __Static__() function IsQuestTask_CrossSupport(questID)
      if IsOnShadowlands() then 
        return C_QuestLog.IsQuestTask(questID)
      end 

      return IsQuestTask(questID)
    end

    __Static__() function IsQuestFlaggedCompleted_CrossSupport(questID)
      if IsOnShadowlands() then 
        return C_QuestLog.IsQuestFlaggedCompleted(questID)
      end 

      return IsQuestFlaggedCompleted(questID)
    end

    __Static__() function IsComplete_CrossSupport(questID)
      if IsOnShadowlands() then 
        return C_QuestLog.IsComplete(questID)
      end 

      return IsQuestComplete(questID)
    end

    __Static__() function GetNumQuestWatches_CrossSupport()
      if IsOnShadowlands() then 
        return C_QuestLog.GetNumQuestWatches()
      end 

      return GetNumQuestWatches()
    end

    __Static__() function IsQuestWatched_CrossSupport(questID)
      if IsOnShadowlands() then 
        return QuestUtils_IsQuestWatched(questID)
      end 

      return IsQuestWatched(questID)
    end

    __Static__() function GetQuestLogIndexByID_CrossSupport(questID)
      if IsOnShadowlands() then 
        return C_QuestLog.GetLogIndexForQuestID(questID)
      end

      return GetQuestLogIndexByID(questID)
    end 

  end)
end)