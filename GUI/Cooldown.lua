local _, AR = ...

------------------------------------------------------------
-- AR_Cooldown: Cooldown tracking icon during replay
------------------------------------------------------------
AR_Cooldown = {}
AR_Cooldown.__index = AR_Cooldown

local C = AR.GUI_CONST
local FADEIN_TIME  = 0.3
local FADEOUT_TIME = 1.0

function AR_Cooldown:New(parent)
    local self = setmetatable({}, AR_Cooldown)

    self.frame    = AR_GUI:CreateCooldown(parent)
    self.spellID  = 0
    self.duration = 0
    self.alive    = 0
    self.timer    = 0
    self.position = 0
    self.entityID = nil
    self.parent   = parent

    return self
end

function AR_Cooldown:SetValue(spellID, duration, entityID, parent)
    local name, icon = AR.Util:GetSpellInfo(spellID)
    if not name then return end

    self.spellID  = spellID
    self.duration = duration
    self.entityID = entityID
    self.parent   = parent
    self.alive    = 0
    self.timer    = 0

    self.frame:SetParent(parent)
    self.frame:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, -(self.position * (C.COOLDOWN_ICON_SIZE + C.COOLDOWN_ICON_MARGIN)))
    self.frame.texture:SetTexture(icon)
    self.frame:SetAlpha(0)
    self.frame:Show()

    self.frame.text:SetText(self:GetDurationText())

    -- Tooltip
    self.frame:EnableMouse(true)
    self.frame:SetScript("OnEnter", function(s)
        if s:GetAlpha() > 0 then
            AR_GUI:SetGameTooltip(name, nil, s)
        end
    end)
    self.frame:SetScript("OnLeave", function()
        GameTooltip:FadeOut()
    end)
end

function AR_Cooldown:GetDurationText()
    local remaining = self.duration - self.alive
    if remaining <= 0 then return "0" end
    if remaining >= 60 then
        return string.format("%dm", math.ceil(remaining / 60))
    end
    return string.format("%ds", math.ceil(remaining))
end

function AR_Cooldown:IsDead()
    return self.alive >= self.duration
end

function AR_Cooldown:Update(elapsed)
    self.timer = self.timer + elapsed

    if self.timer > (1 / C.UPDATE_FPS) then
        -- Update position
        self.frame:SetPoint("TOPLEFT", self.parent, "TOPLEFT", 0,
            -(self.position * (C.COOLDOWN_ICON_SIZE + C.COOLDOWN_ICON_MARGIN)))

        -- Fade in
        if self.frame:GetAlpha() < 1 and self.alive < FADEIN_TIME then
            local alpha = self.frame:GetAlpha() + (self.timer * (1 / FADEIN_TIME))
            if alpha > 1 then alpha = 1 end
            self.frame:SetAlpha(alpha)
        end

        -- Fade out near end
        if self.alive > (self.duration - FADEOUT_TIME) then
            local alpha = self.frame:GetAlpha() - (self.timer * (1 / FADEOUT_TIME))
            if alpha < 0 then alpha = 0 end
            self.frame:SetAlpha(alpha)
        end

        -- Dim if beyond max visible
        if self.position >= C.MAX_COOLDOWNS_VISIBLE then
            self.frame:SetAlpha(0)
        end

        -- Update text
        self.frame.text:SetText(self:GetDurationText())

        self.alive = self.alive + self.timer
        self.timer = 0
    end
end
