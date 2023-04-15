-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                   "SylingTracker.Utils.NavTable"                      ""
-- ========================================================================= --

--- Helper for combinining the paths
local combinePaths = setmetatable({ [0] = function(...) return ... end }, { __index = function(self, cnt)
    local args = List(cnt, "i=>'a['.. i .. ']'"):Join(",")
    local def  = [[ return function(a, ...) return ]] .. args .. [[, ... end]]
    local func = Toolset.loadsnippet(def)()
    rawset(self, cnt, func)
    return func
  end 
})

class "NavTable" (function(_ENV)
  ID_SEPARATOR_CHAR = "/"

  -----------------------------------------------------------------------------
  --                         Private Methods                                 --
  -----------------------------------------------------------------------------
  function private__PostEndProcess(self)
    wipe(self.__path)
    self.__pathId = ""
    self.__explicitPath = false
  end

  __Arguments__ { String + Number }
  function private__GetTableFromCache(self, id)
    local alreadyFetched = self.__cacheTablesIDFetched[id] or false 
    if not alreadyFetched then 
      self.__cacheTablesIDFetched[id] = true 
    end

    return self.__cacheTables[id], alreadyFetched
  end

  __Arguments__ { String + Number, Table/nil }
  function private__PutTableIntoCache(self, id, t)
    self.__cacheTables[id] = t
  end

  __Arguments__ { String + Number, Boolean/true}
  function private__InvalidateCache(self, index, includeChildren)
    local cacheId = self.__pathId == "" and index or self.__pathId .. ID_SEPARATOR_CHAR .. index 
    self.__cacheTablesIDFetched[cacheId] = nil 
    self.__cacheTables[cacheId] = nil

    cacheId = cacheId .. ID_SEPARATOR_CHAR

    if includeChildren then 
      for k in pairs(self.__cacheTables) do 
        if string.find(k, cacheId) then 
          self.__cacheTables[k] = nil
          self.__cacheTablesIDFetched[k] = nil
        end
      end
    end
  end

  __Arguments__{ String + Number, (String + Number)/nil }
  function private__CreateCacheId(self, path, prefix)
    if not prefix or prefix == "" then 
      return path
    end

    return prefix .. ID_SEPARATOR_CHAR .. path 
  end

  __Arguments__ { (String + Number) * 0}
  function private__AbsPath(self, ...)
    for i = 1, select("#", ...) do 
      local value = select(i, ...)
      if i == 1 then 
        self.__pathId = value 
      else
        self.__pathId = self.__pathId .. ID_SEPARATOR_CHAR .. value
      end
      
      tinsert(self.__path, value)
    end

    return self
  end

  __Arguments__{ (String + Number) * 0}
  function private__Path(self, ...)
    if #self.__basePath > 0 then 
      return self:private__AbsPath(combinePaths[#self.__basePath](self.__basePath, ...))
    end

    return self:private__AbsPath(...)
  end

  function private__ImplicitPath(self)
    if self.__explicitPath then 
      return 
    end

    local defaultPathCount = #self.__defaultPath
    if defaultPathCount > 0 then
      self:private__Path(unpack(self.__defaultPath))
      return 
    end

    self:private__Path()
  end

  __Arguments__ { String + Number }
  function private__GetValue(self, index)
    if self.__pathId == "" then 
      return self.Data[index]
    end
    
    -- We use the cache for trying to speed up the things 
    local cacheId = self:private__CreateCacheId(self.__pathId)
    local cache, alreadyFetched = self:private__GetTableFromCache(cacheId)

    if cache then
      return cache[index]
    end

    -- If the cache is nil, and it's has been previously fetch, don't need 
    -- to continue because the path not exists, so the value in all case is nil 
    if alreadyFetched then 
      return 
    end

    -- If we here, we need to iterate the table for trying to get the value 
    -- We take also the opportunity for building the cache for each table iterated
    local currentTable = self.Data
    local currentCacheId = ""
    
    for i, k in ipairs(self.__path) do 
      local t = currentTable[k]
      -- We stop if the table not exists, as SetValue not creates the path 
      if not t then 
        return 
      end

      currentCacheId = self:private__CreateCacheId(k, currentCacheId)

      self:private__PutTableIntoCache(currentCacheId, t)

      currentTable = t 
    end

    return currentTable[index]
  end

  __Arguments__ { String + Number, Any/nil }
  function private__SetValue(self, index, value)
    if self.__pathId == "" then 
      self.Data[index] = value 
      return 
    end

    -- We use the cache for trying to speed up the things 
    local cacheId = self:private__CreateCacheId(self.__pathId)
    local cache, alreadyFetched = self:private__GetTableFromCache(cacheId)

    if cache then 
      -- We check if need to invalidate the cache for paths if the previous value
      -- is a table
      if value == nil and type(cache[index]) == "table" then 
        self:private__InvalidateCache(index)
      end

      cache[index] = value
      return 
    end

    -- If the cache is nil, and it's has been previously fetch, don't need 
    -- to continue because the path not exists
    if alreadyFetched then 
      return 
    end

    -- If we here, we need to iterate the table for trying to get the value 
    -- We take also the opportunity for building the cache for each table iterated
    local currentTable = self.Data
    local currentCacheId = ""

    for i, k in ipairs(self.__path) do 
      local t = currentTable[k]
      -- We stop if the table not exists, as SetValue not creates the path 
      if not t then 
        return 
      end

      currentCacheId = self:private__CreateCacheId(k, currentCacheId)

      self:private__PutTableIntoCache(currentCacheId, t)

      currentTable = t 
    end

    -- We check if need to invalidate the cache for paths if the previous value
    -- is a table
    if value == nil and type(currentTable[index]) == "table" then 
      self:private__InvalidateCache(index)
    end


    currentTable[index] = value 
  end

  __Arguments__ { String + Number, Any/nil }
  function private__SaveValue(self, index, value)
    if self.__pathId == "" then 
      self.Data[index] = value 
      return 
    end

    -- We use the cache for trying to speed up the things 
    local cacheId = self:private__CreateCacheId(self.__pathId)
    local cache, alreadyFetched = self:private__GetTableFromCache(cacheId)

    if cache then
      -- We check if need to invalidate the cache for paths if the previous value
      -- is a table
      if value == nil and type(cache[index]) == "table" then 
        self:private__InvalidateCache(index)
      end

      cache[index] = value
      return 
    end

    -- If the cache is nil, and it's has been previously fetch, don't need 
    -- to continue because the path not exists
    if alreadyFetched then 
      return 
    end

    -- If we here, we need to iterate the table for trying to get the value 
    -- We take also the opportunity for building the cache for each table iterated
    local currentTable = self.Data
    local currentCacheId = ""

    for i, k in ipairs(self.__path) do 
      local t = currentTable[k]
      -- We create the path if not exists
      if not t then
        t = {}
        currentTable[k] = t
      end

      currentCacheId = self:private__CreateCacheId(k, currentCacheId)

      self:private__PutTableIntoCache(currentCacheId, t)

      currentTable = t 
    end

    -- We check if need to invalidate the cache for paths if the previous value
    -- is a table
    if value == nil and type(currentTable[index]) == "table" then 
      self:private__InvalidateCache(index)
    end

    currentTable[index] = value 
  end
  -----------------------------------------------------------------------------
  --                          Public Methods                                 --
  -----------------------------------------------------------------------------
  __Arguments__ { (String + Number) * 0}
  function Path(self, ...)
    self.__explicitPath = true 
    return self:private__Path(...)
  end

  __Arguments__{ (String + Number) * 0 }
  function AbsPath(self, ...)
    self.__explicitPath = true 
    return self:private__AbsPath()
  end

  __Arguments__ { String * 0 }
  function SetDefaultPath(self, ...)
    wipe(self.__defaultPath)

    for i = 1, select("#", ...) do 
      local value = select(i, ...)
      tinsert(self.__defaultPath, value)
    end
  end

  __Arguments__ { (String + Number) * 0 }
  function SetBasePath(self, ...)
    wipe(self.__basePath)

    for i = 1, select("#", ...) do 
      local value = select(i, ...)
      tinsert(self.__basePath, value)
    end
  end

  --- Gethe value for an index in the current path. 
  --- @see also 'Path', 'SetDefaultPath' and 'SetBasePath' for changing the path.
  ---
  --- @param index the index value to get
  __Arguments__ { String + Number }
  function GetValue(self, index)
    -- We call it in case where 'Path' has been called, and SetDefaultPath or 
    -- SetBasePath has been used. 
    -- It does nothing if "Path" or "AbsPath" has been used for this current operation.
    self:private__ImplicitPath()
    
    local value = self:private__GetValue(index)

    self:private__PostEndProcess()

    return value
  end

  --- Set the value for an index in the current path.
  --- Take note this does nothing if the current path not exists. 
  --- if you want setting a value in all case, use 'SaveValue' instead. 
  --- @see also 'Path', 'SetDefaultPath' and 'SetBasePath' for changing the path.
  ---
  --- @param index the index where the value will be set.
  --- @param value the value will be set.
  __Arguments__ { String + Number, Any/nil }
  function SetValue(self, index, value)
    -- We call it in case where 'Path' has been called, and 'SetDefaultPath' or 
    -- 'SetBasePath' has been used.
    -- it does nothing if 'Path' or 'AbsPath' has been used for this current operation.
    self:private__ImplicitPath()

    self:private__SetValue(index, value)

    self:private__PostEndProcess()
  end

  --- Save the value for an index in the current path. In case where this one not 
  --- exists, this will be created. 
  --- If you want setting the value only if the path exists, use 'SetValue' instead.
  --- @see also 'Path', 'SetDefaultPath' and 'SetBasePath' for changing the path. 
  ---
  --- @param index the index where the value will be saved 
  --- @param value the value will be saved 
  __Arguments__ { String + Number, Any/nil }
  function SaveValue(self, index, value)
    -- We call it in case where 'Path' has been called, and 'SetDefaultPath' or 
    -- 'SetBasePath' has been used.
    -- it does nothing if 'Path' or 'AbsPath' has been used for this current operation.
    self:private__ImplicitPath()

    self:private__SaveValue(index, value)

    self:private__PostEndProcess()
  end

  function ClearData(self)
    wipe(self.Data)

    wipe(self.__cacheTables)
    wipe(self.__cacheTablesIDFetched)
  end

  function GetData(self)
    return self.Data
  end
  -----------------------------------------------------------------------------
  --                             MetaMethods                                 --
  -----------------------------------------------------------------------------
  -- function __index(self, index)
  --   return self.Data[index]
  -- end

  -- function __newindex(self, key, value)
  --   self.Data[key] = value
  -- end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  property "Data" {
    type = Table,
    default = function() return {} end 
  }
  -----------------------------------------------------------------------------
  --                            Constructors                                 --
  -----------------------------------------------------------------------------
  function __ctor(self)
    self.__pathId                 = ""
    
    -- Modifiers
    self.__path                   = {}
    self.__explicitPath           = false 
    self.__defaultPath            = {}
    self.__basePath               = {}

    -- Caching 
    self.__cacheTables            = System.Toolset.newtable(false, true)
    self.__cacheTablesIDFetched   = {}
  end
end)


function OnLoad(self)
  print("OnLoad NavTable", Utils.GetAddonVersion, GetAddonVersion)
end
