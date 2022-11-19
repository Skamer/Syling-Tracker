-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling            "SylingTracker.Options.Elements.ColorPicker"               ""
-- ========================================================================= --
__Widget__()
class "SUI.ColorPicker" (function(_ENV)
  inherit "SUI.PushButton"
  -----------------------------------------------------------------------------
  --                               Events                                    --
  -----------------------------------------------------------------------------
  --- Trigger each time the color has changed 
  event "OnColorChanged"

  --- Trigger when the color has been confirmed (the user click on "Ok" or "Cancel" button)
  event "OnColorConfirmed"
  -----------------------------------------------------------------------------
  --                               Handlers                                  --
  -----------------------------------------------------------------------------
  local function OnClickHandler(self)
    ColorPickerFrame:Hide()

    ColorPickerFrame:SetFrameStrata("FULLSCREEN_DIALOG")
  	ColorPickerFrame:SetFrameLevel(self:GetFrameLevel() + 10)
		ColorPickerFrame:SetClampedToScreen(true)

    ColorPickerFrame.func = function()
      local r,g,b = ColorPickerFrame:GetColorRGB()
      local a = self.HasAlpha and (1 - OpacitySliderFrame:GetValue()) or 1
      if ColorPickerFrame:IsVisible() then 
        self:OnColorChanged(r, g, b, a)
      end

      self:SetColor(r, g, b, a)
    end
    ColorPickerFrame.hasOpacity = self.HasAlpha
  	ColorPickerFrame.opacityFunc = function()
		  local r, g, b = ColorPickerFrame:GetColorRGB()
			local a = self.HasAlpha and (1 - OpacitySliderFrame:GetValue()) or 1
      --- ColorPickerFrame call the callback after it's closed. 
      --- opacity callback is called even if the hasOpacity is false, so 
      --- it's the best to confirm a color. 
      if ColorPickerFrame:IsVisible() then 
        self:OnColorChanged(r, g, b, a)
      else 
        self:OnColorConfirmed(r, g, b, a)
      end
      self:SetColor(r, g, b, a)
		end


    local r, g, b, a = self.r, self.g, self.g, self.a

    if self.HasAlpha then 
      ColorPickerFrame.opacity = 1 - (a or 0)
    end

    ColorPickerFrame:SetColorRGB(r, g, b)

  	ColorPickerFrame.cancelFunc = function()
      self:OnColorConfirmed(r, g, b, a)
      self:SetColor(r, g, b, a)
		end

    ColorPickerFrame:Show()
  end
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  __Arguments__ { ColorFloat/1, ColorFloat/1, ColorFloat/1, ColorFloat/1}
  function SetColor(self, r, g, b, a)
    self:GetChild("ColorTexture"):SetVertexColor(r, g, b, a)

    self.r = r
    self.g = g 
    self.b = b 
    self.a = a
  end

  __Arguments__ { Boolean/nil }
  function SetHasAlpha(self, hasAlpha)
    self.HasAlpha = hasAlpha
  end

  function OnRelease(self)
    super.OnRelease(self)

    self.r = nil
    self.g = nil 
    self.b = nil 
    self.a = nil 
    self.HasAlpha = nil
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  property "HasAlpha" {
    type = Boolean,
    default = true
  }

  property "r" {
    type = ColorFloat,
    default = 1
  }

  property "g" {
    type = ColorFloat,
    default = 1
  }

  property "b" {
    type = ColorFloat,
    default = 1
  }

  property "a" {
    type = ColorFloat,
    default = 1
  }
  -----------------------------------------------------------------------------
  --                            Constructors                                 --
  -----------------------------------------------------------------------------
  __Template__{
    ColorTexture = Texture,
    ColorCheckers = Texture
  }
  function __ctor(self)
    self.OnClick = self.OnClick + OnClickHandler
  end
end)
-------------------------------------------------------------------------------
--                                Styles                                     --
-------------------------------------------------------------------------------
Style.UpdateSkin("Default", {
  [SUI.ColorPicker] = {
    size = Size(46, 40),

    Text = {
      visible = false
    },

    ColorTexture = {
      height = 16,
      width = 16,
      drawLayer = "OVERLAY",
      subLevel = 2,
      color = ColorType(1, 1, 1),
      location = {
        Anchor("CENTER")
      }
    },

    ColorCheckers = {
      width = 16,
      height = 16,
      fileId = 188523,
      drawLayer = "OVERLAY",
      subLevel = 1,
      desaturated = true,
      texCoords = { left = 0.25, right = 0, top = 0.5, bottom = 0.25},
      vertexColor = { r = 1, g = 1, b = 1, a = 0.75},
      location = {
        Anchor("CENTER")
      }
    }
  }
})