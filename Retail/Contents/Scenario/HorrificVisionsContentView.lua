-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling           "SylingTracker.Contents.HorrificVisionsContentView"         ""
-- ========================================================================= --
export {
  FromUIProperty                      = Wow.FromUIProperty,
  FromBackdrop                        = Frame.FromBackdrop,
  FromUISetting                       = API.FromUISetting,
  RegisterUISetting                   = API.RegisterUISetting,
}

__UIElement__()
class "HorrificVisionsContentView" (function(_ENV)
  inherit "ScenarioContentView"
  -----------------------------------------------------------------------------
  --                                Methods                                  --
  -----------------------------------------------------------------------------
  function OnViewUpdate(self, data, metadata)
    super.OnViewUpdate(self, data, metadata)

    self.Mementos = data and data.mementos
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  __Observable__()
  property "Mementos" { type = Number, default = 0 }
  -----------------------------------------------------------------------------
  --                              Constructors                               --
  -----------------------------------------------------------------------------
  __Template__ {
    Mementos = Frame,
    {
      Mementos = {
        Icon = Texture,
        Amount = FontString
      }
    } 
  }
  function __ctor(self) end

end)
-------------------------------------------------------------------------------
--                              UI Settings                                  --
-------------------------------------------------------------------------------
RegisterUISetting("horrificVisions.mementos.showBackground", true)
RegisterUISetting("horrificVisions.mementos.showBorder", true)
RegisterUISetting("horrificVisions.mementos.backgroundColor", Color(35/255, 40/255, 46/255, 0.73))
RegisterUISetting("horrificVisions.mementos.borderColor", Color(0, 0, 0, 0.4))
RegisterUISetting("horrificVisions.mementos.borderSize", 1)
RegisterUISetting("horrificVisions.mementos.mediaFont", FontType("DejaVuSansCondensed Bold", 14))
RegisterUISetting("horrificVisions.mementos.textColor", Color(1, 0.914, 0.682))
RegisterUISetting("horrificVisions.mementos.justifyH", "CENTER")
-------------------------------------------------------------------------------
--                              Observables                                  --
-------------------------------------------------------------------------------
function FromMementosText()
  return FromUIProperty("Mementos"):Map(function(amount)
    return CreateTextureMarkup(646678, 32, 32, 18, 18, 0.1, 0.9, 0.1, 0.9) .. " " .. amount
  end)
end
-------------------------------------------------------------------------------
--                                Styles                                     --
-------------------------------------------------------------------------------
Style.UpdateSkin("Default", {
  [HorrificVisionsContentView] = {
    TopScenarioInfo = {
        ScenarioIcon = {
          atlas                       = AtlasType("NzothScenario-TrackerHeader"),
        }   
    },

    Mementos = {
      backdrop                        = FromBackdrop(),
      showBackground                  = FromUISetting("horrificVisions.mementos.showBackground"),
      showBorder                      = FromUISetting("horrificVisions.mementos.showBorder"),
      backdropColor                   = FromUISetting("horrificVisions.mementos.backgroundColor"),
      backdropBorderColor             = FromUISetting("horrificVisions.mementos.borderColor"),
      borderSize                      = FromUISetting("horrificVisions.mementos.borderSize"),

      height                          = 30,
      location                        = {
                                        Anchor("TOP", 0, 0, "TopScenarioInfo", "BOTTOM"),
                                        Anchor("LEFT"),
                                        Anchor("RIGHT")
                                      },

      Amount = {
        text                          = FromMementosText(),
        mediaFont                     = FromUISetting("horrificVisions.mementos.mediaFont"),
        textColor                     = FromUISetting("horrificVisions.mementos.textColor"),
        justifyH                      = FromUISetting("horrificVisions.mementos.justifyH"),
        justifyV                      = "MIDDLE",
        location                      = {
                                        Anchor("TOP"),
                                        Anchor("LEFT", 2, 0),
                                        Anchor("RIGHT", -2, 0),
                                        Anchor("BOTTOM")
                                      },
      }
    },

    Objectives = {
      location                        = {
                                        Anchor("TOP", 0, -5, "Mementos", "BOTTOM"),
                                        Anchor("LEFT"),
                                        Anchor("RIGHT")
                                      }  
    }

  }
})