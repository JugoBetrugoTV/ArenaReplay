local _, AR = ...

------------------------------------------------------------
-- AR_Aura: Single buff/debuff frame
------------------------------------------------------------
AR_Aura = {}
AR_Aura.__index = AR_Aura

function AR_Aura:New(parent, spellID, auraType, position, duration)
    local self = setmetatable({}, AR_Aura)

    self.frame    = AR_GUI:CreateAura(parent)
    self.parent   = parent
    self.spellID  = spellID
    self.auraType = auraType  -- 1 = buff, 2 = debuff
    self.position = position
    self.duration = duration or 0

    return self
end
