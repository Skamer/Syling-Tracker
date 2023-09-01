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

  local function OnChildChanged(self, child, isAdd, noAdjust)
    if self.AdjustHeight then 
      if isAdd then

        if child.OnSizeChanged then 
          child.OnSizeChanged = child.OnSizeChanged + OnStateChanged
        end

        if child.OnTextHeightChanged then 
          child.OnTextHeightChanged = child.OnTextHeightChanged + OnStateChanged
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

        child.OnShow        = child.OnShow  - OnStateChanged
        child.OnHide        = child.OnHide  - OnStateChanged
      end
    end

    return not noAdjust and self:AdjustHeight()
  end

  local function AdjustHeightHandler(self, new)
    if new then
      self.OnChildChanged = self.OnChildChanged + OnChildChanged

      for name, child in self:GetChildrenForAdjustment() do 
        OnChildChanged(self, child, true, true)
      end

      self:AdjustHeight()
    else
      self.OnChildChanged = self.OnChildChanged - OnChildChanged

      for name, child in self:GetChildrenForAdjustment() do 
        OnChildChanged(self, child, false)
      end
    end
  end

  function IsIgnoredForAdjustment(self, child)
    if not child:IsShown() then
      return true 
    end

    local prop = child:GetChildPropertyName() 
    if prop and prop:match("^backdrop") then 
      return true 
    end

    return false
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
      local _, minHeight = self:GetResizeBounds()

      if minHeight and minHeight > 0 then 
        return max(minHeight, Round(self:GetTop() - maxOuterBottom)), maxChild
      else
        return Round(self:GetTop() - maxOuterBottom), maxChild
      end
    end
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  property "AutoAdjustHeight" {
    type = Boolean,
    default = false, 
    handler = AdjustHeightHandler
  }
end)

-- adjustHeight

-- AutoAdjustHeight
