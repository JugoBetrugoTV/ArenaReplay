local ADDON_NAME, AR = ...

------------------------------------------------------------
-- ArenaReplay Core - Main addon logic
-- Multi-version: Midnight, BCC Anniversary, MoP Classic
------------------------------------------------------------
local L = LibStub("AceLocale-3.0"):GetLocale("ArenaReplay", true)
local Compat = AR.Compat

-- Standalone event frame, created at file-load time in a clean
-- execution context so it is never tainted by other addons.
local coreEventFrame = CreateFrame("Frame")

-- Create Ace addon (with AceConsole for slash commands)
local ArenaReplay = LibStub("AceAddon-3.0"):NewAddon("ArenaReplay",
    "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0", "AceComm-3.0", "AceSerializer-3.0")
AR.Core = ArenaReplay

-- State
local currentMatch   = nil  -- AR_MatchStub during recording
local playStub       = nil  -- AR_PlayStub during playback
local isInArena      = false
local isFighting     = false
local arenaStartTime = 0
local healthTimer    = nil
local guidCache      = {}  -- player GUIDs discovered during the match

------------------------------------------------------------
-- Default saved variables (ArenaReplayDB: match data, global)
------------------------------------------------------------
local DEFAULTS = {
    matches       = {},
    recording     = true,
    broadcasting  = false,
    defaults = {
        uniqueColor   = false,
        healthDisplay = 1,  -- 1=percent, 2=absolute, 3=deficit
        shortAuras    = true,
        commChannel   = "GUILD",
    },
}

------------------------------------------------------------
-- AceDB defaults (ArenaReplaySettings: per-profile UI prefs)
------------------------------------------------------------
local DB_DEFAULTS = {
    profile = {
        minimap = { hide = false },
        mmrDisplay = {
            show2v2         = true,
            show3v3         = true,
            show5v5         = false,
            showRBG         = false,
            showShuffle     = false,
            showBlitz       = false,
            showMMRDiff     = true,
            showGains       = true,
            hideNoData      = false,
            lock            = false,
            position        = { "CENTER", "CENTER", 0, 200 },
            fontSize        = 13,
            fontFamily      = "Friz Quadrata TT",
            textColor       = { r = 1, g = 1, b = 1, a = 1 },
            showOnlyInQueue = false,
            showInPVP       = false,
            showInPVE       = true,
            classColors     = true,
            winLossIcons    = true,
        },
        display = {
            uniqueColor   = false,
            healthDisplay = 1,
            shortAuras    = true,
            commChannel   = "GUILD",
        },
    },
}

------------------------------------------------------------
-- Sync AceDB profile settings -> ArenaReplayDB
-- This bridges profile data to the existing code that reads
-- ArenaReplayDB.mmr.display and ArenaReplayDB.defaults directly.
------------------------------------------------------------
-- Deep copy a value (handles nested tables)
local function DeepCopy(val)
    if type(val) ~= "table" then return val end
    local copy = {}
    for k, v in pairs(val) do
        copy[k] = DeepCopy(v)
    end
    return copy
end

local function SyncProfileToDB()
    local profile = ArenaReplay.db and ArenaReplay.db.profile
    if not profile then return end

    -- Ensure mmr.display exists before syncing
    if ArenaReplayDB and ArenaReplayDB.mmr then
        if not ArenaReplayDB.mmr.display then
            ArenaReplayDB.mmr.display = {}
        end
        for k, v in pairs(profile.mmrDisplay) do
            ArenaReplayDB.mmr.display[k] = DeepCopy(v)
        end
    end

    -- Sync general display settings
    if ArenaReplayDB and ArenaReplayDB.defaults then
        for k, v in pairs(profile.display) do
            ArenaReplayDB.defaults[k] = DeepCopy(v)
        end
    end
end

------------------------------------------------------------
-- Initialization
------------------------------------------------------------
function ArenaReplay:OnInitialize()
    -- Setup saved variables (ArenaReplayDB: match data)
    if not ArenaReplayDB then
        ArenaReplayDB = {}
    end
    for k, v in pairs(DEFAULTS) do
        if ArenaReplayDB[k] == nil then
            if type(v) == "table" then
                ArenaReplayDB[k] = {}
                for k2, v2 in pairs(v) do
                    ArenaReplayDB[k][k2] = v2
                end
            else
                ArenaReplayDB[k] = v
            end
        end
    end
    if not ArenaReplayDB.defaults then
        ArenaReplayDB.defaults = {}
        for k, v in pairs(DEFAULTS.defaults) do
            ArenaReplayDB.defaults[k] = v
        end
    end

    -- Initialize AceDB (ArenaReplaySettings: per-profile prefs)
    self.db = LibStub("AceDB-3.0"):New("ArenaReplaySettings", DB_DEFAULTS, true)
    AR.db = self.db

    -- Migrate: if existing ArenaReplayDB has display settings, import into profile
    if ArenaReplayDB.mmr and ArenaReplayDB.mmr.display then
        local src = ArenaReplayDB.mmr.display
        local dst = self.db.profile.mmrDisplay
        for k, v in pairs(src) do
            if dst[k] ~= nil and type(v) == type(dst[k]) then
                dst[k] = v
            elseif type(v) ~= "table" then
                dst[k] = v
            end
        end
    end

    -- Sync profile -> ArenaReplayDB on profile change
    self.db.RegisterCallback(self, "OnProfileChanged", "OnProfileSync")
    self.db.RegisterCallback(self, "OnProfileCopied", "OnProfileSync")
    self.db.RegisterCallback(self, "OnProfileReset", "OnProfileSync")

    -- Initialize communication
    AR_Comm:Init(self)

    -- Initialize MMR tracker
    AR_MMRTracker:Init()

    -- Initial profile sync
    SyncProfileToDB()

    -- Initialize options panel
    AR_Options:Init()

    -- Create minimap button (LibDBIcon)
    AR_MinimapButton:Create()
end

function ArenaReplay:OnProfileSync()
    SyncProfileToDB()
    AR_MMRDisplay:Update()
    AR_MinimapButton:Refresh()
end

------------------------------------------------------------
-- Slash command handler (via AceConsole)
------------------------------------------------------------
function ArenaReplay:OnSlashCommand(input)
    input = (input or ""):trim():lower()
    if input == "settings" or input == "config" or input == "options" then
        AR_Options:Open()
    elseif input == "mmr" then
        AR_MMRDisplay:Toggle()
    elseif input == "history" or input == "table" then
        AR_MMRTable:Toggle()
    elseif input == "minimap" then
        self.db.profile.minimap.hide = not self.db.profile.minimap.hide
        AR_MinimapButton:Refresh()
    else
        AR_TableGUI:ShowMatchesFrame()
    end
end

function ArenaReplay:OnEnable()
    -- Use our own clean event frame (created at file-load time)
    -- to bypass AceEvent's potentially tainted shared frame.
    coreEventFrame:SetScript("OnEvent", function(_, event, ...)
        if ArenaReplay[event] then
            ArenaReplay[event](ArenaReplay, event, ...)
        end
    end)

    -- Register core events (all versions)
    coreEventFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    coreEventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    coreEventFrame:RegisterEvent("UNIT_HEALTH")
    coreEventFrame:RegisterEvent("UNIT_MAXHEALTH")
    coreEventFrame:RegisterEvent("UNIT_AURA")
    coreEventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

    -- Arena-specific events (all supported versions have arenas)
    coreEventFrame:RegisterEvent("CHAT_MSG_BG_SYSTEM_NEUTRAL")
    coreEventFrame:RegisterEvent("UPDATE_BATTLEFIELD_STATUS")
    coreEventFrame:RegisterEvent("ARENA_OPPONENT_UPDATE")
    coreEventFrame:RegisterEvent("UPDATE_BATTLEFIELD_SCORE")

    -- Retail-only events
    if Compat.isRetail then
        coreEventFrame:RegisterEvent("ARENA_PREP_OPPONENT_SPECIALIZATIONS")
        coreEventFrame:RegisterEvent("PVP_MATCH_COMPLETE")
        coreEventFrame:RegisterEvent("LOADING_SCREEN_DISABLED")
        coreEventFrame:RegisterEvent("PVP_MATCH_STATE_CHANGED")
    end

    -- Slash commands via AceConsole
    self:RegisterChatCommand("ar", "OnSlashCommand")
    self:RegisterChatCommand("arenareplay", "OnSlashCommand")

    -- Show MMR display on login (only if rated PvP exists)
    if Compat.hasRatedPvP then
        AR_MMRDisplay:Show()
    end

    local tag = Compat.GetVersionTag()
    print("|cffe392c5<ArenaReplay>|r v" .. AR.VERSION .. " (" .. tag .. ") " .. L.LOADED)
end

------------------------------------------------------------
-- Toggle functions
------------------------------------------------------------
function ArenaReplay:ToggleBroadcast()
    if isInArena then
        print("|cffe392c5<ArenaReplay>|r " .. L.PROHIBITED_ACTION)
        return
    end
    ArenaReplayDB.broadcasting = not ArenaReplayDB.broadcasting
    if ArenaReplayDB.broadcasting then
        print("|cffe392c5<ArenaReplay>|r " .. L.BROADCAST_ON)
    else
        print("|cffe392c5<ArenaReplay>|r " .. L.BROADCAST_OFF)
    end
end

function ArenaReplay:ToggleRecording()
    if isInArena then
        print("|cffe392c5<ArenaReplay>|r " .. L.PROHIBITED_ACTION)
        return
    end
    ArenaReplayDB.recording = not ArenaReplayDB.recording
    if ArenaReplayDB.recording then
        print("|cffe392c5<ArenaReplay>|r " .. L.RECORDING_ON)
    else
        print("|cffe392c5<ArenaReplay>|r " .. L.RECORDING_OFF)
    end
end

------------------------------------------------------------
-- Zone detection
------------------------------------------------------------
function ArenaReplay:PLAYER_ENTERING_WORLD()
    self:CheckArenaZone()
    AR_MMRDisplay:Update()
end

function ArenaReplay:ZONE_CHANGED_NEW_AREA()
    self:CheckArenaZone()
end

function ArenaReplay:CheckArenaZone()
    local inInstance, instanceType = IsInInstance()
    local wasInArena = isInArena
    isInArena = (inInstance and instanceType == "arena")

    if isInArena and not wasInArena then
        self:OnEnterArena()
    elseif not isInArena and wasInArena then
        self:OnLeaveArena()
    end
end

------------------------------------------------------------
-- Arena entry / exit
------------------------------------------------------------
function ArenaReplay:OnEnterArena()
    if not ArenaReplayDB.recording then return end

    currentMatch = AR_MatchStub:New()
    guidCache = {}
    isFighting = false
    arenaStartTime = GetTime()

    -- Snapshot pre-match MMR/Rating for tracking
    AR_MMRTracker:SnapshotPreMatch()

    -- Scan existing party members
    self:ScanParty()

    -- Start health polling timer
    if healthTimer then self:CancelTimer(healthTimer) end
    healthTimer = self:ScheduleRepeatingTimer("PollHealth", 0.5)

    -- Broadcast start
    AR_Comm:BroadcastStart(currentMatch)
end

function ArenaReplay:OnLeaveArena()
    if healthTimer then
        self:CancelTimer(healthTimer)
        healthTimer = nil
    end

    if currentMatch and isFighting then
        self:FinalizeMatch()
    end

    currentMatch = nil
    isInArena = false
    isFighting = false
    guidCache = {}
end

------------------------------------------------------------
-- Scan party/arena for players
------------------------------------------------------------
function ArenaReplay:ScanParty()
    if not currentMatch then return end

    -- Scan friendly team (party/raid)
    local units = { "player" }
    for i = 1, 4 do table.insert(units, "party" .. i) end

    for _, unit in ipairs(units) do
        if UnitExists(unit) and UnitIsPlayer(unit) then
            local guid, _ = currentMatch:AddPlayer(unit, 1) -- team 1 = friendly
            if guid then guidCache[guid] = unit end
        end
    end

    -- Scan enemy team (arena units)
    for i = 1, 5 do
        local unit = "arena" .. i
        if UnitExists(unit) then
            local guid, _ = currentMatch:AddPlayer(unit, 0) -- team 0 = hostile
            if guid then guidCache[guid] = unit end
            -- Try to get spec (may be restricted in 12.0)
            currentMatch:SetOpponentSpec(UnitGUID(unit), i)
        end
    end

    currentMatch:SetBracket()
end

------------------------------------------------------------
-- Arena countdown / fight start detection
------------------------------------------------------------
function ArenaReplay:CHAT_MSG_BG_SYSTEM_NEUTRAL(event, msg)
    if not isInArena or not currentMatch then return end

    if msg == L.ARENA_START or msg:find("The Arena battle has begun") then
        isFighting = true
        arenaStartTime = GetTime()
        self:ScanParty() -- re-scan to catch late-joiners
    end
end

------------------------------------------------------------
-- Arena opponent updates
------------------------------------------------------------
function ArenaReplay:ARENA_OPPONENT_UPDATE(event, unit, updateType)
    if not currentMatch then return end

    if updateType == "seen" or updateType == "cleared" then
        if UnitExists(unit) then
            local guid, _ = currentMatch:AddPlayer(unit, 0)
            if guid then guidCache[guid] = unit end

            -- Try to detect spec
            local index = tonumber(unit:match("arena(%d+)"))
            if index and guid then
                currentMatch:SetOpponentSpec(guid, index)
            end
        end
    end
end

function ArenaReplay:ARENA_PREP_OPPONENT_SPECIALIZATIONS()
    if not currentMatch then return end
    for i = 1, 5 do
        local unit = "arena" .. i
        if UnitExists(unit) then
            local guid = UnitGUID(unit)
            if guid then
                currentMatch:SetOpponentSpec(guid, i)
            end
        end
    end
end

------------------------------------------------------------
-- Update battlefield status (queue/entering detection)
------------------------------------------------------------
function ArenaReplay:UPDATE_BATTLEFIELD_STATUS()
    -- Used for detecting queue pops; zone check handles the rest
    -- Also refresh MMR display (may toggle visibility based on queue state)
    AR_MMRDisplay:Update()
end

function ArenaReplay:LOADING_SCREEN_DISABLED()
    -- Refresh MMR display after loading screens
    self:ScheduleTimer(function()
        AR_MMRDisplay:Update()
    end, 1)
end

function ArenaReplay:PVP_MATCH_STATE_CHANGED()
    -- Refresh MMR display when PvP state changes
    self:ScheduleTimer(function()
        AR_MMRDisplay:Update()
    end, 0.5)
end

------------------------------------------------------------
-- Health events
------------------------------------------------------------
function ArenaReplay:UNIT_HEALTH(event, unit)
    self:RecordHealthUpdate(unit)
end

function ArenaReplay:UNIT_MAXHEALTH(event, unit)
    self:RecordHealthUpdate(unit)
end

function ArenaReplay:RecordHealthUpdate(unit)
    if not currentMatch or not isFighting then return end

    local guid = UnitGUID(unit)
    if not guid then return end

    local player = currentMatch.players[guid]
    if not player then return end

    local flags = currentMatch:GetHealthChangeFlags(unit)
    if flags > 0 then
        local elapsed = GetTime() - arenaStartTime
        local msg = string.format("%f,HP,%d,%d,%d",
            elapsed, player.ID, player.hp, player.hpMax)
        currentMatch:RecordEvent(msg)
        AR_Comm:BroadcastEvent(msg)
    end
end

------------------------------------------------------------
-- Health polling (fallback for units that don't trigger events)
------------------------------------------------------------
function ArenaReplay:PollHealth()
    if not currentMatch or not isFighting then return end

    local units = { "player" }
    for i = 1, 4 do table.insert(units, "party" .. i) end
    for i = 1, 5 do table.insert(units, "arena" .. i) end

    for _, unit in ipairs(units) do
        if UnitExists(unit) then
            self:RecordHealthUpdate(unit)
        end
    end
end

------------------------------------------------------------
-- Aura tracking (supports both Retail 10.0+ and Classic APIs)
------------------------------------------------------------
function ArenaReplay:UNIT_AURA(event, unit, updateInfo)
    if not currentMatch or not isFighting then return end

    local guid = UnitGUID(unit)
    if not guid then return end
    local player = currentMatch.players[guid]
    if not player then return end

    local elapsed = GetTime() - arenaStartTime

    -- Retail 10.0+: use updateInfo with addedAuras/removedAuraInstanceIDs
    if Compat.hasNewAuraAPI and updateInfo then
        if updateInfo.addedAuras then
            for _, aura in ipairs(updateInfo.addedAuras) do
                local spellID = aura.spellId
                local dur = aura.duration or 0
                if spellID and spellID > 0 then
                    local auraType = aura.isHelpful and 1 or 2
                    local msg = string.format("%f,AA,%d,%d,%d,%f",
                        elapsed, player.ID, spellID, auraType, dur)
                    currentMatch:RecordEvent(msg)
                    AR_Comm:BroadcastEvent(msg)

                    if AR.Data.COOLDOWN_SPELLS[spellID] then
                        local cdMsg = string.format("%f,CD,%d,%d,%d",
                            elapsed, player.ID, spellID, AR.Data.COOLDOWN_SPELLS[spellID])
                        currentMatch:RecordEvent(cdMsg)
                    end
                end
            end
        end
        return
    end

    -- Classic / TBC / MoP: scan UnitBuff/UnitDebuff directly
    -- Aura changes are detected via COMBAT_LOG_EVENT_UNFILTERED (SPELL_AURA_APPLIED/REMOVED)
    -- UNIT_AURA on Classic doesn't give us specifics, so we rely on CLEU instead
end

------------------------------------------------------------
-- Combat Log Event processing (all versions)
-- In Retail 12.0+, CLEU may have restricted data for enemy actions.
-- We handle this gracefully with nil checks.
------------------------------------------------------------
function ArenaReplay:COMBAT_LOG_EVENT_UNFILTERED()
    if not currentMatch or not isFighting then return end

    local timestamp, subevent, hideCaster,
          sourceGUID, sourceName, sourceFlags, sourceRaidFlags,
          destGUID, destName, destFlags, destRaidFlags = CombatLogGetCurrentEventInfo()

    -- Safely extract remaining args (position varies by subevent)
    local args = { select(12, CombatLogGetCurrentEventInfo()) }

    -- Only track events involving known players
    local sourcePlayer = currentMatch.players[sourceGUID]
    local destPlayer   = currentMatch.players[destGUID]

    -- If neither source nor dest is a tracked player, try to add them
    if not sourcePlayer and not destPlayer then
        -- Try to discover new arena opponents from combat log
        if sourceGUID and not currentMatch.players[sourceGUID] then
            local unit = self:FindUnitByGUID(sourceGUID)
            if unit then
                local guid, _ = currentMatch:AddPlayer(unit, self:DetermineTeam(unit))
                if guid then
                    guidCache[guid] = unit
                    sourcePlayer = currentMatch.players[guid]
                end
            end
        end
        if destGUID and not currentMatch.players[destGUID] then
            local unit = self:FindUnitByGUID(destGUID)
            if unit then
                local guid, _ = currentMatch:AddPlayer(unit, self:DetermineTeam(unit))
                if guid then
                    guidCache[guid] = unit
                    destPlayer = currentMatch.players[guid]
                end
            end
        end
    end

    if not sourcePlayer and not destPlayer then return end

    local elapsed = GetTime() - arenaStartTime
    local sourceID = sourcePlayer and sourcePlayer.ID or -1
    local destID   = destPlayer and destPlayer.ID or -1

    ----------------------------------------------------
    -- Damage events
    ----------------------------------------------------
    if subevent == "SWING_DAMAGE" then
        local amount = args[1] or 0
        local overkill = args[2] or 0
        local critical = args[7] and 1 or 0
        if destPlayer then
            currentMatch:AddStats(1, destGUID, amount, "Melee")
            local msg = string.format("%f,D,%d,%d,%d,0,%d", elapsed, sourceID, destID, amount, critical)
            currentMatch:RecordEvent(msg)
            AR_Comm:BroadcastEvent(msg)
        end

    elseif subevent == "SPELL_DAMAGE" or subevent == "SPELL_PERIODIC_DAMAGE" or subevent == "RANGE_DAMAGE" then
        local spellID   = args[1] or 0
        local spellName = args[2] or "Unknown"
        local amount    = args[4] or 0
        local critical  = args[10] and 1 or 0
        if destPlayer then
            currentMatch:AddStats(1, destGUID, amount, spellName)
            local msg = string.format("%f,D,%d,%d,%d,%d,%d", elapsed, sourceID, destID, amount, spellID, critical)
            currentMatch:RecordEvent(msg)
            AR_Comm:BroadcastEvent(msg)
        end

        -- Track cooldowns from damage spells
        if sourcePlayer and spellID and AR.Data.COOLDOWN_SPELLS[spellID] then
            local cdMsg = string.format("%f,CD,%d,%d,%d", elapsed, sourceID, spellID, AR.Data.COOLDOWN_SPELLS[spellID])
            currentMatch:RecordEvent(cdMsg)
        end

    ----------------------------------------------------
    -- Healing events
    ----------------------------------------------------
    elseif subevent == "SPELL_HEAL" or subevent == "SPELL_PERIODIC_HEAL" then
        local spellID   = args[1] or 0
        local spellName = args[2] or "Unknown"
        local amount    = args[4] or 0
        local critical  = args[7] and 1 or 0
        if destPlayer then
            currentMatch:AddStats(2, destGUID, amount, spellName)
            local msg = string.format("%f,H,%d,%d,%d,%d,%d", elapsed, sourceID, destID, amount, spellID, critical)
            currentMatch:RecordEvent(msg)
            AR_Comm:BroadcastEvent(msg)
        end

    ----------------------------------------------------
    -- Spell cast events
    ----------------------------------------------------
    elseif subevent == "SPELL_CAST_START" then
        local spellID = args[1] or 0
        if sourcePlayer and spellID > 0 then
            local msg = string.format("%f,SC,%d,%d,1", elapsed, sourceID, spellID)
            currentMatch:RecordEvent(msg)
            AR_Comm:BroadcastEvent(msg)
        end

    elseif subevent == "SPELL_CAST_SUCCESS" then
        local spellID = args[1] or 0
        if sourcePlayer and spellID > 0 then
            local msg = string.format("%f,SC,%d,%d,0", elapsed, sourceID, spellID)
            currentMatch:RecordEvent(msg)
            AR_Comm:BroadcastEvent(msg)

            -- Track cooldowns
            if AR.Data.COOLDOWN_SPELLS[spellID] then
                local cdMsg = string.format("%f,CD,%d,%d,%d", elapsed, sourceID, spellID, AR.Data.COOLDOWN_SPELLS[spellID])
                currentMatch:RecordEvent(cdMsg)
            end
        end

    ----------------------------------------------------
    -- Aura events (from combat log)
    ----------------------------------------------------
    elseif subevent == "SPELL_AURA_APPLIED" then
        local spellID  = args[1] or 0
        local auraType = (args[4] == "BUFF") and 1 or 2
        if destPlayer and spellID > 0 then
            local msg = string.format("%f,AA,%d,%d,%d,0", elapsed, destID, spellID, auraType)
            currentMatch:RecordEvent(msg)
            AR_Comm:BroadcastEvent(msg)
        end

    elseif subevent == "SPELL_AURA_REMOVED" then
        local spellID  = args[1] or 0
        local auraType = (args[4] == "BUFF") and 1 or 2
        if destPlayer and spellID > 0 then
            local msg = string.format("%f,AR,%d,%d,%d", elapsed, destID, spellID, auraType)
            currentMatch:RecordEvent(msg)
            AR_Comm:BroadcastEvent(msg)
        end

    ----------------------------------------------------
    -- Interrupt
    ----------------------------------------------------
    elseif subevent == "SPELL_INTERRUPT" then
        local spellID         = args[1] or 0
        local interruptedID   = args[4] or 0
        if destPlayer then
            local msg = string.format("%f,I,%d,%d,%d", elapsed, sourceID, destID, interruptedID)
            currentMatch:RecordEvent(msg)
            AR_Comm:BroadcastEvent(msg)
        end

    ----------------------------------------------------
    -- Death
    ----------------------------------------------------
    elseif subevent == "UNIT_DIED" then
        if destPlayer then
            local msg = string.format("%f,X,%d", elapsed, destID)
            currentMatch:RecordEvent(msg)
            AR_Comm:BroadcastEvent(msg)
        end
    end
end

------------------------------------------------------------
-- Helper: find unit ID from GUID
------------------------------------------------------------
function ArenaReplay:FindUnitByGUID(guid)
    if guidCache[guid] then
        return guidCache[guid]
    end
    local units = { "player", "party1", "party2", "party3", "party4",
                    "arena1", "arena2", "arena3", "arena4", "arena5" }
    for _, unit in ipairs(units) do
        if UnitGUID(unit) == guid then
            guidCache[guid] = unit
            return unit
        end
    end
    return nil
end

function ArenaReplay:DetermineTeam(unit)
    if UnitIsFriend("player", unit) then return 1 end
    return 0
end

------------------------------------------------------------
-- Match end detection
------------------------------------------------------------
function ArenaReplay:PVP_MATCH_COMPLETE()
    -- Track MMR change (works even if recording is off)
    AR_MMRTracker:OnMatchComplete()

    if not currentMatch or not isInArena then return end
    self:ReadScoreboard()
    self:FinalizeMatch()

    -- Refresh MMR display after match
    AR_MMRDisplay:Update()
end

function ArenaReplay:UPDATE_BATTLEFIELD_SCORE()
    -- Also fired during arena; backup for PVP_MATCH_COMPLETE
end

------------------------------------------------------------
-- Read scoreboard data at match end
------------------------------------------------------------
function ArenaReplay:ReadScoreboard()
    if not currentMatch then return end

    -- Use Compat wrappers for safe API access across versions
    local winner = Compat.GetBattlefieldWinner()

    -- Read team info
    for teamIndex = 0, 1 do
        local name, oldRating, newRating, mmr = Compat.GetBattlefieldTeamInfo(teamIndex)
        if name then
            local diff = (newRating or 0) - (oldRating or 0)
            currentMatch:SetTeam(teamIndex, name, newRating, diff, mmr)
        end
    end

    -- Determine win/loss
    if winner == 0 then
        currentMatch.result = 1 -- win (green team = friendly)
    elseif winner == 1 then
        currentMatch.result = 2 -- loss
    else
        currentMatch.result = 0 -- unknown
    end

    -- Try to read per-player scoreboard
    local numScores = Compat.GetNumBattlefieldScores()
    for i = 1, numScores do
        local name, rating, dmg, heal, ratingChange, mmr, spec = Compat.GetBattlefieldScore(i)
        if name then
            currentMatch:SetPlayerEndData(name, rating, dmg, heal, ratingChange, mmr, spec)
        end
    end
end

------------------------------------------------------------
-- Finalize and save match
------------------------------------------------------------
function ArenaReplay:FinalizeMatch()
    if not currentMatch then return end

    currentMatch.endTime = date("%Y-%m-%d %H:%M:%S")
    currentMatch:SetMatchEnd()
    currentMatch:SetBracket()

    -- Don't save empty matches
    if #currentMatch.data < 5 then
        currentMatch = nil
        return
    end

    -- Insert at the beginning (newest first)
    table.insert(ArenaReplayDB.matches, 1, {})
    currentMatch:SaveToVariable(1)

    -- Broadcast end
    AR_Comm:BroadcastEnd()

    local mapName = AR.Data.ARENA_MAPS[currentMatch.map or 0] or "Unknown"
    local resultStr = "???"
    if currentMatch.result == 1 then resultStr = "|cff00ff00WIN|r"
    elseif currentMatch.result == 2 then resultStr = "|cffff0000LOSS|r"
    elseif currentMatch.result == 3 then resultStr = "|cffffff00DRAW|r" end

    print("|cffe392c5<ArenaReplay>|r Match saved: " .. mapName ..
          " (" .. currentMatch.bracket .. "v" .. currentMatch.bracket .. ") - " ..
          resultStr .. " [" .. AR.Util:FormatTime(currentMatch.elapsed) .. "]")

    AR_TableGUI:RefreshIfShowing()
    currentMatch = nil
end

------------------------------------------------------------
-- Match playback
------------------------------------------------------------
function ArenaReplay:PlayMatch(matchIndex)
    local matchData = ArenaReplayDB.matches[matchIndex]
    if not matchData then
        print("|cffe392c5<ArenaReplay>|r " .. L.CONF_NOMATCHES)
        return
    end

    if playStub then
        playStub:Close()
    end

    playStub = AR_PlayStub:New()
    playStub:Init(matchData)
    playStub:Play()
end

------------------------------------------------------------
-- Delete a match
------------------------------------------------------------
function ArenaReplay:DeleteMatch(matchIndex)
    if ArenaReplayDB.matches[matchIndex] then
        table.remove(ArenaReplayDB.matches, matchIndex)
        AR_TableGUI:RefreshIfShowing()
        print("|cffe392c5<ArenaReplay>|r " .. L.CONF_MATCH_DELETED)
    end
end
