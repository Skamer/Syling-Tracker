-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                  "SylingTracker.UIElements.ContentView"               ""
-- ========================================================================= --
namespace                           "SLT"
-- ========================================================================= --
-- Iterator helper for ignoring the children are used for backdrop, and avoiding
-- they are taken as account for their parent height
IterateFrameChildren  = Utils.IterateFrameChildren
-- ========================================================================= --
ResetStyles           = Utils.ResetStyles
-- ========================================================================= --
class "ContentView" (function(_ENV)
  inherit "Frame" extend "IView"
  -----------------------------------------------------------------------------
  --                               Handlers                                  --
  -----------------------------------------------------------------------------
  __Async__()
  function OnAdjustHeight(self, useAnimation)
    -- First, we need to compute the content height
    local content = self:GetChild("Content")
    local contentMaxOuterBottom
    for childName, child in IterateFrameChildren(content) do 
      local outerBottom = child:GetBottom()
      if outerBottom then 
        if not contentMaxOuterBottom or contentMaxOuterBottom > outerBottom then 
            contentMaxOuterBottom = outerBottom
        end 
      end 
    end

    if contentMaxOuterBottom then 
      local computeHeight = content:GetTop() - contentMaxOuterBottom + self.ContentPaddingBottom
      content:SetHeight(computeHeight)
    end

    -- We need to wait the next "OnUpdate" for the "Self" frame take as 
    -- account the new content height has been computed.
    Next()


    -- And to finish, we compute the "Self" height
    local maxOuterBottom 
    for childName, child in IterateFrameChildren(self) do
      if child then 
        local outerBottom = child:GetBottom() 
        if outerBottom then 
          if not maxOuterBottom or maxOuterBottom > outerBottom then 
            maxOuterBottom = outerBottom
          end 
        end
      end
    end
    
    if maxOuterBottom then
      local computeHeight = self:GetTop() - maxOuterBottom + self.PaddingBottom
      if useAnimation then 
        self:SetAnimatedHeight(computeHeight)
      else 
        self:SetHeight(computeHeight)
      end
    end
  end

  function OnRelease(self)
    local content = self:GetChild("Content")

    self:ClearAllPoints()
    self:SetParent()
    self:Hide()

    -- "CancelAdjustHeight" and "CancelAnimatingHeight" wiil cancel the pending
    -- computing stuff for height, so they not prevent "SetHeight" here doing 
    -- its stuff.
    self:CancelAdjustHeight()
    self:CancelAnimatingHeight()
    self:SetHeight(1)
    content:SetHeight(1)

    -- Will Remove all custom styles properties, so the next time the object will
    -- be used, this one will be in a clean state
    ResetStyles(self)
    ResetStyles(content)
  end

  function OnAcquire(self)
    -- Important ! We need the frame is instantly styled as this may affect 
    -- its height.
    self:InstantApplyStyle()

    self:Show()
    self:AdjustHeight(true)
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  property "Expanded" {
    type    = Boolean,
    default = true
  }

  property "ContentPaddingBottom" {
    type = Number,
    default = 10
  }

  property "PaddingBottom" {
    type = Number,
    default = 0
  }
  -----------------------------------------------------------------------------
  --                            Constructors                                 --
  -----------------------------------------------------------------------------
  __Template__ {
    Header  = Frame,
    Content = Frame,
    {
      Header = {
        IconBadge = IconBadge,
        Label     = SLTFontString
      }
    },
  }
  function __ctor(self) 
    -- Important! As the frame ajusts its height depending of its children height
    -- we need to set its height when contructed for the event "OnSizechanged" of
    -- its children is triggered.
    self:SetHeight(1) -- !important

    self:SetClipsChildren(true)

    local content = self:GetChild("Content")
    content:SetHeight(1)
  end
end)
-------------------------------------------------------------------------------
--                                Styles                                     --
-------------------------------------------------------------------------------
Style.UpdateSkin("Default", {
  [ContentView] = {
    Header = {
      height = 32,
      backdrop = {
        bgFile    = [[Interface\AddOns\SylingTracker\Media\Textures\LinearGradient]],
        edgeFile  = [[Interface\Buttons\WHITE8X8]],
        edgeSize  = 1        
      },
      backdropColor       = { r = 18/255, g = 20/255, b = 23/255, a = 0.87},
      backdropBorderColor = { r = 0, g = 0, b = 0, a = 1},
      location = {
        Anchor("TOP"),
        Anchor("LEFT"),
        Anchor("RIGHT")
      },

      IconBadge = {
        location = {
          Anchor("LEFT", 6, 0)
        },
      },

      Label = {
        sharedMediaFont = FontType("PT Sans Narrow Bold", 16),
        textColor       = Color(0.18, 0.71, 1),
        justifyH        = "CENTER",
        justifyV        = "MIDDLE",
        location        = {
          Anchor("TOP"),
          Anchor("LEFT", 0, 0, "IconBadge", "RIGHT"),
          Anchor("RIGHT"),
          Anchor("BOTTOM")        
        }
      },
    },

    Content = {
      location = {
        Anchor("TOP", 0, 0, "Header", "BOTTOM"),
        Anchor("LEFT"),
        Anchor("RIGHT")
      }
    }
  }
})