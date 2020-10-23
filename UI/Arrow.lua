-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                      "SylingTracker.UI.Arrow"                         ""
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
    ["RIGHT"] = RectType(0, 32/128, 0, 1),
    ["BOTTOM"] = RectType(32/128, 64/128, 0, 1),
    ["LEFT"] = RectType(64/128, 96/128, 0, 1),
    ["TOP"] = RectType(96/128, 1, 0, 1)
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