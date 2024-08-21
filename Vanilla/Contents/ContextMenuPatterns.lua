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
  -- GetSuperTrackedQuestID              = C_SuperTrack.GetSuperTrackedQuestID,
  -- SetSuperTrackedQuestID              = C_SuperTrack.SetSuperTrackedQuestID,
  ShowQuestComplete                   = ShowQuestComplete,
  QuestLogPopupDetailFrame_Show       = QuestLogPopupDetailFrame_Show,
  GetQuestLink                        = GetQuestLink,
  LFGListUtil_FindQuestGroup          = LFGListUtil_FindQuestGroup,
  -- RemoveQuestWatch                    = C_QuestLog.RemoveQuestWatch,
  QuestMapQuestOptions_AbandonQuest   = QuestMapQuestOptions_AbandonQuest,

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
    order = 45;
    type = "separator"
  },
  {
    id = "stopWatchingQuest",
    text = "Stop Watching",
    order = 50,
    icon = { atlas = AtlasType("transmog-icon-hidden") },
    handler = function(questID) 
      RemoveQuestWatch(GetQuestLogIndexByID(questID))
    end
  },
  {
    id = "abandonQuest",
    text = "Abandon",
    order = 60,
    icon = { atlas = AtlasType("transmog-icon-remove") },
    handler = function(questID)
      local questIndex =  GetQuestLogIndexByID(questID)
      SelectQuestLogEntry(questIndex)
      SetAbandonQuest()

      local items = GetAbandonQuestItems();
      if items then
        StaticPopup_Hide("ABANDON_QUEST");
        StaticPopup_Show("ABANDON_QUEST_WITH_ITEMS", GetAbandonQuestName(), items);
      else
        StaticPopup_Hide("ABANDON_QUEST_WITH_ITEMS");
        StaticPopup_Show("ABANDON_QUEST", GetAbandonQuestName());
      end
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