-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                "SylingTracker.Core.SavedVariables"                    ""
-- ========================================================================= --
export {
  GetRealmName                      = GetRealmName,
  UnitName                          = UnitName
}


-- Helper fo combining the paths
local combinePaths = setmetatable({ [0] = function(...) return ... end }, { __index = function(self, cnt)
    local args = List(cnt, "i=>'a['.. i .. ']'"):Join(",")
    local def  = [[ return function(a, ...) return ]] .. args .. [[, ... end]]
    local func = Toolset.loadsnippet(def)()
    rawset(self, cnt, func)
    return func
  end 
})

class "SavedVariables" (function(_ENV)
  PATH_ID             = ""
  BASE_DB_ID          = ""
  ID_SEPARATOR_CHAR   = "/"
  PROFILES_DISABLED   = false 

  -- Modifiers 
  PATH              = {}
  EXPLICIT_PATH     = false 
  DEFAULT_PATH      = {}
  BASE_PATH         = {}
  BASE_DB           = "global"
  PROFILE           = nil 
  PROFILE_SELECTED  = nil 
  ALL               = false

  -- Caching 
  CACHE_TABLES              = System.Toolset.newtable(false, true)
  CACHE_TABLES_ID_FETCHED   = {}
  -----------------------------------------------------------------------------
  --                         Private Methods                                 --
  -----------------------------------------------------------------------------
  __Static__() function private__PostEndProcess() 
    wipe(PATH)
    PATH_ID         = ""

    EXPLICIT_PATH   = false
    RELATIVE_DB     = "global"
    PROFILE         = nil
    ALL             = false
  end

  __Static__() function private__GetRawDB() 
    return SylingTrackerDB
  end

  __Static__() function private__GetDB() 
    return _DB 
  end

  __Static__() function private__GetCharDB() 
    return _DB.Char
  end

  __Static__() function private__GetSpecDB() 
    return _DB.Char.Spec
  end

  __Static__() function private__GetBaseTable()
    -- We don't need to check if the profile has a DB as this one has been 
    -- done previously by Path
    if BASE_DB == "profile" then
      local profilesDB = private__GetDB()["__profiles"]
      local profileDB = profilesDB and profilesDB[PROFILE]
      
      if profileDB then 
        return profileDB
      end
    end

    -- We return the Global DB as fallback
    return private__GetDB()
  end

  __Arguments__ { String + Number }
  __Static__() function private__GetTableFromCache(id) 
    local alreadyFetched = CACHE_TABLES_ID_FETCHED[id] or false 
    if not alreadyFetched then 
      CACHE_TABLES_ID_FETCHED[id] = true 
    end

    return CACHE_TABLES[id], alreadyFetched
  end

  __Arguments__ { String + Number, Table/nil}
  __Static__() function private__PutTableIntoCache(id, t) 
    CACHE_TABLES[id] = t
  end

  __Arguments__ { String + Number, String + Number }
  __Static__() function private__CreateCacheId(prefix, path) 
    if path == "" then 
      return prefix
    end

    if prefix == "" then 
      return path 
    end

    return prefix .. ID_SEPARATOR_CHAR .. path
  end

  __Arguments__ { (String + Number) * 0}
  __Static__() function private__AbsPath(...)
    for i = 1, select("#", ...) do 
      local value = select(i, ...) 
      if i == 1 then 
        PATH_ID = value 
      else 
        PATH_ID = PATH_ID .. ID_SEPARATOR_CHAR .. value 
      end 

      tinsert(PATH, value)
    end

    return SavedVariables
  end

  __Arguments__ { (String + Number) * 0}
  __Static__() function private__Path(...)
    if #BASE_PATH > 0 then
      return private__AbsPath(combinePaths[#BASE_PATH](BASE_PATH, ...))
    end

    return private__AbsPath(...)
  end

  __Static__() function private__ImplicitPath()
    if EXPLICIT_PATH then 
      return 
    end

    local defaultPathCount = #DEFAULT_PATH
    if defaultPathCount > 0 then
      private__Path(unpack(DEFAULT_PATH))
      return 
    end

    private__Path()
  end

  __Arguments__ { String + Number }
  __Static__() function private__GetValue(index) 
    if PATH_ID == "" then 
      return private__GetBaseTable()[index]
    end

    -- We use the cache for trying to speed up the things 
    local cacheId = private__CreateCacheId(BASE_DB_ID, PATH_ID)
    local cache, alreadyFetched = private__GetTableFromCache(cacheId)

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
    local currentTable = private__GetBaseTable()
    local currentCacheId = ""

    for i, k in ipairs(PATH) do 
      local t = currentTable[k]
      -- We don't continue if the table not exists, so the value is nil
      if not t then 
        return 
      end 

      if i == 1 then 
        currentCacheId = private__CreateCacheId(BASE_DB_ID, k)
      else 
        currentCacheId = private__CreateCacheId(currentCacheId, k)
      end 

      private__PutTableIntoCache(currentCacheId, t)

      currentTable = t
    end

    return currentTable[index]
  end

  __Arguments__ { String + Number, Any/nil }
  __Static__() function private__SetValue(index, value)
    if PATH_ID == "" then 
      private__GetBaseTable()[index] = value
    end

    -- We use the cache for trying to speed up the things 
    local cacheId = private__CreateCacheId(BASE_DB_ID, PATH_ID)
    local cache, alreadyFetched = private__GetTableFromCache(cacheId)

    if cache then 
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
    local currentTable = private__GetBaseTable()
    local currentCacheId = ""

    for i, k in ipairs(PATH) do 
      local t = currentTable[k]
      -- We stop if the table not exists, as SetValue not create the path
      if not t then 
        return 
      end

      if i == 1 then 
        currentCacheId = private__CreateCacheId(BASE_DB_ID, k)
      else
        currentCacheId = private__CreateCacheId(currentCacheId, k)
      end

      private__PutTableIntoCache(currentCacheId, t)

      currentTable = t 
    end

    currentTable[index] = value
  end

  __Arguments__ { String + Number, Any/nil }
  __Static__() function private__SaveValue(index, value)

    if PATH_ID == "" then 
      private__GetBaseTable()[index] = value
    end

    -- We use the cache for trying to speed up the things 
    local cacheId = private__CreateCacheId(BASE_DB_ID, PATH_ID)
    local cache  = private__GetTableFromCache(cacheId)

    if cache then 
      cache[index] = value 
      return
    end

    -- If we here, we need to iterate the table for trying to get the value 
    -- We take also the opportunity for building the cache for each table iterated 
    local currentTable = private__GetBaseTable()
    local currentCacheId = ""

    for i, k in ipairs(PATH) do 
      local t = currentTable[k]
      -- We create the path if not exists
      if not t then
        t = {}
        currentTable[k] = t
      end

      if i == 1 then 
        currentCacheId = private__CreateCacheId(BASE_DB_ID, k)
      else
        currentCacheId = private__CreateCacheId(currentCacheId, k)
      end

      private__PutTableIntoCache(currentCacheId, t)

      currentTable = t 
    end

    currentTable[index] = value
  end

  __Arguments__ { Table }
  __Static__() function private__ClearEmptyTable(t)
    for k,v in pairs(t) do 
      if type(v) == "table" then 
        private__ClearEmptyTable(v)
        if next(v) == nil then 
          t[k] = nil 
        end 
      end
    end
  end
  -----------------------------------------------------------------------------
  --                          Public Methods                                 --
  -----------------------------------------------------------------------------
  __Arguments__ { String/nil }
  __Static__() function Profile(profile)
    -- Ignore if the profiles system has been disabled
    if not PROFILES_DISABLED then

      -- if the profile has been given, use the profile selected instead
      if not profile then 
        local specDB = private__GetSpecDB()
        profile = PROFILE_SELECTED
      end

      if profile and profile ~= "__global" then
        local profilesDB = private__GetDB().__profiles
        -- We need to check the profile has a DB, all profiles created have a 
        -- DB as we have a "__profile_id" during the cureation
        if profilesDB and profilesDB[profile] then 
          BASE_DB = "profile"
          BASE_DB_ID = "profiles" .. ID_SEPARATOR_CHAR .. profile
          PROFILE = profile
          return SavedVariables
        end
      end
    end

    -- We fallback to global 
    BASE_DB     = "global"
    BASE_DB_ID  = ""
    PROFILE     = nil

    return SavedVariables
  end

  __Static__() function Global() 
    BASE_DB     = "global"
    BASE_DB_ID  = ""
    PROFILE     = nil

    return SavedVariables
  end

  __Static__() function All()
    ALL = true

    return SavedVariables
  end

  __Arguments__ { (String + Number) * 0 }
  __Static__() function Path(...)
    EXPLICIT_PATH = true 
    return private__Path(...)
  end

  __Arguments__ { (String + Number) * 0}
  __Static__() function AbsPath(...)
    EXPLICIT_PATH = true 
    return private__AbsPath(...)
  end

  __Arguments__ { String * 0 }
  __Static__() function SetDefaultPath(...) 
    wipe(DEFAULT_PATH)
  
    for i = 1, select("#", ...) do 
      local value = select(i, ...)
      tinsert(DEFAULT_PATH, value)
    end
  end

  __Arguments__ { String * 0 }
  __Static__() function SetBasePath(...) 
    wipe(BASE_PATH)
  
    for i = 1, select("#", ...) do 
      local value = select(i, ...)
      tinsert(BASE_PATH, value)
    end
  end

  --- Get the value for an index in the current path.
  --- @see also Path, SetDefaultPath, and SetBasePath for changing the path.
  __Arguments__ { String + Number }
  __Static__() function GetValue(index) 
    -- We call it in case where 'Path' has been called, and SetDefaultPath or 
    -- SetBasePath has been used. 
    -- It does nothing if "Path" or "AbsPath" has been used for this current operation.
    private__ImplicitPath()

    local value = private__GetValue(index)

    private__PostEndProcess()

    return value
  end

  --- Set the value for an index for the current path.
  --- Take note this does nothing if the current path not exists. 
  --- If you want setting a value in all case, use SaveValue instead.
  --- @see also Path, SetDefaultPath, and SetBasePath for changing the path. 
  __Arguments__ { String + Number, Any/nil }
  __Static__() function SetValue(index, value)
    -- We call it in case where 'Path' has been called, and SetDefaultPath or 
    -- SetBasePath has been used. 
    -- It does nothing if "Path" or "AbsPath" has been used for this current operation.
    private__ImplicitPath()

    -- Check if the All() modifier has been used 
    if ALL then
      -- We start with global
      Global()
      private__SetValue(index, value)

      -- We save the value for all existing profiles 
      local profilesDB = private__GetDB().__profiles 
      if profilesDB then 
        for profile in pairs(profilesDB) do 
          -- We need to manually change the base db and its id before calling 
          -- private__SaveValue
          BASE_DB = "profile"
          BASE_DB_ID = "profiles" .. ID_SEPARATOR_CHAR .. profile
          PROFILE = profile
          
          private__SetValue(index, value)
        end
      end
    else 
      private__SetValue(index, value)
    end

    private__PostEndProcess()
  end

  --- Save the value for an index in the current path. In case where the path 
  --- not exists, this will create it.
  --- If you want setting the value only if the path exists, use SetValue instead.
  --- @See also Path, SetDefaultPath and SetBasePath for changing the path
  __Arguments__ { String + Number, Any/nil }
  __Static__() function SaveValue(index, value)
    --- We call it in case where 'Path' has been called, and SetDefaultPath or 
    --- SetBasePath has been used. 
    --- It does nothing if "Path" or "AbsPath" has been used for this current operation.
    private__ImplicitPath()

    --- Check if the All() modifier has been used 
    if ALL then
      --- We start with global
      Global()
      private__SaveValue(index, value)

      --- We save the value for all existing profiles 
      local profilesDB = private__GetDB().__profiles 
      if profilesDB then 
        for profile in pairs(profilesDB) do 
          --- We need to manually change the base db and its id before calling 
          --- private__SaveValue
          BASE_DB = "profile"
          BASE_DB_ID = "profiles" .. ID_SEPARATOR_CHAR .. profile
          PROFILE = profile
          
          private__SaveValue(index, value)
        end
      end
    else 
      private__SaveValue(index, value)
    end

    private__PostEndProcess()
  end

  --- Rename an index in the current path. 
  --- @See also Path, SetDefaultPath and SetBasePath for changing the path
  __Arguments__ { String, String}
  __Static__() function Rename(fromIndex, toIndex)
    --- We call it in case where 'Path' has been called, and SetDefaultPath or 
    --- SetBasePath has been used. 
    --- It does nothing if "Path" or "AbsPath" has been used for this current operation.
    private__ImplicitPath()

    if ALL then 
      --- We start by global
      Global()

      local fromValue = private__GetValue(fromIndex)
      if fromValue ~= nil then 
        private__SaveValue(toIndex, fromValue)
        private__SaveValue(fromIndex, nil)
      end

        --- We rename for all profiles
      local profilesDB = private__GetDB().__profiles
      if profilesDB then
        for profile in pairs(profilesDB) do 
            --- We need to manually change the base db and its id before calling 
            --- private__SaveValue
            BASE_DB = "profile"
            BASE_DB_ID = "profiles" .. ID_SEPARATOR_CHAR .. profile
            PROFILE = profile
            
            fromValue = private__GetValue(fromIndex)
            if fromValue ~= nil then 
              private__SaveValue(toIndex, fromValue)
              private__SaveValue(fromIndex, nil)
            end
        end
      end
    else 
      local fromValue = private__GetValue(fromIndex)
      if fromValue ~= nil then 
        private__SaveValue(toIndex, fromValue)
        private__SaveValue(fromIndex, nil)
      end
    end

    private__PostEndProcess()
  end

  --- This will disable the profile system so Profile() will always return 
  --- the global
  __Static__() function DisableProfiles() 
    PROFILES_DISABLED = true 
  end

  --- This will enable the profile system so Profile() will return the profile 
  --- or global as fallback
  __Static__() function EnableProfiles() 
    PROFILES_DISABLED = false
  end

  --- Create a profile
  __Arguments__ { String }
  __Static__() function CreateProfile(name)
    -- __global is blacklisted
    if name == "__global" then 
      return 
    end

    -- We use "AbsPath" for avoiding conflict if SetDefaultPath or SetBasePath
    -- is used previously
    local profileDB = AbsPath("__profiles").GetValue(name)

    if profileDB then 
      return 
    end

    AbsPath("__profiles").SaveValue(name, { __profileId = name })

    -- TODO: Trigger an event 
  end

  --- Delete a profile
  __Arguments__ { String }
  __Static__() function DeleteProfile(name)
    -- We use "AbsPath" for avoiding conflict if SetDefaultPath or SetBasePath
    -- is used previously
    AbsPath("__profiles").SetValue(name, nil)

    -- TODO: Trigger an event
  end

  __Static__() function GetCurrentProfile()
    return PROFILE_SELECTED or "__global"
  end

  __Arguments__ { Number, String/nil}
  __Static__() function SelectProfileForSpec(specIndex, profile)
    local fullPlayerName = GetRealmName() .. "-" .. UnitName("player")

    -- We use "AbsPath" for avoiding conflict if SetDefaultPath or SetBasePath
    -- is used previously
    AbsPath("__ScorpioChars", fullPlayerName, "__ScorpioSpecs", specIndex)
      .SaveValue("__profileUsed", profile)

    CheckProfileChange()
  end

  __Static__() function CheckProfileChange()
    local hasChanged = false 
    local profileUsed = private__GetSpecDB().__profileUsed

    local old = PROFILE_SELECTED or "__global"
    local new = profile_used or "__global"

    if old ~= new then 
      hasChanged = true 
    end

    PROFILE_SELECTED = profileUsed

    if hasChanged then 
      Scorpio.FireSystemEvent("SLT_PROFILE_CHANGED", new, old)
    end
  end

  --- Clean will remove all empty tables
  __Static__() function Clean()
    -- NOTE: Important using the RawDB else it doesn't work
    private__ClearEmptyTable(private__GetRawDB())
  end

  __Arguments__ { Number }
  __Static__() function SetVersion(version)
    private__GetDB().dbVersion = version
  end

  __Static__() function GetVersion()
    return private__GetDB().dbVersion
  end
end)

__SystemEvent__()
function PLAYER_SPECIALIZATION_CHANGED()
  SavedVariables.CheckProfileChange()
end