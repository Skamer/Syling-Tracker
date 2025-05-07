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
Syling                 "SylingTracker.Contents.PetsView"                     ""
-- ========================================================================= --
export {
  FromUIProperty                      = Wow.FromUIProperty,
  FromBackdrop                        = Frame.FromBackdrop,
  RegisterUISetting                   = API.RegisterUISetting,
  FromUISetting                       = API.FromUISetting,
  FromUISettings                      = API.FromUISettings
}

__UIElement__()
class "PetView" (function(_ENV)
  inherit "Button" extend "IView"
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  function OnViewUpdate(self, data, metadata)
    self.PetName = data.name
    self.PetIcon = data.icon
    self.SpecieID = data.specieID 
    self.SourceIcon = data.sourceIcon
    self.PetQuality = data.quality
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  __Observable__()
  property "PetName" {
    type = String,
    default = ""
  }

  __Observable__()
  property "PetIcon" {
    type = Any
  }
  
  __Observable__()
  property "SourceIcon" {
    type = Any
  }

  __Observable__()
  property "PetQuality" {
    type = Number
  }

  property "SpecieID" {
    type = Number
  }
  -----------------------------------------------------------------------------
  --                              Constructors                               --
  -----------------------------------------------------------------------------
  __Template__ {
    Icon = Texture,
    SourceIcon = Texture,
    Name = FontString, 
  }
  function __ctor(self) end 
end)

__UIElement__()
class "PetListView"(function(_ENV)
  inherit "NewListView"
  -----------------------------------------------------------------------------
  --                                Methods                                  --
  -----------------------------------------------------------------------------
  __Iterator__()
  function IterateData(self, data, metadata)
    local yield = coroutine.yield
    
    wipe(self.PetsOrder)

    for _, petData in pairs(data) do 
      tinsert(self.PetsOrder, petData)
    end

    table.sort(self.PetsOrder, function(a, b)
      if a.quality == b.quality then 
        return a.name < b.name
      end

      return a.quality < b.quality
    end)

    for _, petData in ipairs(self.PetsOrder) do
      if not self:IsFilteredEntry(petData.specieID, petData, metadata) then 
        yield(petData.specieID, petData, metadata)
      end
    end
  end

  function IsFilteredEntry(self, key, petData, metadata)
    if self.HideOwned and petData.quality and petData.quality > 0 then 
      return true 
    end

    return super.IsFilteredEntry(self, key, petData, metadata)
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  property "HideOwned" {
    type = Boolean,
    default = false, 
    handler = function(self) self:RefreshView() end
  }

  property "PetsOrder" {
    set = false,
    default = function() return {} end
  }
end)
-------------------------------------------------------------------------------
--                              UI Settings                                  --
-------------------------------------------------------------------------------
RegisterUISetting("pets.hideOwned", false)
RegisterUISetting("pets.columns", 2)

RegisterUISetting("pet.showBackground", true)
RegisterUISetting("pet.showBorder", true)
RegisterUISetting("pet.useFixedColorForBackground", false)
RegisterUISetting("pet.backgroundColor", Color(35/255, 40/255, 46/255, 0.73))
RegisterUISetting("pet.useFixedColorForBorder", true)
RegisterUISetting("pet.borderColor", Color(0, 0, 0, 0.4))
RegisterUISetting("pet.borderSize", 1)
RegisterUISetting("pet.name.mediaFont", FontType("DejaVuSansCondensed Bold", 10))
RegisterUISetting("pet.name.textTransform", "NONE")
RegisterUISetting("pet.name.useFixedColor", false)
RegisterUISetting("pet.name.fixedColor", nil)
RegisterUISetting("pet.name.textColor", nil)
-------------------------------------------------------------------------------
--                              Observables                                  --
-------------------------------------------------------------------------------
function FromBackdropColor()
  local darkenFactor = 0.6

  return FromUIProperty("PetQuality"):CombineLatest(
    FromUISettings("pet.useFixedColorForBackground", "pet.backgroundColor"))
    :Map(function(quality, useFixedColor, fixedColor)
        if useFixedColor then 
          return fixedColor
        end

        local color = Color(ITEM_QUALITY_COLORS[quality - 1] or RED_FONT_COLOR)
        return Color(color.r * darkenFactor, color.g * darkenFactor, color.b * darkenFactor, 0.73)
    end)
end

function FromBorderColor()
  return FromUIProperty("PetQuality"):CombineLatest(
    FromUISettings("pet.useFixedColorForBorder", "pet.backgroundColor"))
    :Map(function(quality, useFixedColor, fixedColor)
        if useFixedColor then 
          return fixedColor
        end

        local color = Color(ITEM_QUALITY_COLORS[quality - 1] or RED_FONT_COLOR)
        return Color(color.r, color.g, color.b, 1)
    end)
end

function FromPetNameTextColor()
  local darkenFactor = 1.0

  return FromUIProperty("PetQuality"):CombineLatest(
    FromUISettings("pet.name.useFixedColor", "pet.name.fixedColor"))
    :Map(function(quality, useFixedColor, fixedColor)
        if useFixedColor then 
          return fixedColor
        end

        local color = Color(ITEM_QUALITY_COLORS[quality - 1] or RED_FONT_COLOR)
        return Color(color.r * darkenFactor, color.g * darkenFactor, color.b * darkenFactor, 0.73)
    end)
end
-------------------------------------------------------------------------------
--                                Styles                                     --
-------------------------------------------------------------------------------
Style.UpdateSkin("Default", {
  [PetView] = {
    height                            = 28,
    registerForClicks                 = { "LeftButtonDown", "RightButtonDown" },
    backdrop                          = FromBackdrop(),
    showBackground                    = FromUISetting("pet.showBackground"),
    showBorder                        = FromUISetting("pet.showBorder"),
    backdropColor                     = FromBackdropColor(),
    backdropBorderColor               = FromBorderColor(),
    borderSize                        = FromUISetting("pet.borderSize"),

    Icon = {
      width                           = 20,
      height                          = 20,
      file                            = FromUIProperty("PetIcon"),
      texCoords                       = { left = 0.07,  right = 0.93, top = 0.07, bottom = 0.93 } ,
      subLevel                        = 1,
      location                        = { Anchor("LEFT", 5, 0) }
    },

    SourceIcon = {
      width                           = 14,
      height                          = 14,
      subLevel                        = 2,
      file                            = FromUIProperty("SourceIcon"),
      location                        = { Anchor("BOTTOM", 0, 0, "Icon", "BOTTOMRIGHT") }
    },

    Name = {
      text                            = FromUIProperty("PetName"),
      textColor                       = FromPetNameTextColor(),
      mediaFont                       = FromUISetting("pet.name.mediaFont"),
      location                        = {
                                        Anchor("TOP"),
                                        Anchor("LEFT", 5, 0, "Icon", "RIGHT"),
                                        Anchor("RIGHT"),
                                        Anchor("BOTTOM")
                                      }
    }
  },

  [PetListView] = {
    viewClass                         = PetView,
    indexed                           = false,
    hideOwned                         = FromUISetting("pets.hideOwned"),
    columns                           = FromUISetting("pets.columns")
  }
})
