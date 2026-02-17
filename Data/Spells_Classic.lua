local _, AR = ...

------------------------------------------------------------
-- Classic Era Spell Data (Vanilla 1.12 / Classic 1.15 / SoD)
-- Classic has no arenas; data useful for BG PvP recording
------------------------------------------------------------

------------------------------------------------------------
-- Arena Maps: Classic has no arenas
------------------------------------------------------------
AR.Data.ARENA_MAPS = {
    [0] = "Unknown",
}

AR.Data.ARENA_MAP_LOOKUP = {}
for k, v in pairs(AR.Data.ARENA_MAPS) do
    AR.Data.ARENA_MAP_LOOKUP[v] = k
end

------------------------------------------------------------
-- Important skills (CC, defensives, offensives)
-- Classic Era (Vanilla / 1.12 / 1.15 spell IDs)
-- Type: 1 = buff/silence/disarm, 2 = root, 3 = stun/incapacitate/immunity
--
-- Classes: Warrior, Paladin, Hunter, Rogue, Priest,
--          Shaman, Mage, Warlock, Druid
------------------------------------------------------------
AR.Data.IMPORTANT_SKILLS = {

    ------------------------------------
    -- Crowd Control: Stuns / Incapacitates / Disorients
    ------------------------------------

    -- Warrior
    [5246]   = 3,  -- Intimidating Shout
    [12809]  = 3,  -- Concussion Blow
    [20253]  = 3,  -- Intercept Stun (Rank 1)
    [20614]  = 3,  -- Intercept Stun (Rank 2)
    [20615]  = 3,  -- Intercept Stun (Rank 3)

    -- Paladin
    [853]    = 3,  -- Hammer of Justice (Rank 1)
    [5588]   = 3,  -- Hammer of Justice (Rank 2)
    [5589]   = 3,  -- Hammer of Justice (Rank 3)
    [10308]  = 3,  -- Hammer of Justice (Rank 4)
    [20066]  = 3,  -- Repentance

    -- Hunter
    [3355]   = 3,  -- Freezing Trap Effect
    [14308]  = 3,  -- Freezing Trap Effect (Rank 2)
    [14309]  = 3,  -- Freezing Trap Effect (Rank 3)
    [19386]  = 3,  -- Wyvern Sting (Rank 1)
    [24132]  = 3,  -- Wyvern Sting (Rank 2)
    [24133]  = 3,  -- Wyvern Sting (Rank 3)
    [19503]  = 3,  -- Scatter Shot
    [19577]  = 3,  -- Intimidation (stun)
    [24394]  = 3,  -- Intimidation (stun effect)

    -- Rogue
    [1833]   = 3,  -- Cheap Shot
    [408]    = 3,  -- Kidney Shot (Rank 1)
    [8643]   = 3,  -- Kidney Shot (Rank 2)
    [1776]   = 3,  -- Gouge (Rank 1)
    [1777]   = 3,  -- Gouge (Rank 2)
    [8629]   = 3,  -- Gouge (Rank 3)
    [11285]  = 3,  -- Gouge (Rank 4)
    [11286]  = 3,  -- Gouge (Rank 5)
    [2094]   = 3,  -- Blind
    [6770]   = 3,  -- Sap (Rank 1)
    [2070]   = 3,  -- Sap (Rank 2)
    [11297]  = 3,  -- Sap (Rank 3)

    -- Priest
    [8122]   = 3,  -- Psychic Scream (Rank 1)
    [8124]   = 3,  -- Psychic Scream (Rank 2)
    [10888]  = 3,  -- Psychic Scream (Rank 3)
    [10890]  = 3,  -- Psychic Scream (Rank 4)
    [15487]  = 3,  -- Silence (actually a silence, re-typed below)
    [605]    = 3,  -- Mind Control (Rank 1)
    [10911]  = 3,  -- Mind Control (Rank 2)
    [10912]  = 3,  -- Mind Control (Rank 3)

    -- Shaman
    -- (Shaman had no hard CC stuns in Vanilla)

    -- Mage
    [118]    = 3,  -- Polymorph (Rank 1)
    [12824]  = 3,  -- Polymorph (Rank 2)
    [12825]  = 3,  -- Polymorph (Rank 3)
    [12826]  = 3,  -- Polymorph (Rank 4)
    [28272]  = 3,  -- Polymorph: Pig
    [28271]  = 3,  -- Polymorph: Turtle

    -- Warlock
    [5782]   = 3,  -- Fear (Rank 1)
    [6213]   = 3,  -- Fear (Rank 2)
    [6215]   = 3,  -- Fear (Rank 3)
    [5484]   = 3,  -- Howl of Terror (Rank 1)
    [17928]  = 3,  -- Howl of Terror (Rank 2)
    [6358]   = 3,  -- Seduction (Succubus)
    [6789]   = 3,  -- Death Coil (Rank 1)
    [17925]  = 3,  -- Death Coil (Rank 2)
    [17926]  = 3,  -- Death Coil (Rank 3)
    [30283]  = 3,  -- Shadowfury (Rank 1)  -- TBC talent backported in some Classic; included for SoD

    -- Druid
    [5211]   = 3,  -- Bash (Rank 1)
    [6798]   = 3,  -- Bash (Rank 2)
    [8983]   = 3,  -- Bash (Rank 3)
    [22570]  = 3,  -- Maim (added in later Classic patches / SoD)
    [2637]   = 3,  -- Hibernate (Rank 1)
    [18657]  = 3,  -- Hibernate (Rank 2)
    [18658]  = 3,  -- Hibernate (Rank 3)
    [9005]   = 3,  -- Pounce (Rank 1)
    [9823]   = 3,  -- Pounce (Rank 2)
    [9827]   = 3,  -- Pounce (Rank 3)

    ------------------------------------
    -- Roots
    ------------------------------------

    -- Druid
    [339]    = 2,  -- Entangling Roots (Rank 1)
    [1062]   = 2,  -- Entangling Roots (Rank 2)
    [5195]   = 2,  -- Entangling Roots (Rank 3)
    [5196]   = 2,  -- Entangling Roots (Rank 4)
    [9852]   = 2,  -- Entangling Roots (Rank 5)
    [9853]   = 2,  -- Entangling Roots (Rank 6)
    [19975]  = 2,  -- Entangling Roots (Nature's Grasp proc, Rank 1)

    -- Mage
    [122]    = 2,  -- Frost Nova (Rank 1)
    [865]    = 2,  -- Frost Nova (Rank 2)
    [6131]   = 2,  -- Frost Nova (Rank 3)
    [10230]  = 2,  -- Frost Nova (Rank 4)
    [33395]  = 2,  -- Freeze (Water Elemental)

    -- Hunter
    [19229]  = 2,  -- Improved Wing Clip (root proc)
    [19185]  = 2,  -- Entrapment (root proc)

    -- Engineering
    [13099]  = 2,  -- Net-o-Matic (root)

    ------------------------------------
    -- Silences
    ------------------------------------

    [15487]  = 1,  -- Silence (Priest)
    [18469]  = 1,  -- Improved Counterspell (Mage silence effect)
    [18425]  = 1,  -- Improved Kick (Rogue silence effect)
    [24259]  = 1,  -- Spell Lock (Felhunter, silence effect)

    ------------------------------------
    -- Disarms
    ------------------------------------
    [676]    = 1,  -- Disarm (Warrior)

    ------------------------------------
    -- Defensive Buffs / Major Defensives
    ------------------------------------

    -- Warrior
    [871]    = 1,  -- Shield Wall
    [12975]  = 1,  -- Last Stand
    [20230]  = 1,  -- Retaliation

    -- Paladin
    [498]    = 1,  -- Divine Protection
    [1020]   = 1,  -- Divine Shield (Rank 1, old ID)
    [642]    = 1,  -- Divine Shield (Rank 2)
    [1022]   = 1,  -- Blessing of Protection (Rank 1)
    [5599]   = 1,  -- Blessing of Protection (Rank 2)
    [10278]  = 1,  -- Blessing of Protection (Rank 3)
    [1044]   = 1,  -- Blessing of Freedom
    [6940]   = 1,  -- Blessing of Sacrifice (Rank 1)
    [20729]  = 1,  -- Blessing of Sacrifice (Rank 2)

    -- Hunter
    [19263]  = 1,  -- Deterrence
    [5384]   = 1,  -- Feign Death

    -- Rogue
    [5277]   = 1,  -- Evasion
    [31224]  = 1,  -- Cloak of Shadows (added in TBC, included for SoD)

    -- Priest
    [33206]  = 1,  -- Pain Suppression (TBC talent, included for SoD)
    [15286]  = 1,  -- Vampiric Embrace
    [6346]   = 1,  -- Fear Ward
    [27827]  = 1,  -- Spirit of Redemption (passive on death)

    -- Shaman
    [16188]  = 1,  -- Nature's Swiftness (Shaman)
    [16166]  = 1,  -- Elemental Mastery

    -- Mage
    [11958]  = 1,  -- Cold Snap
    [12043]  = 1,  -- Presence of Mind
    [12042]  = 1,  -- Arcane Power
    [12472]  = 1,  -- Icy Veins (late Classic / SoD)

    -- Warlock
    [7812]   = 1,  -- Sacrifice (Voidwalker, Rank 1)
    [19438]  = 1,  -- Sacrifice (Voidwalker, Rank 2)
    [19440]  = 1,  -- Sacrifice (Voidwalker, Rank 3)
    [19441]  = 1,  -- Sacrifice (Voidwalker, Rank 4)
    [19442]  = 1,  -- Sacrifice (Voidwalker, Rank 5)
    [19443]  = 1,  -- Sacrifice (Voidwalker, Rank 6)
    [18708]  = 1,  -- Fel Domination
    [18288]  = 1,  -- Amplify Curse
    [17962]  = 1,  -- Conflagrate (Rank 1)

    -- Druid
    [22812]  = 1,  -- Barkskin
    [17116]  = 1,  -- Nature's Swiftness (Druid)
    [29166]  = 1,  -- Innervate
    [22842]  = 1,  -- Frenzied Regeneration (Rank 1)
    [22895]  = 1,  -- Frenzied Regeneration (Rank 2)
    [22896]  = 1,  -- Frenzied Regeneration (Rank 3)

    ------------------------------------
    -- Immunities
    ------------------------------------
    [45438]  = 3,  -- Ice Block
    [642]    = 3,  -- Divine Shield (Rank 2) -- duplicate intentional: also typed as 3

    ------------------------------------
    -- Major Offensive CDs
    ------------------------------------

    -- Warrior
    [1719]   = 1,  -- Recklessness
    [12292]  = 1,  -- Death Wish
    [12328]  = 1,  -- Sweeping Strikes

    -- Paladin
    [20216]  = 1,  -- Divine Favor
    [20375]  = 1,  -- Seal of Command (included as a key ability)

    -- Hunter
    [19574]  = 1,  -- Bestial Wrath
    [3045]   = 1,  -- Rapid Fire

    -- Rogue
    [13750]  = 1,  -- Adrenaline Rush
    [13877]  = 1,  -- Blade Flurry
    [14177]  = 1,  -- Cold Blood
    [14185]  = 1,  -- Preparation

    -- Priest
    [10060]  = 1,  -- Power Infusion
    [15473]  = 1,  -- Shadowform

    -- Shaman
    [16166]  = 1,  -- Elemental Mastery (also listed above as defensive; dual-purpose)

    -- Mage
    [11129]  = 1,  -- Combustion
    [12042]  = 1,  -- Arcane Power (also listed above)
    [12043]  = 1,  -- Presence of Mind (also listed above)

    -- Warlock
    [18094]  = 1,  -- Nightfall (proc buff)
    [17877]  = 1,  -- Shadowburn (Rank 1 at high level)

    -- Druid
    -- (Tiger's Fury / Berserk not in Vanilla)
}

------------------------------------------------------------
-- Cooldown durations (seconds) for tracking
-- Classic Era (Vanilla / 1.12 / 1.15 spell IDs)
------------------------------------------------------------
AR.Data.COOLDOWN_SPELLS = {

    ------------------------------------
    -- Warrior
    ------------------------------------
    [6552]   = 10,   -- Pummel (Rank 1)
    [6554]   = 10,   -- Pummel (Rank 2)
    [72]     = 12,   -- Shield Bash (Rank 1)
    [1671]   = 12,   -- Shield Bash (Rank 2)
    [1672]   = 12,   -- Shield Bash (Rank 3)
    [29704]  = 12,   -- Shield Bash (Rank 4)
    [5246]   = 180,  -- Intimidating Shout
    [871]    = 1800, -- Shield Wall (30 min in Vanilla, reduced with talents)
    [18499]  = 30,   -- Berserker Rage
    [1719]   = 1800, -- Recklessness (30 min in Vanilla)
    [20230]  = 1800, -- Retaliation (30 min in Vanilla)
    [12975]  = 600,  -- Last Stand (10 min)
    [12809]  = 45,   -- Concussion Blow
    [12292]  = 180,  -- Death Wish
    [12328]  = 30,   -- Sweeping Strikes
    [23920]  = 10,   -- Spell Reflection (SoD)
    [20252]  = 30,   -- Intercept
    [676]    = 60,   -- Disarm
    [6343]   = 6,    -- Thunder Clap (Rank 1, GCD limited)
    [100]    = 15,   -- Charge (Rank 1)
    [7922]   = 15,   -- Charge Stun
    [2565]   = 60,   -- Shield Block

    ------------------------------------
    -- Paladin
    ------------------------------------
    [853]    = 60,   -- Hammer of Justice (Rank 1)
    [5588]   = 60,   -- Hammer of Justice (Rank 2)
    [5589]   = 60,   -- Hammer of Justice (Rank 3)
    [10308]  = 60,   -- Hammer of Justice (Rank 4)
    [642]    = 300,  -- Divine Shield (Rank 2)
    [1020]   = 300,  -- Divine Shield (Rank 1)
    [498]    = 300,  -- Divine Protection
    [1022]   = 300,  -- Blessing of Protection (Rank 1)
    [5599]   = 300,  -- Blessing of Protection (Rank 2)
    [10278]  = 300,  -- Blessing of Protection (Rank 3)
    [1044]   = 25,   -- Blessing of Freedom
    [6940]   = 30,   -- Blessing of Sacrifice (Rank 1)
    [20729]  = 30,   -- Blessing of Sacrifice (Rank 2)
    [20066]  = 60,   -- Repentance
    [20216]  = 120,  -- Divine Favor
    [10326]  = 30,   -- Turn Undead (Rank 1 uses 10326 at highest rank)
    [19752]  = 3600, -- Divine Intervention (1 hour)
    [2878]   = 60,   -- Turn Undead (Rank 1)
    [5627]   = 60,   -- Turn Undead (Rank 2)
    [24275]  = 6,    -- Hammer of Wrath (Rank 1)

    ------------------------------------
    -- Hunter
    ------------------------------------
    [14311]  = 30,   -- Freezing Trap (shared trap CD)
    [13795]  = 30,   -- Immolation Trap (shared trap CD)
    [13809]  = 30,   -- Frost Trap (shared trap CD)
    [13813]  = 30,   -- Explosive Trap (shared trap CD)
    [19386]  = 120,  -- Wyvern Sting (Rank 1)
    [24132]  = 120,  -- Wyvern Sting (Rank 2)
    [24133]  = 120,  -- Wyvern Sting (Rank 3)
    [19503]  = 30,   -- Scatter Shot
    [19263]  = 300,  -- Deterrence (5 min)
    [5384]   = 30,   -- Feign Death
    [781]    = 5,    -- Disengage (melee in Vanilla)
    [19574]  = 120,  -- Bestial Wrath
    [3045]   = 300,  -- Rapid Fire
    [19577]  = 60,   -- Intimidation
    [14327]  = 30,   -- Scare Beast (Rank 1, not a CD but included)
    [1543]   = 30,   -- Flare
    [3034]   = 15,   -- Viper Sting (Rank 1)
    [19801]  = 30,   -- Tranquilizing Shot
    [2974]   = 8,    -- Wing Clip

    ------------------------------------
    -- Rogue
    ------------------------------------
    [1766]   = 10,   -- Kick (Rank 1)
    [1767]   = 10,   -- Kick (Rank 2)
    [1768]   = 10,   -- Kick (Rank 3)
    [1769]   = 10,   -- Kick (Rank 4)
    [38768]  = 10,   -- Kick (Rank 5)
    [2094]   = 300,  -- Blind (5 min in Vanilla)
    [5277]   = 300,  -- Evasion (5 min in Vanilla)
    [1856]   = 300,  -- Vanish (Rank 1, 5 min)
    [1857]   = 300,  -- Vanish (Rank 2)
    [2983]   = 300,  -- Sprint (Rank 1, 5 min)
    [8696]   = 300,  -- Sprint (Rank 2)
    [11305]  = 300,  -- Sprint (Rank 3)
    [14177]  = 180,  -- Cold Blood (3 min)
    [13750]  = 300,  -- Adrenaline Rush (5 min)
    [13877]  = 120,  -- Blade Flurry (2 min)
    [14185]  = 600,  -- Preparation (10 min)
    [14278]  = 20,   -- Ghostly Strike
    [16511]  = 20,   -- Hemorrhage
    [2836]   = 30,   -- Detect Traps
    [1725]   = 10,   -- Distract
    [36554]  = 30,   -- Shadowstep (SoD)
    [31224]  = 60,   -- Cloak of Shadows (SoD)

    ------------------------------------
    -- Priest
    ------------------------------------
    [8122]   = 30,   -- Psychic Scream (Rank 1)
    [8124]   = 30,   -- Psychic Scream (Rank 2)
    [10888]  = 30,   -- Psychic Scream (Rank 3)
    [10890]  = 30,   -- Psychic Scream (Rank 4)
    [15487]  = 45,   -- Silence
    [10060]  = 180,  -- Power Infusion
    [6346]   = 30,   -- Fear Ward
    [15286]  = 10,   -- Vampiric Embrace (10 sec CD)
    [605]    = 0,    -- Mind Control (no CD, channeled)
    [10947]  = 15,   -- Mind Blast (Rank 7, 8 sec reduced by talents)
    [10952]  = 30,   -- Inner Focus (not a real CD but mana-saving ability)
    [14751]  = 180,  -- Inner Focus (talent, 3 min)
    [586]    = 24,   -- Fade (Rank 1)
    [9578]   = 24,   -- Fade (Rank 2)
    [9579]   = 24,   -- Fade (Rank 3)
    [9592]   = 24,   -- Fade (Rank 4)
    [10941]  = 24,   -- Fade (Rank 5)
    [10942]  = 24,   -- Fade (Rank 6)
    [10060]  = 180,  -- Power Infusion
    [33206]  = 120,  -- Pain Suppression (SoD)
    [10890]  = 30,   -- Psychic Scream (highest rank)

    ------------------------------------
    -- Shaman
    ------------------------------------
    [8042]   = 6,    -- Earth Shock (Rank 1)
    [8044]   = 6,    -- Earth Shock (Rank 2)
    [8045]   = 6,    -- Earth Shock (Rank 3)
    [8046]   = 6,    -- Earth Shock (Rank 4)
    [10412]  = 6,    -- Earth Shock (Rank 5)
    [10413]  = 6,    -- Earth Shock (Rank 6)
    [10414]  = 6,    -- Earth Shock (Rank 7)
    [16166]  = 180,  -- Elemental Mastery (3 min)
    [16188]  = 180,  -- Nature's Swiftness (3 min)
    [16190]  = 300,  -- Mana Tide Totem (5 min)
    [2825]   = 300,  -- Bloodlust (Horde, SoD/later Classic)
    [8177]   = 15,   -- Grounding Totem
    [8143]   = 15,   -- Tremor Totem
    [5730]   = 15,   -- Stoneclaw Totem (Rank 1)
    [6390]   = 15,   -- Stoneclaw Totem (Rank 2)
    [6391]   = 15,   -- Stoneclaw Totem (Rank 3)
    [6392]   = 15,   -- Stoneclaw Totem (Rank 4)
    [10427]  = 15,   -- Stoneclaw Totem (Rank 5)
    [10428]  = 15,   -- Stoneclaw Totem (Rank 6)
    [8835]   = 60,   -- Grace of Air Totem (Rank 1)
    [10627]  = 60,   -- Grace of Air Totem (Rank 2)
    [25359]  = 60,   -- Grace of Air Totem (Rank 3)
    [20608]  = 3600, -- Reincarnation (1 hour)
    [8056]   = 6,    -- Frost Shock (Rank 1, shared shock CD)
    [8058]   = 6,    -- Frost Shock (Rank 2)
    [10472]  = 6,    -- Frost Shock (Rank 3)
    [10473]  = 6,    -- Frost Shock (Rank 4)
    [8050]   = 6,    -- Flame Shock (Rank 1, shared shock CD)
    [30823]  = 120,  -- Shamanistic Rage (SoD)

    ------------------------------------
    -- Mage
    ------------------------------------
    [2139]   = 30,   -- Counterspell
    [45438]  = 300,  -- Ice Block (5 min)
    [1953]   = 15,   -- Blink
    [122]    = 25,   -- Frost Nova (Rank 1)
    [865]    = 25,   -- Frost Nova (Rank 2)
    [6131]   = 25,   -- Frost Nova (Rank 3)
    [10230]  = 25,   -- Frost Nova (Rank 4)
    [12042]  = 180,  -- Arcane Power (3 min)
    [12043]  = 180,  -- Presence of Mind (3 min)
    [11958]  = 600,  -- Cold Snap (10 min)
    [11129]  = 180,  -- Combustion (3 min)
    [12472]  = 180,  -- Icy Veins (SoD, 3 min)
    [2136]   = 8,    -- Fire Blast (Rank 1)
    [2137]   = 8,    -- Fire Blast (Rank 2)
    [2138]   = 8,    -- Fire Blast (Rank 3)
    [8412]   = 8,    -- Fire Blast (Rank 4)
    [8413]   = 8,    -- Fire Blast (Rank 5)
    [10197]  = 8,    -- Fire Blast (Rank 6)
    [10199]  = 8,    -- Fire Blast (Rank 7)
    [12051]  = 480,  -- Evocation (8 min)
    [66]     = 300,  -- Invisibility (SoD)
    [12355]  = 0,    -- Impact (proc stun, no CD)

    ------------------------------------
    -- Warlock
    ------------------------------------
    [19647]  = 24,   -- Spell Lock (Felhunter, Rank 1)
    [19650]  = 24,   -- Spell Lock (Felhunter, Rank 2)
    [5484]   = 40,   -- Howl of Terror (Rank 1)
    [17928]  = 40,   -- Howl of Terror (Rank 2)
    [6789]   = 120,  -- Death Coil (Rank 1, 2 min)
    [17925]  = 120,  -- Death Coil (Rank 2)
    [17926]  = 120,  -- Death Coil (Rank 3)
    [18708]  = 900,  -- Fel Domination (15 min)
    [18288]  = 180,  -- Amplify Curse (3 min)
    [17962]  = 10,   -- Conflagrate
    [18223]  = 0,    -- Curse of Exhaustion (no CD)
    [6229]   = 30,   -- Shadow Ward (Rank 1)
    [11739]  = 30,   -- Shadow Ward (Rank 2)
    [11740]  = 30,   -- Shadow Ward (Rank 3)
    [28610]  = 30,   -- Shadow Ward (Rank 4)
    [7812]   = 1800, -- Sacrifice (Voidwalker, Rank 1, 30 min)
    [19438]  = 1800, -- Sacrifice (Voidwalker, Rank 2)
    [19440]  = 1800, -- Sacrifice (Voidwalker, Rank 3)
    [19441]  = 1800, -- Sacrifice (Voidwalker, Rank 4)
    [19442]  = 1800, -- Sacrifice (Voidwalker, Rank 5)
    [19443]  = 1800, -- Sacrifice (Voidwalker, Rank 6)
    [17877]  = 15,   -- Shadowburn (15 sec)
    [18540]  = 600,  -- Summon Doomguard (ritual, 10 min shared)
    [1122]   = 3600, -- Summon Infernal (1 hour)
    [30283]  = 20,   -- Shadowfury (SoD)
    [29858]  = 180,  -- Soulshatter (3 min)

    ------------------------------------
    -- Druid
    ------------------------------------
    [22812]  = 60,   -- Barkskin (1 min)
    [29166]  = 360,  -- Innervate (6 min)
    [5211]   = 60,   -- Bash (Rank 1)
    [6798]   = 60,   -- Bash (Rank 2)
    [8983]   = 60,   -- Bash (Rank 3)
    [17116]  = 180,  -- Nature's Swiftness (Druid, 3 min)
    [9005]   = 0,    -- Pounce (no CD, costs energy + stealth required)
    [16689]  = 60,   -- Nature's Grasp (Rank 1)
    [16810]  = 60,   -- Nature's Grasp (Rank 2)
    [16811]  = 60,   -- Nature's Grasp (Rank 3)
    [16812]  = 60,   -- Nature's Grasp (Rank 4)
    [16813]  = 60,   -- Nature's Grasp (Rank 5)
    [17329]  = 60,   -- Nature's Grasp (Rank 6)
    [22842]  = 180,  -- Frenzied Regeneration (Rank 1, 3 min)
    [22895]  = 180,  -- Frenzied Regeneration (Rank 2)
    [22896]  = 180,  -- Frenzied Regeneration (Rank 3)
    [5229]   = 60,   -- Enrage (1 min, Bear)
    [16979]  = 15,   -- Feral Charge (15 sec)
    [740]    = 300,  -- Tranquility (Rank 1, 5 min)
    [8918]   = 300,  -- Tranquility (Rank 2)
    [9862]   = 300,  -- Tranquility (Rank 3)
    [9863]   = 300,  -- Tranquility (Rank 4)
    [20719]  = 10,   -- Feline Grace (passive)
    [2782]   = 0,    -- Remove Curse (no CD)
    [18960]  = 600,  -- Teleport: Moonglade (10 min)

    ------------------------------------
    -- Racials
    ------------------------------------
    [20549]  = 120,  -- War Stomp (Tauren, 2 min)
    [7744]   = 120,  -- Will of the Forsaken (Undead, 2 min, shared with PvP trinket)
    [20572]  = 120,  -- Blood Fury (Orc, 2 min)
    [26297]  = 180,  -- Berserking (Troll, 3 min)
    [20594]  = 180,  -- Stoneform (Dwarf, 3 min)
    [20589]  = 60,   -- Escape Artist (Gnome, 1 min)
    [20600]  = 120,  -- Perception (Human, 2 min)  -- was 3 min in some patches
    [26635]  = 180,  -- Berserking (Troll, alias)
    [20554]  = 120,  -- Berserking (Troll, melee variant)
    [25046]  = 120,  -- Arcane Torrent (Blood Elf, SoD if applicable)

    ------------------------------------
    -- PvP Trinket
    ------------------------------------
    [42292]  = 300,  -- PvP Trinket (Insignia of the Alliance/Horde, 5 min in Vanilla)
}
