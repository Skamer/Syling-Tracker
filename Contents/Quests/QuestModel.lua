-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling               "SylingTracker.Models.QuestModel"                      ""
-- ========================================================================= --
namespace                          "SLT"
-- ========================================================================= --
class "QuestModel" (function(_ENV)
  inherit "Model"

  __Arguments__ { Number, Table }
  function SetQuestData(self, questID, data)
    self:SetData(data, "quests", questID)
  end
  
  __Arguments__ { Number, Table }
  function AddQuestData(self, questID, data)
    self:AddData(data, "quests", questID)
  end

  __Arguments__ { Table }
  function SetQuestsData(self, data)
    self:SetData(data, "quests")
  end

  __Arguments__ { Table }
  function AddQuestsData(self, data)
    self:AddData(data, "quests")
  end

  __Arguments__ { Number }
  function RemoveQuestData(self, questID)
    self:RemoveData("quests", questID)
  end
end)
