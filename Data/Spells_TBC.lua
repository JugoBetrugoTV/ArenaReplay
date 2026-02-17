local _, AR = ...

------------------------------------------------------------
-- TBC Arena Maps (Burning Crusade Classic 2.4.3)
------------------------------------------------------------
AR.Data.ARENA_MAPS = {
    [0] = "Unknown",
    [1] = "Nagrand Arena",
    [2] = "Ruins of Lordaeron",
    [3] = "Blade's Edge Arena",
}

AR.Data.ARENA_MAP_LOOKUP = {}
for k, v in pairs(AR.Data.ARENA_MAPS) do
    AR.Data.ARENA_MAP_LOOKUP[v] = k
end

------------------------------------------------------------
-- TBC Arena Brackets
------------------------------------------------------------
AR.Data.ARENA_BRACKETS = {
    [2] = "2v2",
    [3] = "3v3",
    [5] = "5v5",
}

------------------------------------------------------------
-- Important skills (CC, defensives, offensives)
-- TBC Classic 2.4.3 spell IDs
-- Type: 1 = buff/silence/disarm, 2 = root, 3 = stun/incapacitate/immunity
------------------------------------------------------------
AR.Data.IMPORTANT_SKILLS = {

    ---------- Crowd Control (Stuns / Incapacitates / Disorients) ----------

    -- Warrior
    [5246]   = 3,  -- Intimidating Shout
    [12809]  = 3,  -- Concussion Blow
    [20253]  = 3,  -- Intercept Stun (Rank 1)
    [20614]  = 3,  -- Intercept Stun (Rank 2)
    [20615]  = 3,  -- Intercept Stun (Rank 3)
    [7922]   = 3,  -- Charge Stun

    -- Paladin
    [853]    = 3,  -- Hammer of Justice (Rank 1)
    [5588]   = 3,  -- Hammer of Justice (Rank 2)
    [5589]   = 3,  -- Hammer of Justice (Rank 3)
    [10308]  = 3,  -- Hammer of Justice (Rank 4)
    [20066]  = 3,  -- Repentance
    [2878]   = 3,  -- Turn Undead (fear effect)
    [10326]  = 3,  -- Turn Evil

    -- Hunter
    [3355]   = 3,  -- Freezing Trap Effect
    [14308]  = 3,  -- Freezing Trap Effect (Rank 2)
    [14309]  = 3,  -- Freezing Trap Effect (Rank 3)
    [19386]  = 3,  -- Wyvern Sting (Rank 1)
    [24132]  = 3,  -- Wyvern Sting (Rank 2)
    [24133]  = 3,  -- Wyvern Sting (Rank 3)
    [27068]  = 3,  -- Wyvern Sting (Rank 4)
    [19503]  = 3,  -- Scatter Shot
    [19577]  = 3,  -- Intimidation
    [24394]  = 3,  -- Intimidation (stun effect)

    -- Rogue
    [1833]   = 3,  -- Cheap Shot
    [408]    = 3,  -- Kidney Shot (Rank 1)
    [8643]   = 3,  -- Kidney Shot (Rank 2)
    [1776]   = 3,  -- Gouge
    [1777]   = 3,  -- Gouge (Rank 2)
    [8629]   = 3,  -- Gouge (Rank 3)
    [11285]  = 3,  -- Gouge (Rank 4)
    [11286]  = 3,  -- Gouge (Rank 5)
    [38764]  = 3,  -- Gouge (Rank 6)
    [2094]   = 3,  -- Blind
    [6770]   = 3,  -- Sap (Rank 1)
    [2070]   = 3,  -- Sap (Rank 2)
    [11297]  = 3,  -- Sap (Rank 3)

    -- Priest
    [8122]   = 3,  -- Psychic Scream (Rank 1)
    [8124]   = 3,  -- Psychic Scream (Rank 2)
    [10888]  = 3,  -- Psychic Scream (Rank 3)
    [10890]  = 3,  -- Psychic Scream (Rank 4)
    [605]    = 3,  -- Mind Control

    -- Mage
    [118]    = 3,  -- Polymorph (Rank 1)
    [12824]  = 3,  -- Polymorph (Rank 2)
    [12825]  = 3,  -- Polymorph (Rank 3)
    [12826]  = 3,  -- Polymorph (Rank 4)
    [28272]  = 3,  -- Polymorph: Pig
    [28271]  = 3,  -- Polymorph: Turtle
    [31661]  = 3,  -- Dragon's Breath (Rank 1)
    [33041]  = 3,  -- Dragon's Breath (Rank 2)
    [33042]  = 3,  -- Dragon's Breath (Rank 3)
    [33043]  = 3,  -- Dragon's Breath (Rank 4)

    -- Warlock
    [5782]   = 3,  -- Fear (Rank 1)
    [6213]   = 3,  -- Fear (Rank 2)
    [6215]   = 3,  -- Fear (Rank 3)
    [5484]   = 3,  -- Howl of Terror (Rank 1)
    [17928]  = 3,  -- Howl of Terror (Rank 2)
    [6358]   = 3,  -- Seduction (Succubus)
    [30283]  = 3,  -- Shadowfury (Rank 1)
    [30413]  = 3,  -- Shadowfury (Rank 2)
    [30414]  = 3,  -- Shadowfury (Rank 3)
    [6789]   = 3,  -- Death Coil (Rank 1)
    [17925]  = 3,  -- Death Coil (Rank 2)
    [17926]  = 3,  -- Death Coil (Rank 3)
    [27223]  = 3,  -- Death Coil (Rank 4)
    [30108]  = 3,  -- Unstable Affliction (silence on dispel)

    -- Shaman
    [39796]  = 3,  -- Stoneclaw Totem Stun

    -- Druid
    [33786]  = 3,  -- Cyclone
    [22570]  = 3,  -- Maim (Rank 1)
    -- Maim only had Rank 1 in TBC
    [5211]   = 3,  -- Bash (Rank 1)
    [6798]   = 3,  -- Bash (Rank 2)
    [8983]   = 3,  -- Bash (Rank 3)
    [9005]   = 3,  -- Pounce (Rank 1)
    [9823]   = 3,  -- Pounce (Rank 2)
    [9827]   = 3,  -- Pounce (Rank 3)
    [27006]  = 3,  -- Pounce (Rank 4)
    [2637]   = 3,  -- Hibernate (Rank 1)
    [18657]  = 3,  -- Hibernate (Rank 2)
    [18658]  = 3,  -- Hibernate (Rank 3)

    ---------- Roots ----------

    -- Druid
    [339]    = 2,  -- Entangling Roots (Rank 1)
    [1062]   = 2,  -- Entangling Roots (Rank 2)
    [5195]   = 2,  -- Entangling Roots (Rank 3)
    [5196]   = 2,  -- Entangling Roots (Rank 4)
    [9852]   = 2,  -- Entangling Roots (Rank 5)
    [9853]   = 2,  -- Entangling Roots (Rank 6)
    [26989]  = 2,  -- Entangling Roots (Rank 7)
    [19975]  = 2,  -- Entangling Roots (Nature's Grasp proc)
    [27010]  = 2,  -- Feral Charge - Bear (root effect)

    -- Mage
    [122]    = 2,  -- Frost Nova (Rank 1)
    [865]    = 2,  -- Frost Nova (Rank 2)
    [6131]   = 2,  -- Frost Nova (Rank 3)
    [10230]  = 2,  -- Frost Nova (Rank 4)
    [27088]  = 2,  -- Frost Nova (Rank 5)
    [33395]  = 2,  -- Freeze (Water Elemental)
    [12494]  = 2,  -- Frostbite (talent proc)

    -- Hunter
    [19185]  = 2,  -- Entrapment (talent proc)
    [4167]   = 2,  -- Web (Spider pet)

    -- Engineering
    [13099]  = 2,  -- Net-o-Matic (net effect)

    ---------- Silences ----------

    -- Priest
    [15487]  = 1,  -- Silence

    -- Rogue
    [1330]   = 1,  -- Garrote - Silence

    -- Mage
    [18469]  = 1,  -- Silenced - Improved Counterspell

    -- Warlock
    [24259]  = 1,  -- Spell Lock (Felhunter silence)

    -- Blood Elf Racial
    [28730]  = 1,  -- Arcane Torrent (silence)

    ---------- Disarms ----------

    -- Warrior
    [676]    = 1,  -- Disarm

    -- Rogue
    [14251]  = 1,  -- Riposte (disarm)

    ---------- Defensive Buffs ----------

    -- Paladin
    [1022]   = 1,  -- Blessing of Protection (Rank 1)
    [5599]   = 1,  -- Blessing of Protection (Rank 2)
    [10278]  = 1,  -- Blessing of Protection (Rank 3)
    [1044]   = 1,  -- Blessing of Freedom
    [6940]   = 1,  -- Blessing of Sacrifice (Rank 1)
    [20729]  = 1,  -- Blessing of Sacrifice (Rank 2)
    [27147]  = 1,  -- Blessing of Sacrifice (Rank 3)
    [27148]  = 1,  -- Blessing of Sacrifice (Rank 4)
    [498]    = 1,  -- Divine Protection (Rank 1)
    [5573]   = 1,  -- Divine Protection (Rank 2)

    -- Priest
    [33206]  = 1,  -- Pain Suppression

    -- Warrior
    [871]    = 1,  -- Shield Wall

    -- Rogue
    [31224]  = 1,  -- Cloak of Shadows
    [5277]   = 1,  -- Evasion (Rank 1)
    [26669]  = 1,  -- Evasion (Rank 2)

    -- Hunter
    [19263]  = 1,  -- Deterrence
    [34471]  = 1,  -- The Beast Within

    -- Mage
    [11958]  = 1,  -- Cold Snap (not a buff, but resets CDs)

    -- Shaman
    [30823]  = 1,  -- Shamanistic Rage

    -- Druid
    [22812]  = 1,  -- Barkskin
    [22842]  = 1,  -- Frenzied Regeneration (Rank 1)
    [22895]  = 1,  -- Frenzied Regeneration (Rank 2)
    [22896]  = 1,  -- Frenzied Regeneration (Rank 3)
    [26999]  = 1,  -- Frenzied Regeneration (Rank 4)

    -- Warlock
    [7812]   = 1,  -- Sacrifice (Voidwalker)

    ---------- Immunities ----------

    -- Mage
    [45438]  = 3,  -- Ice Block

    -- Paladin
    [642]    = 3,  -- Divine Shield
    [1020]   = 3,  -- Divine Shield (Rank 2)

    ---------- Major Offensive CDs ----------

    -- Paladin
    [31884]  = 1,  -- Avenging Wrath

    -- Mage
    [12472]  = 1,  -- Icy Veins
    [12042]  = 1,  -- Arcane Power

    -- Warrior
    [1719]   = 1,  -- Recklessness
    [12292]  = 1,  -- Death Wish

    -- Rogue
    [13750]  = 1,  -- Adrenaline Rush
    [13877]  = 1,  -- Blade Flurry

    -- Hunter
    [19574]  = 1,  -- Bestial Wrath
    [3045]   = 1,  -- Rapid Fire

    -- Priest
    [10060]  = 1,  -- Power Infusion
    [15286]  = 1,  -- Vampiric Embrace
    [34433]  = 1,  -- Shadowfiend

    -- Shaman
    [16166]  = 1,  -- Elemental Mastery
    [2825]   = 1,  -- Bloodlust
    [32182]  = 1,  -- Heroism

    -- Warlock
    [18708]  = 1,  -- Fel Domination

    -- Druid
    [29166]  = 1,  -- Innervate
    [17116]  = 1,  -- Nature's Swiftness (Druid)
    [16188]  = 1,  -- Nature's Swiftness (Shaman)
}

------------------------------------------------------------
-- Cooldown durations (seconds) for tracking
-- TBC Classic 2.4.3 values
------------------------------------------------------------
AR.Data.COOLDOWN_SPELLS = {

    -- Warrior
    [6552]   = 10,   -- Pummel
    [72]     = 12,   -- Shield Bash
    [5246]   = 120,  -- Intimidating Shout
    [871]    = 300,  -- Shield Wall
    [18499]  = 30,   -- Berserker Rage
    [1719]   = 300,  -- Recklessness
    [23920]  = 10,   -- Spell Reflection
    [12809]  = 45,   -- Concussion Blow
    [12292]  = 180,  -- Death Wish
    [12975]  = 480,  -- Last Stand
    [676]    = 60,   -- Disarm
    [20230]  = 300,  -- Retaliation
    [2565]   = 60,   -- Shield Block
    [3411]   = 30,   -- Intervene
    [20252]  = 30,   -- Intercept
    [100]    = 15,   -- Charge

    -- Paladin
    [853]    = 60,   -- Hammer of Justice (Rank 1)
    [10308]  = 60,   -- Hammer of Justice (Rank 4)
    [642]    = 300,  -- Divine Shield
    [1022]   = 300,  -- Blessing of Protection (Rank 1)
    [10278]  = 300,  -- Blessing of Protection (Rank 3)
    [1044]   = 25,   -- Blessing of Freedom
    [6940]   = 30,   -- Blessing of Sacrifice
    [31884]  = 180,  -- Avenging Wrath
    [498]    = 300,  -- Divine Protection
    [20066]  = 60,   -- Repentance
    [31842]  = 180,  -- Divine Illumination
    [20216]  = 120,  -- Divine Favor
    [10326]  = 30,   -- Turn Evil
    [31789]  = 8,    -- Righteous Defense
    [19752]  = 1800, -- Divine Intervention

    -- Hunter
    [781]    = 25,   -- Disengage
    [19263]  = 300,  -- Deterrence
    [19574]  = 120,  -- Bestial Wrath
    [34471]  = 120,  -- The Beast Within
    [19503]  = 30,   -- Scatter Shot
    [34490]  = 20,   -- Silencing Shot
    [14311]  = 30,   -- Freezing Trap (Rank 3)
    [19386]  = 120,  -- Wyvern Sting
    [19577]  = 60,   -- Intimidation
    [3045]   = 300,  -- Rapid Fire
    [23989]  = 300,  -- Readiness
    [5384]   = 30,   -- Feign Death
    [1543]   = 20,   -- Flare
    [13809]  = 30,   -- Frost Trap
    [34600]  = 30,   -- Snake Trap
    [3034]   = 15,   -- Viper Sting

    -- Rogue
    [1766]   = 10,   -- Kick
    [2094]   = 180,  -- Blind
    [5277]   = 300,  -- Evasion (Rank 1)
    [26669]  = 300,  -- Evasion (Rank 2)
    [1856]   = 300,  -- Vanish (Rank 1)
    [26889]  = 300,  -- Vanish (Rank 2)
    [31224]  = 60,   -- Cloak of Shadows
    [13750]  = 300,  -- Adrenaline Rush
    [13877]  = 120,  -- Blade Flurry
    [36554]  = 30,   -- Shadowstep
    [14177]  = 180,  -- Cold Blood
    [2983]   = 300,  -- Sprint (Rank 1)
    [8696]   = 300,  -- Sprint (Rank 2)
    [11305]  = 300,  -- Sprint (Rank 3)
    [14185]  = 300,  -- Preparation
    [1725]   = 30,   -- Distract

    -- Priest
    [8122]   = 30,   -- Psychic Scream (Rank 1)
    [10890]  = 30,   -- Psychic Scream (Rank 4)
    [33206]  = 120,  -- Pain Suppression
    [15487]  = 45,   -- Silence
    [10060]  = 180,  -- Power Infusion
    [34433]  = 300,  -- Shadowfiend
    [15286]  = 10,   -- Vampiric Embrace
    [32379]  = 10,   -- Shadow Word: Death (Rank 1)
    [6346]   = 180,  -- Fear Ward
    [586]    = 30,   -- Fade
    [14751]  = 180,  -- Inner Focus

    -- Shaman
    [16188]  = 180,  -- Nature's Swiftness
    [8042]   = 6,    -- Earth Shock (interrupt)
    [30823]  = 120,  -- Shamanistic Rage
    [16166]  = 180,  -- Elemental Mastery
    [2825]   = 600,  -- Bloodlust
    [32182]  = 600,  -- Heroism
    [16190]  = 300,  -- Mana Tide Totem
    [8177]   = 15,   -- Grounding Totem
    [8143]   = 15,   -- Tremor Totem
    [2484]   = 15,   -- Earthbind Totem
    [8184]   = 15,   -- Fire Resistance Totem
    [8190]   = 20,   -- Magma Totem
    [3738]   = 120,  -- Wrath of Air Totem
    [25908]  = 120,  -- Tranquil Air Totem
    [20608]  = 3600, -- Reincarnation

    -- Mage
    [2139]   = 24,   -- Counterspell
    [45438]  = 300,  -- Ice Block
    [1953]   = 15,   -- Blink
    [122]    = 25,   -- Frost Nova (Rank 1)
    [27088]  = 25,   -- Frost Nova (Rank 5)
    [31661]  = 20,   -- Dragon's Breath (Rank 1)
    [33043]  = 20,   -- Dragon's Breath (Rank 4)
    [12472]  = 180,  -- Icy Veins
    [12042]  = 180,  -- Arcane Power
    [11958]  = 480,  -- Cold Snap
    [12051]  = 480,  -- Evocation
    [12043]  = 180,  -- Presence of Mind
    [31687]  = 180,  -- Summon Water Elemental
    [2136]   = 8,    -- Fire Blast (Rank 1)
    [10199]  = 8,    -- Fire Blast (Rank 9)

    -- Warlock
    [5484]   = 40,   -- Howl of Terror (Rank 1)
    [17928]  = 40,   -- Howl of Terror (Rank 2)
    [6789]   = 120,  -- Death Coil (Rank 1)
    [27223]  = 120,  -- Death Coil (Rank 4)
    [30283]  = 20,   -- Shadowfury (Rank 1)
    [30414]  = 20,   -- Shadowfury (Rank 3)
    [18708]  = 900,  -- Fel Domination
    [19647]  = 24,   -- Spell Lock (Felhunter)
    [7812]   = 1800, -- Sacrifice (Voidwalker)
    [18288]  = 180,  -- Amplify Curse
    [29858]  = 180,  -- Soulshatter
    [698]    = 300,  -- Ritual of Summoning
    [29893]  = 300,  -- Ritual of Souls
    [18540]  = 1800, -- Ritual of Doom

    -- Druid
    [22812]  = 60,   -- Barkskin
    [5211]   = 60,   -- Bash (Rank 1)
    [8983]   = 60,   -- Bash (Rank 3)
    [29166]  = 360,  -- Innervate
    [17116]  = 180,  -- Nature's Swiftness
    [33786]  = 6,    -- Cyclone
    [33831]  = 180,  -- Force of Nature (Treants)
    [22842]  = 180,  -- Frenzied Regeneration (Rank 1)
    [26999]  = 180,  -- Frenzied Regeneration (Rank 4)
    [16689]  = 60,   -- Nature's Grasp
    [18562]  = 15,   -- Swiftmend
    [740]    = 480,  -- Tranquility
    [5229]   = 60,   -- Enrage
    [16979]  = 15,   -- Feral Charge - Bear

    -- Trinket / Racial
    [42292]  = 120,  -- PvP Trinket (Medallion of the Alliance/Horde)
    [20600]  = 120,  -- Perception (Human)
    [20594]  = 180,  -- Stoneform (Dwarf)
    [20589]  = 120,  -- Escape Artist (Gnome)
    [7744]   = 120,  -- Will of the Forsaken
    [20572]  = 120,  -- Blood Fury (Orc)
    [26297]  = 180,  -- Berserking (Troll)
    [20549]  = 120,  -- War Stomp (Tauren)
    [28730]  = 120,  -- Arcane Torrent (Blood Elf)
    [28734]  = 120,  -- Mana Tap (Blood Elf)
    [20580]  = 10,   -- Shadowmeld (Night Elf)
    [28880]  = 180,  -- Gift of the Naaru (Draenei)
}
