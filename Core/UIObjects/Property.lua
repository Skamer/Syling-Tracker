-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                     "SylingTracker.Core.Property"                     ""
-- ========================================================================= --
local EXCLUDE_FROM_AUTO_HEIGHT = {}

UI.Property         {
  name              = "ExcludeFromAutoHeight",
  type              = Boolean,
  require           = { LayoutFrame },
  default           = false,
  get               = function(self) return EXCLUDE_FROM_AUTO_HEIGHT[self] and true or false end, 
  set               = function(self, value) EXCLUDE_FROM_AUTO_HEIGHT[self] = value end
}