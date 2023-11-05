-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                  "SylingTracker.Utils.String"                         ""
-- ========================================================================= --
__Static__() function Utils.ExecStringFunction(func, ...)
  func = "return" .. " " .. func 

  local result, err = System.Toolset.loadsnippet(func)

  if result then 
    return true, result()(...)
  end

  return false, err
end