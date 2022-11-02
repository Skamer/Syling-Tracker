-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling          "SylingTracker_Options.SettingDefinitions.ItemBar"           ""
-- ========================================================================= --
export {
  ItemBarIsLocked = SLT.API.ItemBarIsLocked,
  LockItemBar     = SLT.API.LockItemBar,
  UnlockItemBar   = SLT.API.UnlockItemBar,
  ItemBarIsShown  = SLT.API.ItemBarIsShown,
  ShowItemBar     = SLT.API.ShowItemBar,
  HideItemBar     = SLT.API.HideItemBar
}

__Widget__()
class "SLT.SettingDefinitions.ItemBar" (function(_ENV)
  inherit "Frame"

  local function OnLockCheckBoxClick(self, checkBox)
    local lock = checkBox:IsChecked()
    if lock then 
      LockItemBar()
    else
      UnlockItemBar()
    end
  end

  local function OnShowCheckBoxClick(self, checkBox)
    local show = checkBox:IsChecked()
    if show then 
      ShowItemBar()
    else
      HideItemBar()
    end
  end
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  function BuildSettingControls(self)
    local lockItemBar = SUI.SettingsCheckBox.Acquire(false, self)
    lockItemBar:SetID(10)
    lockItemBar:SetLabel("Lock")
    lockItemBar:SetChecked(ItemBarIsLocked())
    lockItemBar.OnCheckBoxClick = lockItemBar.OnCheckBoxClick + self.OnLockCheckBoxClick
    self.SettingControls.lockItemBar = lockItemBar

    local showItemBar = SUI.SettingsCheckBox.Acquire(false, self)
    showItemBar:SetID(20)
    showItemBar:SetLabel("Show")
    showItemBar:SetChecked(ItemBarIsShown())
    showItemBar.OnCheckBoxClick = showItemBar.OnCheckBoxClick + self.OnShowCheckBoxClick
    self.SettingControls.showItemBar = showItemBar
  end

  function ReleaseSettingControls(self)
    for index, control in pairs(self.SettingControls) do 
      --- Remove the specific event handlers 
      if index == "lockItemBar" then 
        control.OnCheckBoxClick = control.OnCheckBoxClick - self.OnLockCheckBoxClick
      elseif index == "showItemBar" then 
        control.OnCheckBoxClick = control.OnCheckBoxClick - self.OnShowCheckBoxClick
      end

      --- Release the control 
      control:Release()
      self.SettingControls[index] = nil
    end
  end

  function OnBuildSettings(self)
    self:BuildSettingControls()
  end

  function OnRelease(self)
    self:ReleaseSettingControls()
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  --- Contains all controls
  property "SettingControls" {
    set = false,
    default = function() return Toolset.newtable(false, true) end
  }
  -----------------------------------------------------------------------------
  --                            Constructors                                 --
  -----------------------------------------------------------------------------
  function __ctor(self)
    self.OnLockCheckBoxClick = function(...) OnLockCheckBoxClick(self, ...) end
    self.OnShowCheckBoxClick = function(...) OnShowCheckBoxClick(self, ...) end
  end
end)
-------------------------------------------------------------------------------
--                                Styles                                     --
-------------------------------------------------------------------------------
Style.UpdateSkin("Default", {
  [SLT.SettingDefinitions.ItemBar] = {
    layoutManager = Layout.VerticalLayoutManager(true, true)
  }
})