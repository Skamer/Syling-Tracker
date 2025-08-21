-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                  "SylingTracker.Core.CacheManager"                    ""
-- ========================================================================= --

__Arguments__ { String, String + Number, Boolean/false }
function GetCacheValue(group, key, isGlobal)
  local db = isGlobal and _DB or _DB.Char 

  local cacheList = db.caches

  if not cacheList then 
    return
  end 

  local cache = cacheList[group]

  if not cache then 
    return 
  end 

  return cache[key]
end

function GetGlobalCacheValue(group, key)
  return GetCacheValue(group, key, true)
end

function GetCharCacheValue(group, key)
  return GetCacheValue(group, key, false)
end

__Arguments__ { String, String + Number, Any/nil, Boolean/false }
function SetCacheValue(group, key, value, isGlobal)
  local db = isGlobal and _DB or _DB.Char

  local cacheList = db.caches 

  if not cacheList then 
    cacheList = {}
    db.caches = cacheList 
  end 

  local cache = cacheList[group]

  if not cache then 
    cache = {}
    cacheList[group] = cache 
  end 

  cache[key] = value
end

function SetGlobalCacheValue(group, key, value)
  return SetCacheValue(group, key, value, true)
end

function SetCharCacheValue(group, key, value)
  return SetCacheValue(group, key, value, false)
end

__Arguments__ { String, Boolean/false }
function ClearCache(group, isGlobal)
  local db = isGlobal and _DB or _DB.Char 

  local cacheList = db.caches

  if not cacheList then 
    return
  end

  cacheList[group] = nil 
end

__Iterator__()
__Arguments__ { String, Boolean/false}
function IterateCache(group, isGlobal)
  local yield = coroutine.yield

  local db = isGlobal and _DB or _DB.Char

  local cacheList = db.caches 

  if not cacheList then 
    return 
  end 

  local cache = cacheList[group]

  if cache then 
    for k,v in pairs(cache) do 
      yield(k, v)
    end
  end
end

-- Export the functions in the API
API.GetCacheValue         = GetCacheValue
API.GetGlobalCacheValue   = GetGlobalCacheValue
API.GetCharCacheValue     = GetCharCacheValue
API.SetCacheValue         = SetCacheValue
API.SetCharCacheValue     = SetCharCacheValue
API.SetGlobalCacheValue   = SetGlobalCacheValue
API.ClearCache            = ClearCache
API.IterateCache          = IterateCache