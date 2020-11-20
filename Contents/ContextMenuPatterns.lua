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
  
  -- Quest
  IsWorldQuest                          = QuestUtils_IsQuestWorldQuest,
  GetSuperTrackedQuestID                = C_SuperTrack.GetSuperTrackedQuestID,
  SetSuperTrackedQuestID                = C_SuperTrack.SetSuperTrackedQuestID,
  QuestSuperTracking_ChooseClosestQuest = QuestSuperTracking_ChooseClosestQuest,
  GetQuestLink                          = GetQuestLink,
  QuestLogPopupDetailFrame_Show         = QuestLogPopupDetailFrame_Show,
  ShowQuestComplete                     = ShowQuestComplete,
  LFGListUtil_FindQuestGroup            = LFGListUtil_FindQuestGroup,
  RemoveQuestWatch                      = C_QuestLog.RemoveQuestWatch,
  QuestMapQuestOptions_AbandonQuest     = QuestMapQuestOptions_AbandonQuest,

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

  -- The supertracking part
  local supertrack = ContextMenuPatternItemInfo()
  supertrack.id = "supertrack-quest"
  supertrack.text = "Supertrack"
  supertrack.order = 10
  supertrack.icon = { atlas = AtlasType("Target-Tracker")}
  supertrack.isShown = function(questID)
    local supertrackQuestID = GetSuperTrackedQuestID()
    if supertrackQuestID and supertrackQuestID == questID then 
      return false 
    end 

    return true 
  end 
  supertrack.handler = function(questID) SetSuperTrackedQuestID(questID) end
  questPattern:AddAction(supertrack)

  local stopSupertracking = ContextMenuPatternItemInfo()
  stopSupertracking.id = "stop-supertracking-quest"
  stopSupertracking.text = "Stop supertracking"
  stopSupertracking.order = 10
  stopSupertracking.icon = { atlas = AtlasType("Target-Tracker")}
  stopSupertracking.isShown = function(questID)
    local supertrackQuestID = GetSuperTrackedQuestID()
    if supertrackQuestID and supertrackQuestID == questID then 
      return true 
    end 

    return false 
  end
  stopSupertracking.handler = function() 
    SetSuperTrackedQuestID(0)
    QuestSuperTracking_ChooseClosestQuest()
  end
  questPattern:AddAction(stopSupertracking)
  
  -- Add Separator 
  questPattern:AddSeparator(15)

  -- The link to chat part 
  local linkToChat = ContextMenuPatternItemInfo()
  linkToChat.id   = "link-quest-to-chat"
  linkToChat.text = "Link to chat"
  linkToChat.order = 20
  linkToChat.icon = { atlas = AtlasType("communities-icon-chat")}
  linkToChat.handler = function(questID) ChatFrame_OpenChat(GetQuestLink(questID)) end
  questPattern:AddAction(linkToChat)

  -- The show details part
  local showDetails = ContextMenuPatternItemInfo()
  showDetails.id = "show-quest-details"
  showDetails.text = "Show details"
  showDetails.order = 30
  showDetails.icon = { atlas = AtlasType("adventureguide-icon-whatsnew")}
  showDetails.handler = function(questID)
      local quest = QuestCache:Get(questID)
      if quest.isAutoComplete and quest:IsComplete() then 
        ShowQuestComplete(questID)
      else 
        QuestLogPopupDetailFrame_Show(quest:GetQuestLogIndex())
      end
  end
  questPattern:AddAction(showDetails)

  -- Add Separator 
  questPattern:AddSeparator(35)

  -- The find a group part
  local findAGroup = ContextMenuPatternItemInfo()
  findAGroup.id = "find-a-group"
  findAGroup.text = "Find a group"
  findAGroup.order = 40
  findAGroup.icon = { atlas = AtlasType("socialqueuing-icon-group")}
  findAGroup.handler = function(questID) LFGListUtil_FindQuestGroup(questID) end

  questPattern:AddAction(findAGroup)

  -- Add Separator 
  questPattern:AddSeparator(45)

  -- The unwatch quest part 
  local stopWatching = ContextMenuPatternItemInfo()
  stopWatching.id = "stop-watching-quest"
  stopWatching.text = "Stop watching"
  stopWatching.order = 50
  stopWatching.icon = { atlas = AtlasType("transmog-icon-hidden") }
  stopWatching.handler = function(questID) RemoveQuestWatch(questID) end
  questPattern:AddAction(stopWatching)

  -- The abandon quest part
  local abandon = ContextMenuPatternItemInfo()
  abandon.id = "abandon-quest"
  abandon.text = "Abandon"
  abandon.order = 60
  abandon.icon = { atlas = AtlasType("transmog-icon-remove") }
  abandon.handler = function(questID) QuestMapQuestOptions_AbandonQuest(questID) end 
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
-- World Quest Pattern
-- ========================================================================= --
do
  local worldQuestPattern = ContextMenuPattern()
  RegisterContextMenuPattern("world-quest", worldQuestPattern)

  -- The link to chat part 
  local linkToChat = ContextMenuPatternItemInfo()
  linkToChat.id   = "link-quest-to-chat"
  linkToChat.text = "Link to chat"
  linkToChat.order = 10
  linkToChat.icon = { atlas = AtlasType("communities-icon-chat")}
  linkToChat.handler = function(questID) ChatFrame_OpenChat(GetQuestLink(questID)) end
  worldQuestPattern:AddAction(linkToChat)

  -- The show details part
  local showDetails = ContextMenuPatternItemInfo()
  showDetails.id = "show-quest-details"
  showDetails.text = "Show details"
  showDetails.order = 20
  showDetails.icon = { atlas = AtlasType("adventureguide-icon-whatsnew")}
  showDetails.handler = function(questID)
      local quest = QuestCache:Get(questID)
      if quest.isAutoComplete and quest:IsComplete() then 
        ShowQuestComplete(questID)
      else 
        QuestLogPopupDetailFrame_Show(quest:GetQuestLogIndex())
      end
  end
  worldQuestPattern:AddAction(showDetails)

  -- Add Separator 
  worldQuestPattern:AddSeparator(25)

  -- The find a group part
  local findAGroup = ContextMenuPatternItemInfo()
  findAGroup.id = "find-a-group"
  findAGroup.text = "Find a group"
  findAGroup.order = 30
  findAGroup.icon = { atlas = AtlasType("socialqueuing-icon-group")}
  findAGroup.handler = function(questID) LFGListUtil_FindQuestGroup(questID) end

  worldQuestPattern:AddAction(findAGroup)

  -- Add Separator 
  worldQuestPattern:AddSeparator(35)

  --- The help part
  local help = ContextMenuPatternItemInfo()
  help.id = "help-quest"
  help.text = "Help"
  help.order = 40
  help.icon = { atlas = AtlasType("QuestTurnin") }
  help.handler = function(questID) ShowHelperWindow(HELPER_QUEST_TYPE, questID) end
  worldQuestPattern:AddAction(help)
end

-- ========================================================================= --
-- World Quest Pattern
-- ========================================================================= --
do
  local taskPattern = ContextMenuPattern()
  RegisterContextMenuPattern("task", taskPattern)

  -- The link to chat part 
  local linkToChat = ContextMenuPatternItemInfo()
  linkToChat.id   = "link-quest-to-chat"
  linkToChat.text = "Link to chat"
  linkToChat.order = 10
  linkToChat.icon = { atlas = AtlasType("communities-icon-chat")}
  linkToChat.handler = function(questID) ChatFrame_OpenChat(GetQuestLink(questID)) end
  taskPattern:AddAction(linkToChat)

  -- The show details part
  local showDetails = ContextMenuPatternItemInfo()
  showDetails.id = "show-quest-details"
  showDetails.text = "Show details"
  showDetails.order = 20
  showDetails.icon = { atlas = AtlasType("adventureguide-icon-whatsnew")}
  showDetails.handler = function(questID)
      local quest = QuestCache:Get(questID)
      if quest.isAutoComplete and quest:IsComplete() then 
        ShowQuestComplete(questID)
      else 
        QuestLogPopupDetailFrame_Show(quest:GetQuestLogIndex())
      end
  end
  taskPattern:AddAction(showDetails)

  -- Add Separator 
  taskPattern:AddSeparator(25)

  -- The find a group part
  local findAGroup = ContextMenuPatternItemInfo()
  findAGroup.id = "find-a-group"
  findAGroup.text = "Find a group"
  findAGroup.order = 30
  findAGroup.icon = { atlas = AtlasType("socialqueuing-icon-group")}
  findAGroup.handler = function(questID) LFGListUtil_FindQuestGroup(questID) end

  taskPattern:AddAction(findAGroup)

  -- Add Separator 
  taskPattern:AddSeparator(35)

  --- The help part
  local help = ContextMenuPatternItemInfo()
  help.id = "help-quest"
  help.text = "Help"
  help.order = 40
  help.icon = { atlas = AtlasType("QuestTurnin") }
  help.handler = function(questID) ShowHelperWindow(HELPER_QUEST_TYPE, questID) end
  taskPattern:AddAction(help)
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
