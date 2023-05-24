-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                     "SylingTracker.Core.FontString"                   ""
-- ========================================================================= --
export {
  GetMedia        = API.GetMedia,
  FetchFontObject = API.FetchFontObject
}

TEXT_RAWS         = Toolset.newtable(true, false)

__UIElement__()
class "FontString" (function(_ENV)
  inherit "Scorpio.UI.FontString"
  -----------------------------------------------------------------------------
  --                               Events                                    --
  -----------------------------------------------------------------------------
  event "OnTextHeightChanged"
  -----------------------------------------------------------------------------
  --                             Enumerations                                --
  -----------------------------------------------------------------------------
  enum "TextTransformType" {
    "NONE",
    "LOWERCASE",
    "UPPERCASE"
  }
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  __Arguments__ { FontType/nil  }
  function SetMediaFont(self, font)
    if font then
      local flags 

      if font.outline then 
        if font.outline == "NORMAL" then 
          flags = "OUTLINE"
        elseif font.outline == "THICK" then 
          flags = "THICKOUTLINE"
        end
      end

      if font.monochrome then 
        if flags then 
          flags = flags .. ",MONOCHROME"
        else
          flags = "MONOCHROME"
        end
      end

      local mediaFont = GetMedia("font", font.font) 

      return self:SetFontObject(FetchFontObject(mediaFont, font.height or 10, flags))
    end

    return self:SetFontObject(nil)
  end

  __Async__()
  function SetText(self, text)
    TEXT_RAWS[self] = text 

    if text then 
      if self.TextTransform == "LOWERCASE" then 
        text = text:lower()
      elseif self.TextTransform == "UPPERCASE" then 
        text = text:upper()
      end
    end

    super.SetText(self, text)

    Next()

    self.TextHeight = self:GetStringHeight()
  end


  __Async__()
  function SetFontObject(self, ...)
    super.SetFontObject(self, ...)

    Next()

    self.TextHeight = self:GetStringHeight()
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  property "TextTransform" {
    type      = TextTransformType,
    default   = "NONE",
    handler   = function(self) self:SetText(TEXT_RAWS[self] or self:GetText()) end 
  }

  property "MediaFont" {
    type      = FontType,
    handler   = function(self, font) self:SetMediaFont(font) end 
  }

  property "AutoHeight" {
    type = Boolean,
    default = true, 
  }

  property "TextHeight" {
    type      = Number,
    default   = 0,
    handler   = function(self, new, old, prop)
      if self.AutoHeight then 
        self:SetHeight(new)
      end

      OnTextHeightChanged(self, new, old)
    end
  }
end)