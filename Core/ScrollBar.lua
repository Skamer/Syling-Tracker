-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                   "SylingTracker.Core.ScrollBar"                      ""
-- ========================================================================= --
export {
  RegisterSetting   = API.RegisterSetting,
  GetSetting        = API.GetSetting
}

LEFT_BUTTON_NAME = "LeftButton"

SCROLLBAR_THUMB_EDGES_FILE = [[Interface\AddOns\SylingTracker\Media\Textures\MinimalScrollbarProportional]]
SCROLLBAR_THUMB_MIDDLE_FILE = [[Interface\AddOns\SylingTracker\Media\Textures\MinimalScrollbarVertical]]


SCROLLBAR_THUMB_TOP_HOVER_COORDS = { left = 0.015625, top = 0.828125, right = 0.140625, bottom = 0.953125 }
SCROLLBAR_THUMB_BOTTOM_HOVER_COORDS = { left = 0.3125, top = 0.421875, right = 0.4375, bottom = 0.984375 } 
SCROLLBAR_THUMB_MIDDLE_HOVER_COORDS = { left = 0.328125, top = 0.0009765625, right = 0.453125, bottom = 0.69921875 }

class "ScrollBarThumb" (function(_ENV)
  inherit "Button"
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  function GetAtlas(self)
    if self:IsEnabled() then 
      if self.MouseDown then 
        return self.DownTopAtlas, self.DownMiddleAtlas, self.DownBottomAtlas
      elseif self.MouseOver then 
        return self.OverTopAtlas, self.OverMiddleAtlas, self.OverBottomAtlas
      end 
    end 

    return self.UpTopAtlas, self.UpMiddleAtlas, self.UpBottomAtlas
  end

  function RefreshAtlas(self)
    local topAtlas, middleAtlas, bottomAtlas = self:GetAtlas() 
    -- Style[self].TopBGTexture.atlas = topAtlas
    -- Style[self].MiddleBGTexture.atlas = middleAtlas
    -- Style[self].BottomBGTexture.atlas = bottomAtlas
  end

  function GetNormalColor(self)
    return Style[self].MiddleBGTexture.vertexColor
  end

  function SetNormalColor(self, color)
    Style[self].TopBGTexture.vertexColor = color
    Style[self].MiddleBGTexture.vertexColor = color
    Style[self].BottomBGTexture.vertexColor = color
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  property "UpTopAtlas" {
    type    = AtlasType,
    default = AtlasType("minimal-scrollbar-thumb-top", true)
  }

  property "UpMiddleAtlas" {
    type    = AtlasType,
    default = AtlasType("minimal-scrollbar-thumb-middle", true)
  }

  property "UpBottomAtlas" {
    type    = AtlasType,
    default = AtlasType("minimal-scrollbar-thumb-bottom", true)
  }

  property "OverTopAtlas" {
    type    = AtlasType,
    default = AtlasType("minimal-scrollbar-thumb-top-over", true)
  }

  property "OverMiddleAtlas" {
    type    = AtlasType,
    default = AtlasType("minimal-scrollbar-thumb-middle-over", true)
  }

  property "OverBottomAtlas" {
    type    = AtlasType,
    default = AtlasType("minimal-scrollbar-thumb-bottom-over", true)
  }

  property "DownTopAtlas" {
    type    = AtlasType,
    default = AtlasType("minimal-scrollbar-thumb-top-down", true)
  }

  property "DownMiddleAtlas" {
    type    = AtlasType,
    default = AtlasType("minimal-scrollbar-thumb-middle-down", true)
  }

  property "DownBottomAtlas" {
    type = AtlasType,
    default = AtlasType("minimal-scrollbar-thumb-bottom-down", true) 
  }

  --- Used internally
  property "MouseOver" {
    type = Boolean,
    handler = function(self) self:RefreshAtlas() end
  }

  --- Used internally
  property "MouseDown" {
    type = Boolean,
    handler = function(self) self:RefreshAtlas() end 
  }
  -----------------------------------------------------------------------------
  --                            Constructors                                 --
  -----------------------------------------------------------------------------
  function __ctor(self) 
    self.OnEnter = self.OnEnter + function() self.MouseOver = true end
    self.OnLeave = self.OnLeave + function() self.MouseOver = false end 
    self.OnMouseDown = self.OnMouseDown + function() self.MouseDown = true end 
    self.OnMouseUp = self.OnMouseUp + function() self.MouseDown = false end
  end
end)

class "ScrollBar" (function(_ENV)
  inherit "Frame"
  -----------------------------------------------------------------------------
  --                               Events                                    --
  -----------------------------------------------------------------------------
  event "OnScroll"
  -----------------------------------------------------------------------------
  --                               Handlers                                  --
  -----------------------------------------------------------------------------
  local function UnregisterUpdate(self, buttonName)
    if buttonName == LEFT_BUTTON_NAME then 
      self.OnUpdate = nil
      self.OnMouseUp = self.OnMouseUp - UnregisterUpdate
    end
  end

  local function OnMouseWheel(self, direction)
    local wheelExtentPercentage = self.WheelExtentPercentage
    local wheelScalar           = self.WheelScalar
    local delta = wheelExtentPercentage * wheelScalar * (direction * -1)
    self:SetScrollPercentage(Saturate(self:GetScrollPercentage() + delta))
  end

  local function OnTrackMouseDown(self, track, buttonName)
    if buttonName ~= LEFT_BUTTON_NAME then 
      return 
    end 

    local c = self:SelectCursorComponent()
    local scrollPercentage = self:GetScrollPercentage()
    local extentRemaining = self:GetTrackExtend()

    local min, max
    -- the interval range offset allow reduce the range. Not useing an enought
    -- offset can be not user friendly as the user need to click exactly at the 
    -- limit of frame for the scrollbar use the min or max percent.
    -- REVIEW: Should be in the class property instead of be hard coded here ? 
    local intervalRangeOffset = 20
    if self.IsHorizontal then 
      min = track:GetLeft() + intervalRangeOffset
      max = track:GetRight() - intervalRangeOffset
    else
      min = track:GetBottom() + intervalRangeOffset
      max = track:GetTop() - intervalRangeOffset
    end

    track.OnUpdate = function()
      local c = Clamp(self:SelectCursorComponent(), min, max)
      local scrollPercentage = 1.0 - PercentageBetween(c, min, max)

      -- Snap to nearest percentage step if it's enabled 
      if self.StepPercentage > 0 then 
        self:SetScrollPercentage(self:GetNearestStepPercentage(scrollPercentage))
      else 
        self:SetScrollPercentage(scrollPercentage)
      end
    end

    track.OnMouseUp = track.OnMouseUp + UnregisterUpdate
  end


  local function OnThumbMouseDown(self, thumb, buttonName)
    if buttonName ~= LEFT_BUTTON_NAME then
      return 
    end

    local c                 = self:SelectCursorComponent()
    local scrollPercentage  = self:GetScrollPercentage()
    local extentRemaining   = self:GetTrackExtend() - self:GetFrameExtent(thumb)
    
    local min, max 
    if self.IsHorizontal then 
      min = c - scrollPercentage * extentRemaining
      max = c + (1.0 - scrollPercentage) * extentRemaining
    else
      min = c - (1.0 - scrollPercentage) * extentRemaining
      max = c + scrollPercentage * extentRemaining
    end

    thumb.OnUpdate = function()
      local c = Clamp(self:SelectCursorComponent(), min, max)
      local scrollPercentage

      if self.IsHorizontal then 
        scrollPercentage = PercentageBetween(c, min, max)
      else
        scrollPercentage = 1.0 - PercentageBetween(c, min, max)
      end

      -- Snap to nearest percentage step if it's enabled 
      if self.StepPercentage > 0 then
        self:SetScrollPercentage(self:GetNearestStepPercentage(scrollPercentage))
      else
        self:SetScrollPercentage(scrollPercentage)
      end
    end

    thumb.OnMouseUp = thumb.OnMouseUp + UnregisterUpdate
  end

  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  function Update(self)
    if self:HasScrollableExtent() then 
      local visibleExtentPercentage = self:GetVisibleExtentPercentage()
      local trackExtent             = self:GetTrackExtend()
      
      local thumb                   = self:GetThumb()
      local thumbExtent

      if self.FixedThumbExtend > 0 then
        thumbExtent = self.FixedThumbExtend
        self:SetFrameExtent(thumb, thumbExtent)
      elseif self.UseProportionalThumb then
        local minimumThumbExtent = self.MinThumbExtent
        thumbExtent = Clamp(trackExtent * visibleExtentPercentage, minimumThumbExtent, trackExtent)
        self:SetFrameExtent(thumb, thumbExtent)
      else
        thumbExtent = self:GetFrameExtent(thumb)
      end

      local allowScroll = self:IsScrollAllowed()
      local scrollPercentage = self:GetScrollPercentage()

      -- TODO: Add an interpolator

      local offset = (trackExtent - thumbExtent) * scrollPercentage
      local x, y = 0, -offset

      if self.IsHorizontal then 
        x, y = -y, x 
      end 

      thumb:SetPoint(self:GetThumbAnchor(), self:GetTrack(), self:GetThumbAnchor(), x, y)
      thumb:Show()
      thumb:SetEnabled(allowScroll)
    else 
      self:DisableControls()
    end
  end


  function GetTrack(self)
    return self:GetChild("Track")
  end

  function GetThumb(self)
    return self:GetTrack():GetChild("Thumb")
  end

  function GetThumbAnchor(self)
    return self.ThumbAnchor
  end

  --- returns the height if the scrollbar is vertical or the width if its 
  --- horizontal
  __Arguments__ { Frame }
  function GetFrameExtent(self, frame)
    local width, height = frame:GetSize()
    return self.IsHorizontal and width or height
  end

  --- Sets the height if the scrollbar is vertical or the width if its 
  --- horizontal.
  __Arguments__ { Frame, Number }
  function SetFrameExtent(self, frame, value)
    if self.IsHorizontal then 
      frame:SetWidth(value)
    else
      frame:SetHeight(value)
    end
  end

  function GetTrackExtend(self)
    return self:GetFrameExtent(self:GetTrack())
  end

  function SelectCursorComponent(self)
    local x, y = GetScaledCursorPosition()
    return self.IsHorizontal and x or y 
  end

  function GetScrollPercentage(self)
    return self.ScrollPercentage
  end

  function SetScrollPercentage(self, percentage)
    self.ScrollPercentage = Saturate(percentage)
  end

  function SetScrollStepPercentage(self, percentage)
    self.StepPercentage = percentage
  end

  function GetVisibleExtentPercentage(self)
    return self.VisibleExtentPercentage
  end

  __Arguments__ { Number/nil }
  function SetVisibleExtentPercentage(self, percentage)
    self.VisibleExtentPercentage = percentage
  end

  --- Get the nearest step percentage
  --- e.g, if the step percentage is 0.2 and the percentage given is 0.35
  -- the function will return 0.4 
  __Arguments__ { Number }
  function GetNearestStepPercentage(self, percentage)
    local r = percentage % self.StepPercentage
    if r >= (self.StepPercentage / 2) then 
      return (percentage - r) + self.StepPercentage
    else
      return percentage - r
    end 
  end

  --- Whether the scrollbar has a scrollable content
  function HasScrollableExtent(self)
    return WithinRangeExclusive(self:GetVisibleExtentPercentage(), 0, 1)
  end

  --- Whether the scroll is allowed 
  function IsScrollAllowed(self)
    return self.AllowScroll
  end

  __Arguments__ { Boolean/nil }
  function SetScrollAllowed(self, allowScroll)
    self.AllowScroll = allowScroll
  end

  function DisableControls(self)
    self:GetThumb():Hide()
    self:GetThumb():SetEnabled(false)
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  --- TODO: Only Vertical is supported, need to implement Horizontal if needed
  property "IsHorizontal" {
    set     = false,
    type    = Boolean,
    default = false
  }

  --- Whether the scrollbar snap to a step percentage when near of it. You
  --- probably need to set it if you use the scrollbar with a FauxScrollFrame. 
  --- Use 0 as value will disable the step snaping 
  property "StepPercentage" {
    type    = Number,
    default = 0
  }

  --- The Scroll Percentage 
  property "ScrollPercentage" {
    type    = Number,
    default = 0,
    handler = function(self, value)
      self:Update()
      self:OnScroll(value)
    end
  }

  --- The Percentage which is visible 
  --- e.g: 0.5 says only 50% of frame content can be displayed
  property "VisibleExtentPercentage" {
    type = Number,
    default = 0,
    handler = function(self)
      self:Update()
    end
  }

  --- Whether the scrollbar use a proportional thumb. 
  --- A proportional thumb will be resized in function of scrolling amount.
  property "UseProportionalThumb" {
    type    = Boolean,
    default = true
  }

  --- Whether the scrollbar use a fixed thumb fixed. 
  --- Setting a value different of 0 will disable UseProportionalThumb
  property "FixedThumbExtend" {
    type    = Number,
    default = 0
  }

  --- The minimum the thumb height if it's vertical can be 
  property "MinThumbExtent" {
    type    = Number,
    default = 10
  }

  property "ThumbAnchor" {
    type    = String,
    default = "TOPLEFT"
  }

  property "AllowScroll" {
    type    = Boolean,
    default = true
  }

  property "WheelExtentPercentage" {
    type = Number,
    get = function() return GetSetting("mouseWheelScrollStep") or 0.1 end,
    set = false
  }

  property "WheelScalar" {
    type = Number,
    default = 1
  }
  -----------------------------------------------------------------------------
  --                            Constructors                                 --
  -----------------------------------------------------------------------------
  __Template__ {
    Track = Frame,
    {
      Track = {
        Thumb = ScrollBarThumb
      }
    }
  }
  function __ctor(self)
    local track = self:GetTrack()
    local thumb = self:GetThumb()

    track.OnMouseDown = track.OnMouseDown + function(_, buttonName)
      OnTrackMouseDown(self, track, buttonName)
    end 
    thumb.OnMouseDown = thumb.OnMouseDown + function(_, buttonName)
      OnThumbMouseDown(self, thumb, buttonName)
    end
    
    self.OnMouseWheel = self.OnMouseWheel + OnMouseWheel

  end
end)
-------------------------------------------------------------------------------
--                                Styles                                     --
-------------------------------------------------------------------------------
Style.UpdateSkin("Default", {
  [ScrollBarThumb] = {
       width = 6,
        height = 150,

        location = {
          Anchor("TOPLEFT")
        },

        TopBGTexture = {
          --atlas = AtlasType("minimal-scrollbar-thumb-top", true),
          width = 6,
          height = 8,
          file = SCROLLBAR_THUMB_EDGES_FILE,
          texCoords = SCROLLBAR_THUMB_TOP_HOVER_COORDS,
          vertexColor = ColorType(1, 199/255, 0, 0.75),
          drawLayer = "BACKGROUND",
          subLevel = 2,
          location = {
            Anchor("TOPLEFT")
          }
        },
        
        BottomBGTexture = {
          --atlas = AtlasType("minimal-scrollbar-thumb-bottom", true),
          width = 6,
          height = 36,
          file = SCROLLBAR_THUMB_EDGES_FILE,
          texCoords = SCROLLBAR_THUMB_BOTTOM_HOVER_COORDS,
          vertexColor = ColorType(1, 199/255, 0, 0.75),
          drawLayer = "BACKGROUND",
          subLevel = 2,
          location = {
            Anchor("BOTTOMLEFT")
          },
        },
                
        MiddleBGTexture = {
          --atlas = AtlasType("minimal-scrollbar-thumb-middle", true),
          width = 6,
          file = SCROLLBAR_THUMB_MIDDLE_FILE,
          texCoords = SCROLLBAR_THUMB_MIDDLE_HOVER_COORDS,
          vertexColor = ColorType(1, 199/255, 0, 0.75),
          drawLayer = "BACKGROUND",
          subLevel = 1,
          location = {
            Anchor("TOPLEFT", 0, -8),
            Anchor("BOTTOMRIGHT", 0, 5)
          },
        }    
  },

  [ScrollBar] = {
    size = Size(6, 560),

    Track = {
      width = 6,

      location = {
        Anchor("TOP", 0, -19),
        Anchor("BOTTOM", 0, 19)
      },

      TopBGTexture = {
        atlas = AtlasType("minimal-scrollbar-track-top", true),
        width = 6,
        drawLayer = "ARTWORK",
        location = {
          Anchor("TOPLEFT")
        }
      },
      
      BottomBGTexture = {
        atlas = AtlasType("minimal-scrollbar-track-bottom", true),
         width = 6,
        drawLayer = "ARTWORK",
        location = {
          Anchor("BOTTOMLEFT")
        },
      },
              
      MiddleBGTexture = {
        atlas = AtlasType("!minimal-scrollbar-track-middle", true),
        width = 6,
        drawLayer = "ARTWORK",
        location = {
          Anchor("TOPLEFT", 0, 0, "TopBGTexture", "BOTTOMLEFT"),
          Anchor("BOTTOMRIGHT", 0, 0, "BottomBGTexture", "TOPRIGHT")
        },
      },

      Thumb = {
        location = {
          Anchor("TOPLEFT")
        },
      }
    }
  }
})

function OnLoad(self)
  RegisterSetting("mouseWheelScrollStep", 0.1)
end
