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
    text = "Supertrack",
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
    text = "Link to chat",
    order = 20,
    icon = { atlas = AtlasType("communities-icon-chat") },
    handler = function(questID) ChatFrame_OpenChat(GetQuestLink(questID)) end
  },
  {
    id = "showQuestDetails",
    text = "Show details",
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
    text = "Find a group",
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
    text = "Stop Watching",
    order = 50,
    icon = { atlas = AtlasType("transmog-icon-hidden") },
    handler = function(questID) RemoveQuestWatch(questID) end
  },
  {
    id = "abandonQuest",
    text = "Abandon",
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
    text = "Help",
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
    text = "Link to chat",
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
    text = "Show details",
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
    text = "Stop watching",
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
    text = "Help",
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
    text = "Stop tracking",
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
    text = "Show details",
    order = 10,
    icon = { atlas = AtlasType("adventureguide-icon-whatsnew") },
    handler = function(activityID)
      MonthlyActivitiesObjectiveTracker_OpenFrameToActivity(activityID)
    end
  },
  {
    id = "stopTrackingActivity",
    text = "Stop tracking",
    order = 20,
    icon = { atlas = AtlasType("transmog-icon-hidden") },
    handler = function(activityID)
      RemoveTrackedPerksActivity(activityID)
    end
  }
})
-------------------------------------------------------------------------------
--                   Collection Context Menu Pattern                         --
-------------------------------------------------------------------------------
RegisterContextMenuPattern("collection", {
  {
    id = "openCollection",
    text = "Open Collections",
    order = 10,
    icon = { atlas = AtlasType("adventureguide-icon-whatsnew") },
    isShown = function(collectableID, collectableType) return collectableType == EContentTrackingType.Appearance end,
    handler = function(collectableID, collectableType)
      TransmogUtil.OpenCollectionToItem(collectableID)
    end
  },
  {
    id = "stopTrackingCollectable",
    text = "Stop tracking",
    order = 20,
    icon = { atlas = AtlasType("transmog-icon-hidden") },
    handler = function(collectableID, collectableType)
      C_ContentTracking.StopTracking(collectableType, collectableID, EContentTrackingStopType.Manual)
    end
  }
})