-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                     "SylingTracker.Core.Texture"                      ""
-- ========================================================================= --
export {
  GetMediaAtlas = API.GetMediaAtlas
}

struct "MediaTextureType" {
  { name = "name", type = String },
  { name = "type", type = String },
  { name = "atlas", type = AtlasType },
  { name = "file", type = String + Number },
  { name = "isMediaAtlas", type = Boolean },
  { name = "texCoords", type = RectType},
  { name = "color", type = ColorType },
  { name = "size", type = Size} 
}

__UIElement__()
class "Texture" (function(_ENV)
  inherit "Scorpio.UI.Texture"
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  function SetMediaTexture(self, mediaTexture)
    if not mediaTexture then 
      Style[self].file      = CLEAR
      Style[self].texCoords = CLEAR 
      Style[self].size      = CLEAR
      Style[self].atlas     = CLEAR
      Style[self].color     = CLEAR
      return 
    end

    local size

    if mediaTexture.atlas and not mediaTexture.isMediaAtlas then 
      Style[self].texCoords = CLEAR
      Style[self].color     = CLEAR
      Style[self].file      = CLEAR
      Style[self].atlas     = mediaTexture.atlas
      
      if not mediaTexture.atlas.useAtlasSize and mediaTexture.size then 
        size = mediaTexture.size 
      end
    elseif mediaTexture.atlas then 
      Style[self].color     = CLEAR
      Style[self].atlas     = CLEAR
      Style[self].texCoords = atlasInfo.texCoords or CLEAR

      local atlasInfo = GetMediaAtlas(mediaTexture.atlas.atlas)
      if atlasInfo then 
        Style[self].file = atlasInfo.file 

        if mediaTexture.atlas.useAtlasSize then 
          size = Size(atlasInfo.width, atlasInfo.height)
        end 
      end
    elseif mediaTexture.file then 
      Style[self].atlas     = CLEAR
      Style[self].color     = CLEAR
      Style[self].file      = mediaTexture.file
      Style[self].texCoords = mediaTexture.texCoords or CLEAR
      size                  = mediaTexture.size
    elseif mediaTexture.color then 
      Style[self].color     = mediaTexture.color
      Style[self].file      = CLEAR
      Style[self].atlas     = CLEAR
      Style[self].texCoords = CLEAR
    end

    Style[self].size = size or CLEAR
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  property "MediaTexture" {
    type = MediaTextureType,
    handler = function(self, mediaTexture) 
      self:SetMediaTexture(mediaTexture) 
    end 
  }
end)