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
  GetQuestLogIndexByID                = GetQuestLogIndexByID,
  GetQuestLink                        = GetQuestLink,
  RemoveQuestWatch                    = RemoveQuestWatch,
  SetAbandonQuest                     = SetAbandonQuest,
  SelectQuestLogEntry                 = SelectQuestLogEntry,
  GetAbandonQuestItems                = GetAbandonQuestItems,
  GetQuestLogSelection                = GetQuestLogSelection,
  QuestLog_OpenToQuest                = QuestLog_OpenToQuest,
  QuestLogControlPanel_UpdateState    = QuestLogControlPanel_UpdateState,

  -- Achievement
   GetAchievementLink                 = GetAchievementLink,
   RemoveTrackedAchievement           = RemoveTrackedAchievement,

  -- Helper 
  ShowHelperWindow                    = API.ShowHelperWindow
}
-------------------------------------------------------------------------------
--                    Quest Context Menu Pattern                             --
-------------------------------------------------------------------------------
RegisterContextMenuPattern("quest", {
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
    handler = function(questID)
      local questLogIndex = GetQuestLogIndexByID(questID)

      QuestLog_OpenToQuest(questLogIndex)
      QuestLogControlPanel_UpdateState()
    end
  },
  {
    order = 35,
    type = "separator"
  },
  {
    id = "stopWatchingQuest",
    text = "Stop Watching",
    order = 50,
    icon = { atlas = AtlasType("transmog-icon-hidden") },
    handler = function(questID) 
      local questLogIndex = GetQuestLogIndexByID(questID)

      RemoveQuestWatch(questLogIndex) 
      WatchFrame_Update()
      QuestLog_Update()
    end
  },
  {
    id = "abandonQuest",
    text = "Abandon",
    order = 60,
    icon = { atlas = AtlasType("transmog-icon-remove") },
    handler = function(questID)
      local questLogIndex = GetQuestLogIndexByID(questID)
      local lastQuest = GetQuestLogSelection()
      SelectQuestLogEntry(questLogIndex)
      SetAbandonQuest()

      local items = GetAbandonQuestItems()
      if ( items ) then
        StaticPopup_Hide("ABANDON_QUEST")
        StaticPopup_Show("ABANDON_QUEST_WITH_ITEMS", GetAbandonQuestName(), items)
      else
        StaticPopup_Hide("ABANDON_QUEST_WITH_ITEMS")
        StaticPopup_Show("ABANDON_QUEST", GetAbandonQuestName())
      end

      SelectQuestLogEntry(lastQuest)
    end 
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
      RemoveTrackedAchievement(achievementID)
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