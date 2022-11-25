-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling              "SylingTracker.Options.Elements.CheckBox"                ""
-- ========================================================================= --
local BLZ_MINIMAL_CHECKBOX_FILE = [[Interface\AddOns\SylingTracker_Options\Media\BLZ_MinimalCheckbox]]

__Widget__()
class "SUI.CheckBox" (function(_ENV)
  inherit "CheckButton"
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  function OnAcquire(self)
    self:InstantApplyStyle()
  end

  function OnRelease(self)
    self:ClearAllPoints()
    self:Hide()
    self:SetParent()
  end
end)
-------------------------------------------------------------------------------
--                                Styles                                     --
-------------------------------------------------------------------------------
Style.UpdateSkin("Default", {
  [SUI.CheckBox] = {
    size = Size(30, 29),
    checked = false,

    NormalTexture = {
        --- checkbox-minimal, true
      file = BLZ_MINIMAL_CHECKBOX_FILE,
      width = 30,
      height = 29,
      texCoords = { left = 0.015625, right = 0.484375, top = 0.015625, bottom = 0.46875},
    },
    
    PushedTexture = {
      --- checkbox-minimal, true
      file = BLZ_MINIMAL_CHECKBOX_FILE,
      width = 30,
      height = 29,
      texCoords = { left = 0.015625, right = 0.484375, top = 0.015625, bottom = 0.46875},
    },

    CheckedTexture = {
      --- checkmark-minimal", true
      file = BLZ_MINIMAL_CHECKBOX_FILE,
      width = 30,
      height = 29,
      texCoords = { left = 0.015625, right = 0.484375, top = 0.5, bottom = 0.953125},
      location = {
        Anchor("CENTER")
      }
    },

    DisabledCheckedTexture = {
      --- checkmark-minimal-disabled, true
      file = BLZ_MINIMAL_CHECKBOX_FILE,
      width = 30,
      height = 29,
      texCoords = { left = 0.515625, right = 0.984375, top = 0.015625, bottom = 0.46875},
      location = {
        Anchor("CENTER")
      }
    }
  }
})