-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                    "SylingTracker.Core.IView"                         ""
-- ========================================================================= --
REFRESH_VIEW_TASK_TOKEN         = Toolset.newtable(true)

interface "IView" (function(_ENV)
  -----------------------------------------------------------------------------
  --                               Events                                    --
  -----------------------------------------------------------------------------
  event "OnViewUpdateTrigger"
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  --- You need to redefine this method for handling the stuffs for your viws when 
  --- updated.
  __Abstract__()
  function OnViewUpdate(self, data, metadata) end

  function UpdateView(self, data, metadata)
    if self.HookData then 
      data = self:HookData(data, metadata)
    end

    self.Data = data 
    self.Metadata = metadata

    self:OnViewUpdate(data, metadata)

    OnViewUpdateTrigger(self, data, metadata)
  end

  function InstantRefreshView(self)
    self:OnViewUpdate(self.Data, self.Metadata)

    OnViewUpdateTrigger(self, self.Data, self.Metadata)
  end

  __Async__()
  function RefreshView(self)
    -- Update the process token 
    local token = (REFRESH_VIEW_TASK_TOKEN[self] or 0) + 1
    REFRESH_VIEW_TASK_TOKEN[self] = token

    Next()  

    if token ~= REFRESH_VIEW_TASK_TOKEN[self] then 
      return 
    end

    self:InstantRefreshView()

    -- Release the tokens 
    REFRESH_VIEW_TASK_TOKEN[self] = nil
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  property "Order" {
    type = Number,
    default = 100,
    event = "OnOrderChanged"
  }
  
  property "Active" {
    type = Boolean,
    default = true,
    event = "OnActiveChanged"
  }
  
  -- @REVIEW: Need it or probably rename it.
  property "ShouldBeDisplayed" {
    type = Boolean,
    default = true, 
    event = "OnShouldbeDisplayed"
  }  

  property "Data" {
    type = Any,
  }

  property "Metadata" {
    type = Any
  }
end)

__Arguments__ { IObservable * 0 }
__Static__() function API.FromView(...)
  local observable

  for i = 1, select("#", ...) do 
    local arg = select(i, ...)
    observable = observable and observable:CombineLatest(arg) or arg 
  end

  if observable then 
    return Wow.GetFrame("OnViewUpdateTrigger"):CombineLatest(observable, function(v) return v, v.Data, v.Metadata end):Next()
  end

  return Wow.GetFrame("OnViewUpdateTrigger"):Map(function(self) return self, self.Data, self.Metadata end)
end

__Arguments__ { String }
__Static__() function API.FromViewWithUISetting(uiSetting)
  return API.FromView(API.FromUISetting(uiSetting))
end

__Arguments__ { String * 0 }
__Static__() function API.FromViewWithUISettings(...)
  return API.FromView(API.FromUISettings(...))
end

__Arguments__ { String }
__Static__() function API.FromViewWithSetting(setting)
  return API.FromView(API.FromSetting(setting))
end