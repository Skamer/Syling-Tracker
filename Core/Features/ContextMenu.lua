-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                "SylingTracker.Features.ContextMenu"                   ""
-- ========================================================================= --
enum "ContextMenuPatternItemType" {
  "action",
  "separator"
}

struct "ContextMenuPatternItemInfo" {
  { name = "id", type = String},
  { name = "text", type = String, default = ""},
  { name = "handler", type = Function + String}, 
  { name = "order", type = Number, default = 100},
  { name = "icon", type = MediaTextureType },
  { name = "type", type = ContextMenuPatternItemType, default = "action"}, 
  { name = "isDisabled", type = Boolean + Function + String, default = false},
  { name = "isShown", type = Boolean + Function + String, default = true},
  { name = "isSecure", type = Boolean, default = false },
}
Interface "IContextMenuItem"(function(_ENV)
  __Arguments__{ ContextMenuPatternItemInfo, Any * 0}
  function UpdateData(self, data, ...) end 
end)

__UIElement__()
class "ContextMenuAction" (function(_ENV)
  inherit "Button" extend "IContextMenuItem"
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  __Arguments__{ ContextMenuPatternItemInfo, Any * 0}
  function UpdateData(self, data, ...)
    Style[self].Icon.mediaTexture = data.icon
    Style[self].Text.text = data.text

    if data.handler then
      local args = { ... } 
      self.OnClick = function()
        data.handler(unpack(args))
        API.ContextMenu_Close()
      end
    end
  end 
  -----------------------------------------------------------------------------
  --                            Constructors                                 --
  -----------------------------------------------------------------------------
  __Template__ {
    Icon = Texture,
    Text = FontString
  }
  function __ctor(self) end
end)

__UIElement__()
class "ContextMenuSeparator" (function(_ENV)
  inherit "Frame" extend "IContextMenuItem"
end)

__UIElement__()
class "ContextMenu" (function(_ENV)
  inherit "Frame"
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  function AcquireItem(self, type)
    local item = type.Acquire()
    self.Items[item] = true 

    return item
  end

  function ReleaseItems(self)
    for obj in pairs(self.Items) do 
      obj:Release()
    end
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  property "Items" { 
    set = false,
    default = function() return Toolset.newtable(true, false) end
  }
  -----------------------------------------------------------------------------
  --                            Constructors                                 --
  -----------------------------------------------------------------------------
  function __ctor(self) 
    self.OnHide = self.OnHide + function()
      self:ReleaseItems()
    end
  end
end)
-------------------------------------------------------------------------------
--                                Styles                                     --
-------------------------------------------------------------------------------
Style.UpdateSkin("Default", {

  [ContextMenuAction] = {
    height  = 24,
    Icon    = {
      size = Size(16, 16),
      location = {
        Anchor("LEFT")
      }
    },
    Text = {
      text      = "",
      mediaFont = FontType("PT Sans Narrow Bold", 13),
      textColor = Color(0.8, 0.8, 0.8),
      justifyH  = "LEFT",      
      location  = {
        Anchor("TOP"),
        Anchor("LEFT", 5, 0, "Icon", "RIGHT"),
        Anchor("RIGHT"),
        Anchor("BOTTOM")
      }
    },

    HighlightTexture = {
      file = [[Interface\AddOns\SylingTracker\Media\Textures\LinearGradient]],
      vertexColor = { r = 0, g = 148/255, b = 1, a = 0.35},
      setAllPoints = true,
    },
  },

  [ContextMenuSeparator] = {
    height = 2,
    backdrop = {
      bgFile = [[Interface\AddOns\SylingTracker\Media\Textures\LinearGradient]],
    },
    backdropColor       = { r = 1, g = 1, b = 1, a = 0.15},    
  },

  [ContextMenu] = {
    layoutManager = Layout.VerticalLayoutManager(true, true),
    width         = 175,
    height        = 1,
    backdrop      = {
      bgFile              = [[Interface\AddOns\SylingTracker\Media\Textures\LinearGradient]],
      edgeFile            = [[Interface\Buttons\WHITE8X8]],
      edgeSize            = 1   
    },
    backdropColor       = { r = 0, g = 0, b = 0, a = 0.6},
    backdropBorderColor = { r = 0, g = 0, b = 0, a = 0.85},
    hitRectInsets = {
      top     = -30,
      left    = -30,
      bottom  = -30,
      right   = -30
    }
  }
})
-------------------------------------------------------------------------------
--                                   API                                     --
-------------------------------------------------------------------------------
CONTEXT_MENU_PATTERNS = {}
CONTEXT_MENU = ContextMenu("SylingTracker_ContextMenu", UIParent)
CONTEXT_MENU:Hide()
CONTEXT_MENU.OnLeave = function(f)
  if not f:IsMouseOver() then 
    f:Hide()
  end
end

__Iterator__()
function IteratePaternItems(pattern, ...)
  local yield = coroutine.yield
  local count = 0

  for index, itemInfo in List(pattern):Sort("a,b=>a.order<b.order"):GetIterator() do
    local patternItemInfo = ContextMenuPatternItemInfo(itemInfo)

    local isShown 
    if type(itemInfo.isShown) == "function" then 
      isShown = itemInfo.isShown(...)
    else 
      isShown = itemInfo.isShown
    end

    if isShown then 
      count = count + 1
      yield(count, patternItemInfo)
    end
  end
end

--- Hide the context menu
__Static__() function API.ContextMenu_Close()
  CONTEXT_MENU:Hide()
end

--- Show the context menu
---
--- @param patternID the id of pattern to use for feeding the context menu content
--- @param frameToAnchor the frame where the contextMenu will be anchored
--- @param ... the remaining args will be pushed to multiple handlers.
__Static__() function API.ContextMenu_Show(patternID, frameToAnchor, ...)
  local pattern = CONTEXT_MENU_PATTERNS[patternID]

  if not pattern then 
    return 
  end

  if CONTEXT_MENU:IsShown() then 
    CONTEXT_MENU:Hide()
  end

  for index, itemInfo in IteratePaternItems(pattern, ...) do
    local item
    if itemInfo.type == "separator" then 
      item = CONTEXT_MENU:AcquireItem(ContextMenuSeparator)
    else
      item = CONTEXT_MENU:AcquireItem(ContextMenuAction)
    end

    item:SetID(index)
    item:SetParent(CONTEXT_MENU)
    item:UpdateData(itemInfo, ...)
  end

  -- Check the best side 
  if frameToAnchor:GetRight() < (GetScreenWidth() / 2) then 
    CONTEXT_MENU:SetPoint("TOPLEFT", frameToAnchor, "TOPRIGHT", 15, 0)
  else
    CONTEXT_MENU:SetPoint("TOPRIGHT", frameToAnchor, "TOPLEFT", -15, 0)
  end

  -- HACK: For fixing an issue with the background not appear sometimes.
  CONTEXT_MENU:InstantApplyStyle()

  CONTEXT_MENU:Show()
end

--- Register a pattern for a context menu
--- 
--- @param patternID the pattern id
--- @param patternInfo the pattern defenitions
__Arguments__{ String, Table }
__Static__() function API.ContextMenu_RegisterPattern(patternID, patternInfo)
  if CONTEXT_MENU_PATTERNS[patternID] then 
    return 
  end

  CONTEXT_MENU_PATTERNS[patternID] = patternInfo
end

--- Return a iterator for the registered pattern
__Static__() function API.ContextMenu_IteratePattern()
  return pairs(CONTEXT_MENU_PATTERNS)
end

--- Get the pattern info for a pattern ind 
---
--- @param patternID the pattern id to fetch the pattern info
__Static__() function API.ContextMenu_GetPattern(patternID)
  return CONTEXT_MENU_PATTERNS[patternID]
end