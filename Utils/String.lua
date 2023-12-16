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
__Arguments__ { String, Any * 0 }
function ExecStringFunction(func, ...)
  func = "return" .. " " .. func 

  local result, err = System.Toolset.loadsnippet(func, "SylingTracker Snippet", getfenv(1))

  if result then 
    return true, result()(...)
  end

  return false, err
end

__Arguments__ { String }
function GetFunctionFromString(func)
  func = "return" .. " " .. func 

  local result, err = System.Toolset.loadsnippet(func, "SylingTracker Snippet", getfenv(1))

  if result then 
    return true, result()
  end 

  return false, err
end

-- Export Utils functions 
Utils.ExecStringFunction              = ExecStringFunction