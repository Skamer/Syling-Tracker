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
  Round = Round
}

class "Button" (function(_ENV)
  inherit "Scorpio.UI.Button" extend "IQueueAdjustHeight"
  -----------------------------------------------------------------------------
  --                               Handlers                                  --
  -----------------------------------------------------------------------------
  local function OnEnterHandler(self)
    self.IsMouseOver = true
  end 

  local function OnLeaveHandler(self)
    self.IsMouseOver = false
  end

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
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  function IsIgnoredForAdjustment(self, child)
    if Style[child].excludeFromAutoHeight then
      return true 
    end
    
    if not child:IsShown() then
      return true 
    end

    local prop = child:GetChildPropertyName()
    if prop and prop:match("^backdrop") then
      return true 
    end
    
    return false
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
    if top == nil then
      return minHeight > 0 and minHeight
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

  function SetPoint(self, ...)
    super.SetPoint(self, ...)

    if self.AutoAdjustHeight then 
      self:AdjustHeight()
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

  __Observable__()
  property "IsMouseOver" {
    type = Boolean,
    default = false,
  }

  property "RegisterForMouseOver" {
    type = Boolean,
    default = false,
    handler = function(self, new)
      if new then 
        self.OnEnter = self.OnEnter + OnEnterHandler
        self.OnLeave = self.OnLeave + OnLeaveHandler
      else 
        self.OnEnter = self.OnEnter - OnEnterHandler
        self.OnLeave = self.OnLeave - OnLeaveHandler

        self.IsMouseOver = nil
      end
    end
  }
end)

UI.Property         {
    name            = "NormalTexture",
    type            = Texture,
    require         = Button,
    nilable         = true,
    childtype       = Texture,
    -- We need to use Scorpio.UI.Button to check the function exists.
    clear           = Scorpio.UI.Button.ClearNormalTexture and function(self) self:ClearNormalTexture() end,
    set             = function(self, val) self:SetNormalTexture(val) end,
}

UI.Property         {
    name            = "PushedTexture",
    type            = Texture,
    require         = Button,
    nilable         = true,
    childtype       = Texture,
    -- We need to use Scorpio.UI.Button to check the function exists.
    clear           = Scorpio.UI.Button.ClearPushedTexture and function(self) self:ClearPushedTexture() end,
    set             = function(self, val) self:SetPushedTexture(val) end,
}

Style.UpdateSkin("Default", {
  [Button] = {
    -- IMPORTANT: We clip children for all frames to avoid a visual issue with textures when 
    -- the frame is resized or moved.
    clipChildren = true,
  }
})
