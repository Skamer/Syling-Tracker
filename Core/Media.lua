-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                      "SylingTracker.Core.Media"                       ""
-- ========================================================================= --
export {
  LibSharedMedia     = LibStub("LibSharedMedia-3.0", true)
}
-------------------------------------------------------------------------------
--                                   API                                     --
-------------------------------------------------------------------------------
BACKGROUNDS   = {}
BORDERS       = {}
FONTS         = {}
SOUNDS        = {}
STATUSBARS    = {}
FONTS_OBJECTS = {}
ATLASES       = {}

enum "MediaType" {
  "background",
  "border",
  "font",
  "statusbar",
  "sound"
}

struct "MediaAtlasInfo" {
  { name = "name", type = String },
  { name = "file", type = String + Number },
  { name = "width", type = Number},
  { name = "height", type = Number},
  { name = "texCoords", type = RectType },
  { name = "horizTile", type= Boolean },
  { name = "vertTile", type = Boolean },
}

--- Register a media.
--- This will use LibSharedMedia if the lib is installed.
---
--- @param mediaType the media type
--- @param id the media id 
--- @param filepath the media filename 
__Arguments__ { MediaType, String, String}
__Static__() function API.RegisterMedia(mediaType, id, filepath)
  if LibSharedMedia then 
    LibSharedMedia:Register(mediaType, id, filepath)
  else 
    if mediaType == "background" then 
      BACKGROUNDS[id] = filepath
    elseif mediaType == "border" then 
      BORDERS[id] = filepath
    elseif mediaType == "font" then 
      FONTS[id] = filepath
    elseif id == "statusbar" then 
      STATUSBARS[id] = filepath
    elseif id == "sound" then 
      SOUNDS[id] = filepath
    end
  end
end

--- Get a media.
--- This will use LibSharedMedia if the lib is installed.
---
--- @param mediaType the media type
--- @param id the media id
__Arguments__ { MediaType, String }
__Static__() function API.GetMedia(mediaType, id)
  if LibSharedMedia then
    return LibSharedMedia:Fetch(mediaType, id, true)
  else 
    if mediaType == "background" then 
      return BACKGROUNDS[id]
    elseif mediaType == "border" then 
      return BORDERS[id]
    elseif mediaType == "font" then 
      return FONTS[id]
    elseif id == "statusbar" then 
      return STATUSBARS[id]
    elseif id == "sound" then 
      return SOUNDS[id]
    end
  end
end

--- Return a iterator for the media 
--- This will use LibSharedMedia if the lib is installed.
---
--- @param mediaType the media type
__Iterator__()
__Arguments__ { MediaType }
__Static__() function API.IterateMedia(mediaType)
  local yield = coroutine.yield
  local mediaList
  if mediaType == "background" then 
    mediaList = LibSharedMedia and LibSharedMedia:HashTable(mediaType) or BACKGROUND
  elseif mediaType == "border" then 
    mediaList = LibSharedMedia and LibSharedMedia:HashTable(mediaType) or BORDER
  elseif mediaType == "font" then 
    mediaList = LibSharedMedia and LibSharedMedia:List(mediaType) or FONTS
  elseif mediaType == "statusbar" then 
    mediaList = LibSharedMedia and LibSharedMedia:HashTable(mediaType) or STATUSBARS
  elseif mediaType == "sound" then 
    mediaList = LibSharedMedia and LibSharedMedia:HashTable(mediaType) or SOUNDS
  end

  if mediaList then
    if LibSharedMedia then 
      for index, id in pairs(mediaList) do
        yield(id, LibSharedMedia.MediaTable[mediaType][id])
      end
    else
      for id, file in pairs(mediaList) do 
        yield(id, file)
      end
    end
  end
end

--- Fetch a font object depending of fontFile, fontHeight and flags. 
--- This is used to reuse the font ojects. If the font object not exists, this 
--- will create one with these parameters, and keep it for later uses. 
---
--- @param fontFile the font filepath 
--- @param fontHeight the font height
--- @param flags the font flags
__Arguments__ { String, Number, String/"" }
__Static__() function API.FetchFontObject(fontFile, fontHeight, flags)
  local id 
  if flags then 
    id = string.format("%s_%dpx_%s", fontFile, fontHeight, flags)
  else 
    id = string.format("%s_%d", fontFile, fontHeight)
  end

  local fontObject = FONTS_OBJECTS[id]
  
  if not fontObject then 
    fontObject = CreateFont(id)
    fontObject:SetFont(fontFile, fontHeight, flags)

    FONTS_OBJECTS[id] = fontObjects 
  end

  return fontObject
end

--- Register a media atlas 
---
--- @param the atlas name 
--- @param the atlas definition 
__Arguments__ { String, MediaAtlasInfo }
__Static__() function API.RegisterMediaAtlas(name, atlas)
  if ATLASES[name] then 
    error(("Trying to register a media atlas with an id already used ('%s')"):format(name))
  end

  atlas.name = name 

  ATLASES[name] = atlas 
end

--- Get the atlas definition 
---
--- @param the atlas name to return its definition 
__Arguments__ { String }
__Static__() function API.GetMediaAtlas(name)
  return ATLASES[name]
end
-------------------------------------------------------------------------------
-- Media: register the fonts
-------------------------------------------------------------------------------
-- PT Sans Family Fonts
API.RegisterMedia("font", "PT Sans", [[Interface\AddOns\SylingTracker\Media\Fonts\PTSans-Regular.ttf]])
API.RegisterMedia("font", "PT Sans Bold", [[Interface\AddOns\SylingTracker\Media\Fonts\PTSans-Bold.ttf]])
API.RegisterMedia("font", "PT Sans Bold Italic", [[Interface\AddOns\SylingTracker\Media\Fonts\PTSans-Bold-Italic.ttf]])
API.RegisterMedia("font", "PT Sans Narrow", [[Interface\AddOns\SylingTracker\Media\Fonts\PTSans-Narrow.ttf]])
API.RegisterMedia("font", "PT Sans Narrow Bold", [[Interface\AddOns\SylingTracker\Media\Fonts\PTSans-Narrow-Bold.ttf]])
API.RegisterMedia("font", "PT Sans Caption", [[Interface\AddOns\SylingTracker\Media\Fonts\PTSans-Caption.ttf]])
API.RegisterMedia("font", "PT Sans Caption Bold", [[Interface\AddOns\SylingTracker\Media\Fonts\PTSans-Caption-Bold.ttf]])
-- DejaVuSans Family Fonts
API.RegisterMedia("font", "Deja Vu Sans", [[Interface\AddOns\SylingTracker\Media\Fonts\DejaVuSans.ttf]])
API.RegisterMedia("font", "Deja Vu Sans Bold", [[Interface\AddOns\SylingTracker\Media\Fonts\DejaVuSans-Bold.ttf]])
API.RegisterMedia("font", "Deja Vu Sans Bold Italic", [[Interface\AddOns\SylingTracker\Media\Fonts\DejaVuSans-BoldOblique.ttf]])
API.RegisterMedia("font", "DejaVuSansCondensed", [[Interface\AddOns\SylingTracker\Media\Fonts\DejaVuSansCondensed.ttf]])
API.RegisterMedia("font", "DejaVuSansCondensed Bold", [[Interface\AddOns\SylingTracker\Media\Fonts\DejaVuSansCondensed-Bold.ttf]])
API.RegisterMedia("font", "DejaVuSansCondensed Bold Italic", [[Interface\AddOns\SylingTracker\Media\Fonts\DejaVuSansCondensed-BoldOblique.ttf]])
API.RegisterMedia("font", "DejaVuSansCondensed Italic", [[Interface\AddOns\SylingTracker\Media\Fonts\DejaVuSansCondensed-Oblique.ttf]])

-------------------------------------------------------------------------------
-- Media: register the background
-------------------------------------------------------------------------------
API.RegisterMedia("background", "SylingTracker Background", [[Interface\AddOns\SylingTracker\Media\Textures\Frame-Background]])
-------------------------------------------------------------------------------
-- Media: register the atlases
-------------------------------------------------------------------------------
API.RegisterMediaAtlas("arrow-right", { file = [[Interface\AddOns\SylingTracker\Media\Textures\ContextMenu-Arrow]], width = 24, height = 24, texCoords = RectType(0, 32/128, 0, 1)  })
API.RegisterMediaAtlas("arrow-bottom", { file = [[Interface\AddOns\SylingTracker\Media\Textures\ContextMenu-Arrow]], width = 24, height = 24, texCoords = RectType(32/128, 64/128, 0, 1) })
API.RegisterMediaAtlas("arrow-left", { file = [[Interface\AddOns\SylingTracker\Media\Textures\ContextMenu-Arrow]], width = 24, height = 24, texCoords = RectType(64/128, 96/128, 0, 1) })
API.RegisterMediaAtlas("arrow-top", { file = [[Interface\AddOns\SylingTracker\Media\Textures\ContextMenu-Arrow]], width = 24, height = 24, texCoords = RectType(96/128, 1, 0, 1) })