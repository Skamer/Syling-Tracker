-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Scorpio                 "SylingTracker.UIElements.ContentView"               ""
-- ========================================================================= --
namespace                           "SLT"
-- ========================================================================= --
-- Iterator helper for ignoring the children are used for backdrop, and avoiding
-- they are taken as account for their parent height
IterateFrameChildren  = Utils.IterateFrameChildren
-- ========================================================================= --
class "ContentView" (function(_ENV)
  inherit "Frame" extend "IView"
  -----------------------------------------------------------------------------
  --                               Handlers                                  --
  -----------------------------------------------------------------------------
  function Expand(self)
    self.Expanded = true

    local icon = self:GetChild("Header"):GetChild("ExpandedIcon")

    Style[icon].atlas = AtlasType("NPE_ArrowUpGlow")
      
    -- -- Hide the content 
    -- content:Show() 

    -- Adjust the height
    self:ForceAdjustHeight(true)
  end

  function Collapse(self)
    self.Expanded = false

    local icon = self:GetChild("Header"):GetChild("ExpandedIcon")
    Style[icon].atlas = AtlasType("NPE_ArrowDownGlow")

    -- -- Show the content
    -- content:Hide()

    self:ForceAdjustHeight(true)
  end

  
  __Async__() function AdjustContentHeight(self)
    local content = self:GetChild("Content")
    local maxOuterBottom
    local hasChild = false

    for childName, child in content:GetChilds() do
      hasChild = true
      local outerBottom = child:GetBottom() 
      if outerBottom then 
        if not maxOuterBottom or maxOuterBottom > outerBottom then 
          maxOuterBottom = outerBottom
        end 
      end 
    end
    
    if maxOuterBottom then 
      local computeHeight = content:GetTop() - maxOuterBottom + self.PaddingBottom
       content:SetHeight(computeHeight)
    end
    -- elseif not maxOuterBottom and hasChild then
    --   -- If there is atleast a child, and the bottom isn't avalaible, we need
    --   -- to recall this function after the next "OnUpdate" until we get one.
    --   print("Recall")
    --   Next()
    --   self:AdjustContentHeight()
    -- end
  end

  function OnAdjustHeight(self, useAnimation)
    local content = self:GetChild("Content")
    if self.Expanded then 
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
        local computeHeight = content:GetTop() - contentMaxOuterBottom
        content:SetHeight(computeHeight)
      end
    end

    local maxOuterBottom 
    for childName, child in IterateFrameChildren(self) do
      if child ~= content or (content and self.Expanded) then 
        local outerBottom = child:GetBottom() 
        if outerBottom then 
          if not maxOuterBottom or maxOuterBottom > outerBottom then 
            maxOuterBottom = outerBottom
          end 
        end
      end
    end
    
    if maxOuterBottom then
      local paddingBottom = 0
      if self.Expanded then 
        paddingBottom = self.PaddingBottom
        print("PaddingBottom expanded")
      end
      
      local computeHeight = self:GetTop() - maxOuterBottom + paddingBottom
      if useAnimation then 
        self:SetAnimatedHeight(computeHeight)
      else 
        self:SetHeight(computeHeight)
      end
    end
  end


  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  property "Expanded" {
    type    = Boolean,
    default = true
  }

  __Template__ {
    Header  = Button,
    Content = Frame,
    {
      Header = {
        IconBadge = IconBadge,
        Label     = SLTFontString,
        ExpandedIcon = Texture
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
    -- content.OnSizeChanged = function() self:AdjustHeight(true) end
    content:InstantApplyStyle()

    local header = self:GetChild("Header")
    header.OnClick = function(_, button)
      print("OnClick")
      if button == "LeftButton" then 
        if self.Expanded then 
          self:Collapse()
        else 
          self:Expand()
        end
      end
    end


        -- Important ! We need the frame is instantly styled as this may affect 
    -- its height.
    self:InstantApplyStyle()

    self:Show()
    -- self:AdjustContentHeight()
    self:AdjustHeight(true)
  end
end)


Style.UpdateSkin("Default", {
  [ContentView] = {

    Header = {
      height = 32,
      registerForClicks = { "LeftButtonDown" },
      backdrop = {
        bgFile = [[Interface\AddOns\SylingTracker\Media\Textures\LinearGradient]],
        edgeFile = [[Interface\Buttons\WHITE8X8]],
        edgeSize = 1        
      },
      backdropColor = { r = 20/255, g = 20/255, b = 20/255, a = 0.73},
      backdropBorderColor = { r = 0, g = 0, b = 0, a = 1},

      IconBadge = {
        location = {
          Anchor("LEFT", 6, 0)
        },

      },

      ExpandedIcon = {
        width = 12,
        height = 12,
        atlas = AtlasType("NPE_ArrowUpGlow"),
        location = {
          Anchor("RIGHT", -6, 0)
        }
      },

      Label = {
        sharedMediaFont = FontType("PT Sans Narrow Bold", 16),
        textColor = Color(0.18, 0.71, 1),
        justifyH = "CENTER",
        justifyV = "MIDDLE",
        location = {
          Anchor("TOP"),
          Anchor("LEFT", 0, 0, "IconBadge", "RIGHT"),
          Anchor("RIGHT", 0, 0, "ExpandedIcon", "LEFT"),
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