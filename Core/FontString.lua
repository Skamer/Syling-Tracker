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
  function SetMediaFont(self, font)
    if font then 
      local _, fontHeight, flags = self:GetFont()

      if font.outline then 
        if font.outline == "NORMAL" then 
          flags = "OUTLINE"
        elseif font.outline == "THICK" then 
          flags = "THICKOUTLINE"
        end
      end

      if font.monochrome then
        if flags then 
          flags = flags..",MONOCHROME"
        else
          flags = "MONOCHROME"
        end
      end

      if font.height then 
        fontHeight = font.height
      end

      local mediaFont = GetMedia("font", font.font)

      return self:SetFontObject(FetchFontObject(mediaFont, fontHeight or 10, flags))
    end

    return self:SetFontObject(nil)
  end

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
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  property "TextTransform" {
    type = TextTransformType,
    default = "NONE",
    handler = function(self) self:SetText(TEXT_RAWS[self] or self:GetText()) end 
  }

  property "MediaFont" {
    type = FontType,
    handler = function(self, font) self:SetMediaFont(font) end 
  }
end)