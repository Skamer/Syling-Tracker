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
  FetchFontObject = SLT.Fonts.FetchFontObject,
  ResetStyles     = SLT.Utils.ResetStyles
}

--- We need to keep the original text as this can be lose during the text 
--- transform process
_TextRaw          = Toolset.newtable(true, false)

SLT.__Recyclable__ "SylingTracker_FontString%i"
class "SLT.FontString" (function(_ENV)
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
  function SetSharedMediaFont(self, font)
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

    local ft = LibSharedMedia:Fetch("font", font.font)

    return self:SetFontObject(FetchFontObject(ft, fontHeight or 10, flags))
  end

  function SetText(self, text)
    _TextRaw[self] = text 
    if text then 
      if self.TextTransform == TextTransformType.LOWERCASE then 
        text = text:lower()
      elseif self.TextTransform == TextTransformType.UPPERCASE then 
        text = text:upper()
      end
    end

    super.SetText(self, text)
  end

  function OnRelease(self)
    self:Hide()
    self:ClearAllPoints()
    self:SetParent()

    ResetStyles(self)
  end

  function OnAcquire(self)
    self:Show()
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  property "TextTransform" { 
    type = TextTransformType, 
    default = TextTransformType.NONE, 
    handler = function(self) self:SetText(_TextRaw[self] or self:GetText()) end 
  }

  property "SharedMediaFont" {
    type = FontType,
    handler = function(self, font) self:SetSharedMediaFont(font) end
  }
 
end)

--- SLT.SLTFontString is now deprecated, and this part has been added for
--- backward compatibility (the time to migrate to SLT.FontString)
SLT.__Recyclable__ "SylingTracker_SLTFontString%i"
class "SLT.SLTFontString" { SLT.FontString }

