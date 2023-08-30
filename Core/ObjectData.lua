-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                   "SylingTracker.Core.ObjectData"                     ""
-- ========================================================================= --
__Recyclable__()
class "ObjectData" (function(_ENV)
  extend "IObjectData"

  function OnRelease(self)
    if self.ResetDataProperties then 
      self:ResetDataProperties() 
    end
  end
end)