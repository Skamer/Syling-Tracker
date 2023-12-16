-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                "SylingTracker.Features.ItemBar"                       ""
-- ========================================================================= --
export {
  newtable                            = System.Toolset.newtable,
  FromUIProperty                      = Wow.FromUIProperty,
  GetFrameByType                      = Wow.GetFrameByType,
}
-- ========================================================================= --
ITEM_BAR                              = nil
ITEMS_INFO                            = {}
ITEMS_INFO_LIST                       = List()
ITEM_APPEARANCE_ORDER                 = 0
ITEMBAR_ENABLED                       = false
SORT_BY_DISTANCE                      = true
-- ========================================================================= --
__UIElement__()
class "ItemButton"(function(_ENV)
  inherit "SecureButton"
  -----------------------------------------------------------------------------
  --                               Handlers                                  --
  -----------------------------------------------------------------------------
  local function OnLeaveHandler(self)
    GameTooltip:Hide()
  end

  local function OnEnterHandler(self)
    local itemLink = self.ItemLink
    if itemLink then 
      GameTooltip:SetOwner(self)
      GameTooltip:SetHyperlink(itemLink)
      GameTooltip:Show()
    end
  end
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  function OnSystemEvent(self, event)
    local questID = self.id

    if not event == "BAG_UPDATE_COOLDOWN" or not questID or questID <= 0 then 
      return 
    end

    local questLogIndex = GetLogIndexForQuestID(questID)

    if questLogIndex then 
      local start, duration, enable = GetQuestLogSpecialItemCooldown(questLogIndex)

      CooldownFrame_Set(self.__cooldown, start, duration, enable)

      if duration and duration > 0 and enable and enable == 0 then 
        self.ItemUsable = false
      else
        self.ItemUsable = true
      end
    end
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  __Observable__()
  property "ItemLink" {
    type = Any
  }

  __Observable__()
  property "ItemTexture" {
    type = Any
  }

  __Observable__()
  property "ItemUsable" {
    type = Boolean,
    default = true
  }

  property "id" {
    type = Number
  }
  -----------------------------------------------------------------------------
  --                            Constructors                                 --
  -----------------------------------------------------------------------------
  __Template__ {
    Icon    = Texture,
    Keybind = FontString,
  }

  function __ctor(self, name)
    local cooldown = CreateFrame("Cooldown", name.."Cooldown", self,  "CooldownFrameTemplate")
    cooldown:SetAllPoints()
    self.__cooldown = cooldown

    self.OnEnter = self.OnEnter + OnEnterHandler
    self.OnLeave = self.OnLeave + OnLeaveHandler
  end
end)

class "ItemBar" (function(_ENV)
  inherit "SecurePanel"
  -----------------------------------------------------------------------------
  --                               Events                                    --
  -----------------------------------------------------------------------------
  event "OnStopMoving"
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  __Async__()
  function StopMovingOrSizing(self)
    super.StopMovingOrSizing(self)

    Next()

    OnStopMoving(self)
  end
end)
-------------------------------------------------------------------------------
--                                   API                                     --
-------------------------------------------------------------------------------
SETTING_SUBJECTS = {}
SETTINGS = {}

struct "ItemBarSettingInfoType" {
  { name = "id", type = String, require = true},
  { name = "default", type = Any},
  { name = "handler", type = Function},
  { name = "saveHandler", type = Function},
  { name = "ignoreDefault", type = Boolean, default = false},
  { name = "getHandler", type = Function}
}

__Arguments__ { ItemBarSettingInfoType }
function RegisterItemBarSetting(settingInfo)
  if SETTINGS[settingInfo.id] then
    return 
  end

  SETTINGS[settingInfo.id] = settingInfo
end

--- Return the db value for a setting 
---
--- @param setting the setting to get
--- @param ... extra arguments will be pushed to 'get handler'
__Arguments__ { String, Any * 0 }
function GetItemBarSetting(setting, ...)
  local hasDefaultValue = false
  local defaultValue
  local dbValue
  local getHandler 

  local settingInfo = SETTINGS[setting]
  if settingInfo then 
    defaultValue = settingInfo.default
    getHandler  = settingInfo.getHandler
    hasDefaultValue = not settingInfo.ignoreDefault
  end

  if getHandler then
    dbValue = getHandler(...)
  else
    dbValue = SavedVariables.Profile().Path("itemBar").GetValue(setting)
  end

  return dbValue, hasDefaultValue, defaultValue
end

--- Get the value for a item bar setting.
--- The value returned will be replaced by the default value if no db value exists.
---
--- @param setting the setting to get 
--- @param ... extra arguments will be pushed to 'get handler' 
__Arguments__ { String, Any * 0}
function GetItemBarSettingWithDefault(setting, ...)
  local dbValue, hasDefaultValue, defaultValue = GetItemBarSetting(setting, ...)

  if dbValue == nil and hasDefaultValue then 
    return defaultValue
  end

  return dbValue
end

--- Set the value for a item bar setting 
---
--- @param setting the setting to set 
--- @param value the value to set 
--- @param notify if the handler and the observables will be notified. 
--- @param ... extra arguments will be passed to all handlers.
__Arguments__ { String, Any/nil, Boolean/true, Any * 0 }
function SetItemBarSetting(setting, value, notify, ...)
  local default = nil 
  local ignoreDefault = false 
  local handler = nil 
  local saveHandler = nil 

  local settingInfo = SETTINGS[setting]
  if settingInfo then 
    default       = settingInfo.default
    ignoreDefault = settingInfo.ignoreDefault
    handler       = settingInfo.handler
    saveHandler   = settingInfo.saveHandler
  end

  if value == nil and not ignoreDefault then
    value = default
  end

  if saveHandler then 
    saveHandler(value, ...)
  else
    if value == nil or value == default then 
      SavedVariables.Profile().Path("itemBar").SetValue(setting, nil)
    else
      SavedVariables.Profile().Path("itemBar").SaveValue(setting, value)
    end
  end

  if notify then 
    if handler then 
      handler(value, ...)
    end

    local subject = SETTING_SUBJECTS[setting]
    if subject then 
      subject:OnNext(value, ...)
    end
  end
end

--- Create an observable will read the item bar setting 
--- It can be used by the style system 
---
--- @param setting the setting where the value will be fetched.
__Arguments__ { String }
function FromItemBarSetting(setting)
  local observable = Observable(function(observer)
    local subject = SETTING_SUBJECTS[setting]

    if not subject then 
      subject = BehaviorSubject()
      SETTING_SUBJECTS[setting] = subject 
    end 

    subject:Subscribe(observer)

    local dbValue, hasDefault, defaultValue = GetItemBarSetting(setting)

    if dbValue == nil and hasDefault then 
      subject:OnNext(defaultValue)
    else
      subject:OnNext(dbValue)
    end
  end)

  return observable
end

function private__SortItems()
  if SORT_BY_DISTANCE then 
    ITEMS_INFO_LIST:Sort("x,y=>x.distance<y.distance")
  else 
    ITEMS_INFO_LIST:Sort("x,y=>x.appearanceOrder<y.appearanceOrder")
  end
end

__AsyncSingle__(true)
function private__SetLocked(locked)
  NoCombat()

  if ITEM_BAR then
    if locked then  
      Style[ITEM_BAR].Mover = NIL
      
      ITEM_BAR.KeepRowSize = false
      ITEM_BAR.KeepColumnSize = false
    else
      Style[ITEM_BAR].Mover.visible = true
      
      ITEM_BAR.KeepRowSize = true 
      ITEM_BAR.KeepColumnSize = true
    end
  end
end

local function OnItemBarStopMoving(itemBar)
  local left = itemBar:GetLeft()
  local top = itemBar:GetTop()

  SetItemBarSetting("position", Position(left, top), false)
end

local function OnItemBarElementAdd(itemBar, element)
  -- Style[element].Keybind.text = tostring(itemBar.Count)

  element:RegisterSystemEvent("BAG_UPDATE_COOLDOWN")
end

local function OnItemBarElementRemove(itemBar, element)
  element.ItemLink    = nil 
  element.ItemTexture = nil
  element.ItemUsable  = nil 
  element.id          = nil

  element:UnregisterSystemEvent("BAG_UPDATE_COOLDOWN")
end

__AsyncSingle__(true)
function private__SetEnabled(enabled)
  NoCombat()

  if enabled then 
    if not ITEM_BAR then 
      ITEM_BAR = ItemBar("SylingTracker_ItemBar", UIParent)
      ITEM_BAR:InstantApplyStyle()
     
      ITEM_BAR.OnElementAdd     = ITEM_BAR.OnElementAdd + OnItemBarElementAdd
      ITEM_BAR.OnElementRemove  = ITEM_BAR.OnElementRemove + OnItemBarElementRemove
      ITEM_BAR.OnStopMoving     = ITEM_BAR.OnStopMoving + OnItemBarStopMoving
    end

    ITEM_BAR:Show()

    private__Update()
  else
    if ITEM_BAR then
      ITEM_BAR:Hide()
    end
  end

  ITEMBAR_ENABLED = enabled
end


__AsyncSingle__()
function private__Update()
  NoCombat()

  local maxCount = ITEM_BAR.MaxCount
  local itemsCount = ITEMS_INFO_LIST.Count

  ITEM_BAR.Count = min(maxCount, itemsCount)

  for index, itemInfo in ITEMS_INFO_LIST:GetIterator() do
    if index <= ITEM_BAR.MaxCount then 
      local element = ITEM_BAR.Elements[index]
      element.id = itemInfo.id
      element.ItemLink = itemInfo.link
      element.ItemTexture = itemInfo.texture
      element:SetAttribute("type", "item")
      element:SetAttribute("item", itemInfo.link)
    end
  end
end

function ItemBar_Update()
  if ITEMBAR_ENABLED then 
    private__Update()
  end
end

--- Add a item in the item bar
--- 
--- @param id the id where the item will be registered
--- @param link the item link 
--- @param texture the item texture
--- @param distance the distance will be associated to item
__Arguments__ { String + Number, Any/nil, Any/nil, Number/9999999}
function ItemBar_AddItem(id, link, texture, distance)
  if ITEMS_INFO[id] then 
    return
  end

  ITEM_APPEARANCE_ORDER = ITEM_APPEARANCE_ORDER + 1

  local itemInfo = {
    id = id, 
    link = link,
    texture = texture,
    distance = distance, 
    appearanceOrder = ITEM_APPEARANCE_ORDER
  }

  ITEMS_INFO[id] = itemInfo

  ITEMS_INFO_LIST:Insert(itemInfo)

  private__SortItems()

  -- Trigger an update
  ItemBar_Update()
end

--- Remove a item from the item bar
---
--- @param id the item id to revmove 
__Arguments__ { String + Number }
function ItemBar_RemoveItem(id)
  if not ITEMS_INFO[id] then 
    return 
  end

  local itemInfo = ITEMS_INFO[id]

  ITEMS_INFO_LIST:Remove(itemInfo)

  ITEMS_INFO[id] = nil 


  if ITEMS_INFO_LIST.Count == 0 then 
    ITEM_APPEARANCE_ORDER = 0
  else 
    private__SortItems()
  end

  -- Trigger an update
  ItemBar_Update()
end

__Arguments__ { Number + String, Number/9999999 }
function ItemBar_SetItemDistance(id, distance)
  -- @TODO to implement
end

__Arguments__ { Number}
function ItemBar_GetItemKeyBind(id) 
  -- @TODO to implement
end

-- Export the functions as API functions
API.RegisterItemBarSetting        = RegisterItemBarSetting
API.GetItemBarSetting             = GetItemBarSetting
API.SetItemBarSetting             = SetItemBarSetting
API.GetItemBarSettingWithDefault  = GetItemBarSettingWithDefault
API.FromItemBarSetting            = FromItemBarSetting
API.ItemBar_AddItem               = ItemBar_AddItem
API.ItemBar_RemoveItem            = ItemBar_RemoveItem
API.ItemBar_SetItemDistance       = ItemBar_SetItemDistance
API.ItemBar_Update                = ItemBar_Update
-------------------------------------------------------------------------------
--                              UI Settings                                  --
-------------------------------------------------------------------------------
RegisterItemBarSetting({ id = "enabled", default = true, handler = private__SetEnabled })
RegisterItemBarSetting({ id = "locked", default = false, handler = private__SetLocked})
RegisterItemBarSetting({ id = "position"})
RegisterItemBarSetting({ id = "columnCount", default = 10})
RegisterItemBarSetting({ id = "rowCount", default = 1})
RegisterItemBarSetting({ id = "leftToRight", default = true})
RegisterItemBarSetting({ id = "topToBottom", default = true})
RegisterItemBarSetting({ id = "orientation", default = Orientation.HORIZONTAL})
RegisterItemBarSetting({ id = "elementWidth", default = 32})
RegisterItemBarSetting({ id = "elementHeight", default = 32})
RegisterItemBarSetting({ id = "hSpacing", default = 10})
RegisterItemBarSetting({ id = "vSpacing", default = 10})
RegisterItemBarSetting({ id = "marginLeft", default = 5})
RegisterItemBarSetting({ id = "marginRight", default = 5})
RegisterItemBarSetting({ id = "marginTop", default = 5})
RegisterItemBarSetting({ id = "marginBottom", default = 5})
-------------------------------------------------------------------------------
--                                Styles                                     --
-------------------------------------------------------------------------------
Style.UpdateSkin("Default", {
  [ItemButton] = {
    registerForClicks = { "AnyDown", "AnyUp"},
     backdrop = { 
      bgFile = [[Interface\AddOns\SylingTracker\Media\Textures\LinearGradient]],
    },
    backdropColor = { r = 1,  g = 40/255, b = 46/255, a = 0},

    Keybind = {
      visible = false,
      mediaFont = FontType("PT Sans Narrow Bold", 14, "NORMAL"),
      text = "",
      setAllPoints = true,
      justifyV = "TOP",
      justifyH = "LEFT",
    },

    Icon = {
      file = FromUIProperty("ItemTexture"),
      setAllPoints = true,
      texCoords = { left = 0.07, right = 0.93, top = 0.07, bottom = 0.93 },
      vertexColor = FromUIProperty("ItemUsable"):Map(function(usable)
        if usable then 
          return { r = 1, g = 1, b = 1 }
        end 

        return { r = 0.4, g = 0.4, b = 0.4}
      end)
    }
  },

  [ItemBar] = {
     movable = true,
     
     [Mover] = {
      backdrop = {
        bgFile = [[Interface\AddOns\SylingTracker\Media\Textures\LinearGradient]]
      },

      backdropColor = { r = 0, g = 1, b = 0, a = 0.3},
      location = {
        Anchor("BOTTOMLEFT", 0, 0, nil, "TOPLEFT"),
        Anchor("BOTTOMRIGHT", 0, 0, nil, "TOPRIGHT"),
      },
     },

     elementType = ItemButton,
     columnCount = FromItemBarSetting("columnCount"),
     rowCount = FromItemBarSetting("rowCount"),
     leftToRight = FromItemBarSetting("leftToRight"),
     topToBottom = FromItemBarSetting("topToBottom"),
     orientation = FromItemBarSetting("orientation"),
     elementWidth = FromItemBarSetting("elementWidth"),
     elementHeight = FromItemBarSetting("elementHeight"),
     hSpacing = FromItemBarSetting("hSpacing"),
     vSpacing = FromItemBarSetting("vSpacing"),
     marginLeft = FromItemBarSetting("marginLeft"),
     marginRight = FromItemBarSetting("marginRight"),
     marginTop = FromItemBarSetting("marginTop"),
     marginBottom = FromItemBarSetting("marginBottom"),
     backdrop = { 
      bgFile = [[Interface\AddOns\SylingTracker\Media\Textures\LinearGradient]],
    },
    backdropColor = { r = 35/255, g = 40/255, b = 46/255, a = 0.73},

    location = FromItemBarSetting("position"):Map(function(position)
      if position then 
        return { Anchor("TOPLEFT", position.x or 0, position.y or 0, nil, "BOTTOMLEFT") }
      end

      return { Anchor("CENTER") }
    end)
  }
})

__SystemEvent__()
function SylingTracker_DATABASE_LOADED()
  private__SetEnabled(GetItemBarSettingWithDefault("enabled"))
  private__SetLocked(GetItemBarSettingWithDefault("locked"))
end

__SystemEvent__()
function SylingTracker_ENABLE_ITEMBAR()
  SetItemBarSetting("enabled", true)
end

__SystemEvent__()
function SylingTracker_DISABLE_ITEMBAR()
  SetItemBarSetting("enabled", false)
end

__SystemEvent__()
function SylingTracker_LOCK_ITEMBAR()
  SetItemBarSetting("locked", false)
end

__SystemEvent__()
function SylingTracker_UNLOCK_ITEMBAR()
  SetItemBarSetting("locked", true)
end
-- ========================================================================= --
-- Debug Utils Tools
-- ========================================================================= --
DebugTools.TrackData(ITEMS_INFO, "Item Bar")