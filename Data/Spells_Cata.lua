local _, AR = ...

------------------------------------------------------------
-- Arena map IDs (Cataclysm 4.3.4)
------------------------------------------------------------
AR.Data.ARENA_MAPS = {
    [0] = "Unknown",
    [1] = "Nagrand Arena",
    [2] = "Blade's Edge Arena",
    [3] = "Ruins of Lordaeron",
    [4] = "Dalaran Arena",
    [5] = "Tol'viron Arena",
}

-- Reverse lookup: zone name -> map ID
AR.Data.ARENA_MAP_LOOKUP = {}
for k, v in pairs(AR.Data.ARENA_MAPS) do
    AR.Data.ARENA_MAP_LOOKUP[v] = k
end

------------------------------------------------------------
-- Bracket types (Cataclysm)
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
-- Cataclysm 4.3.4 spell IDs
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
    [5211]   = 3,  -- Bash (Druid)
    [22570]  = 3,  -- Maim (Druid)
    [46968]  = 3,  -- Shockwave (Warrior)
    [20549]  = 3,  -- War Stomp (Racial)
    [91800]  = 3,  -- Gnaw (DK Ghoul)
    [91797]  = 3,  -- Monstrous Blow (DK Ghoul, Dark Transformation)
    [89766]  = 3,  -- Axe Toss (Warlock Felguard)
    [19577]  = 3,  -- Intimidation (Hunter)
    [56626]  = 3,  -- Sting (Wasp pet)
    [50519]  = 3,  -- Sonic Blast (Bat pet)
    [64044]  = 3,  -- Psychic Horror (Priest)

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
    [19503]  = 3,  -- Scatter Shot (Hunter)
    [51514]  = 3,  -- Hex (Shaman)
    [33786]  = 3,  -- Cyclone (Druid)
    [99]     = 3,  -- Incapacitating Roar (Druid)
    [9484]   = 3,  -- Shackle Undead (Priest)
    [605]    = 3,  -- Dominate Mind (Priest)
    [88625]  = 3,  -- Holy Word: Chastise (Priest)
    [82691]  = 3,  -- Ring of Frost (Mage)
    [31661]  = 3,  -- Dragon's Breath (Mage)
    [710]    = 3,  -- Banish (Warlock)

    ----------------------------------------------------------------
    -- Fears
    ----------------------------------------------------------------
    [5246]   = 3,  -- Intimidating Shout (Warrior)
    [8122]   = 3,  -- Psychic Scream (Priest)
    [5484]   = 3,  -- Howl of Terror (Warlock)
    [5782]   = 3,  -- Fear (Warlock)
    [6358]   = 3,  -- Seduction (Warlock Succubus)
    [6789]   = 3,  -- Death Coil (Warlock)

    ----------------------------------------------------------------
    -- Roots
    ----------------------------------------------------------------
    [339]    = 2,  -- Entangling Roots (Druid)
    [19975]  = 2,  -- Entangling Roots (Nature's Grasp proc)
    [122]    = 2,  -- Frost Nova (Mage)
    [33395]  = 2,  -- Freeze (Mage Water Elemental)
    [64695]  = 2,  -- Earthgrab (Shaman Earthbind talent)
    [16979]  = 2,  -- Feral Charge - Bear (root effect)
    [4167]   = 2,  -- Web (Spider pet)
    [50245]  = 2,  -- Pin (Crab pet)
    [54706]  = 2,  -- Venom Web Spray (Silithid pet)
    [96294]  = 2,  -- Chains of Ice (root from Chilblains)

    ----------------------------------------------------------------
    -- Silences
    ----------------------------------------------------------------
    [15487]  = 1,  -- Silence (Priest)
    [47476]  = 1,  -- Strangulate (Death Knight)
    [1330]   = 1,  -- Garrote - Silence (Rogue)
    [78675]  = 1,  -- Solar Beam (Druid)
    [55021]  = 1,  -- Improved Counterspell (Mage)
    [18498]  = 1,  -- Improved Shield Bash (Warrior) -- Gag Order silence
    [34490]  = 1,  -- Silencing Shot (Hunter)
    [24259]  = 1,  -- Spell Lock (Warlock Felhunter)

    ----------------------------------------------------------------
    -- Disarms
    ----------------------------------------------------------------
    [676]    = 1,  -- Disarm (Warrior)
    [51722]  = 1,  -- Dismantle (Rogue)
    [64058]  = 1,  -- Psychic Horror (Priest, disarm component)

    ----------------------------------------------------------------
    -- Defensive Buffs
    ----------------------------------------------------------------
    [1022]   = 1,  -- Hand of Protection (Paladin)
    [1044]   = 1,  -- Hand of Freedom (Paladin)
    [6940]   = 1,  -- Hand of Sacrifice (Paladin)
    [64205]  = 1,  -- Divine Sacrifice (Paladin)
    [498]    = 1,  -- Divine Protection (Paladin)
    [31821]  = 1,  -- Aura Mastery (Paladin)
    [33206]  = 1,  -- Pain Suppression (Priest)
    [47788]  = 1,  -- Guardian Spirit (Priest)
    [47585]  = 1,  -- Dispersion (Priest)
    [871]    = 1,  -- Shield Wall (Warrior)
    [12975]  = 1,  -- Last Stand (Warrior)
    [55694]  = 1,  -- Enraged Regeneration (Warrior)
    [48707]  = 1,  -- Anti-Magic Shell (Death Knight)
    [51052]  = 1,  -- Anti-Magic Zone (Death Knight)
    [48792]  = 1,  -- Icebound Fortitude (Death Knight)
    [49039]  = 1,  -- Lichborne (Death Knight)
    [48743]  = 1,  -- Death Pact (Death Knight)
    [31224]  = 1,  -- Cloak of Shadows (Rogue)
    [5277]   = 1,  -- Evasion (Rogue)
    [74001]  = 1,  -- Combat Readiness (Rogue)
    [19263]  = 1,  -- Deterrence (Hunter)
    [53480]  = 1,  -- Roar of Sacrifice (Hunter pet)
    [22812]  = 1,  -- Barkskin (Druid)
    [61336]  = 1,  -- Survival Instincts (Druid)
    [30823]  = 1,  -- Shamanistic Rage (Shaman)
    [98008]  = 1,  -- Spirit Link Totem (Shaman)

    ----------------------------------------------------------------
    -- Immunities
    ----------------------------------------------------------------
    [45438]  = 3,  -- Ice Block (Mage)
    [642]    = 3,  -- Divine Shield (Paladin)

    ----------------------------------------------------------------
    -- Major Offensive CDs
    ----------------------------------------------------------------
    [31884]  = 1,  -- Avenging Wrath (Paladin)
    [85696]  = 1,  -- Zealotry (Paladin)
    [12472]  = 1,  -- Icy Veins (Mage)
    [12042]  = 1,  -- Arcane Power (Mage)
    [1719]   = 1,  -- Recklessness (Warrior)
    [85730]  = 1,  -- Deadly Calm (Warrior)
    [13750]  = 1,  -- Adrenaline Rush (Rogue)
    [51690]  = 1,  -- Killing Spree (Rogue)
    [51713]  = 1,  -- Shadow Dance (Rogue)
    [79140]  = 1,  -- Vendetta (Rogue)
    [51271]  = 1,  -- Pillar of Frost (Death Knight)
    [49206]  = 1,  -- Summon Gargoyle (Death Knight)
    [19574]  = 1,  -- Bestial Wrath (Hunter)
    [3045]   = 1,  -- Rapid Fire (Hunter)
    [82692]  = 1,  -- Focus Fire (Hunter)
    [16166]  = 1,  -- Elemental Mastery (Shaman)
    [51533]  = 1,  -- Feral Spirit (Shaman)
    [50334]  = 1,  -- Berserk (Druid)
    [33891]  = 1,  -- Tree of Life (Druid)
    [10060]  = 1,  -- Power Infusion (Priest)
    [34433]  = 1,  -- Shadowfiend (Priest)
    [89485]  = 1,  -- Inner Focus (Priest)
}

------------------------------------------------------------
-- Cooldown durations (seconds) for tracking
-- Cataclysm 4.3.4 spell IDs and cooldowns
------------------------------------------------------------
AR.Data.COOLDOWN_SPELLS = {

    ----------------------------------------------------------------
    -- Warrior
    ----------------------------------------------------------------
    [6552]   = 10,   -- Pummel
    [5246]   = 120,  -- Intimidating Shout
    [871]    = 300,  -- Shield Wall
    [12975]  = 180,  -- Last Stand
    [1719]   = 300,  -- Recklessness
    [18499]  = 30,   -- Berserker Rage
    [23920]  = 25,   -- Spell Reflection
    [46968]  = 20,   -- Shockwave
    [46924]  = 90,   -- Bladestorm
    [3411]   = 30,   -- Intervene
    [676]    = 60,   -- Disarm
    [55694]  = 180,  -- Enraged Regeneration
    [85730]  = 120,  -- Deadly Calm
    [2457]   = 6,    -- Battle Stance (GCD)
    [97462]  = 180,  -- Rallying Cry
    [85388]  = 45,   -- Throwdown
    [60970]  = 45,   -- Heroic Fury

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
    [20066]  = 60,   -- Repentance
    [96231]  = 10,   -- Rebuke
    [31821]  = 120,  -- Aura Mastery
    [85696]  = 120,  -- Zealotry
    [86150]  = 120,  -- Guardian of Ancient Kings
    [54428]  = 60,   -- Divine Plea
    [64205]  = 120,  -- Divine Sacrifice
    [31842]  = 180,  -- Divine Favor

    ----------------------------------------------------------------
    -- Hunter
    ----------------------------------------------------------------
    [781]    = 16,   -- Disengage
    [19263]  = 120,  -- Deterrence
    [19574]  = 100,  -- Bestial Wrath
    [53480]  = 60,   -- Roar of Sacrifice
    [19386]  = 60,   -- Wyvern Sting
    [19503]  = 30,   -- Scatter Shot
    [34490]  = 20,   -- Silencing Shot
    [3045]   = 300,  -- Rapid Fire
    [23989]  = 180,  -- Readiness
    [19577]  = 60,   -- Intimidation
    [34600]  = 30,   -- Snake Trap
    [60192]  = 30,   -- Freezing Trap (Trap Launcher)
    [82726]  = 120,  -- Fervor
    [82692]  = 120,  -- Focus Fire
    [53351]  = 10,   -- Kill Shot
    [82939]  = 30,   -- Explosive Trap

    ----------------------------------------------------------------
    -- Rogue
    ----------------------------------------------------------------
    [1766]   = 10,   -- Kick
    [2094]   = 180,  -- Blind
    [5277]   = 180,  -- Evasion
    [1856]   = 180,  -- Vanish
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
    [14177]  = 180,  -- Cold Blood

    ----------------------------------------------------------------
    -- Priest
    ----------------------------------------------------------------
    [8122]   = 30,   -- Psychic Scream
    [33206]  = 180,  -- Pain Suppression
    [47585]  = 75,   -- Dispersion
    [15487]  = 45,   -- Silence
    [64044]  = 120,  -- Psychic Horror
    [88625]  = 30,   -- Holy Word: Chastise
    [73325]  = 90,   -- Leap of Faith
    [47788]  = 180,  -- Guardian Spirit
    [62618]  = 180,  -- Power Word: Barrier
    [10060]  = 120,  -- Power Infusion
    [34433]  = 300,  -- Shadowfiend
    [89485]  = 45,   -- Inner Focus
    [6346]   = 180,  -- Fear Ward
    [87151]  = 60,   -- Archangel
    [14751]  = 180,  -- Chakra
    [89766]  = 30,   -- Desperate Prayer

    ----------------------------------------------------------------
    -- Death Knight
    ----------------------------------------------------------------
    [49576]  = 25,   -- Death Grip
    [47476]  = 120,  -- Strangulate
    [48707]  = 45,   -- Anti-Magic Shell
    [51052]  = 120,  -- Anti-Magic Zone
    [48792]  = 180,  -- Icebound Fortitude
    [49028]  = 90,   -- Dancing Rune Weapon
    [49206]  = 180,  -- Summon Gargoyle
    [51271]  = 60,   -- Pillar of Frost
    [47568]  = 300,  -- Empower Rune Weapon
    [49039]  = 120,  -- Lichborne
    [48743]  = 120,  -- Death Pact
    [77575]  = 60,   -- Outbreak
    [77606]  = 60,   -- Dark Simulacrum
    [43265]  = 30,   -- Death and Decay
    [42650]  = 600,  -- Army of the Dead

    ----------------------------------------------------------------
    -- Shaman
    ----------------------------------------------------------------
    [57994]  = 6,    -- Wind Shear
    [51514]  = 45,   -- Hex
    [30823]  = 60,   -- Shamanistic Rage
    [98008]  = 180,  -- Spirit Link Totem
    [16190]  = 180,  -- Mana Tide Totem
    [16166]  = 180,  -- Elemental Mastery
    [51533]  = 120,  -- Feral Spirit
    [79206]  = 120,  -- Spiritwalker's Grace
    [8177]   = 25,   -- Grounding Totem
    [51485]  = 30,   -- Earthgrab Totem
    [2484]   = 30,   -- Earthbind Totem
    [5394]   = 30,   -- Healing Stream Totem
    [2894]   = 300,  -- Fire Elemental Totem
    [2062]   = 300,  -- Earth Elemental Totem
    [8143]   = 60,   -- Tremor Totem
    [51490]  = 45,   -- Thunderstorm
    [16188]  = 180,  -- Nature's Swiftness (Shaman)
    [58875]  = 60,   -- Spirit Walk (Enhancement)

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
    [12042]  = 120,  -- Arcane Power
    [82731]  = 45,   -- Ring of Frost
    [12043]  = 480,  -- Presence of Mind
    [11958]  = 480,  -- Cold Snap
    [44572]  = 30,   -- Deep Freeze
    [11129]  = 120,  -- Combustion
    [66]     = 300,  -- Invisibility
    [80353]  = 300,  -- Time Warp
    [12051]  = 120,  -- Evocation

    ----------------------------------------------------------------
    -- Warlock
    ----------------------------------------------------------------
    [5484]   = 40,   -- Howl of Terror
    [6789]   = 120,  -- Death Coil
    [48020]  = 30,   -- Demonic Circle: Teleport
    [30283]  = 20,   -- Shadowfury
    [89766]  = 30,   -- Axe Toss (Felguard)
    [19647]  = 24,   -- Spell Lock (Felhunter)
    [79268]  = 120,  -- Soul Harvest
    [29858]  = 180,  -- Soulshatter
    [47241]  = 180,  -- Metamorphosis (Demonology)
    [18708]  = 900,  -- Fel Domination
    [50589]  = 30,   -- Immolation Aura (Demo Meta)
    [6229]   = 30,   -- Shadow Ward
    [47986]  = 120,  -- Sacrifice (Voidwalker)
    [74434]  = 120,  -- Soulburn
    [77801]  = 120,  -- Demon Soul

    ----------------------------------------------------------------
    -- Druid
    ----------------------------------------------------------------
    [22812]  = 60,   -- Barkskin
    [5211]   = 60,   -- Bash
    [50334]  = 180,  -- Berserk
    [29166]  = 180,  -- Innervate
    [17116]  = 180,  -- Nature's Swiftness (Druid)
    [77761]  = 120,  -- Stampeding Roar (Bear)
    [77764]  = 120,  -- Stampeding Roar (Cat)
    [61336]  = 180,  -- Survival Instincts
    [740]    = 480,  -- Tranquility
    [78675]  = 60,   -- Solar Beam
    [33831]  = 180,  -- Force of Nature (Treants)
    [33891]  = 180,  -- Tree of Life
    [48505]  = 60,   -- Starfall
    [18562]  = 15,   -- Swiftmend
    [16689]  = 60,   -- Nature's Grasp
    [22842]  = 180,  -- Frenzied Regeneration
    [5229]   = 60,   -- Enrage (Bear)

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
    [33697]  = 180,  -- Blood Fury (Orc)
    [69179]  = 120,  -- Arcane Torrent (Blood Elf, focus/runic power)
    [28730]  = 120,  -- Arcane Torrent (Blood Elf, mana)
    [50613]  = 120,  -- Arcane Torrent (Blood Elf, runic power)
    [80483]  = 120,  -- Arcane Torrent (Blood Elf, focus)
    [68992]  = 120,  -- Darkflight (Worgen)
}
