-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling              "SylingTracker_Options.Elements.Panel"                   ""
-- ========================================================================= --
class "SUI.Panel" (function(_ENV)
    inherit "SUI.Window"

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

    function Refresh(self)
      self:GetChild("Categories"):Refresh()
    end


    __Template__ {
      Categories = SUI.CategoryList,
      Footer = Frame,
      {
        Footer = {
          AddonLogo = Texture,
          AddonVersion = FontString
        }
      }
    }
    function __ctor(self) end
end)

Style.UpdateSkin("Default", {
  [SUI.Panel] = {
    width = 1151,
    height = 775,

    Categories = {
      location = {
        Anchor("TOPLEFT", 0, 0)
      }
    },

    Footer = {
      height = 36,
      location = {
        Anchor("BOTTOM", 0, 5),
        Anchor("LEFT"),
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