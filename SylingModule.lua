-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
PLoop(function(_ENV)
  _G.Syling = class "Syling" (function(_ENV)
    inherit "Scorpio"
    ---------------------------------------------------------------------------
    --                               Methods                                 --
    ---------------------------------------------------------------------------
    __Arguments__ { NEString }
    function IsRegisteredEventByActiveSystem(self, evt)
      if self._ActiveOnEvents and self._ActiveOnEvents:Contains(evt) then
        return true
      end

      if self._InactiveOnEvents and self._InactiveOnEvents:Contains(evt) then
        return true
      end

      return false
    end

    function GetActivatingEvent(self)
      return self._ActiveByEvent
    end

    function GetActivatingEventArgs(self)
      if self._ActivatingEventArgs then 
        return unpack(self._ActivatingEventArgs) 
      end
    end

    __Arguments__ { String }
    function IsActivateByEvent(self, evt)
      if self._ActiveByEvent and self._ActiveByEvent == evt then
        return true
      end
      return false
    end

    __Arguments__ { String }
    function IsActiveByEvent(self, evt)
      return self:IsActivateByEvent(evt)
    end

    __Arguments__ { NEString }
    function AddActiveEvent(self, evt)
      if not self._ActiveOnEvents then
        self._ActiveOnEvents = List(evt)
      else
        if not self._ActiveOnEvents:Contains(evt) then
          self._ActiveOnEvents:Insert(evt)
        end
      end
    end

    __Arguments__ { NEString }
    function AddInactiveEvent(self, evt)
      if not self._InactiveOnEvents then
        self._InactiveOnEvents = List(evt)
      else
        if not self._InactiveOnEvents:Contains(evt) then
          self._InactiveOnEvents:Insert(evt)
        end
      end
    end

    __Arguments__ { String }
    function HasActiveEvent(self, evt)
      if self._ActiveOnEvents and self._ActiveOnEvents:Contains(evt) then
        return true
      end

      return false
    end

    __Arguments__ { String }
    function HasInactiveEvent(self, evt)
      if self._InactiveOnEvents and self._InactiveOnEvents:Contains(evt) then
        return true
      end

      return false
    end

    __Arguments__{ NEString, (NEString + Function)/nil }:Throwable()
    function RegisterEvent(self, evt, handler)
      -- If the event is "EKT_HARD_RELOAD_MODULES", ignore the below stuff 
      if evt == "SLT_HARD_RELOAD_MODULES" then 
        super.RegisterEvent(self, evt, handler)
        return 
      end

      handler = handler or evt
      if type(handler) == "string" then handler = self[handler] end

        local newHandler = function(...)
          if self._Inactive and self:HasActiveEvent(evt) then
            local active = self._ActiveOnHandler(self, evt, ...)

            -- skip if "nil" has been returned
            if active ~= nil then 
              if active then
                self._ActiveByEvent = evt
                self._ActivatingEventArgs = { ... }
              end

              self._Active = active
            end
          end

          -- Call the orig handler only if the module is active
          if self._Active then
            handler(...)
          end

          -- NOTE: _eventActiveChanged is here for avoiding to call two cond
          -- handler in same event.
          if self._Active and not self._EventActiveChanged then
            local active
            
            if self._InactiveOnHandler and self:HasInactiveEvent(evt) then
              active = not self._InactiveOnHandler(self, evt, ...)
            elseif self:HasActiveEvent(evt) then
              active = self._ActiveOnHandler(self, evt, ...)
            end

            -- skip if "nil" has been returned
            if active ~= nil then 
              self._Active = active
            end
          end

          self._EventActiveChanged = nil
        end
        super.RegisterEvent(self, evt, newHandler)
    end

    --- Call when the module become  active
    function OnActive(self) end
    --- Call when the module become inactive
    function OnInactive(self) end
    ---------------------------------------------------------------------------
    --                         Properties                                    --
    ---------------------------------------------------------------------------
    property "_Active" { TYPE = Boolean, DEFAULT = true, HANDLER = function(self, new)
      if new then
        self:OnActive()
        self._EventActiveChanged = true
      else
        self:OnInactive()
      end
    end }
    
    -- Ready only, avoid to edit this property
    property "_Inactive" { TYPE = Boolean, GET = function(self) return not self._Active end }

    -- internal properties
    property "_EventActiveChanged" { TYPE = Boolean }
    property "_InactiveOnHandler" { TYPE = Any }
    property "_ActiveOnHandler" { TYPE = Any}
    property "_ActiveOnEvents" { TYPE = List }
    property "_InactiveOnEvents" { TYPE = List }
  end)
    ---------------------------------------------------------------------------
    --                                                                       --
    --                         __ActiveOnEvents__                            --
    --                                                                       --
    ---------------------------------------------------------------------------
    class "__ActiveOnEvents__" (function(_ENV)
      inherit "__SystemEvent__"

      function AttachAttribute(self, target, targetType, owner, name)
        if #self > 0 then
          for _, evt in ipairs(self) do
            if not owner:IsRegisteredEventByActiveSystem(evt) then
              local handler = owner:GetRegisteredEventHandler(evt)
              if not handler then
                 handler = function() end
               end
               owner:RegisterEvent(evt, handler)
            end
            owner:AddActiveEvent(evt)
          end
        else
          if not owner:IsRegisteredEventByActiveSystem(evt) then
            local handler = owner:GetRegisteredEventHandler(name)
            if not handler then
              handler = function() end
            end
            owner:RegisterEvent(name, handler)
          end
          owner:AddActiveEvent(name)
        end
        owner._ActiveOnHandler = target
      end
    end)
    ----------------------------------------------------------------------------
    --                                                                        --
    --                         __InactiveOnEvents__                           --
    --                                                                        --
    ----------------------------------------------------------------------------
    class "__InactiveOnEvents__" (function(_ENV)
      inherit "__SystemEvent__"

      function AttachAttribute(self, target, targetType, owner, name)
        if #self > 0 then
          for _, evt in ipairs(self) do
            if not owner:IsRegisteredEventByActiveSystem(evt) then
              local handler = owner:GetRegisteredEventHandler(evt)
              if not handler then
                 handler = function() end
               end
               owner:RegisterEvent(evt, handler)
            end

            owner:AddInactiveEvent(evt)
          end
        else
          if not owner:IsRegisteredEventByActiveSystem(evt) then
            local handler = owner:GetRegisteredEventHandler(name)
            if not handler then
              handler = function() end
            end
            owner:RegisterEvent(name, handler)
          end
          owner:AddInactiveEvent(name)
        end
        owner._InactiveOnHandler = target
      end
    end)
end)