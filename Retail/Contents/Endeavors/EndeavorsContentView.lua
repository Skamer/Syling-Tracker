-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling             "SylingTracker.Contents.EndeavorsContentView"             ""
-- ========================================================================= -
export {
  FromUISetting                       = API.FromUISetting,
  GenerateUISettings                  = API.GenerateUISettings,
}

__UIElement__()
class "EndeavorsContentView" (function(_ENV)
  inherit "ContentView"
  -----------------------------------------------------------------------------
  --                                Methods                                  --
  -----------------------------------------------------------------------------
  function OnViewUpdate(self, data, metadata)
    super.OnViewUpdate(self, data, metadata)

    if data and data.endeavors then
      Style[self].Endeavors.visible = self.Expanded
      local endeavorsListView = self:GetPropertyChild("Endeavors")
      endeavorsListView:UpdateView(data.endeavors, metadata)
    else
      Style[self].Endeavors = NIL 
    end
  end

  function OnExpand(self)
    if self:GetPropertyChild("Endeavors") then 
      Style[self].Endeavors.visible = true 
    end
  end

  function OnCollapse(self)
    if self:GetPropertyChild("Endeavors") then 
      Style[self].Endeavors.visible = false 
    end
  end
end)

__ChildProperty__(EndeavorsContentView, "Endeavors")
__UIElement__() class(tostring(EndeavorsContentView) .. ".Endeavors") { EndeavorListView }
-------------------------------------------------------------------------------
--                              UI Settings                                  --
-------------------------------------------------------------------------------
GenerateUISettings("endeavors", "content")
-------------------------------------------------------------------------------
--                              Observables                                  --
-------------------------------------------------------------------------------
function FromEndeavorsLocation()
  return FromUISetting("endeavors.showHeader"):Map(function(visible)
    if visible then 
      return {
        Anchor("TOP", 0, -10, "Header", "BOTTOM"),
        Anchor("LEFT"),
        Anchor("RIGHT")        
      }
    end

    return {
        Anchor("TOP"),
        Anchor("LEFT"),
        Anchor("RIGHT")
    }
  end)
end
-------------------------------------------------------------------------------
--                                Styles                                     --
-------------------------------------------------------------------------------
Style.UpdateSkin("Default", {
  [EndeavorsContentView] = {
    Header = {
      visible                         = FromUISetting("endeavors.showHeader"),
      showBackground                  = FromUISetting("endeavors.header.showBackground"),
      showBorder                      = FromUISetting("endeavors.header.showBorder"),
      backdropColor                   = FromUISetting("endeavors.header.backgroundColor"),
      backdropBorderColor             = FromUISetting("endeavors.header.borderColor"),
      borderSize                      = FromUISetting("endeavors.header.borderSize"),

      Label = {
        mediaFont                     = FromUISetting("endeavors.header.label.mediaFont"),
        textColor                     = FromUISetting("endeavors.header.label.textColor"),
        justifyH                      = FromUISetting("endeavors.header.label.justifyH"),
        justifyV                      = FromUISetting("endeavors.header.label.justifyV"),
        textTransform                 = FromUISetting("endeavors.header.label.textTransform"),
      }
    },

    [EndeavorsContentView.Endeavors] = {
      location                        = FromEndeavorsLocation()
    }
  }
})