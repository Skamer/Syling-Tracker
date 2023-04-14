-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                  "SylingTracker.External._DebugLog"                   ""
-- ========================================================================= --
--- Add the support of the addon _DebugLog for gathering the logs created by 
--- SylingTracker.
--- It's optional and intented for helping the debug process. 
---
--- _DebugLog URL: https://www.curseforge.com/wow/addons/debuglog
local AceAddon = LibStub("AceAddon-3.0")
local _DebugLog = AceAddon and AceAddon:GetAddon("_DebugLog")
local _DebugLogGUI = _DebugLog and _DebugLog:GetModule("GUI")

if _DebugLog and _DebugLogGUI and DLAPI then

  local logFormatter = {}
  logFormatter.colNames = { "id", "Time", "Category", "Level", "Message"}
  logFormatter.colWidth = { 0.05, 0.12, 0.15, 0.1, 1 - 0.1 - 0.12 - 0.15 -0.1 }
  logFormatter.colFlex = { "flex", "flex", "drop", "drop", "search"}
  logFormatter.statusText = {
    "Sort by id",
    "Sort by Time",
    "Sort by Category",
    "Sort by Level",
    "Sort by Message"
  }

  logFormatter.GetSTData = function(a, flex, filter)

    if not _DebugLogGUI.display or _DebugLogGUI.view ~= a then 
      return 
    end

    local content = {}

	  -- generate content only if log data present
    _DebugLog.debuglog = _DebugLog.debuglog or {}

    if not _DebugLog.debuglog[a] then 
      return content, flex
    end

    -- generate content 
    local colHasContent = {}
    local k = 1

    for _, rdata in pairs(_DebugLog.debuglog[a]) do 
      local filterMatch = nil 

      local data = {}
      data[2] = rdata.t -- represent timestamp 
      data[3] = nil -- represent category 
      data[4] = "Info" -- represent the level (default: Info)
      data[5] = rdata.m or "" -- reprsent the message

      local q = "ffffff"

      local flag = strmatch(data[5], "^([^~]+)~")
      while flag do 
        data[5] = strmatch(data[5], "^[^~]+~(.*)$")

        if strmatch(flag, "^(TRACE)") then 
          q = "a9a9a9"
          data[4] = "|cffa9a9a9Trace|r"
        elseif strmatch(flag, "^(DEBUG)") then 
          q = "5f76c4"
          data[4] = "|cff5f76c4Debug|r"
        elseif strmatch(flag, "^(INFO)") then 
          q = "ffffff"
          data[4] = "Info"
        elseif strmatch(flag, "^(WARN)") then 
          q = "ffc300"
          data[4] = "|cffffc300Warn|r"
        elseif strmatch(flag, "^(ERROR)") then 
          q = "e30000"
          data[4] = "|cffe30000Error|r"
        elseif strmatch(flag, "^(FATAL)") then 
          q = "8b0000"
          data[4] = "|cff8b0000Fatal|r"
        elseif strmatch(flag, "^(.+)") then
          data[3] = flag
        end
        flag = strmatch(data[5], "^([^~]+)~")
      end
      
      -- check dropdown
      for j, col in ipairs(flex) do
        colHasContent[j] = colHasContent[j] or data[j]
        if col == "drop" then
          if filter and filter[j] and filter[j] ~= "" then
            if (filterMatch == nil or filterMatch) then
              if data[j] and filter[j] == data[j] then
                filterMatch = true
              else
                filterMatch = false
              end
            end
          end
        end
      end
  
      -- check search
      for j, col in ipairs(flex) do
        if col == "search" then
          if filter and filter[j] and filter[j] ~= "" then
            if (filterMatch == nil or filterMatch) then
              -- search in all column data
              local found = false
              for m, _ in pairs(data) do
                if data[m] and type(data[m]) == "string" and strfind(strlower(data[m]), strlower(filter[j])) then
                  filterMatch = true
                  found = true
                end
               end
              if not found then
                filterMatch = false
              end
            end
          end
        end
      end
      
      if filterMatch or filterMatch == nil then
        data[5] = data[5] .. "\n"
        data[5]:gsub("([^\n]*)\n",
          function(j)
            local en = {}
            en.data = {}
  
            en.data[1] = {k, k}
            en.data[2] = {DLAPI.TimeToString(data[2]), data[2]}
            en.data[3] = {data[3], data[3] or ""}
            en.data[4] = {data[4], data[4] or ""}
            en.data[5] = {"|cff" .. q .. j .. "|r", j}
            tinsert(content, en)
            k = k + 1
          end
        )
      end
    end

    -- disable dropdown if not present
    for j, col in ipairs(flex) do
      if col == "drop" and not colHasContent[j] then
        flex[j] = ""
      end
    end
    
    return content, flex
  end

  -- Register the format as "syling"
  DLAPI.RegisterFormat("syling", logFormatter)

  -- We say to _DebugLog using our custom format for SylingTracker
  DLAPI.SetFormat("SylingTracker", "syling")


  --- Event triggered when SylingTracker does a log 
  --- @param level the log level ('TRACE', 'DEBUG', 'INFO', 'WARN', 'ERROR' or 'FATAL')
  --- @param message the log message 
  --- @param ... the args to give if using the format syntax 
  __SystemEvent__() 
  function SylingTracker_LOG(level, category, message, ...)
    if category then
      DLAPI.DebugLog("SylingTracker", level .. "~" .. category .. "~" .. message, ...)
    else
      DLAPI.DebugLog("SylingTracker", level .. "~" .. message, ...)
    end
  end
end