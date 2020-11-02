-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                    "SylingTracker.UI.ContextMenu"                     ""
-- ========================================================================= --
namespace                          "SLT"
-- ========================================================================= --

enum "ContextMenuItemType" {
  "Action",
  "Separator"
}

struct "ContextMenuPatternItemInfo" (function(_ENV)
  member "id" { type = Number + String }
  member "text" { type = String, default = "" }
  member "handler" { type = Function }
  member "order" { tpye= Number, default = 100 }
  member "icon" { type = String + Table }
  member "type" { type = ContextMenuItemType }
  member "disabled" { type = Boolean + Function, default = false }
  member "isShown" { type = Boolean + Function, default = true }
end)


--- Contains the info relative to a context menu to build
class "ContextMenuPattern" (function(_ENV)
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  __Arguments__{ ContextMenuPatternItemInfo }
  function AddAction(self, info)
    info.type = "Action"
    self.Items:Insert(info)
  end

  __Arguments__ { Number }
  function AddSeparator(self, order)
    local info = ContextMenuPatternItemInfo()
    info.order = order 
    info.type = "Separator"
    self.Items:Insert(info)
  end 

  __Iterator__()
  function IterateItems(self)
    local yield = coroutine.yield

    local count = 0
    for index, itemInfo in self.Items:Sort("a,b=>a.order<b.order"):GetIterator() do
      local isShown
      if type(itemInfo.isShown) == "function" then 
        isShown = itemInfo.isShown() 
      else 
        isShown = itemInfo.isShown 
      end

      if isShown then 
        count = count + 1
        yield(count, itemInfo)
      end
    end
  end 
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  property "Items" { 
    default = function() return List() end
  }
end)

class "ContextMenuAction" (function(_ENV)
  inherit "Button"

  _Recycler = Recycle(ContextMenuAction, "SylingTracker_ContextMenuAction%d")
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  function Release(self)
    self:Hide()
    self:SetParent()
    self:ClearAllPoints()

    _Recycler(self)
  end 

  __Static__() function Acquire()
    local obj = _Recycler()
    obj:Show() 

    return obj
  end 
  -----------------------------------------------------------------------------
  --                            Constructors                                 --
  -----------------------------------------------------------------------------
  __Template__{
    Icon = Texture,
    Text = SLTFontString
  }
  function __ctor(self) self:InstantApplyStyle() end

end)

class "ContextMenuSeparator" (function(_ENV)
  inherit "Frame"

  _Recycler = Recycle(ContextMenuSeparator, "SylingTracker_ContextMenuSeparator%d")
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  function Release(self)
    self:Hide()
    self:SetParent()
    self:ClearAllPoints()

    _Recycler(self)
  end
  
  __Static__() function Acquire()
    local obj = _Recycler() 
    obj:Show()

    return obj 
  end
end)


class "ContextMenu" (function(_ENV)
  inherit "Frame"

  _ItemObjects = {
    [ContextMenuItemType.Action] = setmetatable({}, { __mode = "v"}),
    [ContextMenuItemType.Separator] = setmetatable({}, { __mode = "v"})
  }

  function AcquireItem(self, type, index)

    local obj = _ItemObjects[type][index]
    if not obj then 
      if type == ContextMenuItemType.Separator then
        obj = ContextMenuSeparator.Acquire() 
      else
        obj = ContextMenuAction.Acquire()
      end
    end

    _ItemObjects[type][index] = obj

    obj:SetParent(self)
    obj:Show()

    return obj
  end
  
  function ReleaseUnusedItems(self, type, releaseFromIndex)
    local objects = _ItemObjects[type]
    for index, obj in pairs(objects) do
      if index > releaseFromIndex then 
        obj:Release()
        objects[index] = nil
      end
    end 
  end 

  
end)

Style.UpdateSkin("Default", {
  [ContextMenu] = {
      width  = 175,
      backdrop = {
        bgFile = [[Interface\AddOns\SylingTracker\Media\Textures\LinearGradient]]
      },
      backdropColor = { r = 0, g = 0, b = 0, a = 0.6},
      hitRectInsets = {
        top = -30,
        left = -30,
        bottom = -30,
        right = -30
      }
  },
  [ContextMenuAction] = {
    height = 24,
    Icon = {
      size = Size(16, 16),
      atlas = AtlasType("communities-icon-redx"),
      location = {
        Anchor("TOPLEFT", 4, -4)
      }
    },
    Text = {
      location = {
        Anchor("TOP"),
        Anchor("LEFT", 24, 0),
        Anchor("RIGHT"),
        Anchor("BOTTOM")
      },
      -- font = FontType([[Interface\AddOns\EskaTracker2\Media\Fonts\PTSans-Narrow-Bold.ttf]], 13),
      sharedMediaFont = FontType("PT Sans Narrow Bold", 13),
      textColor = Color(0.8, 0.8, 0.8),
      justifyH = "LEFT",
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
      bgFile = [[Interface\AddOns\SylingTracker\Media\Textures\LinearGradient]]
    },
    backdropColor = {r = 1 , g = 1, b = 1, a = 0.15}
  }
})


_ContextMenu = ContextMenu("SylingTracker_ContextMenu", UIParent)
-- _ContextMenu:SetPoint("CENTER", 0, -200)

_ContextMenuArrow = Arrow.Acquire()
_ContextMenuArrow:SetParent(UIParent)
-- _ContextMenuArrow.Orientation = "RIGHT"
-- _ContextMenu:SetPoint("TOPRIGHT", _ContextMenuArrow, "LEFT", 5, 20)

_ContextMenuArrow:Hide()
_ContextMenu:Hide()



_ContextMenuPatterns = {}




class "API" (function(_ENV)
  __Static__() function CloseContextMenu()
    _ContextMenu:Hide()
    _ContextMenuArrow:Hide()
    _ContextMenu.OnUpdate = nil
  end

  __Static__() function ShowContextMenu(patternID, frameToAnchor, ...)
    local pattern = _ContextMenuPatterns[patternID]
    
    if not pattern then 
      return 
    end


    local args = { ... }

    local counts = {
      [ContextMenuItemType.Action] = 0,
      [ContextMenuItemType.Separator] = 0,
    }

    local height = 0 
    
    local previousItem 
    for index, itemInfo in pattern:IterateItems() do
      local i = counts[itemInfo.type] + 1
      counts[itemInfo.type] = i 
      local item = _ContextMenu:AcquireItem(itemInfo.type, i)
      item:ClearAllPoints()
      item:SetParent(_ContextMenu)

      if index == 1 then 
        item:SetPoint("TOP")
        item:SetPoint("LEFT")
        item:SetPoint("RIGHT")
      else
        item:SetPoint("TOP", previousItem, "BOTTOM")
        item:SetPoint("LEFT")
        item:SetPoint("RIGHT")
      end

      if itemInfo.type == ContextMenuItemType.Action then
        if itemInfo.handler then 
          item.OnClick = function() 
            itemInfo.handler(unpack(args))
            CloseContextMenu()
          end
        end
        
        Style[item].Text.text = itemInfo.text

        local iconType = type(itemInfo.icon)
        if iconType == "string" then 
          Style[item].Icon.file = itemInfo.icon 
        elseif iconType == "table" then 
          Style[item].Icon = itemInfo.icon
        end
      end 
          item:InstantApplyStyle()

      height = height + item:GetHeight()

      previousItem = item
    end

    _ContextMenu:SetHeight(height)

    _ContextMenuArrow:ClearAllPoints()
    _ContextMenu:ClearAllPoints()

    --  Check the best side 
    if frameToAnchor:GetRight() < (GetScreenWidth() / 2) then
      _ContextMenuArrow.Orientation = "LEFT"
      _ContextMenu:SetPoint("TOPLEFT", _ContextMenuArrow, "RIGHT", -5, 20)
      _ContextMenuArrow:SetPoint("LEFT", frameToAnchor, "RIGHT")
    else 
      _ContextMenuArrow.Orientation = "RIGHT"
      _ContextMenu:SetPoint("TOPRIGHT", _ContextMenuArrow, "LEFT", 5, 20)
      _ContextMenuArrow:SetPoint("RIGHT", frameToAnchor, "LEFT")
    end 

    _ContextMenuArrow:Show()
    _ContextMenu:Show()

    _ContextMenu.OnLeave = function(f)  
      if not f:IsMouseOver() then
        CloseContextMenu() 
      end
    end


    -- Release the items unused 
    for type, count in pairs(counts) do 
      _ContextMenu:ReleaseUnusedItems(type, count)
    end 
  end

  __Static__() function RegisterContextMenuPattern(patternID, pattern)
    _ContextMenuPatterns[patternID] = pattern
  end

  __Static__() function GetContextMenuPattern(patternID)
    return _ContextMenuPatterns[pattern]
  end
end)