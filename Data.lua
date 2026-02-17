local _, AR = ...
AR.Data = {}
local Data = AR.Data

------------------------------------------------------------
-- Addon version
------------------------------------------------------------
AR.VERSION_MAJOR = 1
AR.VERSION_MINOR = 3
AR.VERSION_PATCH = 0
AR.VERSION = AR.VERSION_MAJOR .. "." .. AR.VERSION_MINOR .. "." .. AR.VERSION_PATCH

------------------------------------------------------------
-- GUI constants (shared across all versions)
------------------------------------------------------------
AR.GUI_CONST = {
    PLAYER_FRAME_WIDTH      = 570,
    PLAYER_FRAME_HEIGHT     = 350,
    HEALTHBAR_WIDTH         = 170,
    HEALTHBAR_HEIGHT        = 28,
    MANABAR_HEIGHT          = 6,
    ICON_SIZE               = 28,
    SKILL_ICON_SIZE         = 22,
    SKILL_ICON_MARGIN       = 2,
    SKILL_PERSISTENCE       = 4.0,
    SKILL_FADEOUT_TIME      = 1.5,
    SKILL_FADEIN_TIME       = 0.3,
    SKILL_ICON_SPEED        = 80,
    BUFF_ICON_SIZE          = 18,
    COOLDOWN_ICON_SIZE      = 20,
    COOLDOWN_ICON_MARGIN    = 2,
    CC_ICON_SIZE            = 28,
    COMBATTEXT_FONTSIZE     = 12,
    COMBATTEXT_CRIT_PLUS    = 18,
    COMBATTEXT_SPEED        = 40,
    COMBATTEXT_PERSISTENCE  = 2.0,
    COMBATTEXT_FADETIME     = 0.8,
    SEEKER_WIDTH            = 500,
    SEEKER_HEIGHT           = 16,
    MAX_AURAS_VISIBLE       = 8,
    MAX_COOLDOWNS_VISIBLE   = 6,
    UPDATE_FPS              = 30,
    AURA_INDEX_STEP         = 50,
}

------------------------------------------------------------
-- Event type encoding for match data serialization (shared)
------------------------------------------------------------
Data.EVENT_TYPES = {
    DAMAGE    = "D",
    HEAL      = "H",
    AURA_APP  = "AA",
    AURA_REM  = "AR",
    SPELL_CAST = "SC",
    DEATH     = "X",
    HP_UPDATE = "HP",
    MANA_UPDATE = "MP",
    INTERRUPT = "I",
    CC_APP    = "CC",
    CC_REM    = "CR",
    CD_USED   = "CD",
}

------------------------------------------------------------
-- Communication protocol constants (shared)
------------------------------------------------------------
Data.COMM_PREFIX_LOOKUP = "ARLookup"
Data.COMM_PREFIX_HANDLE = "ARHandle"

Data.COMM = {
    VERSION_CHECK  = "VC",
    BROADCAST_ON   = "BO",
    BROADCAST_OFF  = "BF",
    SPECTATE_REQ   = "SR",
    SPECTATE_ACK   = "SA",
    MATCH_HEADER   = "MH",
    MATCH_DATA     = "MD",
    MATCH_END      = "ME",
    PLAYER_INFO    = "PI",
}

------------------------------------------------------------
-- Placeholder tables (populated by version-specific Spells file)
------------------------------------------------------------
Data.ARENA_MAPS        = Data.ARENA_MAPS or { [0] = "Unknown" }
Data.ARENA_MAP_LOOKUP  = Data.ARENA_MAP_LOOKUP or {}
Data.IMPORTANT_SKILLS  = Data.IMPORTANT_SKILLS or {}
Data.COOLDOWN_SPELLS   = Data.COOLDOWN_SPELLS or {}
