local _, AR = ...

------------------------------------------------------------
-- Arena map IDs (Mists of Pandaria 5.4.8)
------------------------------------------------------------
AR.Data.ARENA_MAPS = {
    [0] = "Unknown",
    [1] = "Nagrand Arena",
    [2] = "Blade's Edge Arena",
    [3] = "Ruins of Lordaeron",
    [4] = "Dalaran Arena",
    [5] = "Tol'viron Arena",
    [6] = "Tiger's Peak",
}

-- Reverse lookup: zone name -> map ID
AR.Data.ARENA_MAP_LOOKUP = {}
for k, v in pairs(AR.Data.ARENA_MAPS) do
    AR.Data.ARENA_MAP_LOOKUP[v] = k
end

------------------------------------------------------------
-- Bracket types (Mists of Pandaria)
-- 2v2, 3v3, 5v5, Rated Battleground
------------------------------------------------------------
AR.Data.BRACKETS = {
    [1] = "2v2",
    [2] = "3v3",
    [3] = "5v5",
    [4] = "RBG",
}

------------------------------------------------------------
-- Important skills (CC, defensives, offensives)
-- MoP 5.4.8 spell IDs
-- Type: 1 = buff/silence/disarm, 2 = root, 3 = stun/incapacitate/immunity
------------------------------------------------------------
AR.Data.IMPORTANT_SKILLS = {

    ----------------------------------------------------------------
    -- Stuns
    ----------------------------------------------------------------
    [853]    = 3,  -- Hammer of Justice (Paladin)
    [1833]   = 3,  -- Cheap Shot (Rogue)
    [408]    = 3,  -- Kidney Shot (Rogue)
    [44572]  = 3,  -- Deep Freeze (Mage)
    [30283]  = 3,  -- Shadowfury (Warlock)
    [5211]   = 3,  -- Mighty Bash (Druid)
    [22570]  = 3,  -- Maim (Druid)
    [46968]  = 3,  -- Shockwave (Warrior)
    [132168] = 3,  -- Shockwave (Warrior - MoP ID)
    [20549]  = 3,  -- War Stomp (Racial)
    [91800]  = 3,  -- Gnaw (DK Ghoul)
    [91797]  = 3,  -- Monstrous Blow (DK Ghoul, Dark Transformation)
    [89766]  = 3,  -- Axe Toss (Warlock Felguard)
    [19577]  = 3,  -- Intimidation (Hunter)
    [119381] = 3,  -- Leg Sweep (Monk)
    [120086] = 3,  -- Fists of Fury stun (Monk)
    [119392] = 3,  -- Charging Ox Wave (Monk)
    [105593] = 3,  -- Fist of Justice (Paladin)
    [108194] = 3,  -- Asphyxiate (Death Knight)
    [118905] = 3,  -- Static Charge (Shaman Capacitor Totem)
    [118345] = 3,  -- Pulverize (Warlock Felguard)

    ----------------------------------------------------------------
    -- Incapacitates / Disorients
    ----------------------------------------------------------------
    [118]    = 3,  -- Polymorph (Mage)
    [28272]  = 3,  -- Polymorph: Pig (Mage)
    [28271]  = 3,  -- Polymorph: Turtle (Mage)
    [61305]  = 3,  -- Polymorph: Black Cat (Mage)
    [61025]  = 3,  -- Polymorph: Serpent (Mage)
    [61721]  = 3,  -- Polymorph: Rabbit (Mage)
    [61780]  = 3,  -- Polymorph: Turkey (Mage)
    [2094]   = 3,  -- Blind (Rogue)
    [6770]   = 3,  -- Sap (Rogue)
    [1776]   = 3,  -- Gouge (Rogue)
    [20066]  = 3,  -- Repentance (Paladin)
    [3355]   = 3,  -- Freezing Trap (Hunter)
    [19386]  = 3,  -- Wyvern Sting (Hunter)
    [51514]  = 3,  -- Hex (Shaman)
    [33786]  = 3,  -- Cyclone (Druid)
    [99]     = 3,  -- Incapacitating Roar (Druid)
    [9484]   = 3,  -- Shackle Undead (Priest)
    [605]    = 3,  -- Dominate Mind (Priest)
    [88625]  = 3,  -- Holy Word: Chastise (Priest)
    [82691]  = 3,  -- Ring of Frost (Mage)
    [31661]  = 3,  -- Dragon's Breath (Mage)
    [710]    = 3,  -- Banish (Warlock)
    [115078] = 3,  -- Paralysis (Monk)
    [115268] = 3,  -- Mesmerize (Warlock Shivarra)
    [137143] = 3,  -- Blood Horror (Warlock)
    [113724] = 3,  -- Ring of Frost (Mage, MoP talent)

    ----------------------------------------------------------------
    -- Fears
    ----------------------------------------------------------------
    [5246]   = 3,  -- Intimidating Shout (Warrior)
    [8122]   = 3,  -- Psychic Scream (Priest)
    [5484]   = 3,  -- Howl of Terror (Warlock)
    [5782]   = 3,  -- Fear (Warlock)
    [6358]   = 3,  -- Seduction (Warlock Succubus)
    [6789]   = 3,  -- Mortal Coil (Warlock)
    [104045] = 3,  -- Sleep (Warlock, Metamorphosis)
    [115191] = 3,  -- Stealth (subtlety passive, not fear but included)

    ----------------------------------------------------------------
    -- Roots
    ----------------------------------------------------------------
    [339]    = 2,  -- Entangling Roots (Druid)
    [102359] = 2,  -- Mass Entanglement (Druid)
    [122]    = 2,  -- Frost Nova (Mage)
    [33395]  = 2,  -- Freeze (Mage Water Elemental)
    [64695]  = 2,  -- Earthgrab (Shaman)
    [116706] = 2,  -- Disable (Monk)
    [96294]  = 2,  -- Chains of Ice (root from Chilblains)
    [136634] = 2,  -- Narrow Escape (Hunter)

    ----------------------------------------------------------------
    -- Silences
    ----------------------------------------------------------------
    [15487]  = 1,  -- Silence (Priest)
    [47476]  = 1,  -- Strangulate (Death Knight)
    [1330]   = 1,  -- Garrote - Silence (Rogue)
    [78675]  = 1,  -- Solar Beam (Druid)
    [116709] = 1,  -- Spear Hand Strike (Monk)
    [102051] = 1,  -- Frostjaw (Mage)
    [114238] = 1,  -- Fae Silence (Warlock, Imp)
    [137557] = 1,  -- Silence (Warlock, Optical Blast)

    ----------------------------------------------------------------
    -- Disarms
    ----------------------------------------------------------------
    [676]    = 1,  -- Disarm (Warrior)
    [51722]  = 1,  -- Dismantle (Rogue)
    [117368] = 1,  -- Grapple Weapon (Monk)
    [126458] = 1,  -- Grapple Weapon rank 2 (Monk)

    ----------------------------------------------------------------
    -- Defensive Buffs
    ----------------------------------------------------------------
    [1022]   = 1,  -- Hand of Protection (Paladin)
    [1044]   = 1,  -- Hand of Freedom (Paladin)
    [6940]   = 1,  -- Hand of Sacrifice (Paladin)
    [498]    = 1,  -- Divine Protection (Paladin)
    [31821]  = 1,  -- Devotion Aura (Paladin)
    [33206]  = 1,  -- Pain Suppression (Priest)
    [47788]  = 1,  -- Guardian Spirit (Priest)
    [47585]  = 1,  -- Dispersion (Priest)
    [114908] = 1,  -- Spirit Shell (Priest)
    [871]    = 1,  -- Shield Wall (Warrior)
    [12975]  = 1,  -- Last Stand (Warrior)
    [118038] = 1,  -- Die by the Sword (Warrior)
    [114029] = 1,  -- Safeguard (Warrior)
    [48707]  = 1,  -- Anti-Magic Shell (Death Knight)
    [51052]  = 1,  -- Anti-Magic Zone (Death Knight)
    [48792]  = 1,  -- Icebound Fortitude (Death Knight)
    [48743]  = 1,  -- Death Pact (Death Knight)
    [31224]  = 1,  -- Cloak of Shadows (Rogue)
    [5277]   = 1,  -- Evasion (Rogue)
    [74001]  = 1,  -- Combat Readiness (Rogue)
    [19263]  = 1,  -- Deterrence (Hunter)
    [53480]  = 1,  -- Roar of Sacrifice (Hunter pet)
    [22812]  = 1,  -- Barkskin (Druid)
    [61336]  = 1,  -- Survival Instincts (Druid)
    [102342] = 1,  -- Ironbark (Druid)
    [30823]  = 1,  -- Shamanistic Rage (Shaman)
    [98008]  = 1,  -- Spirit Link Totem (Shaman)
    [108271] = 1,  -- Astral Shift (Shaman)
    [115176] = 1,  -- Zen Meditation (Monk)
    [122783] = 1,  -- Diffuse Magic (Monk)
    [122278] = 1,  -- Dampen Harm (Monk)
    [115295] = 1,  -- Guard (Monk)
    [116849] = 1,  -- Life Cocoon (Monk)
    [115203] = 1,  -- Fortifying Brew (Monk)

    ----------------------------------------------------------------
    -- Immunities
    ----------------------------------------------------------------
    [45438]  = 3,  -- Ice Block (Mage)
    [642]    = 3,  -- Divine Shield (Paladin)

    ----------------------------------------------------------------
    -- Major Offensive CDs
    ----------------------------------------------------------------
    [31884]  = 1,  -- Avenging Wrath (Paladin)
    [105809] = 1,  -- Holy Avenger (Paladin)
    [12472]  = 1,  -- Icy Veins (Mage)
    [12042]  = 1,  -- Arcane Power (Mage)
    [1719]   = 1,  -- Recklessness (Warrior)
    [107574] = 1,  -- Avatar (Warrior)
    [13750]  = 1,  -- Adrenaline Rush (Rogue)
    [51690]  = 1,  -- Killing Spree (Rogue)
    [51713]  = 1,  -- Shadow Dance (Rogue)
    [79140]  = 1,  -- Vendetta (Rogue)
    [137573] = 1,  -- Burst of Speed (Rogue)
    [51271]  = 1,  -- Pillar of Frost (Death Knight)
    [49206]  = 1,  -- Summon Gargoyle (Death Knight)
    [19574]  = 1,  -- Bestial Wrath (Hunter)
    [3045]   = 1,  -- Rapid Fire (Hunter)
    [121471] = 1,  -- Shadow Blades (Rogue)
    [120360] = 1,  -- Barrage (Hunter)
    [131894] = 1,  -- A Murder of Crows (Hunter)
    [16166]  = 1,  -- Elemental Mastery (Shaman)
    [51533]  = 1,  -- Feral Spirit (Shaman)
    [114049] = 1,  -- Ascendance (Shaman)
    [106951] = 1,  -- Berserk (Druid)
    [102543] = 1,  -- Incarnation: King of the Jungle (Druid)
    [102560] = 1,  -- Incarnation: Chosen of Elune (Druid)
    [102558] = 1,  -- Incarnation: Son of Ursoc (Druid)
    [33891]  = 1,  -- Incarnation: Tree of Life (Druid)
    [10060]  = 1,  -- Power Infusion (Priest)
    [34433]  = 1,  -- Shadowfiend (Priest)
    [123904] = 1,  -- Invoke Xuen, the White Tiger (Monk)
    [137562] = 1,  -- Energizing Brew (Monk)
    [116740] = 1,  -- Tigereye Brew (Monk)
    [113656] = 1,  -- Fists of Fury (Monk)
}

------------------------------------------------------------
-- Cooldown durations (seconds) for tracking
-- MoP 5.4.8 spell IDs and cooldowns
------------------------------------------------------------
AR.Data.COOLDOWN_SPELLS = {

    ----------------------------------------------------------------
    -- Warrior
    ----------------------------------------------------------------
    [6552]   = 10,   -- Pummel
    [5246]   = 90,   -- Intimidating Shout
    [871]    = 180,  -- Shield Wall
    [12975]  = 180,  -- Last Stand
    [1719]   = 180,  -- Recklessness
    [18499]  = 30,   -- Berserker Rage
    [114028] = 30,   -- Mass Spell Reflection
    [23920]  = 25,   -- Spell Reflection
    [46968]  = 40,   -- Shockwave
    [132168] = 40,   -- Shockwave (talent version)
    [46924]  = 60,   -- Bladestorm
    [3411]   = 30,   -- Intervene
    [676]    = 60,   -- Disarm
    [118038] = 120,  -- Die by the Sword
    [107574] = 180,  -- Avatar
    [114029] = 30,   -- Safeguard
    [97462]  = 180,  -- Rallying Cry
    [102060] = 15,   -- Disrupting Shout
    [107570] = 30,   -- Storm Bolt

    ----------------------------------------------------------------
    -- Paladin
    ----------------------------------------------------------------
    [853]    = 60,   -- Hammer of Justice
    [642]    = 300,  -- Divine Shield
    [1022]   = 300,  -- Hand of Protection
    [1044]   = 25,   -- Hand of Freedom
    [6940]   = 120,  -- Hand of Sacrifice
    [31884]  = 180,  -- Avenging Wrath
    [498]    = 60,   -- Divine Protection
    [20066]  = 15,   -- Repentance
    [96231]  = 10,   -- Rebuke
    [31821]  = 180,  -- Devotion Aura
    [105593] = 60,   -- Fist of Justice
    [105809] = 120,  -- Holy Avenger
    [86659]  = 180,  -- Guardian of Ancient Kings
    [114157] = 60,   -- Execution Sentence
    [115750] = 120,  -- Blinding Light

    ----------------------------------------------------------------
    -- Hunter
    ----------------------------------------------------------------
    [781]    = 20,   -- Disengage
    [19263]  = 120,  -- Deterrence
    [19574]  = 60,   -- Bestial Wrath
    [53480]  = 60,   -- Roar of Sacrifice
    [19386]  = 45,   -- Wyvern Sting
    [109248] = 45,   -- Binding Shot
    [3045]   = 120,  -- Rapid Fire
    [19577]  = 60,   -- Intimidation
    [120360] = 30,   -- Barrage
    [131894] = 120,  -- A Murder of Crows
    [53351]  = 10,   -- Kill Shot
    [120697] = 24,   -- Lynx Rush
    [117050] = 180,  -- Glaive Toss
    [82726]  = 30,   -- Fervor
    [34600]  = 30,   -- Snake Trap
    [136634] = 60,   -- Narrow Escape

    ----------------------------------------------------------------
    -- Rogue
    ----------------------------------------------------------------
    [1766]   = 10,   -- Kick
    [2094]   = 120,  -- Blind
    [5277]   = 180,  -- Evasion
    [1856]   = 120,  -- Vanish
    [31224]  = 60,   -- Cloak of Shadows
    [13750]  = 180,  -- Adrenaline Rush
    [51690]  = 120,  -- Killing Spree
    [36554]  = 24,   -- Shadowstep
    [76577]  = 180,  -- Smoke Bomb
    [2983]   = 60,   -- Sprint
    [14185]  = 300,  -- Preparation
    [51722]  = 60,   -- Dismantle
    [51713]  = 60,   -- Shadow Dance
    [79140]  = 120,  -- Vendetta
    [74001]  = 120,  -- Combat Readiness
    [121471] = 180,  -- Shadow Blades
    [137573] = 15,   -- Burst of Speed

    ----------------------------------------------------------------
    -- Priest
    ----------------------------------------------------------------
    [8122]   = 30,   -- Psychic Scream
    [33206]  = 180,  -- Pain Suppression
    [47585]  = 75,   -- Dispersion
    [15487]  = 45,   -- Silence
    [88625]  = 30,   -- Holy Word: Chastise
    [73325]  = 90,   -- Leap of Faith
    [47788]  = 180,  -- Guardian Spirit
    [62618]  = 180,  -- Power Word: Barrier
    [10060]  = 120,  -- Power Infusion
    [34433]  = 180,  -- Shadowfiend
    [6346]   = 30,   -- Fear Ward
    [114908] = 60,   -- Spirit Shell
    [108920] = 30,   -- Void Tendrils
    [123040] = 60,   -- Mindbender
    [108968] = 60,   -- Void Shift
    [64044]  = 45,   -- Psychic Horror

    ----------------------------------------------------------------
    -- Death Knight
    ----------------------------------------------------------------
    [49576]  = 25,   -- Death Grip
    [47476]  = 60,   -- Strangulate
    [108194] = 60,   -- Asphyxiate
    [48707]  = 45,   -- Anti-Magic Shell
    [51052]  = 120,  -- Anti-Magic Zone
    [48792]  = 180,  -- Icebound Fortitude
    [49028]  = 90,   -- Dancing Rune Weapon
    [49206]  = 180,  -- Summon Gargoyle
    [51271]  = 60,   -- Pillar of Frost
    [47568]  = 300,  -- Empower Rune Weapon
    [48743]  = 120,  -- Death Pact
    [77575]  = 60,   -- Outbreak
    [77606]  = 60,   -- Dark Simulacrum
    [43265]  = 30,   -- Death and Decay
    [42650]  = 600,  -- Army of the Dead
    [115989] = 90,   -- Unholy Blight

    ----------------------------------------------------------------
    -- Shaman
    ----------------------------------------------------------------
    [57994]  = 12,   -- Wind Shear
    [51514]  = 45,   -- Hex
    [30823]  = 60,   -- Shamanistic Rage
    [98008]  = 180,  -- Spirit Link Totem
    [16190]  = 180,  -- Mana Tide Totem
    [16166]  = 120,  -- Elemental Mastery
    [51533]  = 120,  -- Feral Spirit
    [79206]  = 120,  -- Spiritwalker's Grace
    [8177]   = 25,   -- Grounding Totem
    [2484]   = 30,   -- Earthbind Totem
    [5394]   = 30,   -- Healing Stream Totem
    [2894]   = 300,  -- Fire Elemental Totem
    [2062]   = 300,  -- Earth Elemental Totem
    [8143]   = 60,   -- Tremor Totem
    [51490]  = 45,   -- Thunderstorm
    [108271] = 90,   -- Astral Shift
    [114049] = 180,  -- Ascendance
    [108281] = 120,  -- Ancestral Guidance
    [118905] = 45,   -- Capacitor Totem

    ----------------------------------------------------------------
    -- Mage
    ----------------------------------------------------------------
    [2139]   = 24,   -- Counterspell
    [45438]  = 300,  -- Ice Block
    [1953]   = 15,   -- Blink
    [122]    = 25,   -- Frost Nova
    [31661]  = 20,   -- Dragon's Breath
    [55342]  = 180,  -- Mirror Image
    [12472]  = 180,  -- Icy Veins
    [12042]  = 90,   -- Arcane Power
    [113724] = 45,   -- Ring of Frost
    [11958]  = 180,  -- Cold Snap
    [44572]  = 30,   -- Deep Freeze
    [11129]  = 45,   -- Combustion
    [66]     = 300,  -- Greater Invisibility / Invisibility
    [80353]  = 300,  -- Time Warp
    [12051]  = 120,  -- Evocation
    [102051] = 20,   -- Frostjaw

    ----------------------------------------------------------------
    -- Warlock
    ----------------------------------------------------------------
    [5484]   = 40,   -- Howl of Terror
    [6789]   = 45,   -- Mortal Coil
    [48020]  = 30,   -- Demonic Circle: Teleport
    [30283]  = 30,   -- Shadowfury
    [89766]  = 30,   -- Axe Toss (Felguard)
    [19647]  = 24,   -- Spell Lock (Felhunter)
    [104773] = 180,  -- Unending Resolve
    [108359] = 120,  -- Dark Regeneration
    [110913] = 180,  -- Dark Bargain
    [113858] = 120,  -- Dark Soul: Instability
    [113860] = 120,  -- Dark Soul: Misery
    [113861] = 120,  -- Dark Soul: Knowledge
    [111397] = 60,   -- Blood Horror
    [118345] = 30,   -- Pulverize (Felguard)

    ----------------------------------------------------------------
    -- Druid
    ----------------------------------------------------------------
    [22812]  = 60,   -- Barkskin
    [5211]   = 50,   -- Mighty Bash
    [106951] = 180,  -- Berserk
    [29166]  = 180,  -- Innervate
    [102793] = 60,   -- Ursol's Vortex
    [102359] = 120,  -- Mass Entanglement
    [61336]  = 180,  -- Survival Instincts
    [740]    = 480,  -- Tranquility
    [78675]  = 60,   -- Solar Beam
    [102543] = 180,  -- Incarnation: King of the Jungle
    [102560] = 180,  -- Incarnation: Chosen of Elune
    [102558] = 180,  -- Incarnation: Son of Ursoc
    [33891]  = 180,  -- Incarnation: Tree of Life
    [48505]  = 60,   -- Starfall
    [18562]  = 15,   -- Swiftmend
    [102342] = 60,   -- Ironbark
    [108238] = 60,   -- Renewal
    [124974] = 90,   -- Nature's Vigil

    ----------------------------------------------------------------
    -- Monk
    ----------------------------------------------------------------
    [116705] = 15,   -- Spear Hand Strike
    [119381] = 60,   -- Leg Sweep
    [115078] = 15,   -- Paralysis
    [115203] = 180,  -- Fortifying Brew
    [116849] = 120,  -- Life Cocoon
    [115176] = 180,  -- Zen Meditation
    [122783] = 90,   -- Diffuse Magic
    [122278] = 90,   -- Dampen Harm
    [115295] = 30,   -- Guard
    [116844] = 45,   -- Ring of Peace
    [123904] = 180,  -- Invoke Xuen, the White Tiger
    [137562] = 60,   -- Energizing Brew
    [113656] = 25,   -- Fists of Fury
    [101545] = 25,   -- Flying Serpent Kick
    [109132] = 20,   -- Roll
    [115399] = 120,  -- Chi Brew
    [119392] = 30,   -- Charging Ox Wave
    [115310] = 180,  -- Revival
    [116680] = 30,   -- Thunder Focus Tea
    [117368] = 60,   -- Grapple Weapon

    ----------------------------------------------------------------
    -- Trinket / Racial
    ----------------------------------------------------------------
    [42292]  = 120,  -- PvP Trinket
    [59752]  = 120,  -- Every Man for Himself (Human)
    [7744]   = 120,  -- Will of the Forsaken (Undead)
    [20594]  = 120,  -- Stoneform (Dwarf)
    [58984]  = 120,  -- Shadowmeld (Night Elf)
    [20589]  = 60,   -- Escape Artist (Gnome)
    [26297]  = 180,  -- Berserking (Troll)
    [33697]  = 120,  -- Blood Fury (Orc)
    [69179]  = 120,  -- Arcane Torrent (Blood Elf)
    [28730]  = 120,  -- Arcane Torrent (Blood Elf, mana)
    [50613]  = 120,  -- Arcane Torrent (Blood Elf, runic power)
    [80483]  = 120,  -- Arcane Torrent (Blood Elf, focus)
    [68992]  = 120,  -- Darkflight (Worgen)
    [107079] = 120,  -- Quaking Palm (Pandaren)
}
