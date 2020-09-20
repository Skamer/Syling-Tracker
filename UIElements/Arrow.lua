-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                 "SylingTracker.UIElements.Arrow"                      ""
-- ========================================================================= --
namespace                          "SLT"
-- ========================================================================= --
class "Arrow" (function(_ENV)
  inherit "Texture"

  _Reycler = Recycle(Arrow, "SLT_Arrow%d")

  enum "OrientationType" {
        "RIGHT",
        "BOTTOM",
        "LEFT",
        "TOP"
  }

  _ARROW_TEX_COORDS = {
    ["RIGHT"] = { left = 0, right = 32/128, top = 0, bottom = 1 },
    ["BOTTOM"] = { left = 32/128, right = 64/128, top = 0, bottom = 1 },
    ["LEFT"] = { left = 64/128, right = 96/128, top = 0, bottom = 1 },
    ["TOP"] = { left = 96/128, right = 1, top = 0, bottom = 1 }
  }
  -----------------------------------------------------------------------------
  --                               Handlers                                  --
  -----------------------------------------------------------------------------
  local function HandleOrientationChange(self, new, old, prop)
    Style[self].texCoords = _ARROW_TEX_COORDS[new]
  end
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  function Release(self)
    self.Orientation = nil
    self:Hide()
    self:SetParent()
    self:ClearAllPoints()

    _Reycler(self)
  end

  __Static__() function Acquire()
    local obj = _Reycler()
    obj:Show()

    return obj 
  end

  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  property "Orientation" {
    type    = OrientationType,
    default = OrientationType.RIGHT,
    handler = HandleOrientationChange
  }
  -----------------------------------------------------------------------------
  --                            Constructors                                 --
  -----------------------------------------------------------------------------
  function __ctor(self)
    HandleOrientationChange(self, self.Orientation)
  end 
end)

Style.UpdateSkin("Default", {
  [Arrow] = {
    size = Size(24, 24),
    vertexColor = { r = 0, g = 0, b = 0, a = 0.6},
    file = [[Interface\AddOns\SylingTracker\Media\Textures\ContextMenu-Arrow]]
  }
})