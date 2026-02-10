-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                    "SylingTracker.ContextMenuPatterns"                ""
-- ========================================================================= --
export {
  RegisterContextMenuPattern          = API.ContextMenu_RegisterPattern,

  -- Shared 
  ChatFrame_OpenChat                  = ChatFrame_OpenChat,

  -- Quest 
  GetSuperTrackedQuestID              = C_SuperTrack.GetSuperTrackedQuestID,
  SetSuperTrackedQuestID              = C_SuperTrack.SetSuperTrackedQuestID,
  OpenQuestDetails                    = QuestUtil.OpenQuestDetails,
  ShowQuestComplete                   = ShowQuestComplete,
  QuestLogPopupDetailFrame_Show       = QuestLogPopupDetailFrame_Show,
  GetQuestLink                        = GetQuestLink,
  LFGListUtil_FindQuestGroup          = LFGListUtil_FindQuestGroup,
  RemoveQuestWatch                    = C_QuestLog.RemoveQuestWatch,
  QuestMapQuestOptions_AbandonQuest   = QuestMapQuestOptions_AbandonQuest,

  -- Achievement
   GetAchievementLink                 = GetAchievementLink,

   -- Recipe Tracker
  SetRecipeTracked                    = C_TradeSkillUI.SetRecipeTracked,

  -- Activity
  RemoveTrackedPerksActivity          = C_PerksActivities.RemoveTrackedPerksActivity,

  -- Endeavor
  RemoveTrackedInitiativeTask         = C_NeighborhoodInitiative.RemoveTrackedInitiativeTask,


  -- Collections
  EContentTrackingType                = _G.Enum.ContentTrackingType,
  EContentTrackingStopType            = _G.Enum.ContentTrackingStopType,

  -- Helper 
  ShowHelperWindow                    = API.ShowHelperWindow
}
-------------------------------------------------------------------------------
--                    Quest Context Menu Pattern                             --
-------------------------------------------------------------------------------
RegisterContextMenuPattern("quest", {
  {
    id = "supertrackQuest",
    text = _Locale.CONTEXT_MENU_SUPERTRACK,
    type = "action",
    order = 10,
    icon = { atlas = AtlasType("Target-Tracker")},
    isShown = function(questID)
      local supertrackQuestID = GetSuperTrackedQuestID()
      if supertrackQuestID and supertrackQuestID == questID then 
        return false 
      end 

      return true 
    end,
    handler = function(questID) SetSuperTrackedQuestID(questID) end
  },
  {
    order = 15,
    type = "separator"
  },
  {
    id = "linkQuestToChat",
    text = _Locale.CONTEXT_MENU_LINK_TO_CHAT,
    order = 20,
    icon = { atlas = AtlasType("communities-icon-chat") },
    handler = function(questID) ChatFrame_OpenChat(GetQuestLink(questID)) end
  },
  {
    id = "showQuestDetails",
    text = _Locale.CONTEXT_MENU_SHOW_DETAILS,
    order = 30,
    icon = { atlas = AtlasType("adventureguide-icon-whatsnew") },
    handler = function(questID)OpenQuestDetails(questID) end
  },
  {
    order = 35,
    type = "separator"
  },
  {
    id = "findAGroup",
    text = _Locale.CONTEXT_MENU_FIND_A_GROUP,
    order = 40,
    icon = { atlas = AtlasType("socialqueuing-icon-group")},
    handler = function(questID) LFGListUtil_FindQuestGroup(questID) end
  },
  {
    order = 45;
    type = "separator"
  },
  {
    id = "stopWatchingQuest",
    text = _Locale.CONTEXT_MENU_STOP_WATCHING,
    order = 50,
    icon = { atlas = AtlasType("transmog-icon-hidden") },
    handler = function(questID) RemoveQuestWatch(questID) end
  },
  {
    id = "abandonQuest",
    text = _Locale.CONTEXT_MENU_ABANDON,
    order = 60,
    icon = { atlas = AtlasType("transmog-icon-remove") },
    handler = function(questID)  QuestMapQuestOptions_AbandonQuest(questID) end
  },
  {
    order = 65,
    type = "separator"
  },
  {
    id = "helpQuest",
    text = _Locale.CONTEXT_MENU_HELP,
    order = 70,
    icon  =  { atlas = AtlasType("QuestTurnin") },
    handler = function(questID) ShowHelperWindow("quest", questID) end,
  }
})
-------------------------------------------------------------------------------
--                   Achievement Context Menu Pattern                       --
-------------------------------------------------------------------------------
RegisterContextMenuPattern("achievement", {
  {
    id = "linkAchievementToChat",
    text = _Locale.CONTEXT_MENU_LINK_TO_CHAT,
    order = 10,
    icon = { atlas = AtlasType("communities-icon-chat")},
    handler = function(achievementID)
      local achievementLink = GetAchievementLink(achievementID)
      if achievementLink then 
        ChatFrame_OpenChat(achievementLink)
      end
    end
  },
  {
    id = "showAchievementDetails",
    text = _Locale.CONTEXT_MENU_SHOW_DETAILS,
    order = 20,
    icon = { atlas = AtlasType("adventureguide-icon-whatsnew")},
    handler = function(achievementID)
      if not AchievementFrame then
        AchievementFrame_LoadUI()
      end
      if not AchievementFrame:IsShown() then
        AchievementFrame_ToggleAchievementFrame()
      end
      AchievementFrame_SelectAchievement(achievementID)
    end
  },
  {
    order = 25,
    type = "separator"
  },
  {
    id = "stopWatchingAchievement",
    text = _Locale.CONTEXT_MENU_STOP_WATCHING,
    order = 30,
    icon = { atlas = AtlasType("transmog-icon-hidden")},
    handler = function(achievementID)
      C_ContentTracking.StopTracking(_G.Enum.ContentTrackingType.Achievement, achievementID, _G.Enum.ContentTrackingStopType.Manual)
    end
  },
  {
    order = 35,
    type = "separator"
  },
  {
    id = "helpAchievement",
    text = _Locale.CONTEXT_MENU_HELP,
    order = 40,
    icon = { atlas = AtlasType("QuestTurnin")},
    handler = function(achievementID)
      ShowHelperWindow("achievement", achievementID)
    end
  }
})
-------------------------------------------------------------------------------
--                   Profession Recipe Context Menu Pattern                  --
-------------------------------------------------------------------------------
RegisterContextMenuPattern("recipe", {
  {
    id = "stopTrackingRecipe",
    text = _Locale.CONTEXT_MENU_STOP_TRACKING,
    order = 10,
    icon = { atlas = AtlasType("transmog-icon-hidden") },
    handler = function(recipeID, isRecraft)
      SetRecipeTracked(recipeID, false, isRecraft)
    end
  }
})
-------------------------------------------------------------------------------
--                     Activity Context Menu Pattern                         --
-------------------------------------------------------------------------------
RegisterContextMenuPattern("activity", {
  {
    id = "showDetails",
    text = _Locale.CONTEXT_MENU_SHOW_DETAILS,
    order = 10,
    icon = { atlas = AtlasType("adventureguide-icon-whatsnew") },
    handler = function(activityID)
      -- MonthlyActivitiesFrame_OpenFrameToActivity is undefined if the EncounterJournal isn't loaded.
      if not EncounterJournal then
        EncounterJournal_LoadUI();
      end

      MonthlyActivitiesFrame_OpenFrameToActivity(activityID)
    end
  },
  {
    id = "stopTrackingActivity",
    text = _Locale.CONTEXT_MENU_STOP_TRACKING,
    order = 20,
    icon = { atlas = AtlasType("transmog-icon-hidden") },
    handler = function(activityID)
      RemoveTrackedPerksActivity(activityID)
    end
  }
})
-------------------------------------------------------------------------------
--                     Endeavor Context Menu Pattern                         --
-------------------------------------------------------------------------------
RegisterContextMenuPattern("endavor", {
  {
    id = "showDetails",
    text = _Locale.CONTEXT_MENU_SHOW_DETAILS,
    order = 10,
    icon = { atlas = AtlasType("adventureguide-icon-whatsnew") },
    handler = function(endeavorID)
      HousingFramesUtil.OpenFrameToTaskID(endeavorID)
    end
  },
  {
    id = "stopTrackingEndeavor",
    text = _Locale.CONTEXT_MENU_STOP_TRACKING,
    order = 20,
    icon = { atlas = AtlasType("transmog-icon-hidden") },
    handler = function(endeavorID)
      RemoveTrackedInitiativeTask(endeavorID)
    end
  }
})
-------------------------------------------------------------------------------
--                   Collection Context Menu Pattern                         --
-------------------------------------------------------------------------------
RegisterContextMenuPattern("collection", {
  {
    id = "openCollection",
    text = _Locale.CONTEXT_MENU_OPEN_COLLECTIONS,
    order = 10,
    icon = { atlas = AtlasType("adventureguide-icon-whatsnew") },
    isShown = function(collectableID, collectableType) return collectableType == EContentTrackingType.Appearance end,
    handler = function(collectableID, collectableType)
      TransmogUtil.OpenCollectionToItem(collectableID)
    end
  },
  {
    id = "stopTrackingCollectable",
    text = _Locale.CONTEXT_MENU_STOP_TRACKING,
    order = 20,
    icon = { atlas = AtlasType("transmog-icon-hidden") },
    handler = function(collectableID, collectableType)
      C_ContentTracking.StopTracking(collectableType, collectableID, EContentTrackingStopType.Manual)
    end
  }
})