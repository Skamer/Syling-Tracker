-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                   "SylingTracker.Core.Settings"                       ""
-- ========================================================================= --

class "Setting" (function(_ENV)
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  property "id" {
    type = String
  }

  property "Default" {
    type = Any
  }

  property "Func" {
    type = Callable
  }

  __Arguments__ { String, Any, Callable/nil }
  function Setting(self, id, default, func)
    self.id       = id 
    self.Default  = default
    self.Func     = func 
  end

end)
-------------------------------------------------------------------------------
-- Extending the API                                                         --
-------------------------------------------------------------------------------
SUBJECTS_ONLOAD_PROCESS_DONE        = false
SETTINGS                            = {}
SETTINGS_DB_INDEX                   = "settings"
SETTING_SUBJECTS                    = {}

--- Get the value of setting has been registered. If the player hasn't set 
--- value for this, this will return the default value. 
---
--- @param id the setting id. 
__Arguments__ { String }
__Static__() function API.GetSetting(id)
  local settingInfo = SETTINGS[id] 

  if not settingInfo then 
    return 
  end

  local value = SavedVariables.Profile().Path(SETTINGS_DB_INDEX).GetValue(id)

  if value ~= nil then
    return value 
  end

  return settingInfo.Default
end

--- Set the value for a registered setting. This will trigger a event if the 
--- value has changed. 
---
--- @param id the setting id.
--- @param value the new value for the setting 
--- @param useHandler if the function must be called (default to true)
--- @param passValue if the value will be passed to the function (default to true)
__Arguments__ { String, Any/nil, Boolean/true, Boolean/true}
__Static__() function API.SetSetting(id, value, useHandler, passValue)
  local oldValue = SavedVariables.Profile().Path(SETTINGS_DB_INDEX).GetValue(id)
  local newValue = value 
  local settingInfo = SETTINGS[id]


  if not settingInfo then 
    error(("Try to set an unregistered setting '%s'"):format(id))
  end

  local defaultValue = settingInfo.Default

  if oldValue == nil then 
    oldValue = defaultValue
  end

  if value and value == defaultValue then 
    SavedVariables.Profile().Path(SETTINGS_DB_INDEX).SetValue(id, nil)
  else
    SavedVariables.Profile().Path(SETTINGS_DB_INDEX).SaveValue(id, value)
  end

  if newValue == nil then 
    newValue = defaultValue
  end

  if newValue ~= oldValue then 
    _M:FireSystemEvent("SylingTracker_SETTING_CHANGED", id, newValue, oldValue)

    -- We notify the observers if needed 
    local subject = SETTING_SUBJECTS[id]
    if subject then 
      subject:OnNext(newValue)
    end
  end

  -- Call the handler if needed 
  if useHandler and settingInfo.Func then 
    if passValue then 
      settingInfo.Func(newValue)
    else
      settingInfo.Func()
    end
  end
end

--- Reset the value for a registered setting. 
---
--- @param id the setting id. 
__Arguments__ { String }
__Static__() function API.ResetSetting(id)
  API.SetSetting(id, nil)
end

--- Register a setting. 
---
--- @param id the setting id to register.
--- @param default the default value.
--- @param func a optional function will be called when the setting value is changed.
__Arguments__ { String, Any, Callable/nil }
__Static__() function API.RegisterSetting(id, default, func)
  SETTINGS[id] = Setting(id, default, func)
end

__Arguments__ { String }
__Static__() function API.FromSetting(id)
  return Observable(function(observer)
    local subject = SETTING_SUBJECTS[id]

    if not subject then 
      subject = BehaviorSubject()
      SETTING_SUBJECTS[id] = subject
    end

    subject:Subscribe(observer)

    if SUBJECTS_ONLOAD_PROCESS_DONE then 
      local value = API.GetSetting(id)
      subject:OnNext(value)
    end


    return subject
  end)
end

function OnLoad(self)
  -- When the db is initialized, we read the settings and notify the observer.
  for id, subject in pairs(SETTING_SUBJECTS) do    
    local value = API.GetSetting(id)
    subject:OnNext(value)
  end

  SUBJECTS_ONLOAD_PROCESS_DONE = true
end