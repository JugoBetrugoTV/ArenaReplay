local _, AR = ...

------------------------------------------------------------
-- AR_PlayerEntity: Visual representation of a player in replay
------------------------------------------------------------
AR_PlayerEntity = {}
AR_PlayerEntity.__index = AR_PlayerEntity

local C = AR.GUI_CONST

function AR_PlayerEntity:New(parent, playerData, yIndex, maxHP)
    local self = setmetatable({}, AR_PlayerEntity)

    self.data     = playerData
    self.parent   = parent
    self.playerID = playerData.ID
    self.team     = playerData.team
    self.skills   = {}
    self.buffs    = {}
    self.debuffs  = {}
    self.cooldowns = {}

    self.frame, self.bar, self.icon, self.crange, self.nameText, self.srange, self.mana =
        AR_GUI:CreateEntityBar(parent, playerData, yIndex, maxHP)
    self.hpText = AR_GUI:CreateBarHealthText(self.bar)
    self.brange, self.drange = AR_GUI:CreateAuraRanges(self.frame)
    self.cdrange = AR_GUI:CreateCooldownRanges(self.frame, playerData.team)

    return self
end

function AR_PlayerEntity:Hide()
    self.bar:Hide()
    self.icon:Hide()
    self.hpText:Hide()
    self.crange:Hide()
    self.srange:Hide()
    self.brange:Hide()
    self.drange:Hide()
    self.cdrange:Hide()
    if self.mana then self.mana:Hide() end
end

function AR_PlayerEntity:Show()
    self.bar:Show()
    self.icon:Show()
    self.hpText:Show()
    self.crange:Show()
    self.srange:Show()
    self.brange:Show()
    self.drange:Show()
    self.cdrange:Show()
end

function AR_PlayerEntity:SetOpacity(val)
    self.bar:SetAlpha(val)
    self.icon:SetAlpha(val)
    if self.mana then self.mana:SetAlpha(val) end
end

function AR_PlayerEntity:SetValue(class, name, maxHP, playerData)
    self.data = playerData
    self.icon.texture:SetTexture("Interface\\Icons\\ClassIcon_" .. (class or "Warrior"))
    self.nameText:SetText(name or "")
    self.bar:SetMinMaxValues(0, maxHP or 1)
    self.bar:SetValue(maxHP or 1)
    self.hpText:SetText("100%")

    if AR.Util:IsManaUser(class) then
        self.mana:Show()
        self.bar:SetHeight(C.HEALTHBAR_HEIGHT - C.MANABAR_HEIGHT)
        self.mana:SetValue(100)
        self.mana:SetStatusBarColor(0.53, 0.53, 1.0)
    else
        self.mana:Hide()
        self.bar:SetHeight(C.HEALTHBAR_HEIGHT)
    end
end

function AR_PlayerEntity:UpdateHealthText()
    local txt = "???"
    local minVal, maxVal = self.bar:GetMinMaxValues()
    local value = self.bar:GetValue()

    if value <= 0 then
        txt = "Dead"
        self.bar:SetStatusBarColor(0.5, 0.5, 0.5)
    else
        self.bar:SetStatusBarColor(0.02, 0.87, 0)
        local defaults = ArenaReplayDB and ArenaReplayDB.defaults or {}
        local mode = defaults.healthDisplay or 1

        if mode == 1 then
            local pct = (value / maxVal) * 100
            txt = string.format("%.1f%%", pct)
        elseif mode == 2 then
            txt = AR.Util:AbbreviateNumber(value) .. " / " .. AR.Util:AbbreviateNumber(maxVal)
        elseif mode == 3 then
            txt = AR.Util:AbbreviateNumber(value - maxVal) .. " / " .. AR.Util:AbbreviateNumber(maxVal)
        end
    end

    self.hpText:SetText(txt)
end

------------------------------------------------------------
-- Aura management
------------------------------------------------------------
function AR_PlayerEntity:AddAura(spellID, auraType, duration)
    local target = (auraType == 1) and self.buffs or self.debuffs
    local range  = (auraType == 1) and self.brange or self.drange

    local aura = AR_Aura:New(range, spellID, auraType, #target, duration)
    self:SetAura(aura, spellID, auraType)

    -- Trim old auras if too many
    if #target > C.MAX_AURAS_VISIBLE then
        for k, v in pairs(target) do
            self:RemoveAura(v.spellID, auraType)
            break
        end
    end

    return aura
end

function AR_PlayerEntity:SetAura(aura, spellID, auraType)
    local name, icon = AR.Util:GetSpellInfo(spellID)
    local target = (auraType == 1) and self.buffs or self.debuffs
    local parent = (auraType == 1) and self.brange or self.drange

    self:AdjustAuraPositions(target)

    aura.auraType = auraType
    aura.spellID  = spellID
    aura.frame:SetParent(parent)
    if icon then
        aura.frame.texture:SetTexture(icon)
    end

    aura.frame:SetPoint("TOPLEFT", parent, "TOPLEFT", aura.position * C.BUFF_ICON_SIZE, 0)
    aura.frame:Show()
    table.insert(target, aura)

    -- Tooltip
    aura.frame:EnableMouse(true)
    aura.frame:SetScript("OnEnter", function(s)
        if s:GetAlpha() > 0 then
            AR_GUI:SetGameTooltip(name, nil, s)
        end
    end)
    aura.frame:SetScript("OnLeave", function()
        GameTooltip:FadeOut()
    end)
end

function AR_PlayerEntity:RemoveAura(spellID, auraType)
    local target = (auraType == 1) and self.buffs or self.debuffs

    for k, v in pairs(target) do
        if v.spellID == spellID then
            v.frame:Hide()
            table.remove(target, k)
            break
        end
    end
    self:AdjustAuraPositions(target)
end

function AR_PlayerEntity:RemoveAllAuras()
    for i = #self.buffs, 1, -1 do
        self.buffs[i].frame:Hide()
        table.remove(self.buffs, i)
    end
    for i = #self.debuffs, 1, -1 do
        self.debuffs[i].frame:Hide()
        table.remove(self.debuffs, i)
    end
end

function AR_PlayerEntity:HideAllAuras()
    for _, v in pairs(self.buffs) do v.frame:Hide() end
    self.buffs = {}
    for _, v in pairs(self.debuffs) do v.frame:Hide() end
    self.debuffs = {}
end

function AR_PlayerEntity:AdjustAuraPositions(target)
    table.sort(target, function(a, b) return a.position < b.position end)
    for i, v in ipairs(target) do
        v.position = i - 1
        v.frame:SetPoint("TOPLEFT", v.parent, "TOPLEFT", v.position * C.BUFF_ICON_SIZE, 0)
    end
end

------------------------------------------------------------
-- Cooldown management
------------------------------------------------------------
function AR_PlayerEntity:AddCooldown(obj)
    table.insert(self.cooldowns, obj)
end

function AR_PlayerEntity:RemoveCooldown(obj)
    for i, v in ipairs(self.cooldowns) do
        if v == obj then
            table.remove(self.cooldowns, i)
            break
        end
    end
end

function AR_PlayerEntity:RemoveAllCooldowns()
    for k in pairs(self.cooldowns) do
        self.cooldowns[k] = nil
    end
    self.cooldowns = {}
end

function AR_PlayerEntity:ArrangeCooldowns()
    table.sort(self.cooldowns, function(a, b)
        return (a.duration - a.alive) < (b.duration - b.alive)
    end)
    for i, v in ipairs(self.cooldowns) do
        v.position = i - 1
    end
end
