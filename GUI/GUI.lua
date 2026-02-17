local _, AR = ...

------------------------------------------------------------
-- AR_GUI: All frame creation functions for ArenaReplay
------------------------------------------------------------
AR_GUI = {}
local GUI = AR_GUI
local C = AR.GUI_CONST

local ADDON_PATH = "Interface\\Addons\\ArenaReplay\\"
local BARTEXTURE = "Interface\\TargetingFrame\\UI-StatusBar"
local BACKDROP_MAIN = {
    bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 },
}
local BACKDROP_TITLE = {
    bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 16, edgeSize = 20,
    insets = { left = 4, right = 4, top = 4, bottom = 4 },
}

------------------------------------------------------------
-- Helper: apply backdrop (12.0 uses BackdropTemplateMixin)
------------------------------------------------------------
local function ApplyBackdrop(frame, bd)
    if frame.SetBackdrop then
        frame:SetBackdrop(bd)
    end
end

------------------------------------------------------------
-- Main player frame (the replay viewer)
------------------------------------------------------------
function GUI:CreatePlayerFrame(parent)
    local f = CreateFrame("Frame", "ArenaReplayPlayerFrame", parent or UIParent, "BackdropTemplate")
    f:SetFrameStrata("MEDIUM")
    f:SetSize(C.PLAYER_FRAME_WIDTH, C.PLAYER_FRAME_HEIGHT)
    f:SetPoint("CENTER", 0, 0)
    ApplyBackdrop(f, BACKDROP_MAIN)
    f:SetBackdropColor(0, 0, 0, 0.85)

    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)
    f:SetClampedToScreen(true)

    -- Title bar
    local title = CreateFrame("Frame", "$parentTitle", f, "BackdropTemplate")
    title:SetHeight(28)
    ApplyBackdrop(title, BACKDROP_TITLE)
    title:SetBackdropColor(0, 0, 0, 1)
    title:SetPoint("TOP", f, "TOP", 0, 16)

    local titleText = title:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    titleText:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
    titleText:SetText("ArenaReplay")
    titleText:SetPoint("CENTER", title, 0, 0)
    title:SetWidth(titleText:GetStringWidth() + 30)
    title:SetMovable(true)
    title:RegisterForDrag("LeftButton")
    title:SetScript("OnDragStart", function() f:StartMoving() end)
    title:SetScript("OnDragStop", function() f:StopMovingOrSizing() end)

    -- Close button
    local closeBtn = CreateFrame("Button", "$parentClose", f, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", f, "TOPRIGHT", -2, -2)
    closeBtn:SetScript("OnClick", function() f:Hide() end)

    f.title = title
    f.titleText = titleText

    return f
end

------------------------------------------------------------
-- Player entity bar (health bar, class icon, name)
------------------------------------------------------------
function GUI:CreateEntityBar(parent, playerData, yIndex, maxHP)
    local team = playerData.team
    local isLeft = (team == 1)
    local xOffset = isLeft and 15 or (C.PLAYER_FRAME_WIDTH - C.HEALTHBAR_WIDTH - C.ICON_SIZE - 25)
    local yOffset = -50 - (yIndex * (C.HEALTHBAR_HEIGHT + 8))

    -- Container frame
    local container = CreateFrame("Frame", nil, parent)
    container:SetSize(C.HEALTHBAR_WIDTH + C.ICON_SIZE + 5, C.HEALTHBAR_HEIGHT)
    container:SetPoint("TOPLEFT", parent, "TOPLEFT", xOffset, yOffset)

    -- Class icon
    local icon = CreateFrame("Frame", nil, container)
    icon:SetSize(C.ICON_SIZE, C.ICON_SIZE)
    if isLeft then
        icon:SetPoint("LEFT", container, "LEFT", 0, 0)
    else
        icon:SetPoint("RIGHT", container, "RIGHT", 0, 0)
    end

    local iconTex = icon:CreateTexture(nil, "BACKGROUND")
    iconTex:SetAllPoints(icon)
    local classFile = playerData.class or "WARRIOR"
    iconTex:SetTexture("Interface\\Icons\\ClassIcon_" .. classFile)
    icon.texture = iconTex

    -- Health bar
    local bar = CreateFrame("StatusBar", nil, container)
    bar:SetSize(C.HEALTHBAR_WIDTH, C.HEALTHBAR_HEIGHT)
    bar:SetStatusBarTexture(BARTEXTURE)
    bar:SetStatusBarColor(0.02, 0.87, 0)
    bar:SetMinMaxValues(0, maxHP or 1)
    bar:SetValue(maxHP or 1)
    if isLeft then
        bar:SetPoint("LEFT", icon, "RIGHT", 3, 0)
    else
        bar:SetPoint("RIGHT", icon, "LEFT", -3, 0)
    end

    -- Health bar background
    local barBg = bar:CreateTexture(nil, "BACKGROUND")
    barBg:SetAllPoints(bar)
    barBg:SetColorTexture(0.15, 0.15, 0.15, 0.8)

    -- Mana bar
    local mana = CreateFrame("StatusBar", nil, container)
    mana:SetSize(C.HEALTHBAR_WIDTH, C.MANABAR_HEIGHT)
    mana:SetStatusBarTexture(BARTEXTURE)
    mana:SetStatusBarColor(0.53, 0.53, 1.0)
    mana:SetMinMaxValues(0, 100)
    mana:SetValue(100)
    mana:SetPoint("TOPLEFT", bar, "BOTTOMLEFT", 0, 0)
    mana:Hide()

    -- Mana bar bg
    local manaBg = mana:CreateTexture(nil, "BACKGROUND")
    manaBg:SetAllPoints(mana)
    manaBg:SetColorTexture(0.05, 0.05, 0.2, 0.8)

    -- Player name
    local nameStr = container:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    nameStr:SetText(playerData.name or "")
    if isLeft then
        nameStr:SetPoint("BOTTOMLEFT", bar, "TOPLEFT", 2, 1)
    else
        nameStr:SetPoint("BOTTOMRIGHT", bar, "TOPRIGHT", -2, 1)
    end

    -- Skill range (where used skill icons appear)
    local srange = CreateFrame("Frame", nil, container)
    srange:SetSize(C.SKILL_ICON_SIZE * 6, C.SKILL_ICON_SIZE)
    if isLeft then
        srange:SetPoint("TOPLEFT", bar, "BOTTOMLEFT", 0, -(C.MANABAR_HEIGHT + 2))
    else
        srange:SetPoint("TOPRIGHT", bar, "BOTTOMRIGHT", 0, -(C.MANABAR_HEIGHT + 2))
    end

    -- CC range (where CC icon overlays appear)
    local crange = CreateFrame("Frame", nil, container)
    crange:SetSize(C.CC_ICON_SIZE, C.CC_ICON_SIZE)
    crange:SetPoint("CENTER", icon, "CENTER", 0, 0)
    crange:SetFrameLevel(icon:GetFrameLevel() + 5)

    container:Show()

    return container, bar, icon, crange, nameStr, srange, mana
end

------------------------------------------------------------
-- Health bar text
------------------------------------------------------------
function GUI:CreateBarHealthText(bar)
    local text = bar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    text:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
    text:SetText("100%")
    text:SetPoint("CENTER", bar, "CENTER", 0, 0)
    return text
end

------------------------------------------------------------
-- Buff/Debuff display ranges
------------------------------------------------------------
function GUI:CreateAuraRanges(parent)
    local buffRange = CreateFrame("Frame", nil, parent)
    buffRange:SetSize(C.BUFF_ICON_SIZE * C.MAX_AURAS_VISIBLE, C.BUFF_ICON_SIZE)
    buffRange:SetPoint("TOPLEFT", parent, "BOTTOMLEFT", C.ICON_SIZE + 3, -2)

    local debuffRange = CreateFrame("Frame", nil, parent)
    debuffRange:SetSize(C.BUFF_ICON_SIZE * C.MAX_AURAS_VISIBLE, C.BUFF_ICON_SIZE)
    debuffRange:SetPoint("TOPLEFT", buffRange, "BOTTOMLEFT", 0, -1)

    return buffRange, debuffRange
end

------------------------------------------------------------
-- Single aura icon frame
------------------------------------------------------------
function GUI:CreateAura(parent)
    local f = CreateFrame("Frame", nil, parent)
    f:SetSize(C.BUFF_ICON_SIZE, C.BUFF_ICON_SIZE)

    local tex = f:CreateTexture(nil, "ARTWORK")
    tex:SetAllPoints(f)
    f.texture = tex

    return f
end

------------------------------------------------------------
-- Cooldown display ranges
------------------------------------------------------------
function GUI:CreateCooldownRanges(parent, team)
    local cdRange = CreateFrame("Frame", nil, parent)
    cdRange:SetSize(C.COOLDOWN_ICON_SIZE, C.COOLDOWN_ICON_SIZE * C.MAX_COOLDOWNS_VISIBLE)
    if team == 1 then
        cdRange:SetPoint("TOPLEFT", parent, "TOPRIGHT", 5, 0)
    else
        cdRange:SetPoint("TOPRIGHT", parent, "TOPLEFT", -5, 0)
    end
    return cdRange
end

------------------------------------------------------------
-- Single cooldown frame
------------------------------------------------------------
function GUI:CreateCooldown(parent)
    local f = CreateFrame("Frame", nil, parent)
    f:SetSize(C.COOLDOWN_ICON_SIZE, C.COOLDOWN_ICON_SIZE)

    local tex = f:CreateTexture(nil, "ARTWORK")
    tex:SetAllPoints(f)
    f.texture = tex

    local text = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    text:SetFont("Fonts\\FRIZQT__.TTF", 9, "OUTLINE")
    text:SetPoint("BOTTOM", f, "BOTTOM", 0, -1)

    f.text = text
    return f
end

------------------------------------------------------------
-- Floating combat text font string
------------------------------------------------------------
function GUI:CreateCombatText(parent)
    local text = parent:CreateFontString(nil, "OVERLAY")
    text:SetFont("Fonts\\FRIZQT__.TTF", C.COMBATTEXT_FONTSIZE, "OUTLINE")
    text:SetPoint("CENTER", parent, "CENTER", 0, 0)
    return text
end

------------------------------------------------------------
-- Crowd control overlay
------------------------------------------------------------
function GUI:CreateCC(parent)
    local f = CreateFrame("Frame", nil, parent)
    f:SetSize(C.CC_ICON_SIZE, C.CC_ICON_SIZE)
    f:SetPoint("CENTER", parent, "CENTER", 0, 0)

    local tex = f:CreateTexture(nil, "ARTWORK")
    tex:SetAllPoints(f)
    f.texture = tex

    local text = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    text:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
    text:SetTextColor(1, 1, 1, 1)
    text:SetPoint("CENTER", f, "CENTER", 0, -1)

    return f, text
end

------------------------------------------------------------
-- Used-skill icon frame
------------------------------------------------------------
function GUI:CreateUsedSkill(parent, num)
    local f = CreateFrame("Frame", nil, parent)
    f:SetSize(C.SKILL_ICON_SIZE, C.SKILL_ICON_SIZE)
    f:SetPoint("LEFT", parent, "BOTTOMLEFT", num * (C.SKILL_ICON_SIZE + C.SKILL_ICON_MARGIN), 0)

    local tex = f:CreateTexture(nil, "ARTWORK")
    tex:SetAllPoints(f)
    f.texture = tex

    -- Cast bar overlay
    local castBar = CreateFrame("Frame", nil, f)
    castBar:SetSize(C.SKILL_ICON_SIZE, C.SKILL_ICON_SIZE)
    castBar:SetPoint("TOPLEFT", f, "TOPLEFT", 0, 0)

    local castTex = castBar:CreateTexture(nil, "OVERLAY")
    castTex:SetAllPoints(castBar)
    castTex:SetColorTexture(0, 0, 0, 0.65)
    castBar.texture = castTex

    -- Target color indicator
    local tcolor = CreateFrame("Frame", nil, f)
    tcolor:SetSize(C.SKILL_ICON_SIZE, 3)
    tcolor:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 0, 0)
    local tcolorTex = tcolor:CreateTexture(nil, "OVERLAY")
    tcolorTex:SetAllPoints(tcolor)
    tcolor.texture = tcolorTex
    tcolor:Hide()

    -- Target text
    local target = f:CreateFontString(nil, "OVERLAY")
    target:SetFont("Fonts\\FRIZQT__.TTF", 7, "OUTLINE")
    target:SetPoint("BOTTOM", f, "BOTTOM", 0, 3)
    target:Hide()

    return f, castBar, target, tcolor
end

------------------------------------------------------------
-- Interrupt X overlay
------------------------------------------------------------
function GUI:CreateInterruptFrame(skillFrame)
    local f = CreateFrame("Frame", nil, skillFrame)
    f:SetSize(C.SKILL_ICON_SIZE, C.SKILL_ICON_SIZE)
    f:SetPoint("CENTER", skillFrame, "CENTER", 0, 0)
    f:SetFrameLevel(skillFrame:GetFrameLevel() + 2)

    local tex = f:CreateTexture(nil, "OVERLAY")
    tex:SetAllPoints(f)
    tex:SetColorTexture(1, 0, 0, 0.7)
    f.texture = tex

    return f
end

------------------------------------------------------------
-- Seeker / Timeline bar
------------------------------------------------------------
function GUI:CreateSeekerBar(parent)
    local f = CreateFrame("Slider", "ArenaReplaySeekerBar", parent, "OptionsSliderTemplate")
    f:SetSize(C.SEEKER_WIDTH, C.SEEKER_HEIGHT)
    f:SetPoint("BOTTOM", parent, "BOTTOM", -30, 12)
    f:SetMinMaxValues(0, 100)
    f:SetValue(0)
    f:SetValueStep(1)
    f:SetObeyStepOnDrag(true)

    -- Speed slider
    local speed = CreateFrame("Slider", "ArenaReplaySpeedSlider", parent, "OptionsSliderTemplate")
    speed:SetSize(60, C.SEEKER_HEIGHT)
    speed:SetPoint("LEFT", f, "RIGHT", 10, 0)
    speed:SetMinMaxValues(0, 300)
    speed:SetValue(100)
    speed:SetValueStep(25)
    speed:SetObeyStepOnDrag(true)

    local speedLabel = speed:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    speedLabel:SetText("100%")
    speedLabel:SetPoint("TOP", speed, "BOTTOM", 0, -2)

    f.speed = speed
    f.speedLabel = speedLabel

    return f
end

------------------------------------------------------------
-- Seeker time text
------------------------------------------------------------
function GUI:CreateSeekerText(seekerBar)
    local text = seekerBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    text:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
    text:SetText("00:00")
    text:SetPoint("LEFT", seekerBar, "LEFT", -45, 0)
    return text
end

------------------------------------------------------------
-- Stats frame
------------------------------------------------------------
function GUI:CreateStatsFrame(parent)
    local f = CreateFrame("Frame", "ArenaReplayStats", parent, "BackdropTemplate")
    f:SetSize(C.PLAYER_FRAME_WIDTH - 20, 160)
    f:SetPoint("BOTTOM", parent, "BOTTOM", 0, 30)
    ApplyBackdrop(f, BACKDROP_MAIN)
    f:SetBackdropColor(0, 0, 0, 0.9)
    f:Hide()
    return f
end

------------------------------------------------------------
-- Detail entry for stats
------------------------------------------------------------
function GUI:CreateDetailEntry(parent, yOffset)
    local f = CreateFrame("Frame", nil, parent)
    f:SetSize(C.PLAYER_FRAME_WIDTH - 40, 20)
    f:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, yOffset)

    local icon = f:CreateTexture(nil, "ARTWORK")
    icon:SetSize(18, 18)
    icon:SetPoint("LEFT", f, "LEFT", 0, 0)

    local name = f:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    name:SetPoint("LEFT", icon, "RIGHT", 5, 0)
    name:SetWidth(100)
    name:SetJustifyH("LEFT")

    local dmg = f:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    dmg:SetPoint("LEFT", f, "LEFT", 130, 0)
    dmg:SetWidth(70)

    local crit = f:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    crit:SetPoint("LEFT", f, "LEFT", 210, 0)
    crit:SetWidth(70)

    local heal = f:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    heal:SetPoint("LEFT", f, "LEFT", 290, 0)
    heal:SetWidth(70)

    local rating = f:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    rating:SetPoint("LEFT", f, "LEFT", 370, 0)
    rating:SetWidth(70)

    local mmr = f:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    mmr:SetPoint("LEFT", f, "LEFT", 450, 0)
    mmr:SetWidth(60)

    f.icon = icon
    f.nameText = name
    f.dmg = dmg
    f.crit = crit
    f.heal = heal
    f.rating = rating
    f.mmr = mmr

    return f
end

------------------------------------------------------------
-- Tooltip helper
------------------------------------------------------------
function GUI:SetGameTooltip(name, desc, owner)
    if not owner then return end
    GameTooltip:SetOwner(owner, "ANCHOR_CURSOR")
    if name then
        GameTooltip:AddLine(name, 1, 1, 1)
    end
    if desc then
        GameTooltip:AddLine(desc, 0.8, 0.8, 0.8, true)
    end
    GameTooltip:Show()
end
