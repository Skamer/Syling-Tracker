-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Scorpio                 "SylingTracker.ContextMenuPatterns"                  ""
-- ========================================================================= --
import                          "SLT"
-- ========================================================================= --
RegisterContextMenuPattern = API.RegisterContextMenuPattern

--- Simple fix registers the pattern of all content type

-------------------------------------------------------------------------------
-- Quest Pattern                                                             --
-------------------------------------------------------------------------------
do
  local SetSuperTrackedQuestID = SetSuperTrackedQuestID
  local QuestSuperTracking_ChooseClosestQuest = QuestSuperTracking_ChooseClosestQuest
  local GetQuestLink = GetQuestLink
  local ChatFrame_OpenChat = ChatFrame_OpenChat
  local GetQuestLogIndexByID = GetQuestLogIndexByID
  local IsQuestComplete = IsQuestComplete
  local GetQuestLogIsAutoComplete = GetQuestLogIsAutoComplete
  local QuestLogPopupDetailFrame_Show = QuestLogPopupDetailFrame_Show
  local ShowQuestComplete = ShowQuestComplete
  local LFGListUtil_FindQuestGroup = LFGListUtil_FindQuestGroup
  local RemoveQuestWatch = RemoveQuestWatch
  local QuestMapQuestOptions_AbandonQuest = QuestMapQuestOptions_AbandonQuest


  local questPattern = ContextMenuPattern()
  RegisterContextMenuPattern("quest", questPattern)

  -- The supertracking part
  local supertrack = ContextMenuPatternItemInfo()
  supertrack.id = "supertrack-quest"
  supertrack.text = "Supertrack"
  supertrack.order = 10
  supertrack.icon = { atlas = AtlasType("Target-Tracker")}
  supertrack.handler = function(questID) SetSuperTrackedQuestID(questID) end
  questPattern:AddAction(supertrack)
  -- TODO: supertrack.isShown = function() end

  local stopSupertracking = ContextMenuPatternItemInfo()
  stopSupertracking.id = "stop-supertracking-quest"
  stopSupertracking.text = "Stop supertracking"
  stopSupertracking.order = 10
  supertrack.icon = { atlas = AtlasType("Target-Tracker")}
  stopSupertracking.handler = function() 
    SetSuperTrackedQuestID(0)
    QuestSuperTracking_ChooseClosestQuest()
  end
  
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
      local questLogIndex = GetQuestLogIndexByID(questID)
      if IsQuestComplete(questID) and GetQuestLogIsAutoComplete(questLogIndex) then
        ShowQuestComplete(questLogIndex)
      else
        QuestLogPopupDetailFrame_Show(questLogIndex)
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
  stopWatching.handler = function(questID)
    print(questID)
    local questLogIndex = GetQuestLogIndexByID(questID)
    RemoveQuestWatch(questLogIndex)
  end
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
  help.handler = function(questID)  
    -- TODO: Implement the help action
  end 
  questPattern:AddAction(help)
end
-------------------------------------------------------------------------------
-- Achievement Pattern                                                       --
-------------------------------------------------------------------------------
do
  local achievementPattern = ContextMenuPattern()
  RegisterContextMenuPattern("achievement", achievementPattern)

  -- The link to chat part 
  local linkToChat = ContextMenuPatternItemInfo()
  linkToChat.id   = "link-achievement-to-chat"
  linkToChat.text = "Link to chat"
  linkToChat.order = 10
  linkToChat.icon = { atlas = AtlasType("communities-icon-chat")}
  linkToChat.handler = function(achievementID)  end
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
  end
  achievementPattern:AddAction(stopWatching)
end 