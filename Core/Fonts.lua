-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling "SylingTracker.Core.Fonts" ""
namespace                          "SLT"

_FontsObjects = {}
class "Fonts" (function(_ENV)

  __Static__() function FetchFontObject(fontFile, fontHeight, flags)
    local id
    if flags then 
      id = string.format("%s_%dpx_%s", fontFile, fontHeight, flags)
    else 
      id = string.format("%s_%d", fontFile, fontHeight)
    end

    local fontObj = _FontsObjects[id]
    if not fontObj then 
      fontObj = CreateFont(id)
      fontObj:SetFont(fontFile, fontHeight, flags)
      _FontsObjects[id] = fontObj
    end

    return fontObj
  end
end)

