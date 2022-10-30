-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                  "SylingTracker.Core.Profiles"                        ""
-- ========================================================================= --
namespace                          "SLT"
-- ========================================================================= --
_SPECS_INDEX_ID            = "__ScorpioSpecs"
_FIRST_EVENT_CALL_OCCURRED = false
GetActiveSpecGroup         = GetActiveSpecGroup
-- ========================================================================= --
class "Profiles" (function(_ENV)
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  __Static__() function SelectSpec()
    Database.SelectRootSpec()
    Database.SetValue("profile_used", "__spec")
  end

  __Static__() function SelectChar()
    Database.SelectRootSpec()
    Database.SetValue("profile_used", "__char")
  end

  __Static__() function SelectGlobal()
    Database.SelectRootSpec()
    Database.SetValue("profile_used", nil)
  end

  __Arguments__ { String }
  __Static__() function Select(name)
    Database.SelectRootSpec()
    Database.SetValue("profile_used", name)
  end

  __Arguments__ { String }
  __Static__() function Create(name)
    Database.SelectRoot()
    Database.SelectTable("profiles")
    Database.SetValue(name, { __profile_name = name })
  end

  __Arguments__ {  String }
  __Static__() function Delete(name)
    Database.SelectRoot()
    if Database.SelectTable(false, "profiles") then
      Database.SetValue(name, nil)
    end
  end

  __Arguments__ { String }
  __Static__() function CopyFrom(name)
    local sourceDB
    if Profiles.IsGlobal(name) then
      sourceDB = Database:GetCopyTable(Database:Path())
    elseif Profiles.IsChar(name) then
      sourceDB = Database:GetCopyTable(Database:Path():SetRelativeDB("char"))
    elseif Profiles.IsSpec(name) then
      sourceDB = Database:GetCopyTable(Database:Path():SetRelativeDB("spec"))
    end

    Profiles.PrepareDatabase()
    Scorpio.FireSystemEvent("SLT_COPY_PROFILE_PROCESS", sourceDB, Database.GetCurrentTable(), destProfile)
  end

  __Arguments__ { Variable.Optional(String) }
  __Static__() function IsGlobal(profileName)
    return profileName == nil or profileName == "__global"
  end

  __Arguments__ { String }
  __Static__() function IsSpec(profileName)
    return profileName == "__spec"
  end

  __Arguments__ { String }
  __Static__() function IsChar(profileName)
    return profileName == "__char"
  end

  __Arguments__ { String }
  __Static__() function IsUser(profileName)
    return not Profiles.IsGlobal(profileName) and not Profiles.IsSpec(profileName) and not Profiles.IsChar(profileName)
  end

  __Arguments__ { Number, Variable.Optional(String) }
  __Static__() function SelectForSpec(specIndex, profile)
    if not Database.GetChar()[_SPECS_INDEX_ID] then
      Database.GetChar()[_SPECS_INDEX_ID] = {}
    end

    if not Database.GetChar()[_SPECS_INDEX_ID][specIndex] then
      Database.GetChar()[_SPECS_INDEX_ID][specIndex] = {}
    end

    Database.GetChar()[_SPECS_INDEX_ID][specIndex].profile_used = profile

    if GetSpecialization() == specIndex then
      Profiles.CheckProfileChange()
    end
  end

   __Arguments__ { Number }
  __Static__() function GetProfileForSpec(specIndex)
    Database.SelectRootChar()
    if Database.SelectTable(false, _SPECS_INDEX_ID) then
      local value = Database.GetValue(specIndex)
      if value then
        return value.profile_used
      end
    end
  end

  __Arguments__ { Variable.Optional(String) }
  __Static__() function PrepareDatabase(profile)
    if not profile then
      profile = Database.GetSpec().profile_used
    end

    if not profile or profile == "__global" then
      Database.SelectRoot()
    elseif profile == "__spec" then
      Database.SelectRootSpec()
    elseif profile == "__char" then
      Database.SelectRootChar()
    else
      Database.SelectRoot()
      Database.SelectTable(false, "profiles", profile)
    end
  end


  __Arguments__ { String, Variable.Rest(String) }
  __Static__() function RemoveValueForAllProfiles(index, ...)
    local count = select("#", ...)

    --- Remove for root
    Database.SelectRoot()
    if Database.SelectTable(false, ...) then 
      Database.SetValue(index, nil)
    end

    --- Remove for spec 
    Database.SelectRootSpec()
    if Database.SelectTable(false, ...) then 
      Database.SetValue(index, nil)
    end

    --- Remove for char
    Database.SelectRootChar()
    if Database.SelectTable(false, ...) then 
      Database.SetValue(index, nil)
    end

    --- Remove for all profiles
    local profiles = Profiles.GetUserProfilesList()
    if profiles then 
      for profileName in pairs(profiles) do 
        Database.SelectRoot()
        if Database.SelectTable(false, "profiles", profileName, ...) then 
          Database.SetValue(index, nil)
        end
      end
    end
  end

  __Static__() function GetUserProfilesList()
    Database.SelectRoot()
    local list = {}
    if Database.SelectTable(false, "profiles") then
      for profileName in Database.IterateTable() do
        list[profileName] = profileName
      end
    end

    return list
  end

  __Async__()
  __Static__() function CheckProfileChange()
    local profile = Database.GetSpec().profile_used or "__global"
    local oldProfile = Profiles.name or "__global"
    local hasChanged = false


    if profile == "__spec" then
      hasChanged = true
    elseif profile ~= oldProfile then
      hasChanged = true
    end

    Profiles.name = profile

    if hasChanged  then
      Scorpio.FireSystemEvent("SLT_PROFILE_CHANGED", profile, oldProfile)
    end
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  __Static__() property "name" { 
    type = String
  }
end)

function OnLoad(self)
  local spec = GetSpecialization()
  if not spec then
    TryToLoadProfiles()
  else
    Profiles:CheckProfileChange()
    Scorpio.FireSystemEvent("SLT_PROFILES_LOADED")
  end
end 

__Async__()
function TryToLoadProfiles()
  NextEvent("PLAYER_LOGIN")

  Profiles:CheckProfileChange()
  Scorpio.FireSystemEvent("SLT_PROFILES_LOADED")
end

__SystemEvent__()
function PLAYER_SPECIALIZATION_CHANGED()
  Profiles:CheckProfileChange()
end