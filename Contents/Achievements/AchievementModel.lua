-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                  "SylingTracker.Models.AchievementModel"              ""
-- ========================================================================= --
namespace                          "SLT"
-- ========================================================================= --
class "AchievementModel" (function(_ENV)
  inherit "Model"

  __Arguments__ { Number, Table }
  function SetAchievementData(self, achievementID, data)
    self:SetData(data, "achievements", achievementID)
  end

  __Arguments__ { Number, Table }
  function AddAchievementData(self, achievementID, data)
    self:AddData(data, "achievements", achievementID)
  end
  
  __Arguments__ { Table }
  function SetAchievementsData(self, data)
    self:SetData(data, "achievements")
  end

  __Arguments__  { Table }
  function AddAchievementsData(self, data)
    self:AddData(data, "achievements")
  end
  
  __Arguments__ { Number }
  function RemoveAchievementData(self, achievementID)
    self:RemoveData("achievements", achievementID)
  end
end)