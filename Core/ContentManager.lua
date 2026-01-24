-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                  "SylingTracker.Core.ContentManager"                  ""
-- ========================================================================= --
export {
  GetSetting      = API.GetSetting,
}

_Module                   = _M
CONTENT_EVENTS_REGISTERED = {}

-- Helper function to register the events for content
local function RegisterEventForContent(event, content)
  local contentsRegistered = CONTENT_EVENTS_REGISTERED[event]

  if not contentsRegistered then 
    contentsRegistered = System.Toolset.newtable(true, false)

    CONTENT_EVENTS_REGISTERED[event] = contentsRegistered

    _Module:RegisterEvent(event, function(...)
      for content in pairs(contentsRegistered) do
        -- content.Enabled = content.StatusFunc(event, ...)
        content:ProcessUpdate(true, nil, event, ...)
      end
    end)

  end

  contentsRegistered[content] = true 
end

-- Helper function to unregister the events for content 
local function UnregisterEventForContent(event, content)
  local contentsRegistered = CONTENT_EVENTS_REGISTERED[event]

  if contentsRegistered then 
    contentsRegistered[content] = nil 
  end
end

-- class "ContentSubject" (function(_ENV)
--   inherit "BehaviorSubject"
--   -----------------------------------------------------------------------------
--   --                               Methods                                   --
--   -----------------------------------------------------------------------------
--   function QueueOnNext(self)
--     if not self.__pendingQueueOnNext then 
--       self.__pendingQueueOnNext = true
      
--       Scorpio.Delay(0.1, function()
--         self:OnNext(self:GetData())
--         self.__pendingQueueOnNext = nil 
--         self:ResetChanges()
--       end)
--     end
--   end

--   function GetData(self)
--     return self.Data
--   end

--   __Arguments__ { ObjectData }
--   function AddChild(self, child)
--     self.Children[child] = true
--   end

--   __Arguments__ { ObjectData}
--   function RemoveChild(self, child)
--      self.Children[child] = nil
--   end


--   function ResetChanges(self)
--     self.DataChanged = false 

--     for child in pairs(self.Children) do 
--       child:ResetChanges()
--     end
--   end
--   -----------------------------------------------------------------------------
--   --                              Constructors                               --
--   -----------------------------------------------------------------------------
--   property "DataChanged" {
--     type = Boolean,
--     handler = function(self, new)
--       if new then 
--         self:QueueOnNext()
--       end
--     end
--   }

--   property "Data" {
--     set = false,
--     default = function() return {} end 
--   }

--   property "Children" {
--     set = false, 
--     default = function() return System.Toolset.newtable(true, false) end
--   }
-- end)

class "ContentSubject" (function(_ENV)
  inherit "BehaviorSubject" extend "IObjectData"
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  function QueueOnNext(self)
    if not self.__pendingQueueOnNext then 
      self.__pendingQueueOnNext = true 

      Scorpio.Delay(0.1, function()
        local serializedData = self:GetSerializedData()
        self.Data = serializedData

        self:OnNext(serializedData)
        self.__pendingQueueOnNext = nil 
        self:ResetChanges()
      end)
    end
  end

  function NotifyChanges(self) 
    self:QueueOnNext()
  end

  property "Data" { type = Any }
end)


class "Content" (function(_ENV)
  extend "IObserver"
  -----------------------------------------------------------------------------
  --                               Handlers                                  --
  -----------------------------------------------------------------------------
  local function OnEnabledChanged(self, new)
    if new then
      for tracker in pairs(self.Trackers) do 
        self:PrepareView(tracker)
      end
    else
      for tracker, view in pairs(self.Views) do 
        tracker:RemoveView(view)

        self.Views[tracker] = nil 

        view:Release()
      end
    end
  end

  local function OnObservableChanged(self, new, old)
    if old then 
      old:Unsubscribe()
      obj:Resubscribe()
    end

    if new then 
      new:Subscribe(self)
    end
  end
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  function OnNext(self, data)
    self:ProcessUpdate(false, data)
    self.__data = data
  end

  --- Say to content to process to its update: check its status, hook data, and
  --- update its views
  ---
  --- @param isSystemEvent If process is run because to a system event. 
  --- @param customData Say to take this data instead to fetch it from datastore. 
  --- @param event If isSystemEvent is true, this is the event name has triggered the process.
  --- @param eventArgs if SystemEvent is true, this is the event args has triggered the process.
  __Arguments__ { Boolean, Any/nil, String/nil, Any * 0}   
  function ProcessUpdate(self, isSystemEvent, customData, event, ...)  
    local data
    if customData then 
      data = customData
    elseif self.__data then
      data = self.__data
    end

    if self.StatusFunc then 
      self.Enabled = self.StatusFunc(data, isSystemEvent, event, ...)
    end

    if not self.Enabled then 
      return 
    end

    if self.HookDataFunc then 
      data = self.HookDataFunc(data)
    end

    -- Create the metadata. 
    -- The metadata is usefull for giving the context and additional info which 
    -- may be used by the views. 
    local metadata = {
      contentID = self.id, 
      contentName = self.Name,
      contentIcon = self.Icon,
      contentFormattedName = self.FormattedName,
      contentDescription = self.Description,
    }

    for _, view in pairs(self.Views) do
      view:UpdateView(data, metadata)
    end
  end

  __Arguments__ { Tracker }
  function PrepareView(self, tracker)
    local view = self.ViewClass.Acquire()

    -- Get order from tracker-specific settings, fallback to original order
    local settingId = self.id .. "Order"
    local customOrder = API.GetTrackerSetting(tracker.id, settingId)
    -- Convert to number if it's a string, fallback to original order
    view.Order = tonumber(customOrder) or self.Order

    -- Add it to tracker
    tracker:AddView(view)

    -- @TODO: Replace by the metadata
    -- self.metadata.fromContentName 
    -- self.metadata.fromcontentIcon
    -- view:SetContentName(self.Name)
    -- view:SetContentIcon(self.Icon)

    self.Views[tracker] = view
  end

  __Arguments__ { Tracker }
  function RegisterTracker(self, tracker)
    if self.Views[tracker] then 
      return 
    end

    -- Register the tracker and its view
    self.Trackers[tracker] = true 

    -- IMPORTANT ! Prepare the view only if the content is enabled or relevant.
    if self.Enabled then 
      self:PrepareView(tracker)
      self:ProcessUpdate(false)
    end
  end

  __Arguments__ { Tracker }
  function UnregisterTracker(self, tracker)
    self.Trackers[tracker] = nil

    -- Remove the view if exists
    local view = self.Views[tracker]
    if not view then
      return 
    end
    
    tracker:RemoveView(view)
    
    view:Release()
    self.Views[tracker] = nil
  end  
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  --- The content id (e.g, "quests")
  property "id" {
    type = String
  }

  --- The name (e.g, "Quests")
  --- A simple name without markups
  property "Name" {
    type = String
  }

  property "Icon" {
    type = MediaTextureType
  }
  
  --- The formatted name.
  --- Similiar to name but can include atlas, texture or color markup. 
  property "FormattedName" {
    type = String
  }
  
  --- The description (e.g, "This tracks the quests are watched.")
  property "Description" {
    type = String
  }

  --- The order
  --- The lowest order is displayed at first in the trackers. 
  property "Order" {
    type = Number,
    default = 100
  }

  --- The views the content will manage, contained in a weak reference table 
  --- as it's not their owner. 
  property "Views" {
    set = false,
    default = function() return System.Toolset.newtable(true, true) end 
  }

  --- Contains the trackers are registered 
  property "Trackers" {
    set = false, 
    default = function() return System.Toolset.newtable(true, false) end
  }

  --- The source of data will be pushed to all views.
  --- NOTE: It's possible a content don't have data.
  property "Observable" {
    type = IObservable,
    handler = OnObservableChanged
  }

  --- The class of the view will be instantiate.
  property "ViewClass" {
    type = -IView
  }

  --- The Status Function will check if the content must be enabled or not.
  property "StatusFunc" {
    type = Callable + String
  }
  
  property "Events" {
    type = Table + String
  }

  --- Is the status is enabled ? 
  --- A content become disabled will remove all their associated views from their 
  --- their registered trackers. 
  property "Enabled" {
    type = Boolean,
    default = true,
    handler = OnEnabledChanged,
  }
end)
-------------------------------------------------------------------------------
-- Extending the API                                                         --
-------------------------------------------------------------------------------
CONTENTS = {}
OBSERVABLE_CONTENTS = {}

struct "ContentConfig" {
  { name = "id", type = String },
  { name = "name", type = String },
  { name = "icon", type = MediaTextureType}, 
  { name = "formattedName", type = String },
  { name = "description", type = String },
  { name = "data", type = IObservable },
  { name = "viewClass", type = -IView },
  { name = "order", type = Number },
  { name = "events", type = Table + String },
  { name = "statusFunc", type = Callable + String },
  { name = "hookDataFunc", type = Callable + String},
  { name = "ignoreDataUpdate", type = Boolean }
}

--- Register a content 
---
--- @param config the config for the content will be registered.
__Arguments__ { ContentConfig }
__Static__() function API.RegisterContent(config)

  if not config.id then 
    error("Trying to register a content without an id")
  end

  if not config.viewClass then 
    error("Trying to register a content without a view class")
  end

  if CONTENTS[config.id] then 
    error(("Trying to register a content where the id '%s' is already used."):format(config.id))
  end



  local content = Content()
  content.id = config.id 
  content.Name = config.name 
  content.Icon = config.icon
  content.FormattedName = config.formattedName or config.name 
  content.Description = config.description
  content.ViewClass = config.viewClass
  content.Order = config.order 
  content.StatusFunc = config.statusFunc
  content.Observable = config.data
  
  local events = config.events
  content.Events = events
  if config.statusFunc then 
    local t = type(events)
    if t == "string" then 
      RegisterEventForContent(events, content)
    elseif t == "table" then 
      for _, evt in ipairs(events) do 
        RegisterEventForContent(evt, content)
      end
    end
  end

  CONTENTS[config.id] = content
end

--- Return a content
---
--- @param id the content id to return
__Arguments__ { String }
__Static__() function API.GetContent(id)
  return CONTENTS[id]
end

--- Return a iterator for the contents have been registered 
__Iterator__()
__Static__() function API.IterateContents()
  local yield = coroutine.yield

  for contentID, content in pairs(CONTENTS) do
    yield(contentID, content)
  end
end

--- Register an observable, allowing to use it later for the contents
--- In case where the observable class is given, the method will instantiate a 
--- new object of this class.
---
--- @param id the observable id to register
--- @param clsOrObservable the observable class or an observable instance.
---
--- @return return the observable instance.
__Arguments__{ String, (-IObservable + IObservable) }
__Static__() function API.RegisterObservableContent(id, clsOrObservable)
  if OBSERVABLE_CONTENTS[id] then 
    error(("This id '%s' to register a observable content is already user"):format(id))
  end

  local observable
  if Class.IsObjectType(clsOrObservable, IObservable) then 
    observable = clsOrObservable
  else
    observable = clsOrObservable()
  end

  OBSERVABLE_CONTENTS[id] = observable

  return observable
end
--- Retrieve an observable has been registered.
---
--- @param id the observable id to retrieve.
__Arguments__ { String }
__Static__() function API.GetObservableContent(id)
  return OBSERVABLE_CONTENTS[id]
end

--- Combine multiple observable contents into one. 
--- @param ... the observables id to combine
---
--- @return return the combined observable
__Arguments__ { String * 2 }
__Static__() function API.CombineObservableContent(...)
  local observable

  for i = 1, select("#", ...) do
    local id = select(i, ...)
    if not observable then 
      observable = OBSERVABLE_CONTENTS[id]
    else
      observable = observable:CombineLatest(OBSERVABLE_CONTENTS[id]):Map(function(a, b)
        if a == nil and b == nil then 
          return
        end 

        if a == nil and b ~= nil then 
          return b 
        end 

        if b == nil and a ~= nil then 
          return a 
        end 

        for k,v in pairs(b) do a[k] = v end 
        return a 
      end)
    end
  end

  return observable
end

__SystemEvent__()
function SylingTracker_TRACK_CONTENT(tracker, contentID)
  local content = API.GetContent(contentID)
  if not content then 
    return 
  end

  content:RegisterTracker(tracker)
end

__SystemEvent__()
function SylingTracker_UNTRACK_CONTENT(tracker, contentID)
  local content = API.GetContent(contentID)
  if not content then 
    return 
  end

  content:UnregisterTracker(tracker)
end

-- Handle tracker-specific settings changes for content order
__SystemEvent__()
function SylingTracker_TRACKER_SETTING_UPDATED(settingId, trackerID, newValue)
  -- Check if this is a content order setting
  if settingId:match("Order$") then
    local contentId = settingId:gsub("Order$", "")
    local content = API.GetContent(contentId)
    local tracker = API.GetTracker(trackerID)
    
    if content and tracker then
      -- Update existing view for this specific tracker
      local view = content.Views[tracker]
      if view then
        local customOrder = API.GetTrackerSetting(tracker.id, settingId)
        -- Convert to number if it's a string, fallback to original order
        view.Order = tonumber(customOrder) or content.Order
        
        -- Trigger tracker layout refresh
        if tracker.OnLayout then
          tracker:OnLayout()
        end
        if tracker.OnAdjustHeight then
          tracker:OnAdjustHeight()
        end
      end
    end
  end
end
