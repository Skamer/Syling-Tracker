-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                 "SylingTracker.UI.ListView"                           ""
-- ========================================================================= --
export {
  newtable = System.Toolset.newtable,
  IsObjectType = Class.IsObjectType,
}


__UIElement__()
class "ListView" (function(_ENV)
  inherit "Frame" extend "IView"
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  function OnViewUpdate(self, data, metadata)
    wipe(self.ViewKeys)

    if data and self.ViewClass then 
      local previousView

      for key, itemData, itemMetadata in self:IterateData(data) do
        local classType = self:GetViewClass(itemData, metadata)

        if classType then 
          local view = self:AcquireView(key, classType)
          view:ClearAllPoints()

          if previousView then 
            view:SetPoint("TOP", previousView, "BOTTOM", 0, -self.Spacing)
          else
            view:SetPoint("TOP")
          end
          
          view:SetPoint("LEFT")
          view:SetPoint("RIGHT")

          -- Update the view with the data 
          view:UpdateView(itemData, itemMetadata)

          previousView = view

          self.ViewKeys[key] = true 
        end
      end
    end
    
    self:ReleaseUnusedViews()
  end

  __Iterator__()
  function IterateData(self, data, metadata)
    local yield = coroutine.yield
    local iterator = self.Indexed and ipairs or pairs 

    for k, v in iterator(data) do 
      yield(k, v, metadata)
    end
  end

  function AcquireView(self, key, classType)
    local view = self.Views[key]
    local new = false 

    if view and not IsObjectType(view, classType) then 
      view.OnSizeChanged = view.OnSizeChanged - self.OnViewSizeChanged

      view:Release()
      self.Views[key] = nil 

      new = true 
    end

    if not view or new then 
      view = classType.Acquire()
      view:SetParent(self)
      view:Show()
      -- view:InstantApplyStyle()

      view.OnSizeChanged = view.OnSizeChanged + self.OnViewSizeChanged

      self.Views[key] = view 

      new = true 
    end

    return view, new
  end

  function OnAdjustHeight(self)

    local height = 0
    local count = 0

    for childName, child in pairs(self.Views) do 
      height = height + child:GetHeight()

      count = count + 1
    end

    height = height + self.Spacing * math.max(0, count - 1) + self.PaddingBottom


    self:SetHeight(height)
  end

  function GetViewClass(self, data, ...)
    if type(self.ViewClass) == "function" then 
      return self.ViewClass(data, ...)
    end

    return self.ViewClass
  end

  function ReleaseUnusedViews(self)
    for key, view in pairs(self.Views) do
      if not self.ViewKeys[key] then
        view.OnSizeChanged = view.OnSizeChanged - self.OnViewSizeChanged 
        view:Release() 

        self.Views[key] = nil 

        self:AdjustHeight()
      end
    end
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  property "ViewClass" {
    type = ClassType + Function,
    handler = function(self) self:RefreshView() end
  }

  property "ViewKeys" {
    set = false,
    default = function() return {} end
  }

  property "Views" {
    set = false,
    default = function() return newtable(false, true) end 
  }

  property "Indexed" {
    type = Boolean,
    default = false 
  }

  property "Spacing" {
    type = Number,
    default = 10,
    handler = function(self) self:RefreshView() end
  }

  property "PaddingBottom" {
    type = Number,
    default = 5
  }
  -----------------------------------------------------------------------------
  --                            Constructors                                 --
  -----------------------------------------------------------------------------
  __Template__ {}
  function __ctor(self)
    self:InstantApplyStyle()
    self:SetHeight(1)

    self.OnViewSizeChanged = function() self:AdjustHeight() end
  end
end)
-------------------------------------------------------------------------------
--                                Styles                                     --
-------------------------------------------------------------------------------
Style.UpdateSkin("Default", {
  [ListView] = {
    autoAdjustHeight = true
  }
})