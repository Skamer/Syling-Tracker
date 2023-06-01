-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                     "SylingTracker.Core.Button"                       ""
-- ========================================================================= --
export {
   TryToComputeHeightFromChildren = Utils.Frame_TryToComputeHeightFromChildren,
}

class "Button" (function(_ENV)
  inherit "Scorpio.UI.Button" extend "ISizeAnimation" "IQueueAdjustHeight"
  -----------------------------------------------------------------------------
  --                               Handlers                                  --
  -----------------------------------------------------------------------------
  local function OnChildChanged(self, child, isAdd)
    if isAdd then 
      if child.OnSizeChanged then 
        child.OnSizeChanged = child.OnSizeChanged + self.OnSelfAdjustHeight
      end 

      if child.OnTextHeightChanged then 
        child.OnTextHeightChanged = child.OnTextHeightChanged + self.OnSelfAdjustHeight
      end
    else
      if child.OnSizeChanged then 
        child.OnSizeChanged = child.OnSizeChanged - self.OnSelfAdjustHeight 
      end

      if child.OnTextHeightChanged then 
        child.OnTextHeightChanged = child.OnTextHeightChanged - self.OnSelfAdjustHeight
      end
    end

    if self.AutoHeight then 
      self:AdjustHeight() 
    end
  end
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  function OnAdjustHeight(self)
    local height = TryToComputeHeightFromChildren(self)
    self:SetHeight(height or 0)
  end

  function OnRelease(self)
    self:Hide()
    self:SetParent()
    self:ClearAllPoints()

    self:CancelAnimatingHeight()
    self:CancelAnimatingWidth()
  end

  function OnAcquire(self)
    self:Show()
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  property "AutoHeight" {
    type    = Boolean,
    default = false,
  }
  -----------------------------------------------------------------------------
  --                            Constructors                                 --
  -----------------------------------------------------------------------------
  function __ctor(self)
    self.OnChildChanged = self.OnChildChanged + OnChildChanged
    self.OnSelfAdjustHeight = function()
      if self.AutoHeight then 
        self:AdjustHeight() 
      end
    end
  end

end)

__ChildProperty__( Button, "Background")
class "Background"{ Texture }

__ChildProperty__( Button, "TopBorder")
class "TopBorder" { Texture }

__ChildProperty__ (Button, "BottomBorder")
class "BottomBorder" { Texture }

__ChildProperty__ (Button, "LeftBorder")
class "LeftBorder" { Texture }

__ChildProperty__ ( Button, "RightBorder")
class "RightBorder" { Texture }

__ChildProperty__ (Button, "TopLeftBorder")
class "TopLeftBorder" { Texture }

__ChildProperty__ (Button, "TopRightBorder")
class "TopRightBorder" { Texture }

__ChildProperty__ (Button, "BottomLeftBorder")
class "BottomLeftBorder" { Texture }

__ChildProperty__ (Button, "BottomRightBorder")
class "BottomRightBorder" { Texture }

-------------------------------------------------------------------------------
--                                Styles                                     --
-------------------------------------------------------------------------------
Style.UpdateSkin("Default", {
  [Button] = {
    [Background] = {
      file = "Interface\\Buttons\\WHITE8X8",
      drawLayer = "BACKGROUND",
      vertexColor = Color.BLACK,
      setAllPoints = true,
    },

    -- Corner
    [TopLeftBorder] = {
      width = 4, 
      height = 4,
      file = "Interface\\Buttons\\WHITE8X8",
      drawLayer = "BORDER",
      vertexColor = Color.RED,
      location = {
        Anchor("BOTTOMRIGHT", 0, 0, nil, "TOPLEFT")
      }      
    },

    [TopRightBorder] = {
      width = 4, 
      height = 4,
      file = "Interface\\Buttons\\WHITE8X8",
      drawLayer = "BORDER",
      vertexColor = Color.GREEN,
      location = {
        Anchor("BOTTOMLEFT", 0, 0, nil , "TOPRIGHT")
      }      
    },

    [BottomLeftBorder] = {
      width = 4, 
      height = 4,
      file = "Interface\\Buttons\\WHITE8X8",
      drawLayer = "BORDER",
      vertexColor = Color.YELLOW,
      location = {
        Anchor("TOPRIGHT", 0, 0, nil, "BOTTOMLEFT")
      }     
    },

    [BottomRightBorder] = {
      width = 4,
      height = 4,
      file = "Interface\\Buttons\\WHITE8X8",
      drawLayer = "BORDER",
      vertexColor = Color.BLUE,
      location = {
        Anchor("TOPLEFT", 0, 0, nil, "BOTTOMRIGHT")
      }
    },

    -- Edges
    [TopBorder] =  {
      file = "Interface\\Buttons\\WHITE8X8",
      drawLayer = "BORDER",
      vertexColor = Color.WHITE,
      location = {
        Anchor("TOPLEFT", 0, 0, "TopLeftBorder", "TOPRIGHT"),
        Anchor("BOTTOMRIGHT", 0, 0, "TopRightBorder", "BOTTOMLEFT")
      }
    },
    [BottomBorder]=  {
      file = "Interface\\Buttons\\WHITE8X8",
      drawLayer = "BORDER",
      vertexColor = Color.WHITE,
      location = {
        Anchor("TOPLEFT", 0, 0, "BottomLeftBorder", "TOPRIGHT"),
        Anchor("BOTTOMRIGHT", 0, 0, "BottomRightBorder", "BOTTOMLEFT")
      }
    },
    [LeftBorder] =  {
      file = "Interface\\Buttons\\WHITE8X8",
      drawLayer = "BORDER",
      vertexColor = Color.WHITE,
      location = {
        Anchor("TOPLEFT", 0, 0, "TopLeftBorder", "BOTTOMLEFT"),
        Anchor("BOTTOMRIGHT", 0, 0, "BottomLeftBorder", "TOPRIGHT")
      }
    },
    [RightBorder] =  {
      file = "Interface\\Buttons\\WHITE8X8",
      drawLayer = "BORDER",
      vertexColor = Color.WHITE,
      location = {
        Anchor("TOPLEFT", 0, 0, "TopRightBorder", "BOTTOMLEFT"),
        Anchor("BOTTOMRIGHT", 0, 0, "BottomRightBorder", "TOPRIGHT")
      }
    }
  }
})
