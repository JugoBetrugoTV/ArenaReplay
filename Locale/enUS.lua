local L = LibStub("AceLocale-3.0"):NewLocale("ArenaReplay", "enUS", true)

-- Arena countdown messages (used to detect arena state)
L.ARENA_START           = "The Arena battle has begun!"
L.ARENA_60              = "One minute until the Arena battle begins!"
L.ARENA_30              = "Thirty seconds until the Arena battle begins!"
L.ARENA_15              = "Fifteen seconds until the Arena battle begins!"

-- Addon messages
L.LOADED                = "loaded! Type /ar for options."
L.UNKNOWN               = "Unknown"
L.SPEED                 = "Speed"
L.VIEW_STATS            = "Show Stats"
L.VIEW_MATCH            = "Show Match"

-- Commands
L.CONF_NOMATCHES        = "No matches found."
L.CONF_WRONG_INPUT      = "Invalid input."
L.CONF_MATCH_DELETED    = "Match has been deleted."
L.HELP_LINE1            = "ArenaReplay Help"
L.HELP_LINE2            = "ui - Display all recorded matches."
L.HELP_LINE3            = "delete all - Delete all recorded matches."
L.HELP_LINE4            = "broadcast - Enable/disable broadcasting."
L.HELP_LINE5            = "lookup - List available broadcasts."
L.HELP_LINE6            = "connect [name] - Connect to a broadcast."
L.HELP_LINE7            = "spectators - List connected spectators."

-- Status
L.STATUS                = "Status"
L.STATUS_IDLE           = "Idle"
L.STATUS_QUEUE          = "In Queue"
L.STATUS_ENTER          = "Entering Arena"
L.STATUS_BOX_60         = "Preparation (60s)"
L.STATUS_BOX_30         = "Preparation (30s)"
L.STATUS_BOX_15         = "Preparation (15s)"
L.STATUS_FIGHT          = "In Fight"

-- Broadcast
L.BROADCAST_ON          = "Broadcasting [|cff00e300ON|r]"
L.BROADCAST_OFF         = "Broadcasting [|cffff0000OFF|r]"
L.RECORDING_ON          = "Recording [|cff00e300ON|r]"
L.RECORDING_OFF         = "Recording [|cffff0000OFF|r]"
L.PROHIBITED_ACTION     = "Action not possible in arena."
L.NEW_BROADCASTER       = "Broadcaster found: "
L.NEW_SPECTATOR         = "Spectator connected: "
L.CONNECTED_TO          = "Connected to "
L.WAITING_DATA          = "Waiting for arena data."

-- Arena maps
L.MAP_UNKNOWN           = "Unknown"
L.MAP_NAGRAND           = "Nagrand Arena"
L.MAP_LORDAERON         = "Ruins of Lordaeron"
L.MAP_BLADEEDGE         = "Blade's Edge Arena"
L.MAP_DALARAN           = "Dalaran Arena"
L.MAP_TOLVIR            = "Tol'viron Arena"
L.MAP_ASHAMANE          = "Ashamane's Fall"
L.MAP_BLACKROOK         = "Black Rook Hold Arena"
L.MAP_SHADOPAN          = "Shado-Pan Showdown"
L.MAP_HOOKPOINT         = "Hook Point"
L.MAP_MUGAMBALA         = "Mugambala"
L.MAP_ROBODROME         = "The Robodrome"
L.MAP_ENIGMA_CRUCIBLE   = "Enigma Crucible"
L.MAP_NOKHUDON          = "Nokhudon Proving Grounds"
L.MAP_EMPYREAN_DOMAIN   = "Empyrean Domain"

-- Stats
L.DETAIL_DAMAGEDONE     = "Damage\nDone"
L.DETAIL_HIGHDAMAGE     = "Highest\nDamage"
L.DETAIL_HEALDONE       = "Healing\nDone"
L.DETAIL_RATING         = "Rating"
L.DETAIL_MMR            = "MMR"

-- MMR Tracker help
L.HELP_MMR1             = "mmr - Toggle MMR display on screen."
L.HELP_MMR2             = "mmr lock - Lock/unlock the MMR display position."
L.HELP_MMR3             = "mmr table - Show MMR match history table."
L.HELP_MMR4             = "mmr reset - Clear all MMR history data."

-- MMR Tracker labels
L.MMR_NO_DATA           = "No data yet"
L.MMR_2V2               = "2v2"
L.MMR_3V3               = "3v3"
L.MMR_RBG               = "RBG"
L.MMR_SHUFFLE           = "Shuffle"
L.MMR_BLITZ             = "Blitz"
L.MMR_RATING            = "Rating"
L.MMR_MMR               = "MMR"
L.MMR_WIN_RATE          = "Win Rate"
L.MMR_GAMES             = "Games"

-- Errors
L.ERROR_OLDMATCHES      = "Older matches may have outdated spell data."
