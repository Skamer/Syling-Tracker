-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling              "SylingTracker.Options.Elements.Panel"                   ""
-- ========================================================================= --
__Widget__()
class "SUI.Panel" (function(_ENV)
    inherit "SUI.Window"
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

    function SetAddonLogo(self, logoFile)
      Style[self].Footer.AddonLogo.file = logoFile
    end

    __Arguments__ { String, String/"" }
    function CreateCategory(self, id, text)
      self:GetChild("Categories"):CreateCategory(id, text)
    end 

    __Arguments__ { SUI.EntryData, String }
    function AddCategoryEntry(self, entryData, categoryId)
      self:GetChild("Categories"):AddCategoryEntry(entryData, categoryId)
    end

    __Arguments__ { String, Number}
    function SelectEntry(self, categoryId, index)
      self:GetChild("Categories"):SelectEntry(categoryId, index)
    end

    function Refresh(self)
      self:GetChild("Categories"):Refresh()
    end
  -----------------------------------------------------------------------------
  --                            Constructors                                 --
  -----------------------------------------------------------------------------
    --- This is important to instant apply style for the scrollbox have a valid
    --- size
    __InstantApplyStyle__()
    __Template__ {
      Categories = SUI.CategoryList,
      Footer = Frame,
      InnerTexture = Texture,
      Header = Frame,
      Container = SUI.ScrollBox,
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
class "SUI.SettingsPanel" (function(_ENV)
  inherit "SUI.Panel"
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
      local settings = settingsDefinitionsClass.Acquire()
      local scrollBox = self:GetChild("Container")
      self.CurrentSettings = settings

      scrollBox:SetScrollTarget(settings)
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
  [SUI.Panel] = {
    width = 1051,
    height = 775,

    Categories = {
      visible = true,
      location = {
        Anchor("TOPLEFT", 20, -15)
      }
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
        Anchor("TOP", 0, -45),
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