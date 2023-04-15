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
  GetQuestTagInfo = C_QuestLog.GetQuestTagInfo,
  EnumQuestTag = _G.Enum.QuestTag
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