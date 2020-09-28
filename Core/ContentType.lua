-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                 "SylingTracker.Core.ContentType"                      ""
-- ========================================================================= --
namespace                          "SLT"
-- ========================================================================= --
--- Manages the view of trackers for a specific content type.
--- If the content type isn't enabled, this will remove the views related to it
--  from trackers. 
class "ContentType" (function(_ENV)
  -----------------------------------------------------------------------------
  --                               Handlers                                  --
  -----------------------------------------------------------------------------
  local function HandleEnabledChange(self, new)
    if new then 
      for tracker in pairs(self.Trackers) do 
        self:PrepareViewForTracker(tracker)
      end 
    else
      local model = self.Model
      for tracker, view in pairs(self.Views) do 
          tracker:RemoveView(view)
          model:RemoveView(view)

          self.Views[tracker] = nil 

          view:Release()
      end 
    end 
  end
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  __Arguments__ { Tracker }
  function RegisterTracker(self, tracker)
    if self.Views[tracker] then 
      return 
    end

    -- Register the tracker and its view
    self.Trackers[tracker] = true

    -- IMPORTANT ! Prepare the view only if the content type is enable or relevant
    if self.Enabled then 
      self:PrepareViewForTracker(tracker)
    end
  end

  __Arguments__ { Tracker }
  function UnregisterTracker(self, tracker)
    local view = self.Views[tracker]
    if not view then 
      return 
    end 

    tracker:RemoveView(view)

    self.Model:RemoveView(view)

    view:Release() 

    self.Views[tracker] = nil 
    self.Trackers[tracker] = nil
  end 

  function PrepareViewForTracker(self, tracker)
    local view = self.ViewClass.Acquire()

    -- TODO: ADD the below code 
    -- Check if the tracker has overrided the order for this content type
    -- Profiles.PrepareDatabase()
    -- if Database.SelectTable(false, "trackers", self.id, "contents", contentID) then 
    --   view.order = Database.GetValue("order")
    -- end

    view.Order = self.Order

    -- Add it to tracker 
    tracker:AddView(view)

    -- REVIEW: Probably need to change to "RegisterView" for model 
    self.Model:AddView(view)

    self.Views[tracker] = view
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  --- The ID of content type (e.g, "quests")
  property "ID" { 
    type = String + Number
  }

  --- The display name (e.g, "Quests"). 
  --- This is intended to be used by options.
  property "DisplayName" {
    type = String
  }

  --- The description (e.g, "This tracks the quests are watched"). 
  -- This is intended to be used by options.
  property "Description" {
    type = String
  }


  property "Order" {
    type = Number,
    defualt = 100,
  }

  --- The views the content type will handles, contained in a table with 
  --- a weak reference so it's not their owner. 
  property "Views" {
    type = Table, 
    default = function() return setmetatable({}, { __mode = "kv"}) end
  }

  --- Contains the trackers are registered
  property "Trackers" {
    type = Table,
    default = function() return setmetatable({}, { __mode = "k"}) end
  }

  --- The Default Model used by this contentType
  property "DefaultModel" {
    type = Model,
  }

  --- The current Model, may be overrided by user.
  property "Model" {
    default = function(self) return self.DefaultModel end 
  }

  --- the Default View Class associated to contentType
  property "DefaultViewClass" {
    type = ClassType
  }

  --- The current View Class, may be overrided by user.
  property "ViewClass" {
    default = function(self) return self.DefaultViewClass end,
  }

  property "Events"

  property "Status" {
    type = Callable
  }

  property "Enabled" {
    type = Boolean,
    default = true,
    handler = HandleEnabledChange
    -- Put a handler
  }
end)
-------------------------------------------------------------------------------
-- Enhancing the API                                                         --
-------------------------------------------------------------------------------
_Events = {}
_Module = _M

_ContentTypes = {}
class "API" (function(_ENV)

  __Arguments__ { String, ContentType }
  __Static__() function RegisterEvent(evt, contentType)
    local CTList = _Events[evt]
    if not CTList then 
      CTList = setmetatable({}, { __mode = "k"} )
      _Events[evt] = CTList

      _Module:RegisterEvent(evt, function(...)
        for ct in pairs(CTList) do 
          ct.Enabled = ct.Status(evt, ...)
        end
      end)
    end

    CTList[contentType] = true 
  end

  
  __Arguments__ { Table }
  __Static__() function RegisterContentType(config)
    local contentType = ContentType() 
    contentType.ID = config.ID
    contentType.DisplayName = config.DisplayName
    contentType.Description = config.Description
    contentType.DefaultModel  = config.DefaultModel
    contentType.DefaultViewClass = config.DefaultViewClass
    contentType.Order = config.DefaultOrder
    
    if config.Status then 
      contentType.Status = config.Status

      if config.Events then
        local t = type(config.Events)
        if t == "string" then 
          RegisterEvent(config.Events, contentType)
        elseif t == "table" then 
          for _, evt in ipairs(config.Events) do 
            RegisterEvent(evt, contentType)
          end 
        end 
      end
    end

    _ContentTypes[contentType.ID] = contentType

    -- TODO: Trigger an event for the tracker
    -- FireSystemEvent("SLT_CONTENT_TYPE_REGISTERED", contentType)
  end

  __Arguments__ { String + Number }
  __Static__() function GetContentType(id)
    return _ContentTypes[id]
  end 
end)

__SystemEvent__()
function SLT_TRACKER_TRACK_CONTENT_TYPE(tracker, contentID)
  local contentType = API.GetContentType(contentID)
  if not contentType then 
    return 
  end

  contentType:RegisterTracker(tracker)
end

__SystemEvent__()
function SLT_TRACKER_UNTRACK_CONTENT_TYPE(tracker, contentID)
  local contentType = API.GetContentType(contentID)
  if not contentType then 
    return 
  end

  contentType:UnregisterTracker(tracker)
end


