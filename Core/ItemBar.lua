-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                      "SylingTracker.Core.ItemBar"                     ""
-- ========================================================================= --
namespace                          "SLT"
-- ========================================================================= --
export {
  GameTooltip                       = GameTooltip
}
-- ========================================================================= --
RegisterModel                       = API.RegisterModel
-- ========================================================================= --
_ItemModel                          = RegisterModel(Model, "items-data")
-- ========================================================================= --
DB_READ_ONLY                        = true
-- ========================================================================= --
__Recyclable__ "SylingTracker_ItemButton%d"
class "ItemButton" (function(_ENV)
  inherit "Frame"
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  function SetItemLink(self, itemLink)
    self.__ActionButton:SetAttribute("type", "item")
    self.__ActionButton:SetAttribute("item", itemLink)
    self.__ActionButton:SetScript("OnLeave", function()
      GameTooltip:Hide()
    end)
    self.__ActionButton:SetScript("OnEnter", function()
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:SetHyperlink(itemLink)
        GameTooltip:Show()
    end)
  end

  function SetItemTexture(self, texture)
    self.__Texture:SetTexture(texture)
  end
  
  function OnAcquire(self)
    self:Show()
  end

  function OnRelease(self)
    self:Hide()
    self:ClearAllPoints()
    self:SetParent()

    self.__ActionButton:SetScript("OnLeave", nil)
    self.__ActionButton:SetScript("OnEnter", nil)
  end
  -----------------------------------------------------------------------------
  --                            Constructors                                 --
  -----------------------------------------------------------------------------
  function __ctor(self, name, ...)

    local actionButton = CreateFrame("Button", name.."ActionButton", self, "SecureActionButtonTemplate")

    -- local actionButton = Button(name.."Action", self, "SecureActionButtonTemplate")
    actionButton:SetAllPoints()
    self.__ActionButton = actionButton

    self:SetWidth(32)
    self:SetHeight(32)

    local texture = Texture(name.."Texture", self)
    texture:SetAllPoints()
    texture:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    self.__Texture = texture

    local cooldown = Cooldown(name.."Cooldown", self)
    cooldown:SetAllPoints()
    self.__Cooldown = cooldown
  end
end)
-- ========================================================================= --
class "ItemBarMover" (function(ENV)
  inherit "Frame"

  __Template__{
    TextFS = SLTFontString
  }
  function __ctor() end
end)
-- ========================================================================= --
class "ItemBar" (function(_ENV)
  inherit "Frame" extend "IView"
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  function OnViewUpdate(self, data)
    local itemIndex = 0


    wipe(self.itemButtonsID)
    wipe(self.itemButtonsOrder)

    if data.items then 
      for _, itemData in pairs(data.items) do 
        tinsert(self.itemButtonsOrder, itemData)
      end

      table.sort(self.itemButtonsOrder, function(a, b) 
        local aOrder, bOrder = a.order or 100,  b.order or 100 
        return aOrder < bOrder 
      end)

      local previousItemButton 
      for _, itemButtonData in ipairs(self.itemButtonsOrder) do 
        itemIndex = itemIndex + 1

        local id = itemButtonData.id 

        local itemButton = self:AcquireItemButton(id)

        if itemIndex > 1 then 
          itemButton:SetPoint("LEFT", previousItemButton, "RIGHT", 5, 0)
        else 
          itemButton:SetPoint("LEFT", 5, 0)
        end

        itemButton:SetItemLink(itemButtonData.link)
        itemButton:SetItemTexture(itemButtonData.texture)

        previousItemButton = itemButton

        self.itemButtonsID[id] = true
      end
    end 

    self:ReleaseUnusedItemButtons()
  end 

  function AcquireItemButton(self, id)
    local itemButton = self.itemButtonsCache[id]
    if not itemButton then
      itemButton = ItemButton.Acquire()
      itemButton:SetParent(self)

      self.itemButtonsCache[id] = itemButton
    end

    return itemButton
  end


  function ReleaseUnusedItemButtons(self)
    for itemButtonID, itemButton in pairs(self.itemButtonsCache) do
      if not self.itemButtonsID[itemButtonID] then
        itemButton:Release()

        self.itemButtonsCache[itemButtonID] = nil 
      end 
    end 
  end

  -- __Template__{}
  function __ctor(self)
    -- Keep in the cache the item buttons, to be reused
    -- use: self.itemButtonsCache[id] = ItemButton
    self.itemButtonsCache = setmetatable({}, { __mode = "v"})

    -- Get the current item button id list, used internally for releasing the 
    -- unused items
    self.itemButtonsID = {}

    -- Control the item order 
    self.itemButtonsOrder = {}
  end 
end)
-------------------------------------------------------------------------------
--                                Styles                                     --
-------------------------------------------------------------------------------
Style.UpdateSkin("Default", {
  [ItemBarMover] = {
    height = 26,
    backdrop = {
      bgFile = [[Interface\AddOns\SylingTracker\Media\Textures\LinearGradient]]
    },
    backdropColor = { r = 0, g = 1, b = 0, a = 0.3},

    location = {
      Anchor("BOTTOMLEFT", 0, 0, nil, "TOPLEFT"),
      Anchor("BOTTOMRIGHT", 0, 0, nil, "TOPRIGHT")
    },

    TextFS = {
      text = "Click here to move the Item Bar",
      setAllPoints = true,
      sharedMediaFont = FontType("PT Sans Narrow Bold", 13)
    }
  },

  [ItemBar] = {
    movable = true,
    backdrop = { 
        bgFile = [[Interface\AddOns\SylingTracker\Media\Textures\LinearGradient]],
    },
    backdropColor = { r = 35/255, g = 40/255, b = 46/255, a = 0.73},
  }
})
-------------------------------------------------------------------------------
--                             Enchance the API                              --
-------------------------------------------------------------------------------
class "API" (function(_ENV)
  __Static__() function ItemBar_AddItemData(id, data)
    data.id = id

    _ItemModel:AddData(data, "items", id)
  end

  __Static__() function ItemBar_SetItemData(id, data)
    data.id = id 

    _ItemModel:SetData(data, "items", id)
  end

  __Static__() function ItemBar_RemoveItemData(id)
    _ItemModel:RemoveData("items", id)
  end

  __Static__() function ItemBar_Update()
    _ItemModel:SecureFlush()
  end
end)
-- ========================================================================= --
function OnEnable(self)
  self:NonCombatLoad()
end

__NoCombat__()
function NonCombatLoad(self)
  -- Create the item bar
  _ItemBar = ItemBar("SylingTracker_ItemBar", UIParent)
  _ItemBar:SetWidth(250)
  _ItemBar:SetHeight(34)
  _ItemBar:SetPoint("CENTER", 200, 0)
  _ItemBar:SetMovable(true)

  -- Create the Item bar mover
  _ItemBarMover = ItemBarMover("SylingTracker_ItemBarMover", _ItemBar)
  _ItemBarMover:SetScript("OnMouseUp", function(f)
    _ItemBar:StopMovingOrSizing()

    local top   = _ItemBar:GetTop()
    local left  = _ItemBar:GetLeft()

    Profiles.PrepareDatabase()
    if Database.SelectTable(true, "itemBar") then 
      Database.SetValue("xPos", left)
      Database.SetValue("yPos", top)
    end 
  end)

  _ItemBarMover:SetScript("OnMouseDown", function(f)
    _ItemBar:StartMoving()
  end)

  Profiles.PrepareDatabase()
  local xPos, yPos, locked, hidden
  if Database.SelectTable(false, "itemBar") then 
    xPos    = Database.GetValue("xPos")
    yPos    = Database.GetValue("yPos")
    locked  = Database.GetValue("locked")
    hidden  = Database.GetValue("hidden")
  end
  
  if not xPos and not yPos then 
    _ItemBar:SetPoint("TOPRIGHT", -175, -190)
  else 
    _ItemBar:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", xPos or 0, yPos or 0)
  end

  if locked then 
    self:LockItemBar()
  else
    self:UnlockItemBar()
  end

  if hidden then 
    self:HideItemBar()
  end

  DB_READ_ONLY = false

  _ItemModel:AddView(_ItemBar)
end
-- ========================================================================= --
-- Debug Utils Tools
-- ========================================================================= --
if ViragDevTool_AddData then 
  ViragDevTool_AddData(_ItemModel, "SLT Item Model")
end


__SystemEvent__ "SLT_LOCK_ITEMBAR"
__NoCombat__()
function LockItemBar()
  _ItemBarMover:Hide()

  _ItemBar:SetMovable(true)
  Style[_ItemBar].backdropColor = { r = 0, g = 1, b = 0, a = 0}


  if not DB_READ_ONLY then 
    Profiles.PrepareDatabase()
    if Database.SelectTable(true, "itemBar") then 
      Database.SetValue("locked", true)
    end
  end
end

__SystemEvent__ "SLT_UNLOCK_ITEMBAR"
__NoCombat__()
function UnlockItemBar()
  _ItemBarMover:Show()

  _ItemBar:SetMovable(false)
  Style[_ItemBar].backdropColor = nil

  if not DB_READ_ONLY then 
    Profiles.PrepareDatabase()
    if Database.SelectTable(true, "itemBar") then 
      Database.SetValue("locked", false)
    end 
  end
end

__SystemEvent__"SLT_TOGGLE_ANCHORS"
__SystemEvent__ "SLT_TOGGLE_LOCK_ITEMBAR"
function ToogleLocking()
  if _ItemBarMover:IsShown() then 
    _M:LockItemBar()
  else 
    _M:UnlockItemBar()
  end
end

__SystemEvent__()
function SLT_SHOW_ANCHORS()
  _M:UnlockItemBar()
end

__SystemEvent__()
function SLT_HIDE_ANCHORS()
  if _ItemBarMover:IsShown() then 
    _M:LockItemBar()
  end
end

__SystemEvent__ "SLT_SHOW_ITEMBAR"
__NoCombat__()
function ShowItemBar()
  _ItemBar:Show()

  if not DB_READ_ONLY then 
    Profiles.PrepareDatabase()
    if Database.SelectTable(true, "itemBar") then 
      Database.SetValue("hidden", false)
    end
  end
end

__SystemEvent__ "SLT_HIDE_ITEMBAR"
__NoCombat__()
function HideItemBar()
  _ItemBar:Hide()

  if not DB_READ_ONLY then 
    Profiles.PrepareDatabase()
    if Database.SelectTable(true, "itemBar") then 
      Database.SetValue("hidden", true)
    end
  end
end

__SystemEvent__ "SLT_TOGGLE_ITEMBAR"
__NoCombat__()
function ToggleItemBar()
  if _ItemBar:IsShown() then
    HideItemBar()
  else
    ShowItemBar()
  end
end
-------------------------------------------------------------------------------
-- Enhancing the API                                                         --
-------------------------------------------------------------------------------
_Module = _M
class "SLT.API" (function(_ENV)

  __Static__() function ItemBarIsLocked()
    return not _ItemBarMover:IsShown()
  end

  __Static__() function LockItemBar()
    _Module:LockItemBar()
  end

  __Static__() function UnlockItemBar()
    _Module:UnlockItemBar()
  end

  __Static__() function ItemBarIsShown()
    return _ItemBar:IsShown()
  end

  __Static__() function ShowItemBar()
    _Module:ShowItemBar()
  end

  __Static__() function HideItemBar()
    _Module:HideItemBar()
  end
end)
