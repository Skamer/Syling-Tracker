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
}

__UIElement__()
class "Texture" (function(_ENV)
  inherit "Scorpio.UI.Texture"
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  function SetMediaTexture(self, mediaTexture)
    if not mediaTexture then 
      Style[self].file = nil 
      Style[self].size = nil 
      Style[self].texCoords = nil 
      Style[self].size = nil 
      return 
    end 

    if mediaTexture.atlas and not mediaTexture.isMediaAtlas then
      Style[self].atlas = mediaTexture.atlas 
    elseif mediaTexture.atlas then
      local atlasInfo = GetMediaAtlas(mediaTexture.atlas.atlas)
      if atlasInfo then 
        Style[self].file = atlasInfo.file 

        if mediaTexture.atlas.useAtlasSize then 
          Style[self].size = Size(atlasInfo.width, atlasInfo.height)
        else 
          Style[self].size = nil 
        end

        Style[self].texCoords = atlasInfo.texCoords 
      end
    elseif mediaTexture.file then
      Style[self].atlas = nil
      Style[self].color = nil
      Style[self].file = mediaTexture.file 
    elseif mediaTexture.color then 
      Style[self].atlas = nil
      Style[self].file = nil
      Style[self].color = mediaTexture.color 
    end
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  property "MediaTexture" {
    type = MediaTextureType,
    handler = function(self, mediaTexture) self:SetMediaTexture(mediaTexture) end 
  }

end)
