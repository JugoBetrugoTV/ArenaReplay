local _, AR = ...
AR.Util = {}
local Util = AR.Util

------------------------------------------------------------
-- String splitting
------------------------------------------------------------
function Util:Split(str, pat)
    if not str then return nil end
    local t = {}
    local fpat = "(.-)" .. pat
    local last_end = 1
    local s, e, cap = string.find(str, fpat, 1)
    while s do
        if s ~= 1 or cap ~= "" then
            table.insert(t, cap)
        end
        last_end = e + 1
        s, e, cap = string.find(str, fpat, last_end)
    end
    if last_end <= #str then
        cap = string.sub(str, last_end)
        table.insert(t, cap)
    end
    return t
end

------------------------------------------------------------
-- Class color lookup (all WoW versions)
------------------------------------------------------------
local CLASS_COLORS = {
    DEATHKNIGHT  = { 0.77, 0.12, 0.23 },
    DEMONHUNTER  = { 0.64, 0.19, 0.79 },
    DRUID        = { 1.00, 0.49, 0.04 },
    EVOKER       = { 0.20, 0.58, 0.50 },
    HUNTER       = { 0.67, 0.83, 0.45 },
    MAGE         = { 0.41, 0.80, 0.94 },
    MONK         = { 0.00, 1.00, 0.60 },
    PALADIN      = { 0.96, 0.55, 0.73 },
    PRIEST       = { 1.00, 1.00, 1.00 },
    ROGUE        = { 1.00, 0.96, 0.41 },
    SHAMAN       = { 0.00, 0.44, 0.87 },
    WARLOCK      = { 0.58, 0.51, 0.79 },
    WARRIOR      = { 0.78, 0.61, 0.43 },
}

function Util:GetClassColor(class)
    local c = CLASS_COLORS[class]
    if c then return c[1], c[2], c[3] end
    return 1, 1, 1
end

------------------------------------------------------------
-- Unique-color palette (for distinguishing players by ID)
------------------------------------------------------------
local UNIQUE_COLORS = {
    [0]  = { 0.00, 0.29, 1.00 },
    [1]  = { 0.91, 0.40, 0.72 },
    [2]  = { 0.13, 0.91, 0.75 },
    [3]  = { 0.62, 0.62, 0.62 },
    [4]  = { 0.37, 0.00, 0.54 },
    [5]  = { 0.53, 0.77, 0.95 },
    [6]  = { 1.00, 0.99, 0.00 },
    [7]  = { 0.07, 0.36, 0.27 },
    [8]  = { 1.00, 0.58, 0.07 },
    [9]  = { 0.35, 0.20, 0.02 },
}

function Util:GetTargetColor(data, useClassColor)
    if useClassColor or not ArenaReplayDB.defaults.uniqueColor then
        return self:GetClassColor(data.class)
    end
    local c = UNIQUE_COLORS[data.ID]
    if c then return c[1], c[2], c[3] end
    return 1, 1, 1
end

------------------------------------------------------------
-- Mana-user detection (all WoW versions)
-- Classes that don't exist in a given version simply won't appear
------------------------------------------------------------
local MANA_CLASSES = {
    PALADIN = true, PRIEST = true, DRUID = true,
    WARLOCK = true, MAGE = true, MONK = true,
    SHAMAN = true, EVOKER = true, DEMONHUNTER = false,
    HUNTER = false, ROGUE = false, WARRIOR = false,
    DEATHKNIGHT = false,
}

function Util:IsManaUser(class)
    return MANA_CLASSES[class] == true
end

------------------------------------------------------------
-- Format elapsed time
------------------------------------------------------------
function Util:FormatTime(seconds)
    if not seconds or seconds < 0 then seconds = 0 end
    return string.format("%02d:%02d", math.floor(seconds / 60), seconds % 60)
end

------------------------------------------------------------
-- Spell info / Health wrappers (delegate to Compat layer)
------------------------------------------------------------
function Util:GetSpellInfo(spellID)
    return AR.Compat.GetSpellInfo(spellID)
end

function Util:SafeUnitHealth(unit)
    return AR.Compat.SafeUnitHealth(unit)
end

function Util:SafeUnitHealthMax(unit)
    return AR.Compat.SafeUnitHealthMax(unit)
end

------------------------------------------------------------
-- Abbreviate large numbers
------------------------------------------------------------
function Util:AbbreviateNumber(val)
    if val >= 1000000 then
        return string.format("%.1fM", val / 1000000)
    elseif val >= 1000 then
        return string.format("%.1fK", val / 1000)
    end
    return tostring(val)
end

------------------------------------------------------------
-- Class-colored name string
------------------------------------------------------------
function Util:ClassColoredName(name, class)
    local r, g, b = self:GetClassColor(class)
    return string.format("|cff%02x%02x%02x%s|r", r * 255, g * 255, b * 255, name)
end
