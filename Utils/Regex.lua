-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                  "SylingTracker.Utils.Regex"                          ""
-- ========================================================================= --

__Arguments__ { String }
__Static__() function Utils.EscapeSpecialRegexCharacter(str)
 return str:gsub("[%(%)%.%%%+%-%*%?%[%]%^%$]", "%%%1")
end