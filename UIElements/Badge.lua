-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                  "SylingTracker.UIElements.Badge"                     ""
-- ========================================================================= --
namespace                           "SLT"
-- ========================================================================= --
-- Helper function for resetting the styles
ClearStyles         = Utils.ClearStyles

ResetStyles = Utils.ResetStyles

__Recyclable__ "SylingTracker_IconBadge%d"
class "IconBadge" (function(_ENV)
  inherit "Frame"

  function OnRelease(self)
    self:Hide()
    self:ClearAllPoints()
    self:SetParent()

    ResetStyles(self, true)
  end

  function OnAcquire(self)
    self:Show()
  end

  __Template__{
    Icon = Texture 
  }
  function __ctor(self) end

end)

__Recyclable__ "SylingTracker_TextBadge%d"
class "TextBadge" (function(_ENV)
  inherit "Frame"

  function OnRelease(self)
    self:Hide()
    self:ClearAllPoints()
    self:SetParent()

    ResetStyles(self, true)
  end

  function OnAcquire(self)
    self:Show()
  end

  __Template__ {
    Label = SLTFontString
  }
  function __ctor(self) end
end)

class "Badge" (function(_ENV)
  inherit "Frame"

  _Recycler = Recycle(Badge, "SylingTracker_Badge%d")

  local function HideLabelHandler(self, new, old, prop)
    local labelFrame = self:GetChild("Label")

    if not new then 
      ClearStyles(labelFrame, self.HideTextStyles)
      labelFrame:Show()
      return
    end 

    local styles = self.HideTextStyles
    if new and styles then 
      Style[self] = styles
      labelFrame:Hide()
    end
  end

  local function HideIconHandler(self, new, old, prop)
    local iconFrame = self:GetChild("Icon")

    if not new then 
      ClearStyles(iconFrame, self.HideIconStyles)
      iconFrame:Show()
      return 
    end 

    local styles = self.HideIconStyles
    if new and styles then 
      Style[self] = styles
      iconFrame:Hide()
    end 
  end 
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  function Release(self)
    self:ClearAllPoints()
    self:SetParent()
    self:Hide()

    _Recycler(self)
  end
  
  __Static__() function Acquire(self)
    local obj = _Recycler()
    obj:Show() 

    return obj 
  end

  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  property "HideLabel" {
    type = Boolean, 
    default = false,
    handler = HideLabelHandler
  }

  property "HideIcon" {
    type = Boolean,
    default = false,
    handler = HideIconHandler
  }

  property "HideIconStyles" {
    type = Table
  }

  property "HideTextStyles" {
    type = Table
  }

  __Template__ {
    Label = SLTFontString,
    Icon  = Texture
  }
  function __ctor() end

end)


Style.UpdateSkin("Default", {
  [IconBadge] = {
    height = 24,
    width  = 24,
    Icon = {
      setAllPoints = true
    },
  },
  [TextBadge] = {
    height = 16,
    width  = 30,

    Label = {
      sharedMediaFont = FontType("PT Sans Caption Bold", 10),
      shadowOffset = { x = 0.5, y = 0},
      shadowColor = Color(0, 0, 0, 1),
      setAllPoints = true
    }
  }
})


Style.UpdateSkin("Default", {
  [Badge] = {
    height  = 16,
    width   = 30,
    backdrop = {
      bgFile = [[Interface\AddOns\SylingTracker\Media\Textures\LinearGradient]]
    },
    backdropColor = { r = 160/255, g = 160/255, b = 160/255, a = 0.5},

    Icon = {
      atlas = AtlasType("groupfinder-icon-greencheckmark"),
      size = Size(10, 10),
      location = {
        Anchor("LEFT")
      }
    },
    Label = {
      font = FontType([[Interface\AddOns\SylingTracker\Media\Fonts\PTSans-Caption-Bold.ttf]], 10),
      shadowOffset = { x = 0.5, y = 0},
      shadowColor = Color(0, 0, 0, 1),
      location = {
        Anchor("TOP"),
        Anchor("LEFT", 0, 0, "Icon", "RIGHT"),
        Anchor("BOTTOM"),
        Anchor("RIGHT")
      }
    },

    HideIconStyles = {
      Label = {
        setAllPoints = true,
        justifyV = "MIDDLE",
        justifyH = "CENTER"
      }
    },

    HideTextStyles = {
      Icon = {
        location = {
          Anchor("CENTER")
        }
      }
    }
      
  }
})



-- Style.UpdateSkin("Default", {
--   [IconBadge] ={
--     backdrop = {
--       bgFile = [[Interface\AddOns\SylingTracker\Media\Textures\LinearGradient]]
--     },
--     Icon = {
--       setAllPoints = true
--     }
--   },
--   [TextBadge] = {
--     backdrop = {
--       bgFile = [[Interface\AddOns\SylingTracker\Media\Textures\LinearGradient]]
--     },
--     Text
--   }
-- })