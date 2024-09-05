-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                 "SylingTracker.Contents.DungeonContentView"           ""
-- ========================================================================= --
export {
  FromUIProperty                      = Wow.FromUIProperty,
  FromBackdrop                        = Frame.FromBackdrop,
  FromUISetting                       = API.FromUISetting,
  RegisterUISetting                   = API.RegisterUISetting,
  GenerateUISettings                  = API.GenerateUISettings,
}

__UIElement__()
class "DungeonContentView" (function(_ENV)
  inherit "ContentView"
  -----------------------------------------------------------------------------
  --                                Methods                                  --
  -----------------------------------------------------------------------------
  function OnViewUpdate(self, data, metadata)
    super.OnViewUpdate(self, data, metadata)

    if data then 
      self.DungeonName          = data.name
      self.DungeonTextureFileID = data.textureFileID

      local objectives = self:GetChild("Objectives")
      objectives:UpdateView(data.objectives, metadata)
    else 
      self.DungeonName          = nil 
      self.DungeonTextureFileID = nil
    end
  end

  function OnExpand(self)
    Style[self].TopDungeonInfo.visible  = true
    Style[self].Objectives.visible      = true
  end

  function OnCollapse(self)
    Style[self].TopDungeonInfo.visible  = false
    Style[self].Objectives.visible      = false
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  __Observable__()
  property "DungeonTextureFileID" {
    type = Number
  }

  __Observable__()
  property "DungeonName" {
    type = String
  }
  -----------------------------------------------------------------------------
  --                              Constructors                               --
  -----------------------------------------------------------------------------
  __Template__{
    TopDungeonInfo  = Frame,
    Objectives      = ObjectiveListView,
    {
      TopDungeonInfo = {
        DungeonName       = FontString,
        DungeonIcon       = Texture,
        DungeonObjectIcon = Texture,
      }
    }
  }
  function __ctor(self) end
end)
-------------------------------------------------------------------------------
--                              UI Settings                                  --
-------------------------------------------------------------------------------
GenerateUISettings("dungeon", "content", function(generatedSettings)
  -- We ovveride the default value as we want by default the header wasn't show for 
  -- scenario
  if generatedSettings["dungeon.showHeader"] then 
    generatedSettings["dungeon.showHeader"].default = false
  end
end)

RegisterUISetting("dungeon.name.mediaFont", FontType("DejaVuSansCondensed Bold", 14))
RegisterUISetting("dungeon.name.textTransform", "NONE")
RegisterUISetting("dungeon.name.textColor", Color(1, 0.914, 0.682))
RegisterUISetting("dungeon.topInfo.showBackground", false)
RegisterUISetting("dungeon.topInfo.showBorder", true)
RegisterUISetting("dungeon.topInfo.backgroundColor", Color(35/255, 40/255, 46/255, 0.73))
RegisterUISetting("dungeon.topInfo.borderColor", Color(0, 0, 0, 0.4))
RegisterUISetting("dungeon.topInfo.borderSize", 1)
-------------------------------------------------------------------------------
--                              Observables                                  --
-------------------------------------------------------------------------------
function FromTopInfoLocation()
  return FromUISetting("dungeon.showHeader"):Map(function(visible)
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
  [DungeonContentView] = {
    Header = {
      visible                         = FromUISetting("dungeon.showHeader"),
      showBackground                  = FromUISetting("dungeon.header.showBackground"),
      showBorder                      = FromUISetting("dungeon.header.showBorder"),
      backdropColor                   = FromUISetting("dungeon.header.backgroundColor"),
      backdropBorderColor             = FromUISetting("dungeon.header.borderColor"),
      borderSize                      = FromUISetting("dungeon.header.borderSize"),

      Label = {
        mediaFont                     = FromUISetting("dungeon.header.label.mediaFont"),
        textColor                     = FromUISetting("dungeon.header.label.textColor"),
        justifyH                      = FromUISetting("dungeon.header.label.justifyH"),
        justifyV                      = FromUISetting("dungeon.header.label.justifyV"),
        textTransform                 = FromUISetting("dungeon.header.label.textTransform"),
      }
    },

    TopDungeonInfo = {
      backdrop                        = FromBackdrop(),
      showBackground                  = FromUISetting("scenario.topInfo.showBackground"),
      showBorder                      = FromUISetting("scenario.topInfo.showBorder"),
      backdropColor                   = FromUISetting("scenario.topInfo.backgroundColor"),
      backdropBorderColor             = FromUISetting("scenario.topInfo.borderColor"),
      borderSize                      = FromUISetting("scenario.topInfo.borderSize"),
      height                          = 48,
      location                        = FromTopInfoLocation(),

      DungeonObjectIcon = {
        atlas                         = AtlasType("Dungeon", true),
        location                      = { Anchor("TOPLEFT", 5, -5) }
      },

      DungeonIcon = {
        fileID                        = FromUIProperty("DungeonTextureFileID"),
        setAllPoints                  = true,
      },

      DungeonName = {
        text                          = FromUIProperty("DungeonName"),
        mediaFont                     = FromUISetting("dungeon.name.mediaFont"),
        textTransform                 = FromUISetting("dungeon.name.textTransform"),
        textColor                     = FromUISetting("dungeon.name.textColor"),

        location                      = {
                                        Anchor("LEFT", 5, 0),
                                        Anchor("TOP"),
                                        Anchor("BOTTOM"),
                                        Anchor("RIGHT")
                                      }
      }
    },

    Objectives = {
      autoAdjustHeight                = true,
      backdrop                        = { 
                                        bgFile = [[Interface\AddOns\SylingTracker\Media\Textures\LinearGradient]],
                                        edgeFile  = [[Interface\Buttons\WHITE8X8]],
                                        edgeSize  = 1
                                      },

      backdropColor                   = Color(35/255, 40/255, 46/255, 0.73),
      backdropBorderColor             = Color(0, 0, 0, 0.4),

      location                        = {
                                        Anchor("TOP", 0, -5, "TopDungeonInfo", "BOTTOM"),
                                        Anchor("LEFT"),
                                        Anchor("RIGHT")
                                      }
    }
  }
})