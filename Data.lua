local _, AR = ...
AR.Data = {}
local Data = AR.Data

------------------------------------------------------------
-- Addon version
------------------------------------------------------------
AR.VERSION_MAJOR = 1
AR.VERSION_MINOR = 0
AR.VERSION_PATCH = 0
AR.VERSION = AR.VERSION_MAJOR .. "." .. AR.VERSION_MINOR .. "." .. AR.VERSION_PATCH

------------------------------------------------------------
-- GUI constants
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
    SEEKER_HEIGHT            = 16,
    MAX_AURAS_VISIBLE       = 8,
    MAX_COOLDOWNS_VISIBLE   = 6,
    UPDATE_FPS              = 30,
    AURA_INDEX_STEP         = 50,
}

------------------------------------------------------------
-- Arena map IDs (WoW 12.0)
------------------------------------------------------------
Data.ARENA_MAPS = {
    [0]  = "Unknown",
    [1]  = "Nagrand Arena",
    [2]  = "Ruins of Lordaeron",
    [3]  = "Blade's Edge Arena",
    [4]  = "Dalaran Arena",
    [5]  = "Tol'viron Arena",
    [6]  = "Ashamane's Fall",
    [7]  = "Black Rook Hold Arena",
    [8]  = "Shado-Pan Showdown",
    [9]  = "Hook Point",
    [10] = "Mugambala",
    [11] = "The Robodrome",
    [12] = "Enigma Crucible",
    [13] = "Nokhudon Proving Grounds",
    [14] = "Empyrean Domain",
}

-- Reverse lookup: zone name -> map ID
Data.ARENA_MAP_LOOKUP = {}
for k, v in pairs(Data.ARENA_MAPS) do
    Data.ARENA_MAP_LOOKUP[v] = k
end

------------------------------------------------------------
-- Important skills (CC, defensives, offensives)
-- Updated for WoW 12.0 Midnight
-- Type: 1 = buff/silence/disarm, 2 = root, 3 = stun/incapacitate/immunity
------------------------------------------------------------
Data.IMPORTANT_SKILLS = {
    -- Crowd Control (Stuns / Incapacitates / Disorients)
    [853]    = 3,  -- Hammer of Justice
    [20066]  = 3,  -- Repentance
    [105421] = 3,  -- Blinding Light
    [1833]   = 3,  -- Cheap Shot
    [408]    = 3,  -- Kidney Shot
    [1776]   = 3,  -- Gouge
    [2094]   = 3,  -- Blind
    [6770]   = 3,  -- Sap
    [118]    = 3,  -- Polymorph
    [28272]  = 3,  -- Polymorph (pig)
    [28271]  = 3,  -- Polymorph (turtle)
    [61305]  = 3,  -- Polymorph (black cat)
    [61025]  = 3,  -- Polymorph (serpent)
    [31661]  = 3,  -- Dragon's Breath
    [82691]  = 3,  -- Ring of Frost
    [44572]  = 3,  -- Deep Freeze
    [33786]  = 3,  -- Cyclone
    [5211]   = 3,  -- Mighty Bash
    [22570]  = 3,  -- Maim
    [99]     = 3,  -- Incapacitating Roar
    [3355]   = 3,  -- Freezing Trap
    [19386]  = 3,  -- Wyvern Sting
    [19503]  = 3,  -- Scatter Shot
    [51514]  = 3,  -- Hex
    [5246]   = 3,  -- Intimidating Shout
    [132169] = 3,  -- Storm Bolt
    [132168] = 3,  -- Shockwave
    [8122]   = 3,  -- Psychic Scream
    [605]    = 3,  -- Dominate Mind
    [88625]  = 3,  -- Holy Word: Chastise
    [64044]  = 3,  -- Psychic Horror
    [6789]   = 3,  -- Mortal Coil
    [30283]  = 3,  -- Shadowfury
    [5484]   = 3,  -- Howl of Terror
    [118699] = 3,  -- Fear
    [6358]   = 3,  -- Seduction
    [115078] = 3,  -- Paralysis
    [119381] = 3,  -- Leg Sweep
    [119392] = 3,  -- Charging Ox Wave
    [108194] = 3,  -- Asphyxiate
    [91800]  = 3,  -- Gnaw
    [91797]  = 3,  -- Monstrous Blow
    [221562] = 3,  -- Asphyxiate (Blood)
    [207167] = 3,  -- Blinding Sleet
    [211881] = 3,  -- Fel Eruption
    [217832] = 3,  -- Imprison
    [200166] = 3,  -- Metamorphosis stun
    [360806] = 3,  -- Sleep Walk (Evoker)

    -- Roots
    [339]    = 2,  -- Entangling Roots
    [102359] = 2,  -- Mass Entanglement
    [122]    = 2,  -- Frost Nova
    [33395]  = 2,  -- Freeze (Water Elemental)
    [64695]  = 2,  -- Earthgrab
    [107566] = 2,  -- Staggering Shout
    [96294]  = 2,  -- Chains of Ice (root component)
    [233395] = 2,  -- Frozen Center

    -- Silences
    [15487]  = 1,  -- Silence
    [47476]  = 1,  -- Strangulate
    [1330]   = 1,  -- Garrote
    [78675]  = 1,  -- Solar Beam
    [202137] = 1,  -- Sigil of Silence

    -- Disarms
    [236077] = 1,  -- Disarm

    -- Defensive Buffs
    [1022]   = 1,  -- Blessing of Protection
    [1044]   = 1,  -- Blessing of Freedom
    [6940]   = 1,  -- Blessing of Sacrifice
    [33206]  = 1,  -- Pain Suppression
    [47788]  = 1,  -- Guardian Spirit
    [47585]  = 1,  -- Dispersion
    [871]    = 1,  -- Shield Wall
    [48707]  = 1,  -- Anti-Magic Shell
    [31224]  = 1,  -- Cloak of Shadows
    [19263]  = 2,  -- Deterrence / Aspect of the Turtle
    [116849] = 1,  -- Life Cocoon
    [53480]  = 1,  -- Roar of Sacrifice
    [104773] = 1,  -- Unending Resolve
    [22812]  = 1,  -- Barkskin
    [498]    = 1,  -- Divine Protection
    [118038] = 1,  -- Die by the Sword
    [198589] = 1,  -- Blur (DH)
    [363916] = 1,  -- Obsidian Scales (Evoker)

    -- Immunities
    [45438]  = 3,  -- Ice Block
    [642]    = 3,  -- Divine Shield
    [186265] = 3,  -- Aspect of the Turtle
    [110913] = 3,  -- Dark Bargain

    -- Major Offensive CDs
    [31884]  = 1,  -- Avenging Wrath
    [12472]  = 1,  -- Icy Veins
    [1719]   = 1,  -- Recklessness
    [13750]  = 1,  -- Adrenaline Rush
    [51690]  = 1,  -- Killing Spree
    [51271]  = 1,  -- Pillar of Frost
    [49206]  = 1,  -- Summon Gargoyle
    [19574]  = 1,  -- Bestial Wrath
    [114049] = 1,  -- Ascendance
    [137639] = 1,  -- Storm, Earth, and Fire
    [152173] = 1,  -- Serenity
    [191427] = 1,  -- Metamorphosis (DH)
    [375087] = 1,  -- Dragonrage (Evoker)
}

------------------------------------------------------------
-- Cooldown durations (seconds) for tracking
-- Updated for 12.0
------------------------------------------------------------
Data.COOLDOWN_SPELLS = {
    -- Warrior
    [6552]   = 15,   -- Pummel
    [5246]   = 90,   -- Intimidating Shout
    [871]    = 180,  -- Shield Wall
    [18499]  = 60,   -- Berserker Rage
    [1719]   = 90,   -- Recklessness
    [23920]  = 25,   -- Spell Reflection
    [46968]  = 40,   -- Shockwave
    [107574] = 90,   -- Avatar
    [118038] = 120,  -- Die by the Sword
    [46924]  = 60,   -- Bladestorm
    [132169] = 30,   -- Storm Bolt
    [132168] = 40,   -- Shockwave
    [184364] = 120,  -- Enraged Regeneration
    [97462]  = 180,  -- Rallying Cry

    -- Paladin
    [853]    = 60,   -- Hammer of Justice
    [642]    = 300,  -- Divine Shield
    [1022]   = 300,  -- Blessing of Protection
    [1044]   = 25,   -- Blessing of Freedom
    [6940]   = 120,  -- Blessing of Sacrifice
    [31884]  = 120,  -- Avenging Wrath
    [498]    = 60,   -- Divine Protection
    [20066]  = 15,   -- Repentance
    [96231]  = 15,   -- Rebuke
    [105421] = 90,   -- Blinding Light
    [31821]  = 180,  -- Aura Mastery

    -- Hunter
    [781]    = 20,   -- Disengage
    [186265] = 180,  -- Aspect of the Turtle
    [19574]  = 90,   -- Bestial Wrath
    [53480]  = 60,   -- Roar of Sacrifice
    [109248] = 45,   -- Binding Shot
    [187650] = 30,   -- Freezing Trap
    [19386]  = 45,   -- Wyvern Sting
    [147362] = 24,   -- Counter Shot
    [53351]  = 10,   -- Kill Shot
    [3045]   = 120,  -- Rapid Fire
    [288613] = 120,  -- Trueshot

    -- Rogue
    [1766]   = 15,   -- Kick
    [2094]   = 120,  -- Blind
    [5277]   = 120,  -- Evasion
    [1856]   = 120,  -- Vanish
    [31224]  = 120,  -- Cloak of Shadows
    [13750]  = 180,  -- Adrenaline Rush
    [51690]  = 120,  -- Killing Spree
    [121471] = 180,  -- Shadow Blades
    [36554]  = 30,   -- Shadowstep
    [76577]  = 180,  -- Smoke Bomb
    [2983]   = 120,  -- Sprint

    -- Priest
    [8122]   = 60,   -- Psychic Scream
    [33206]  = 180,  -- Pain Suppression
    [47585]  = 120,  -- Dispersion
    [15487]  = 45,   -- Silence
    [64044]  = 45,   -- Psychic Horror
    [88625]  = 60,   -- Holy Word: Chastise
    [73325]  = 90,   -- Leap of Faith
    [47788]  = 180,  -- Guardian Spirit
    [62618]  = 180,  -- Power Word: Barrier
    [10060]  = 120,  -- Power Infusion
    [34433]  = 180,  -- Shadowfiend
    [246287] = 90,   -- Evangelism

    -- Death Knight
    [49576]  = 25,   -- Death Grip
    [47476]  = 60,   -- Strangulate
    [48707]  = 60,   -- Anti-Magic Shell
    [51052]  = 120,  -- Anti-Magic Zone
    [48792]  = 180,  -- Icebound Fortitude
    [49028]  = 120,  -- Dancing Rune Weapon
    [49206]  = 180,  -- Summon Gargoyle
    [51271]  = 60,   -- Pillar of Frost
    [47568]  = 120,  -- Empower Rune Weapon
    [207167] = 60,   -- Blinding Sleet
    [221562] = 45,   -- Asphyxiate (Blood)

    -- Shaman
    [57994]  = 12,   -- Wind Shear
    [51514]  = 30,   -- Hex
    [108271] = 90,   -- Astral Shift
    [98008]  = 180,  -- Spirit Link Totem
    [108280] = 180,  -- Healing Tide Totem
    [16166]  = 90,   -- Elemental Mastery
    [51533]  = 120,  -- Feral Spirit
    [114049] = 180,  -- Ascendance
    [79206]  = 120,  -- Spiritwalker's Grace
    [192058] = 60,   -- Capacitor Totem

    -- Mage
    [2139]   = 24,   -- Counterspell
    [45438]  = 240,  -- Ice Block
    [1953]   = 15,   -- Blink / Shimmer
    [122]    = 30,   -- Frost Nova
    [31661]  = 45,   -- Dragon's Breath
    [55342]  = 120,  -- Mirror Image
    [12472]  = 180,  -- Icy Veins
    [12042]  = 120,  -- Arcane Power
    [113724] = 45,   -- Ring of Frost
    [235219] = 300,  -- Cold Snap

    -- Warlock
    [5484]   = 40,   -- Howl of Terror
    [6789]   = 45,   -- Mortal Coil
    [48020]  = 30,   -- Demonic Circle: Teleport
    [30283]  = 60,   -- Shadowfury
    [104773] = 180,  -- Unending Resolve
    [108416] = 60,   -- Dark Pact
    [113858] = 120,  -- Dark Soul: Instability
    [113860] = 120,  -- Dark Soul: Misery
    [111898] = 120,  -- Grimoire: Felguard

    -- Monk
    [115078] = 45,   -- Paralysis
    [119381] = 60,   -- Leg Sweep
    [116705] = 15,   -- Spear Hand Strike
    [116849] = 120,  -- Life Cocoon
    [115203] = 180,  -- Fortifying Brew
    [122783] = 90,   -- Diffuse Magic
    [122278] = 120,  -- Dampen Harm
    [115310] = 180,  -- Revival
    [137639] = 90,   -- Storm, Earth, and Fire
    [152173] = 90,   -- Serenity
    [116841] = 30,   -- Tiger's Lust
    [122470] = 90,   -- Touch of Karma

    -- Druid
    [22812]  = 60,   -- Barkskin
    [5211]   = 60,   -- Mighty Bash
    [106951] = 180,  -- Berserk
    [102359] = 30,   -- Mass Entanglement
    [29166]  = 180,  -- Innervate
    [132158] = 60,   -- Nature's Swiftness
    [77761]  = 120,  -- Stampeding Roar
    [102793] = 60,   -- Ursol's Vortex
    [61336]  = 180,  -- Survival Instincts
    [740]    = 180,  -- Tranquility
    [78675]  = 60,   -- Solar Beam

    -- Demon Hunter
    [217832] = 45,   -- Imprison
    [183752] = 15,   -- Disrupt
    [198589] = 60,   -- Blur
    [196718] = 180,  -- Darkness
    [191427] = 240,  -- Metamorphosis
    [211881] = 30,   -- Fel Eruption
    [202137] = 60,   -- Sigil of Silence
    [179057] = 60,   -- Chaos Nova
    [206491] = 120,  -- Nemesis

    -- Evoker
    [351338] = 90,   -- Quell
    [363916] = 90,   -- Obsidian Scales
    [370960] = 180,  -- Emerald Communion
    [375087] = 120,  -- Dragonrage
    [360806] = 15,   -- Sleep Walk
    [357210] = 120,  -- Deep Breath
    [358385] = 120,  -- Landslide
    [378441] = 120,  -- Time Spiral
    [370553] = 120,  -- Tip the Scales

    -- Trinket / Racial
    [42292]  = 120,  -- PvP Trinket
    [59752]  = 120,  -- Every Man for Himself
    [7744]   = 120,  -- Will of the Forsaken
}

------------------------------------------------------------
-- Event type encoding for match data serialization
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
-- Communication protocol constants
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
