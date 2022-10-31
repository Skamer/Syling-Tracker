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
__Widget__()
class "SUI.CheckBox" (function(_ENV)
  inherit "CheckButton"
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  function OnAcquire(self)
    Style[self].checked = nil
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
      atlas = AtlasType("checkbox-minimal", true)
    },
    
    PushedTexture = {
      atlas = AtlasType("checkbox-minimal", true)
    },

    CheckedTexture = {
      atlas = AtlasType("checkmark-minimal", true)
    },

    DisabledCheckedTexture = {
      atlas = AtlasType("checkmark-minimal-disabled", true)
    }
  }
})