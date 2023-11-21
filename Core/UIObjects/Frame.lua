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
  Round = Round,
  GetFrame = Wow.GetFrame,
}

class "Frame" (function(_ENV)
  inherit "Scorpio.UI.Frame" extend "IQueueAdjustHeight"
  -----------------------------------------------------------------------------
  --                            Helper functions                             --
  -----------------------------------------------------------------------------
  local function RegisterHandlersToChild(parent, child, handler)
    if child.OnSizeChanged then 
      child.OnSizeChanged = child.OnSizeChanged + handler
    end 

    if child.OnTextHeightChanged then 
      child.OnTextHeightChanged = child.OnTextHeightChanged + handler
    end
  end

  local function UnregisterHandlersFromChild(parent, child, handler)
    if child.OnSizeChanged then 
      child.OnSizeChanged = child.OnSizeChanged - handler
    end

    if child.OnTextHeightChanged then 
      child.OnTextHeightChanged = child.OnTextHeightChanged - handler
    end   
  end
  -----------------------------------------------------------------------------
  --                               Handlers                                  --
  -----------------------------------------------------------------------------
  local function OnStateChanged(self)
    local parent = self:GetParent()

    -- As the common frame (e.g, Scorpio RecycleHolder) can be a parent, we 
    -- need to check the parent has the 'AdjustHeight' method
    if parent and parent.AdjustHeight then
      parent:AdjustHeight()
    end
  end

  local function OnStyleAppliedHandler(self)
    if self.AdjustHeight then 
      self:AdjustHeight()
    end
  end

  local function OnChildChanged(self, child, isAdd, noAdjust)
    if isAdd then

      if child.OnSizeChanged then 
        child.OnSizeChanged = child.OnSizeChanged + OnStateChanged
      end

      if child.OnTextHeightChanged then 
        child.OnTextHeightChanged = child.OnTextHeightChanged + OnStateChanged
      end

      if child.OnStyleApplied then 
        child.OnStyleApplied = child.OnStyleApplied + OnStateChanged
      end
      
      child.OnShow        = child.OnShow + OnStateChanged
      child.OnHide        = child.OnHide + OnStateChanged
    else

      if child.OnSizeChanged then 
        child.OnSizeChanged = child.OnSizeChanged - OnStateChanged
      end

      if child.OnTextHeightChanged then 
        child.OnTextHeightChanged = child.OnTextHeightChanged - OnStateChanged 
      end

      if child.OnStyleApplied then 
        child.OnStyleApplied = child.OnStyleApplied - OnStateChanged
      end

      child.OnShow        = child.OnShow  - OnStateChanged
      child.OnHide        = child.OnHide  - OnStateChanged
    end
    
    return not noAdjust and self:AdjustHeight()
  end

  local function AdjustHeightHandler(self, new)
    if new then
      self.OnChildChanged = self.OnChildChanged + OnChildChanged
      self.OnStyleApplied = self.OnStyleApplied + OnStyleAppliedHandler

      for name, child in self:GetChildrenForAdjustment() do
        if self:ShouldSubscribeForAdjustment(child) then
          OnChildChanged(self, child, true, true)
        end
      end

      self:AdjustHeight()
    else
      self.OnChildChanged = self.OnChildChanged - OnChildChanged
      self.OnStyleApplied = self.OnStyleApplied - OnStyleAppliedHandler

      for name, child in self:GetChilds() do
        if self:ShouldSubscribeForAdjustment(child) then
          OnChildChanged(self, child, false)
        end
      end
    end
  end

  POINTS = { "TOP", "TOPLEFT", "TOPRIGHT"}
  function IsIgnoredForAdjustment(self, child)
    if not child:IsShown() then
      return true 
    end

    local prop = child:GetChildPropertyName()
    if prop and prop:match("^backdrop") then
      return true 
    end
  
    for _, point in ipairs(POINTS) do
      return false 
    end

    return true
  end

  function ShouldSubscribeForAdjustment(self, child)
    local prop = child:GetChildPropertyName()
    if prop and prop:match("^backdrop") then
      return false  
    end

    return true 
  end

  function OnAdjustHeight(self)
    -- If the height is 0, the children bottom will be incorrectly, so we 
    -- set our parent height to 1
    -- if self:GetHeight() == 0 then
    --   self:SetHeight(1)
    -- end

    local height, child = self:TryToComputeHeightFromChildren()
    if height then 
      self:SetHeight(height)
    end
  end

  __Iterator__()
  function GetChildrenForAdjustment(self)
    local yield = coroutine.yield
    for name, child in self:GetChilds() do 
      if not self:IsIgnoredForAdjustment(child) then 
        yield(name, child)
      end
    end
  end

  function TryToComputeHeightFromChildren(self)
    local maxOuterBottom
    local maxChild
    local top = self:GetTop()
    local _, minHeight = self:GetResizeBounds()
    
    -- As top may be nil, we need to check it. In case where it's nil, we 
    -- return the minHeight. minHeight is by default '0'
    if top == nil and minHeight > 0 then
      return minHeight
    end
    
    for _, child in self:GetChildrenForAdjustment() do 
      local outerBottom = child:GetBottom()
      if outerBottom then 
        if not maxOuterBottom or maxOuterBottom > outerBottom then 
          maxOuterBottom = outerBottom
          maxChild = child
        end
      end
    end

    if maxOuterBottom then
      -- NOTE: As 'paddingBottom' is an UI.Property, self.PaddingBottom won't work
      -- so we need to pass by Style[self]
      local paddingBottom = Style[self].paddingBottom or 0

      if minHeight and minHeight > 0 then 
        return max(minHeight, Round(self:GetTop() - maxOuterBottom)) + paddingBottom, maxChild
      else
        return Round(self:GetTop() - maxOuterBottom) + paddingBottom, maxChild
      end
    end
  end
-------------------------------------------------------------------------------
--                              Observables                                  --
-------------------------------------------------------------------------------
function FromBackdrop()
 return GetFrame("OnBackdropChanged")
    :Next()
    :Map(function(frame, value, _, prop)
      local showBackground = frame.ShowBackground
      local showBorder = frame.ShowBorder
      if not showBackground and not showBorder then 
        return nil 
      end

      local backdrop = {}
      if showBackground then 
        backdrop.bgFile = [[Interface\AddOns\SylingTracker\Media\Textures\LinearGradient]]
      end

      if showBorder then 
        backdrop.edgeFile = [[Interface\Buttons\WHITE8X8]]
        backdrop.edgeSize = frame.BorderSize
      end

      return backdrop
    end)
end

Frame.FromBackdrop = FromBackdrop

  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  property "AutoAdjustHeight" {
    type = Boolean,
    default = false, 
    handler = AdjustHeightHandler
  }

  property "ShowBackground" {
    type = Boolean,
    default = false,
    event = "OnBackdropChanged"
  }

  property "ShowBorder" {
    type = Boolean,
    default = false,
    event = "OnBackdropChanged"
  }

  property "BorderSize" {
    type = Number,
    default = 1,
    event = "OnBackdropChanged"
  }
end)

Style.UpdateSkin("Default", {
  [Frame] = {
    -- IMPORTANT: We clip children for all frames to avoid a visual issue with textures when 
    -- the frame is resized or moved.
    clipChildren = true,
  }
})