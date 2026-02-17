local _, AR = ...

------------------------------------------------------------
-- AR_Crowd: Crowd control overlay (icon + countdown on entity)
------------------------------------------------------------
AR_Crowd = {}
AR_Crowd.__index = AR_Crowd

local C = AR.GUI_CONST
local FADEIN_TIME   = 0.3
local FADEIN_SPEED  = 1 / FADEIN_TIME
local FADEOUT_TIME  = 0.5
local FADEOUT_SPEED = 1 / FADEOUT_TIME

function AR_Crowd:New(parent, id)
    local self = setmetatable({}, AR_Crowd)

    self.frame, self.text = AR_GUI:CreateCC(parent, id)
    self.id        = id
    self.icon      = ""
    self.parent    = nil
    self.startTime = 0
    self.ttl       = 0  -- time to live
    self.timer     = 0
    self.alive     = 0
    self.spellID   = 0
    self.lvl       = 0
    self.frameLvl  = 0

    return self
end

function AR_Crowd:SetValue(spellID, id, icon, parent, duration, lvl, frameLvl)
    self.spellID   = spellID
    self.id        = id
    self.icon      = icon
    self.parent    = parent
    self.startTime = duration
    self.ttl       = duration
    self.alive     = 0
    self.timer     = 0
    self.lvl       = lvl or 0
    self.frameLvl  = frameLvl or 1

    self.frame:SetParent(self.parent)
    self.frame:SetPoint("TOPLEFT", self.parent, "TOPLEFT", 0, 0)
    self.frame:SetAlpha(0)
    self.frame.texture:SetTexture(self.icon)
    self.frame:SetFrameLevel(self.frameLvl)
    self.frame.texture:Show()
    self.frame:Show()
    self.text:SetText(string.format("%.1f", duration))
end

function AR_Crowd:IsDead()
    return self.ttl <= 0
end

function AR_Crowd:SetDead()
    self.ttl = 0
    self.frame:SetAlpha(0)
    self.frame:Hide()
    self.frame:SetParent(nil)
end

function AR_Crowd:Update(elapsed)
    self.timer = self.timer + elapsed

    if self.timer > (1 / C.UPDATE_FPS) then
        local remaining = self.ttl - self.alive
        local txt = string.format("%.1f", math.max(0, remaining))
        self.text:SetText(txt)

        -- Fade in
        if self.frame:GetAlpha() < 1 and self.alive < FADEIN_TIME then
            local alpha = self.frame:GetAlpha() + (self.timer * FADEIN_SPEED)
            if alpha > 1 then alpha = 1 end
            self.frame:SetAlpha(alpha)
            self.text:SetAlpha(alpha)
        end

        -- Fade out
        if self.alive > (self.startTime - FADEOUT_TIME) then
            local alpha = self.frame:GetAlpha() - (self.timer * FADEOUT_SPEED)
            if alpha < 0 then alpha = 0 end
            self.frame:SetAlpha(alpha)
            self.text:SetAlpha(alpha)
        end

        self.alive = self.alive + self.timer
        self.timer = 0

        if self.alive > self.ttl then
            self:SetDead()
        end
    end
end
