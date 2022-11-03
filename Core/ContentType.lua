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
--- Manages the view of trackers for a specific content type.
--- If the content type isn't enabled, this will remove the views related to it
---  from trackers. 
class "SLT.ContentType" (function(_ENV)
  -----------------------------------------------------------------------------
  --                               Handlers                                  --
  -----------------------------------------------------------------------------
  local function OnEnabledChanged(self, new)
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
  __Arguments__ { SLT.Tracker }
  function RegisterTracker(self, tracker)
    if self.Views[tracker] then 
      return 
    end

    --- Register the tracker and its view
    self.Trackers[tracker] = true

    --- IMPORTANT ! Prepare the view only if the content type is enable or relevant
    if self.Enabled then 
      self:PrepareViewForTracker(tracker)
    end
  end

  __Arguments__ { SLT.Tracker }
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
  --- The id of content type (e.g, "quests")
  property "ID" {
    type = String + Number
  }

  --- The name (e.g "Quests")
  --- A simple name without markups 
  --- This is intented to be used by the options.
  property "Name" {
    type = String
  }

  --- The display name (e.g, "Quests")
  --- May include atlas, texture, or color markup
  --- This is intended to be used by the options. 
  property "DisplayName" {
    type = String
  }

  --- The description (e.g, "This tracks the quests are watched")?
  --- This is intended to be used by the options 
  property "Description" {
    type = String
  }

  --- The order 
  property "Order" {
    type = Number,
    default = 100,
  }

  --- The views the content type will handle, contained in a table with a weak 
  --- reference as it's not their owner.
  property "Views" {
    set = false,
    default = function() return System.Toolset.newtable(true, true) end 
  }

  --- Contains the trackers are registered
  property "Trackers" {
    set = false,
    default = function() return System.Toolset.newtable(true, false) end
  }

  --- The Default Model used by the content type 
  property "DefaultModel" {
    type = SLT.Model
  }

  --- The current model, may be overrided by the user. 
  property "Model" {
    default = function(self) return self.DefaultModel end 
  }

  --- The Default View Class associated to content type 
  property "DefaultViewClass" {
    type = -SLT.IView
  }

  --- The current View Class, may be overrided by the user.
  property "ViewClass" {
    default = function(self) return self.DefaultViewClass end
  }

  property "Status" {
    type = Callable
  }

  property "Enabled" {
    type = Boolean,
    default = true, 
    handler = OnEnabledChanged
  }
end)

struct "SLT.ContentTypeConfig" {
  { name = "ID", type = String + Number, require = true },
  { name = "Name", type = String, require = true},
  { name = "DisplayName", type = String, require = true},
  { name = "Description", type = String},
  { name = "DefaultModel", type = SLT.Model},
  { name = "DefaultViewClass", type = -SLT.IView },
  { name = "Order", type = Number },
  { name = "Status", type = Callable },
  { name = "Events", type = Table + String },
}
-------------------------------------------------------------------------------
-- Enhancing the API                                                         --
-------------------------------------------------------------------------------
_Events = {}
_Module = _M
_ContentTypes = Array()


--- Helper function to register event for content type 
local function RegisterEventForContentType(evt, contentType)
    local CTList = _Events[evt]
    if not CTList then 
      CTList = System.Toolset.newtable(true, false)
      _Events[evt] = CTList

      _Module:RegisterEvent(evt, function(...)
        for ct in pairs(CTList) do 
          ct.Enabled = ct.Status(evt, ...)
        end
      end)
    end

    CTList[contentType] = true 
end

class "SLT.API" (function(_ENV)
  __Arguments__ { SLT.ContentTypeConfig }
  __Static__() function RegisterContentType(config)
    local contentType = SLT.ContentType() 
    contentType.ID = config.ID
    contentType.Name = config.Name
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
          RegisterEventForContentType(config.Events, contentType)
        elseif t == "table" then 
          for _, evt in ipairs(config.Events) do 
            RegisterEventForContentType(evt, contentType)
          end 
        end 
      end
    end

    _ContentTypes:Insert(contentType)

    -- TODO: Trigger an event for the tracker
    -- FireSystemEvent("SLT_CONTENT_TYPE_REGISTERED", contentType)
  end


  __Arguments__ { String + Number }
  __Static__() function GetContentType(id)
    for _, contentType in _ContentTypes:GetIterator() do 
      if contentType.ID == id then 
        return contentType
      end
    end
  end

  __Static__() function GetContentTypes(self)
    return _ContentTypes
  end
  
  __Iterator__()
  __Static__() function IterateContentTypes()
    local yield = coroutine.yield
    for index, content in _ContentTypes:GetIterator() do 
      yield(index, content)
    end
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
