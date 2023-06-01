-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                     "SylingTracker.Core.Frame"                        ""
-- ========================================================================= --
export {
   TryToComputeHeightFromChildren = Utils.Frame_TryToComputeHeightFromChildren,
}

class "Frame" (function(_ENV)
  inherit "Scorpio.UI.Frame" extend "ISizeAnimation" "IQueueAdjustHeight" 
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


__ChildProperty__( Frame, "Background")
class "Background"{ Texture }

__ChildProperty__( Frame, "TopBorder")
class "TopBorder" { Texture }

__ChildProperty__ (Frame, "BottomBorder")
class "BottomBorder" { Texture }

__ChildProperty__ (Frame, "LeftBorder")
class "LeftBorder" { Texture }

__ChildProperty__ ( Frame, "RightBorder")
class "RightBorder" { Texture }

__ChildProperty__ (Frame, "TopLeftBorder")
class "TopLeftBorder" { Texture }

__ChildProperty__ (Frame, "TopRightBorder")
class "TopRightBorder" { Texture }

__ChildProperty__ (Frame, "BottomLeftBorder")
class "BottomLeftBorder" { Texture }

__ChildProperty__ (Frame, "BottomRightBorder")
class "BottomRightBorder" { Texture }
-------------------------------------------------------------------------------
--                                Styles                                     --
-------------------------------------------------------------------------------
Style.UpdateSkin("Default", {
  [Frame] = {
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
