local _, AR = ...

------------------------------------------------------------
-- AR_UsedSkill: Visual for a skill used during replay
------------------------------------------------------------
AR_UsedSkill = {}
AR_UsedSkill.__index = AR_UsedSkill

local C = AR.GUI_CONST

function AR_UsedSkill:New(parent, spellID, isCast, num, targetData)
    local self = setmetatable({}, AR_UsedSkill)

    self.frame, self.castBar, self.targetText, self.tcolor = AR_GUI:CreateUsedSkill(parent, num)
    self.num   = num
    self.alive = 0
    self.timer = 0
    self:SetValue(parent, spellID, isCast, num, targetData)

    return self
end

function AR_UsedSkill:SetValue(parent, spellID, isCast, num, targetData)
    local name, icon, castTime = AR.Util:GetSpellInfo(spellID)
    if not name then return end

    self.spellID      = spellID
    self.isCast       = isCast
    self.castTime     = (castTime or 0) / 1000
    self.currentOrder = 0
    self.order        = 0
    self.timer        = 0
    self.alive        = 0
    self.parent       = parent

    local _, _, _, posX, posY = self.parent:GetPoint(1)
    self.posX = posX or 0
    self.posY = posY or 0

    -- Reset interrupt overlay if present
    if self.interrupt and self.interrupt:GetParent() == self.frame then
        self.interrupt:Hide()
    end

    self.frame:SetPoint("LEFT", self.parent, "BOTTOMLEFT", self.posX, self.posY)
    self.frame.texture:SetTexture(icon)

    self.castBar:SetHeight(C.SKILL_ICON_SIZE)
    self.castBar.texture:SetColorTexture(0, 0, 0, 0.65)
    self.castBar:SetAlpha(1)
    self:UpdateBarPosition()

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

    self.frame:Show()
    self.frame:SetAlpha(0) -- will fade in

    -- Target indicator
    if targetData then
        self.tcolor:Show()
        self.targetText:Show()
        local r, g, b = AR.Util:GetTargetColor(targetData, false)
        self.tcolor.texture:SetColorTexture(r, g, b, 1)
    else
        self.tcolor:Hide()
        self.targetText:Hide()
    end

    if isCast then self.castBar:Show() else self.castBar:Hide() end
end

function AR_UsedSkill:SlideRight()
    self.order = self.order + 1
    self.isCast = false
    self.castBar:SetAlpha(0)
end

function AR_UsedSkill:IsCasting()
    return self.isCast
end

function AR_UsedSkill:IsDead()
    return self.alive > C.SKILL_PERSISTENCE
end

function AR_UsedSkill:MoveSkill(elapsed)
    self.timer = self.timer + elapsed

    if self.timer > (1 / C.UPDATE_FPS) then
        local _, _, _, parentLeft, _ = self.parent:GetPoint(1)
        parentLeft = parentLeft or 0

        -- Slide to target position
        if self.order ~= self.currentOrder then
            local targetX = parentLeft + (self.order * (C.SKILL_ICON_SIZE + C.SKILL_ICON_MARGIN))
            self.posX = self.posX + (self.timer * C.SKILL_ICON_SPEED)
            if self.posX >= targetX then
                self.posX = targetX
                self.currentOrder = self.order
            end
            self.frame:SetPoint("LEFT", self.parent, "BOTTOMLEFT", self.posX + 1, self.posY)
        end

        -- Cast bar animation
        if self.isCast and self.castTime > 0 then
            local h = self.castBar:GetHeight()
            local decrement = (self.timer * C.SKILL_ICON_SIZE) / self.castTime
            h = h - decrement
            if h < 0 then h = 0 end
            self.castBar:SetHeight(h)
            self:UpdateBarPosition()
        end

        -- Fade out
        local fadeStart = C.SKILL_PERSISTENCE - C.SKILL_FADEOUT_TIME
        if self.alive > fadeStart then
            local alpha = self.frame:GetAlpha() - (self.timer * (1 / C.SKILL_FADEOUT_TIME))
            if alpha < 0 then
                alpha = 0
                self.frame:EnableMouse(false)
            end
            self.frame:SetAlpha(alpha)
        end

        -- Fade in
        if self.frame:GetAlpha() < 1 and self.alive < C.SKILL_FADEIN_TIME then
            local alpha = self.frame:GetAlpha() + (self.timer * (1 / C.SKILL_FADEIN_TIME))
            if alpha > 1 then alpha = 1 end
            self.frame:SetAlpha(alpha)
        end

        self.alive = self.alive + self.timer
        self.timer = 0
    end
end

function AR_UsedSkill:UpdateBarPosition()
    self.castBar:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 0, 0)
end

function AR_UsedSkill:Hide()
    self.frame:EnableMouse(false)
    self.frame:Hide()
    self.castBar:Hide()
    self.tcolor:Hide()
    self.targetText:Hide()
end
