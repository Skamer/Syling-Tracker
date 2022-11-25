-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                 "SylingTracker.ContextMenuPatterns"                   ""
-- ========================================================================= --
import                                 "SLT"
-- ========================================================================= --
export {
  RegisterContextMenuPattern            = API.RegisterContextMenuPattern,

  -- Shared 
  ChatFrame_OpenChat                    = ChatFrame_OpenChat,
  StaticPopup_Hide                      = StaticPopup_Hide,
  StaticPopup_Show                      = StaticPopup_Show,
  WatchFrame_Update                     = WatchFrame_Update,
  QuestLog_Update                       = QuestLog_Update,
  
  -- Quest
  GetQuestLogIndexByID                  = GetQuestLogIndexByID,
  GetQuestLink                          = GetQuestLink,
  RemoveQuestWatch                      = RemoveQuestWatch,
  SetAbandonQuest                       = SetAbandonQuest,
  SelectQuestLogEntry                   = SelectQuestLogEntry,
  GetAbandonQuestItems                  = GetAbandonQuestItems,
  GetQuestLogSelection                  = GetQuestLogSelection,
  QuestLog_OpenToQuest                  = QuestLog_OpenToQuest,
  QuestLogControlPanel_UpdateState      = QuestLogControlPanel_UpdateState,

  -- Achievement
  GetAchievementLink                    = GetAchievementLink,
  RemoveTrackedAchievement              = RemoveTrackedAchievement,

  -- Helper 
  ShowHelperWindow                      = API.ShowHelperWindow
}
-- ========================================================================= --
local HELPER_QUEST_TYPE = "quest"
local HELPER_ACHIEVEMENT_TYPE = "achievement"
-- ========================================================================= --
-- Quest Pattern
-- ========================================================================= --
do
  local questPattern = ContextMenuPattern()
  RegisterContextMenuPattern("quest", questPattern)

  -- The link to chat part 
  local linkToChat = ContextMenuPatternItemInfo()
  linkToChat.id   = "link-quest-to-chat"
  linkToChat.text = "Link to chat"
  linkToChat.order = 20
  linkToChat.icon = { atlas = AtlasType("communities-icon-chat")}
  linkToChat.handler = function(questID, questLogIndex) ChatFrame_OpenChat(GetQuestLink(questID)) end
  questPattern:AddAction(linkToChat)

  -- The show details part
  local showDetails = ContextMenuPatternItemInfo()
  showDetails.id = "show-quest-details"
  showDetails.text = "Show details"
  showDetails.order = 30
  showDetails.icon = { atlas = AtlasType("adventureguide-icon-whatsnew")}
  showDetails.handler = function(questID)
    local questLogIndex = GetQuestLogIndexByID(questID)

     QuestLog_OpenToQuest(questLogIndex)
     QuestLogControlPanel_UpdateState()
  end
  questPattern:AddAction(showDetails)

  -- Add Separator 
  questPattern:AddSeparator(35)

  -- The unwatch quest part 
  local stopWatching = ContextMenuPatternItemInfo()
  stopWatching.id = "stop-watching-quest"
  stopWatching.text = "Stop watching"
  stopWatching.order = 50
  stopWatching.icon = { atlas = AtlasType("transmog-icon-hidden") }
  stopWatching.handler = function(questID) 
    local questLogIndex = GetQuestLogIndexByID(questID)

    RemoveQuestWatch(questLogIndex) 
    WatchFrame_Update()
    QuestLog_Update()
  end
  questPattern:AddAction(stopWatching)

  -- The abandon quest part
  local abandon = ContextMenuPatternItemInfo()
  abandon.id = "abandon-quest"
  abandon.text = "Abandon"
  abandon.order = 60
  abandon.icon = { atlas = AtlasType("transmog-icon-remove") }
  abandon.handler = function(questID)
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
  questPattern:AddAction(abandon)

  -- Add Separator 
  questPattern:AddSeparator(65)

  --- The help part
  local help = ContextMenuPatternItemInfo()
  help.id = "help-quest"
  help.text = "Help"
  help.order = 70
  help.icon = { atlas = AtlasType("QuestTurnin") }
  help.handler = function(questID) ShowHelperWindow(HELPER_QUEST_TYPE, questID) end 
  questPattern:AddAction(help)
end
-- ========================================================================= --
-- Achievement Pattern
-- ========================================================================= --
do
  local achievementPattern = ContextMenuPattern()
  RegisterContextMenuPattern("achievement", achievementPattern)

  -- The link to chat part 
  local linkToChat = ContextMenuPatternItemInfo()
  linkToChat.id   = "link-achievement-to-chat"
  linkToChat.text = "Link to chat"
  linkToChat.order = 10
  linkToChat.icon = { atlas = AtlasType("communities-icon-chat")}
  linkToChat.handler = function(achievementID)  
    local achievementLink = GetAchievementLink(achievementID);
		if achievementLink then
			ChatFrame_OpenChat(achievementLink);
		end
  end
  achievementPattern:AddAction(linkToChat)

  -- The show details part
  local showDetails = ContextMenuPatternItemInfo()
  showDetails.id = "show-achievement-details"
  showDetails.text = "Show details"
  showDetails.order = 20
  showDetails.icon = { atlas = AtlasType("adventureguide-icon-whatsnew")}
  showDetails.handler = function(achievementID) 
    if not AchievementFrame then
      AchievementFrame_LoadUI()
    end
    if not AchievementFrame:IsShown() then
      AchievementFrame_ToggleAchievementFrame()
    end
    AchievementFrame_SelectAchievement(achievementID)
  end
  achievementPattern:AddAction(showDetails)

  -- Add Separator
  achievementPattern:AddSeparator(25)
  
  -- The unwatch quest part 
  local stopWatching = ContextMenuPatternItemInfo()
  stopWatching.id = "stop-watching-achievement"
  stopWatching.text = "Stop watching"
  stopWatching.order = 30
  stopWatching.icon = { atlas = AtlasType("transmog-icon-hidden") }
  stopWatching.handler = function(achievementID)
    RemoveTrackedAchievement(achievementID)
  end
  achievementPattern:AddAction(stopWatching)

  -- Add Separator
  achievementPattern:AddSeparator(35)

  --- The help part
  local help = ContextMenuPatternItemInfo()
  help.id = "help-achievement"
  help.text = "Help"
  help.order = 40
  help.icon = { atlas = AtlasType("QuestTurnin") }
  help.handler = function(achievementID) ShowHelperWindow(HELPER_ACHIEVEMENT_TYPE, achievementID) end
  achievementPattern:AddAction(help)
end 
