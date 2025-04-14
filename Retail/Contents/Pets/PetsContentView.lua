-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
if not C_AddOns.IsAddOnLoaded("PetTracker") then return end
-- ========================================================================= --
Syling             "SylingTracker.Contents.PetsContentView"                  ""
-- ========================================================================= --
export {
  FromUISetting                       = API.FromUISetting,
  GenerateUISettings                  = API.GenerateUISettings
}

__UIElement__()
class "PetsContentView" (function(_ENV)
  inherit "ContentView"
  -----------------------------------------------------------------------------
  --                                Methods                                  --
  -----------------------------------------------------------------------------
  function OnViewUpdate(self, data, metadata)
    super.OnViewUpdate(self, data, metadata)

    if data and data.pets then
      Style[self].Progress.visible = self.Expanded 
      Style[self].Pets.visible = self.Expanded

      local progressBar = self:GetPropertyChild("Progress")
      local ownedInZone = data.ownedInZone
      local totalInZone = data.totalInZone
      
      local ownedByQualityInZone = data.ownedByQualityInZone
      local maxQuality = 6

      progressBar:ClearBreakpoints()
      if ownedByQualityInZone then 
        local segmentIndex = 0
        local owned = 0
        for i = maxQuality, 1, -1 do 
          local qualityOwned = ownedByQualityInZone[i] or 0
          if qualityOwned > 0 then 
            segmentIndex = segmentIndex + 1 

            if segmentIndex > 1 then 
              progressBar:AddBreakpoint(owned)
            end

            local color = ITEM_QUALITY_COLORS[i - 1] or RED_FONT_COLOR
            local darkenFactor = 0.6

            progressBar.SegmentColors[segmentIndex] = Color(color.r * 0.5, color.g * 0.5, color.b * 0.5, color.a)

            owned = owned + qualityOwned
          end
        end
      end

      progressBar:SetMinMaxValues(0, totalInZone)
      progressBar:SetValue(ownedInZone)

      Style[progressBar].FText.Text.text = ("%i / %i"):format(ownedInZone, totalInZone)

      local petsListView = self:GetPropertyChild("Pets")
      petsListView:UpdateView(data.pets, metadata)
    else 
      Style[self].Progress = NIL
      Style[self].Pets = NIL 
    end
  end

  function OnExpand(self)
    if self:GetPropertyChild("Progress") then 
      Style[self].Progress.visible = true 
    end

    if self:GetPropertyChild("Pets") then 
      Style[self].Pets.visible = true 
    end
  end

  function OnCollapse(self)
    if self:GetPropertyChild("Progress") then 
      Style[self].Progress.visible = false
    end

    if self:GetPropertyChild("Pets") then 
      Style[self].Pets.visible = false 
    end
  end
end)

__ChildProperty__(PetsContentView, "Progress")
__UIElement__() class(tostring(PetsContentView) .. ".Progress")  { ProgressWithSegments }

__ChildProperty__(PetsContentView, "Pets")
__UIElement__() class(tostring(PetsContentView) .. ".Pets") { PetListView }
-------------------------------------------------------------------------------
--                              UI Settings                                  --
-------------------------------------------------------------------------------
GenerateUISettings("pets", "content")
-------------------------------------------------------------------------------
--                              Observables                                  --
-------------------------------------------------------------------------------
function FromProgressLocation() 
  return FromUISetting("pets.showHeader"):Map(function(visible)
    if visible then 
      return {
        Anchor("TOP", 0, -10, "Header", "BOTTOM"),
        Anchor("LEFT", 10, 0),
        Anchor("RIGHT", -10, 0)        
      }
    end

    return {
        Anchor("TOP"),
        Anchor("LEFT", 10, 0),
        Anchor("RIGHT", -10, 0)
    }
  end)
end
-------------------------------------------------------------------------------
--                                Styles                                     --
-------------------------------------------------------------------------------
Style.UpdateSkin("Default", {
  [PetsContentView] = {
    Header = {
      visible                         = FromUISetting("pets.showHeader"),
      showBackground                  = FromUISetting("pets.header.showBackground"),
      showBorder                      = FromUISetting("pets.header.showBorder"),
      backdropColor                   = FromUISetting("pets.header.backgroundColor"),
      backdropBorderColor             = FromUISetting("pets.header.borderColor"),
      borderSize                      = FromUISetting("pets.header.borderSize"),

      Label = {
        mediaFont                     = FromUISetting("pets.header.label.mediaFont"),
        textColor                     = FromUISetting("pets.header.label.textColor"),
        justifyH                      = FromUISetting("pets.header.label.justifyH"),
        justifyV                      = FromUISetting("pets.header.label.justifyV"),
        textTransform                 = FromUISetting("pets.header.label.textTransform"),
      }
    },

    [PetsContentView.Progress] = {
      height                          = 20,
      location                        = FromProgressLocation(),
    },

    [PetsContentView.Pets] = {
      location = {
        Anchor("TOP", 0, -10, "Progress", "BOTTOM"),
        Anchor("LEFT"),
        Anchor("RIGHT")        
      }
    }
  }
})