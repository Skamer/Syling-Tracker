-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling              "SylingTracker.Options.Elements.Button"                  ""
-- ========================================================================= --
PUSHBUTTON_FILE         = [[Interface\AddOns\SylingTracker_Options\Media\button]]
DANGER_PUSHBUTTON_FILE  = [[Interface\AddOns\SylingTracker_Options\Media\button_danger]]
SUCCESS_PUSHBUTTON_FILE = [[Interface\AddOns\SylingTracker_Options\Media\button_success]]

__Widget__()
class "SUI.PushButton" (function(_ENV)
  inherit "Button"
  -----------------------------------------------------------------------------
  --                               Handlers                                  --
  -----------------------------------------------------------------------------
  local function RefreshState(self)
    local leftTexture
    local middleTexture
    local rightTexture

    if self.Mouseover then 
      leftTexture, middleTexture, rightTexture = self:GetHoverTexture() 
    else 
      leftTexture, middleTexture, rightTexture = self:GetNormalTexture() 
    end 

    Style[self].LeftBGTexture = leftTexture
    Style[self].RightBGTexture = rightTexture
    Style[self].MiddleBGTexture = middleTexture
  end
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  __Arguments__ { String/""}
  function SetText(self, text)
    Style[self].Text.text = text
  end

  function GetHoverTexture(self)
    local leftTexture = {
      width = 16,
      file = PUSHBUTTON_FILE,
      texCoords = { left = 0.03125, right = 0.53125, top = 0.283203125, bottom = 0.373046875 },
      location = {
        Anchor("TOPLEFT"),
        Anchor("BOTTOMLEFT")
      }
    }

    local rightTexture = {
      width = 16,
      file = PUSHBUTTON_FILE,
      texCoords = { left = 0.03125, right = 0.53125, top = 0.376953125, bottom = 0.466796875 },
      location = {
        Anchor("TOPRIGHT"),
        Anchor("BOTTOMRIGHT")
      }
    }

    local middleTexture = {
      file = PUSHBUTTON_FILE,
      texCoords = { left = 0, right = 0.5, top = 0.001953125, bottom = 0.091796875 },
      location = {
        Anchor("TOPLEFT", 0, 0, "LeftBGTexture", "TOPRIGHT"),
        Anchor("BOTTOMRIGHT", 0, 0, "RightBGTexture", "BOTTOMLEFT")
      }
    }

    return leftTexture, middleTexture, rightTexture
  end

  function GetNormalTexture(self)
    local leftTexture = {
      width = 16,
      file = PUSHBUTTON_FILE,
      texCoords = { left = 0.03125, right = 0.53125, top = 0.470703125, bottom = 0.560546875 },
      location = {
        Anchor("TOPLEFT"),
        Anchor("BOTTOMLEFT")
      }
    }

    local rightTexture = {
      width = 16,
      file = PUSHBUTTON_FILE,
      texCoords = { left = 0.03125, right = 0.53125, top = 0.751953125, bottom = 0.841796875 },
      location = {
        Anchor("TOPRIGHT"),
        Anchor("BOTTOMRIGHT")
      }
    }

    local middleTexture = {
      file = PUSHBUTTON_FILE,
      texCoords = { left = 0, right = 0.5, top = 0.095703125, bottom = 0.185546875 },
      location = {
        Anchor("TOPLEFT", 0, 0, "LeftBGTexture", "TOPRIGHT"),
        Anchor("BOTTOMRIGHT", 0, 0, "RightBGTexture", "BOTTOMLEFT")
      }
    }

    return leftTexture, middleTexture, rightTexture
  end

  function OnRelease(self)
    self:SetID(0)
    self:Hide()
    self:ClearAllPoints()
    self:SetParent(nil)
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  property "Mouseover" {
    type = Boolean,
    default = false,
    handler = RefreshState
  }
  -----------------------------------------------------------------------------
  --                            Constructors                                 --
  -----------------------------------------------------------------------------
  __Template__ {
    Text = FontString
  }
  function __ctor(self)
    self.OnEnter = self.OnEnter + function() self.Mouseover = true end 
    self.OnLeave = self.OnLeave + function() self.Mouseover = false end

    RefreshState(self)
  end
end)

__Widget__()
class "SUI.DangerPushButton" (function(_ENV)
  inherit "SUI.PushButton"
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  function GetHoverTexture(self)
    local leftTexture = {
      width = 16,
      file = DANGER_PUSHBUTTON_FILE,
      texCoords = { left = 0.03125, right = 0.53125, top = 0.283203125, bottom = 0.373046875 },
      location = {
        Anchor("TOPLEFT"),
        Anchor("BOTTOMLEFT")
      }
    }

    local rightTexture = {
      width = 16,
      file = DANGER_PUSHBUTTON_FILE,
      texCoords = { left = 0.03125, right = 0.53125, top = 0.376953125, bottom = 0.466796875 },
      location = {
        Anchor("TOPRIGHT"),
        Anchor("BOTTOMRIGHT")
      }
    }

    local middleTexture = {
      file = DANGER_PUSHBUTTON_FILE,
      texCoords = { left = 0, right = 0.5, top = 0.001953125, bottom = 0.091796875 },
      location = {
        Anchor("TOPLEFT", 0, 0, "LeftBGTexture", "TOPRIGHT"),
        Anchor("BOTTOMRIGHT", 0, 0, "RightBGTexture", "BOTTOMLEFT")
      }
    }

    return leftTexture, middleTexture, rightTexture
  end

  function GetNormalTexture(self)
    local leftTexture = {
      width = 16,
      file = DANGER_PUSHBUTTON_FILE,
      texCoords = { left = 0.03125, right = 0.53125, top = 0.470703125, bottom = 0.560546875 },
      location = {
        Anchor("TOPLEFT"),
        Anchor("BOTTOMLEFT")
      }
    }

    local rightTexture = {
      width = 16,
      file = DANGER_PUSHBUTTON_FILE,
      texCoords = { left = 0.03125, right = 0.53125, top = 0.751953125, bottom = 0.841796875 },
      location = {
        Anchor("TOPRIGHT"),
        Anchor("BOTTOMRIGHT")
      }
    }

    local middleTexture = {
      file = DANGER_PUSHBUTTON_FILE,
      texCoords = { left = 0, right = 0.5, top = 0.095703125, bottom = 0.185546875 },
      location = {
        Anchor("TOPLEFT", 0, 0, "LeftBGTexture", "TOPRIGHT"),
        Anchor("BOTTOMRIGHT", 0, 0, "RightBGTexture", "BOTTOMLEFT")
      }
    }

    return leftTexture, middleTexture, rightTexture
  end
end)

__Widget__()
class "SUI.SuccessPushButton" (function(_ENV)
  inherit "SUI.PushButton"
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  function GetHoverTexture(self)
    local leftTexture = {
      width = 16,
      file = SUCCESS_PUSHBUTTON_FILE,
      texCoords = { left = 0.03125, right = 0.53125, top = 0.283203125, bottom = 0.373046875 },
      location = {
        Anchor("TOPLEFT"),
        Anchor("BOTTOMLEFT")
      }
    }

    local rightTexture = {
      width = 16,
      file = SUCCESS_PUSHBUTTON_FILE,
      texCoords = { left = 0.03125, right = 0.53125, top = 0.376953125, bottom = 0.466796875 },
      location = {
        Anchor("TOPRIGHT"),
        Anchor("BOTTOMRIGHT")
      }
    }

    local middleTexture = {
      file = SUCCESS_PUSHBUTTON_FILE,
      texCoords = { left = 0, right = 0.5, top = 0.001953125, bottom = 0.091796875 },
      location = {
        Anchor("TOPLEFT", 0, 0, "LeftBGTexture", "TOPRIGHT"),
        Anchor("BOTTOMRIGHT", 0, 0, "RightBGTexture", "BOTTOMLEFT")
      }
    }

    return leftTexture, middleTexture, rightTexture
  end

  function GetNormalTexture(self)
    local leftTexture = {
      width = 16,
      file = SUCCESS_PUSHBUTTON_FILE,
      texCoords = { left = 0.03125, right = 0.53125, top = 0.470703125, bottom = 0.560546875 },
      location = {
        Anchor("TOPLEFT"),
        Anchor("BOTTOMLEFT")
      }
    }

    local rightTexture = {
      width = 16,
      file = SUCCESS_PUSHBUTTON_FILE,
      texCoords = { left = 0.03125, right = 0.53125, top = 0.751953125, bottom = 0.841796875 },
      location = {
        Anchor("TOPRIGHT"),
        Anchor("BOTTOMRIGHT")
      }
    }

    local middleTexture = {
      file = SUCCESS_PUSHBUTTON_FILE,
      texCoords = { left = 0, right = 0.5, top = 0.095703125, bottom = 0.185546875 },
      location = {
        Anchor("TOPLEFT", 0, 0, "LeftBGTexture", "TOPRIGHT"),
        Anchor("BOTTOMRIGHT", 0, 0, "RightBGTexture", "BOTTOMLEFT")
      }
    }

    return leftTexture, middleTexture, rightTexture
  end
end)
-------------------------------------------------------------------------------
--                                Styles                                     --
-------------------------------------------------------------------------------
Style.UpdateSkin("Default", {
  [SUI.PushButton] = {
    size = Size(150, 40),

    Text = {
      setAllPoints = true,
      fontObject = GameFontNormal,
      justifyH = "CENTER",
      maxLines = 1,
      text = "Button",
      textColor = ColorType(1, 1, 1)
    }
  }
})