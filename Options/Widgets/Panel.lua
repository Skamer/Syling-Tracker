-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling              "SylingTracker_Options.Widgets.Panel"                    ""
-- ========================================================================= --
namespace               "SylingTracker.Options.Widgets"
-- ========================================================================= --

__Widget__()
class "Panel" (function(_ENV)
  inherit "Window"
  -----------------------------------------------------------------------------
  --                               Events                                    --
  -----------------------------------------------------------------------------
    __Bubbling__{ Categories = "OnEntrySelected"}
    event "OnCategorySelected"
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  function SetAddonVersion(self, version)
    Style[self].Footer.AddonVersion.text = version
  end

  function SetAddonLogo(self, file)
    Style[self].Footer.AddonLogo.file = file
  end

  __Arguments__ { String, String/"" }
  function CreateCategory(self, id, text)
    self:GetChild("Categories"):CreateCategory(id, text)
  end 

  __Arguments__ { EntryData, String }
  function AddCategoryEntry(self, entryData, categoryId)
    self:GetChild("Categories"):AddCategoryEntry(entryData, categoryId)

    if entryData.id then 
      self.EntriesId[entryData.id] = entryData
    end

    self.EntriesCategory[entryData] = categoryId
  end

  __Arguments__ { String, Number}
  function SelectEntry(self, categoryId, index)
    self:GetChild("Categories"):SelectEntry(categoryId, index)
  end

  __Arguments__ { String, String}
  function SelectEntryById(self, categoryId, entryId)
    self:GetChild("Categories"):SelectEntryById(categoryId, entryId)
  end

  __Arguments__ { String }
  function RemoveEntryById(self, entryId)
    local entry = self.EntriesId[entryId]
    if not entry then 
      return 
    end

    local categoryId = self.EntriesCategory[entry]

    self:GetChild("Categories"):RemoveEntry(categoryId, entry)

    self.EntriesId[entryId] = nil
    self.EntriesCategory[entry] = nil
  end

  __Arguments__ { String/nil }
  function Refresh(self, categoryId)
    self:GetChild("Categories"):Refresh(categoryId)
  end
  __Arguments__ { String/nil}
  function ClearEntries(self, categoryId)
    self:GetChild("Categories"):ClearEntries(categoryId)
  end

  property "EntriesId" {
    set = false,
    default = function() return System.Toolset.newtable(true, false) end
  }

  property "EntriesCategory" {
    set = false,
    default = function() return System.Toolset.newtable(true, false) end
  }
  -----------------------------------------------------------------------------
  --                            Constructors                                 --
  -----------------------------------------------------------------------------
  __Template__ {
    Categories = PanelCategories,
    Footer = Frame,
    InnerTexture = Texture,
    Header =  Frame,
    Container = ScrollBox,
    {
      Footer = {
        AddonLogo = Texture,
        AddonVersion = FontString
      },
      Header = {
        Title = FontString,
        Separator = Texture
      }
    }
  }
  function __ctor(self) end 
end)

__Widget__()
class "SettingsPanel" (function(_ENV)
  inherit "Panel"
  -----------------------------------------------------------------------------
  --                               Handlers                                  --
  -----------------------------------------------------------------------------
  local function OnPanelCategorySelected(self, entry)
    local data = entry:GetEntryData()
    local settingsDefinitionsClass = data.value

    if self.CurrentSettings then 
      self.CurrentSettings:Release() 
    end

    if settingsDefinitionsClass then
      local settings 
      if type(settingsDefinitionsClass) == "function" then
        settings = settingsDefinitionsClass(self, entry)
      else 
        settings = settingsDefinitionsClass.Acquire()
      end

      --- The settings should be created from this method, and not in the OnAcquire
      --- where this one will miss properties.
      if settings.OnBuildSettings then 
        settings:OnBuildSettings()
      end

      local scrollBox = self:GetChild("Container")
      self.CurrentSettings = settings

      scrollBox:SetScrollTarget(settings)

      -- We move the scroll to begin
      scrollBox:SetVerticalScroll(0)

      settings:Show()
    else 
      self.CurrentSettings = nil 
    end

    Style[self].Header.Title.text = data.text
  end
  -----------------------------------------------------------------------------
  --                            Constructors                                 --
  -----------------------------------------------------------------------------
  __Template__{}
  function __ctor(self)
    self.OnPanelCategorySelected = function(_, entry) OnPanelCategorySelected(self, entry) end

    self.OnCategorySelected = self.OnCategorySelected + self.OnPanelCategorySelected
  end
end)


-------------------------------------------------------------------------------
--                                Styles                                     --
-------------------------------------------------------------------------------
Style.UpdateSkin("Default", {
  [Panel] = {
    width   = 1051,
    height  = 775,

    Title = {
      location = {
        Anchor("TOP", 0, -15),
        Anchor("LEFT", 60, 0),
        Anchor("RIGHT", -60, 0)
      }
    },

    Categories = {
      height = 680,
      location = {
        Anchor("TOPLEFT", 23, -40)
      },

      -- [Category] = {
      --   paddingTop = 40
      -- }
    },

    InnerTexture = {
      atlas = AtlasType("Options_InnerFrame", false),
      visible = true,
      drawLayer = "OVERLAY",
      subLevel = 0,
      location = {
        Anchor("TOPLEFT", 20, -35),
        Anchor("BOTTOMRIGHT", -20, 45)
      }
    },


    Header = {

      height = 50,
      location = {
        Anchor("TOP", 0, -30),
        Anchor("LEFT", 40, 0, "Categories", "RIGHT"),
        Anchor("RIGHT", -30, 0),
      },

      Title = {
        fontObject = GameFontHighlightHuge,
        justifyH = "LEFT",
        text = "Header Text",

        location = {
          Anchor("TOPLEFT", 7, -22)
        }
      },

      Separator = {
        atlas = AtlasType("Options_HorizontalDivider", true),
        snapToPixelGrid = false,
        texelSnappingBias = 0,  
        location = {
          Anchor("TOP", 0, -50)
        }
      }
    },

    Container = {
      location = {
        Anchor("TOP", 0, -10, "Header", "BOTTOM"),
        Anchor("LEFT", 50, 0, "Categories", "RIGHT"),
        Anchor("RIGHT", -45, 0),
        Anchor("BOTTOM", 0, 5, "Footer", "TOP")
      }
    },
    
    Footer = {
      height = 36,
      visible = true, 
      location = {
        Anchor("BOTTOM", 0, 10),
        Anchor("LEFT", 15, 0),
        Anchor("RIGHT")
      },

      AddonLogo = {
        width = 32,
        height = 32,
        vertexColor = { r = 1, g = 1, b = 1, a = 0.35},
        location = {
          Anchor("LEFT", 5, 0)
        }
      },

      AddonVersion = {  
        fontObject = GameFontNormal,
        textColor = { r = 0.9, g = 0.9, b = 0.9, a = 0.35},
        location = {
          Anchor("LEFT", 5, 0, "AddonLogo", "RIGHT")
        }

      }      
    }
  }
})