local _, AR = ...

------------------------------------------------------------
-- AR_CombatText: Floating combat text in replay
------------------------------------------------------------
AR_CombatText = {}
AR_CombatText.__index = AR_CombatText

local C = AR.GUI_CONST

function AR_CombatText:New(parent, team, textType, amount, crit)
    local self = setmetatable({}, AR_CombatText)

    self.text = AR_GUI:CreateCombatText(parent)
    self.team = team
    self:SetValue(parent, textType, amount, crit)

    return self
end

----
-- Sets text, color and initial position
-- @param textType 1 = damage, 2 = heal
-- @param crit 0 = normal, 1 = critical
function AR_CombatText:SetValue(parent, textType, amount, crit)
    self.parent = parent
    local _, _, _, posX, posY = parent:GetPoint(1)
    self.posX  = posX or 0
    self.posY  = posY or 0
    self.timer = 0
    self.alive = 0
    self.crit  = crit or 0

    self.text:SetPoint("CENTER", self.parent, "BOTTOM", self.posX, self.posY)

    local prefix
    if textType == 1 then
        self.text:SetTextColor(1.0, 0, 0)
        prefix = "-"
    elseif textType == 2 then
        self.text:SetTextColor(0.07, 1.0, 0)
        prefix = "+"
    end

    if crit == 0 then
        self.text:SetFont("Fonts\\FRIZQT__.TTF", C.COMBATTEXT_FONTSIZE, "OUTLINE")
    else
        self.text:SetFont("Fonts\\FRIZQT__.TTF", C.COMBATTEXT_CRIT_PLUS, "OUTLINE")
    end

    self.text:SetText((prefix or "") .. AR.Util:AbbreviateNumber(amount))
    self.text:SetAlpha(1)
    self.text:Show()
end

function AR_CombatText:MoveText(elapsed)
    self.timer = self.timer + elapsed

    if self.timer > (1 / C.UPDATE_FPS) then
        self.posY = self.posY + (C.COMBATTEXT_SPEED * self.timer)
        self.text:SetPoint("CENTER", self.parent, "BOTTOM", self.posX, self.posY)

        -- Fade out near end of life
        if self.alive > (C.COMBATTEXT_PERSISTENCE - C.COMBATTEXT_FADETIME) then
            local newAlpha = self.text:GetAlpha() - (2.0 * self.timer)
            if newAlpha < 0 then newAlpha = 0 end
            self.text:SetAlpha(newAlpha)
        end

        -- Shrink crit text back to normal size
        local currentHeight = self.text:GetStringHeight()
        if currentHeight and currentHeight > C.COMBATTEXT_FONTSIZE then
            local newSize = currentHeight - (20 * self.timer)
            if newSize < C.COMBATTEXT_FONTSIZE then newSize = C.COMBATTEXT_FONTSIZE end
            self.text:SetFont("Fonts\\FRIZQT__.TTF", newSize, "OUTLINE")
        end

        self.alive = self.alive + self.timer
        self.timer = 0
    end
end

function AR_CombatText:IsDead()
    return self.alive > (C.COMBATTEXT_PERSISTENCE + C.COMBATTEXT_FADETIME)
end

function AR_CombatText:Hide()
    self.text:SetAlpha(0)
    self.text:Hide()
end
