-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                     "SylingTracker.Core.TextFrame"                    ""
-- ========================================================================= --
UPDATE_TEXT_HEIGHT_TASK_TOKENS         = Toolset.newtable(true)

__UIElement__()
class "TextFrame" (function(_ENV)
  inherit "Scorpio.UI.Frame"
  -----------------------------------------------------------------------------
  --                               Handlers                                  --
  -----------------------------------------------------------------------------
  local function OnTextHeightChangedHandler(self)
    self:GetParent():UpdateTextHeight()
  end

  local function OnSizeChangedHandler(self, width)
    local w = Round(width)
    if not self.__width or (self.__width ~= w) then 
      self.__width = w 
      self:UpdateTextHeight()
    end    
  end
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  __Async__()
  function UpdateTextHeight(self)
    local token = (UPDATE_TEXT_HEIGHT_TASK_TOKENS[self] or 0) + 1
    UPDATE_TEXT_HEIGHT_TASK_TOKENS[self] = token

    Next()

    if token ~= UPDATE_TEXT_HEIGHT_TASK_TOKENS[self] then 
      return 
    end

    local fsText = self:GetChild("Text")
    fsText:SetText(fsText:GetText())
    
    self:SetHeight(fsText:GetStringHeight())

    -- Release the tokens 
    UPDATE_TEXT_HEIGHT_TASK_TOKENS[self]        = nil   
  end
  
  function BindHandlers(self)
    local fsText = self:GetChild("Text")
    fsText.OnTextHeightChanged = fsText.OnTextHeightChanged + OnTextHeightChangedHandler
    
    self.OnSizeChanged = self.OnSizeChanged + OnSizeChangedHandler
  end

  function UnbindHandlers(self)
    local fsText = self:GetChild("Text")
    fsText.OnTextHeightChanged = fsText.OnTextHeightChanged - OnTextHeightChangedHandler
    
    self.OnSizeChanged = self.OnSizeChanged - OnSizeChangedHandler    
  end
  
  function OnRelease(self)
    self:UnbindHandlers()
  end
  
  function OnAcquire(self, isChildProperty, isFirstAcquire)
    if not isFirstAcquire then 
      self:BindHandlers()
    end
  end
  -----------------------------------------------------------------------------
  --                            Constructors                                 --
  -----------------------------------------------------------------------------
  __Template__{
    Text = FontString
  }
  function __ctor(self)
    self:BindHandlers()
  end
end)
-------------------------------------------------------------------------------
--                                Styles                                     --
-------------------------------------------------------------------------------
Style.UpdateSkin("Default", {
  [TextFrame] = {
    Text = {
      location = {
        Anchor("TOPLEFT"),
        Anchor("TOPRIGHT")
      }
    }
  }
})