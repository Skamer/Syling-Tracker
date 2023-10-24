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
  ShowQuestComplete                   = ShowQuestComplete,
  QuestLogPopupDetailFrame_Show       = QuestLogPopupDetailFrame_Show,
  GetQuestLink                        = GetQuestLink,
  LFGListUtil_FindQuestGroup          = LFGListUtil_FindQuestGroup,
   QuestMapQuestOptions_AbandonQuest  = QuestMapQuestOptions_AbandonQuest,
}
-------------------------------------------------------------------------------
--                   Quests Context Menu Pattern                             --
-------------------------------------------------------------------------------
RegisterContextMenuPattern("quests", {
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
    handler = function(questID)
      local quest = QuestCache:Get(questID)
      if quest.isAutoComplete and quest:IsComplete() then 
        ShowQuestComplete(questID)
      else 
        QuestLogPopupDetailFrame_Show(quest:GetQuestLogIndex())
      end
    end
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
    handler = function(questID) end,
  }
})
