# ArenaReplay

**Arena replay addon for World of Warcraft: Midnight (12.0)**

Record, replay, and broadcast your arena matches directly in WoW. Inspired by [AAV (Atrox Arena Viewer)](https://github.com/zwacky/aav), completely rebuilt for WoW Midnight 12.0.

## Features

- **Match Recording** - Automatically records arena matches (damage, healing, abilities, CC, cooldowns, health)
- **In-Game Replay** - Watch recorded matches with full visual playback including floating combat text, skill icons, buff/debuff tracking, crowd control overlays, and cooldown tracking
- **Broadcasting** - Stream your arena matches live to guildmates or raid members
- **Spectating** - Watch other players' arena matches via broadcast
- **Match History** - Browse all recorded matches with date, map, result, rating, and duration
- **Timeline Seeker** - Scrub through match replays with adjustable playback speed (0-300%)
- **Post-Match Stats** - Damage done, healing done, highest crit, rating changes, MMR

## WoW 12.0 Midnight Compatibility

This addon is built specifically for WoW Midnight (Interface 120000) and handles the new API restrictions:

- Uses `C_Spell.GetSpellInfo()` (new 12.0 API) with fallback to legacy `GetSpellInfo()`
- Gracefully handles Secret Values - enemy data that may be restricted
- Uses `pcall` wrappers for potentially restricted APIs (`GetArenaOpponentSpec`, scoreboard functions)
- Compatible with the new `UNIT_AURA` updateInfo format (AuraInstanceIDs)
- Uses `C_ChatInfo.SendAddonMessage` for addon communication
- Uses `BackdropTemplate` mixin for frame creation

## Supported Classes (12.0)

Death Knight, Demon Hunter, Druid, Evoker, Hunter, Mage, Monk, Paladin, Priest, Rogue, Shaman, Warlock, Warrior

## Supported Arena Maps

Nagrand Arena, Ruins of Lordaeron, Blade's Edge Arena, Dalaran Arena, Tol'viron Arena, Ashamane's Fall, Black Rook Hold Arena, Shado-Pan Showdown, Hook Point, Mugambala, The Robodrome, Enigma Crucible, Nokhudon Proving Grounds, Empyrean Domain

## Installation

1. Copy the `ArenaReplay` folder to `World of Warcraft/_retail_/Interface/AddOns/`
2. Restart WoW or `/reload`
3. The addon will appear on your minimap as an arena icon

## Usage

### Slash Commands

| Command | Description |
|---------|-------------|
| `/ar` or `/ar ui` | Open the match list window |
| `/ar broadcast` | Toggle broadcasting on/off |
| `/ar record` | Toggle recording on/off |
| `/ar lookup` | Find available broadcasts |
| `/ar connect [name]` | Connect to a broadcaster |
| `/ar spectators` | List connected spectators |
| `/ar delete all` | Delete all saved matches |
| `/ar play` | Play the most recent match |
| `/ar stop` | Stop current playback |

### Minimap Button

- **Left-click**: Open match list
- **Right-click**: Options menu
- **Drag**: Reposition around minimap

### Match Playback Controls

- Click any match in the list to start playback
- Use the timeline slider to seek through the match
- Adjust playback speed with the speed slider (0-300%)
- Click "Show Stats" to view end-of-match statistics

## Data Storage

Match data is stored in `World of Warcraft/_retail_/WTF/<Account>/SavedVariables/ArenaReplay.lua`

## Libraries

This addon includes minimal embedded versions of:
- LibStub
- CallbackHandler-1.0
- AceAddon-3.0
- AceEvent-3.0
- AceComm-3.0
- AceTimer-3.0
- AceSerializer-3.0
- AceLocale-3.0

For production use, you may want to replace these with the full Ace3 libraries from [WowAce](https://www.wowace.com/projects/ace3).

## Credits

- Original concept: [AAV - Atrox Arena Viewer](https://github.com/zwacky/aav) by Borborad (zwacky)
- Rebuilt for WoW Midnight 12.0

## License

This project is open source.
