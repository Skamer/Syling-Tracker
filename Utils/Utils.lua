-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                     "SylingTracker.Utils"                             ""
-- ========================================================================= --
-- __Sealed__() __Final__() interface "Utils" {}

namespace                  "SylingTracker.Utils"

export {
  IsObjectType = Class.IsObjectType
}


__Arguments__ { UIObject }
__Static__() function Utils.Frame_IsUsedAsBackdrop(frame)
  local prop = frame:GetChildPropertyName()
  if prop and prop:match("^backdrop") then
    return true 
  end

  return false 
end

-- __Iterator__()
-- __Arguments__ { UIObject, Boolean/false }
-- __Static__() function Utils.Frame_IterateChildren(frame, includeHidden)
--   local yield = coroutine.yield
--   for childName, child in frame:GetChilds() do 
--     if not Utils.Frame_IsUsedAsBackdrop(child) then 
--       if child:IsShown() or (not child:IsShown() and includeHidden) then 
--         yield(childName, child)
--       end
--     end
--   end
-- end

  __Iterator__()
  __Static__() function Utils.Frame_IterateChildren(frame, includeHidden)
    local yield = coroutine.yield

    for childName, child in frame:GetChilds() do
      -- print("Iteratro", childName, child)
      local prop = child:GetChildPropertyName()
      if not (prop and prop:match("^backdrop")) then
        if child:IsShown() or (not child:IsShown() and includeHidden) then 
          yield(childName, child)
        end
      end
    end 
  end

__Arguments__ { UIObject, Boolean/false}
__Static__() function Utils.ResetStyles(frame, applyToChildren)
  if applyToChildren then 
    for _, child in Utils.Frame_IterateChildren(frame) do 
      ResetStyles(child, applyToChildren)
    end
  end

  for propName in Style.GetCustomStyles(frame) do
    Style[frame][propName] = nil
  end
end

--- Try to compute the frame height based on its children height. 
---
--- @param frame The frame to compute its height.
--- @param iter a custom iterator for iterate its children.
--- @param ...args the args to pass to custom iterator.
---
--- IMPORTANT: THe value returned can be 'nil', so you need to check it before to make 
--- operation with. 
__Arguments__( UIObject, Function/nil, Any/nil, Any * 0) 
__Static__() function Utils.Frame_TryToComputeHeightFromChildren(frame, iter, firstArg, ...)
  if not iter then 
    iter = Utils.Frame_IterateChildren

    if not firstArg then 
      firstArg = frame 
    end
  end 

  local maxOuterBottom
  local maxChild
  for _, child in iter(firstArg, ...) do
    local outerBottom = child:GetBottom() 

    if outerBottom then 
      if not maxOuterBottom or maxOuterBottom > outerBottom then 
        maxOuterBottom = outerBottom
        maxChild = child
      end
    end
  end

  if maxOuterBottom then 
    return frame:GetTop() - maxOuterBottom, maxChild
  end
end

--- Get the nearest frame of type given. 
--- The function will first check the frame given, then if the type mot matches 
--- the frame type will iterate its parent until to have parent maches the type given.
--- May return nil if the frame and all its parents don't match the type. 
---
--- @param frame the frame to check and the start point. 
--- @param cls the type to check. 
__Static__() function Utils.GetNearestFrameForType(frame, cls)
  if IsObjectType(frame, cls) then 
    return frame 
  end

  frame = frame:GetParent()
  while frame do 
    if IsObjectType(frame, cls) then 
      return frame 
    end

    frame = frame:GetParent()
  end
end

