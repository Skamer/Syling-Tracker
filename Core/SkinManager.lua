-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                  "SylingTracker.Core.SkinManager"                     ""
-- ========================================================================= --
DEFAULT_SKIN_NAME                     = "default"
ADDON_SKIN_NAME                       = "syling"
CLASS_LIST                            = {}
TAG_CLASSES                           = {}

-- Register the addon skin
Style.RegisterSkin(ADDON_SKIN_NAME, {})

-------------------------------------------------------------------------------
--                                   API                                     --
-------------------------------------------------------------------------------
__Arguments__ { NEString, -UIObject/nil }
__Static__() function API.GetFallbackSkin(name, class)
  name = strlower(name)
  local hasAddonSkin = false 

  for skinName in Style.GetSkins(class) do 
    if skinName == name then
      return name 
    end

    if skinName == ADDON_SKIN_NAME then 
      hasAddonSkin = true 
    end
  end

  if hasAddonSkin then 
    return ADDON_SKIN_NAME
  end

  return DEFAULT_SKIN_NAME
end

__Arguments__{ NEString, Any, Any * 0 }
__Static__() function API.UpdateSkin(name, settings, ...)
  for k in pairs(settings) do 
    CLASS_LIST[k] = true 
  end

  Style.UpdateSkin(name, settings, ...)
end

__Arguments__{ Any * 0 }
__Static__() function API.UpdateDefaultSkin(...)
  API.UpdateSkin(DEFAULT_SKIN_NAME, ...)
end

__Static__() function API.UpdateAddonSkin(...)
  API.UpdateSkin(ADDON_SKIN_NAME, ...)
end

--- Switch the skin for a class
---
__Async__() __Static__() function API.SwitchSkin(skin, cls)
  if strlower(skin) == DEFAULT_SKIN_NAME then 
    return Style.ActiveSkin(DEFAULT_SKIN_NAME, cls)
  end

  local fallbackSkin = API.GetFallbackSkin(skin, cls)
  local activeSkin = Style.GetActiveSkin(cls)

  if fallbackSkin == DEFAULT_SKIN_NAME then 
    return Style.ActiveSkin(DEFAULT_SKIN_NAME, cls)
  end

  local needDelay = true 

  if activeSkin == DEFAULT_SKIN_NAME then
    return Style.ActiveSkin(fallbackSkin, cls)
  end

  Style.ActiveSkin(DEFAULT_SKIN_NAME, cls)

  Delay(0.1)

  return Style.ActiveSkin(fallbackSkin, cls)
end

--- Switch the skin for a skin tag 
--- All the classes associated to skin tag will switch on the new skin. 
---
--- @param skin  the skin to switch 
--- @param tagName the skin tag to used 
__Arguments__ { NEString, NEString }
__Async__() __Static__() function API.SwitchSkinByTag(skin, tagName)
  skin = strlower(skin)

  local classes = TAG_CLASSES[tagName]

  if classes then 
    for _, cls in ipairs(classes) do 
      API.SwitchSkin(skin, cls)
    end 

    SavedVariables.Profile().Path("skins").SaveValue(tagName, skin)
  end
end

--- Register a skin tag for a collection of class. 
--- The skin tag will be used for swapping the skin of multiple classes in one time.
---
--- @param id the id of skin tag to register 
--- @param ... reppresent multiple or one class
__Static__() function API.RegisterSkinTag(id, ...)
  TAG_CLASSES[id] = { ... }
end

--- Active a skin for a class ui object 
---
--- @param name the skin name.
--- @param class the class to skin.
--- @param fallback say if a fallback skin is used in case where the given one is not found.
__Arguments__ { NEString, -UIObject/nil, Boolean/true}
__Static__() function API.ActiveSkin(name, class, fallback)
  if not fallback or strlower(name) == "default" then 
    return Style.ActiveSkin(name, class)
  end

  local fallbackSkin = API.GetFallbackSkin(name, class)

  return Style.ActiveSkin(fallbackSkin, class)
end

__SystemEvent__()
function SylingTracker_DATABASE_LOADED()
  -- SavedVariables.Profile().Path("skins").SaveValue("keystone", "syling")
  local tagSkins = SavedVariables.Profile().GetValue("skins")
  local clsBlacklist = {}

  for tagName, skinName in pairs(tagSkins) do
    local tagClass = TAG_CLASSES[tagName]
    if tagClass then  
      for _, cls in ipairs(tagClass) do 
        API.ActiveSkin(skinName, cls)
        clsBlacklist[cls] = true
      end
    end
  end 

  for k in pairs(CLASS_LIST) do
    if not clsBlacklist[k] then 
      API.ActiveSkin("syling", k)
    end
  end
end
-------------------------------------------------------------------------------
--                                Module                                     --
-------------------------------------------------------------------------------
--- `/slt skin keystone` switch to 'syling' skin for 'keystone' tag 
--- `/slt skin keystone eddy` switch to 'eddy' skin for 'keyston' tag
__SlashCmd__ "slt" "skin"
function SwitchSkinCommand(args)
  local arg1, arg2 = strsplit(" ", args)

  if arg1 and arg1 ~= "" then
    local tagName = arg1
    local skinName = ADDON_SKIN_NAME
    if arg2 and arg2 ~= "" then
      skinName = arg2
    end

    API.SwitchSkinByTag(skinName, tagName)
  end
end


