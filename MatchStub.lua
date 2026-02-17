local _, AR = ...

------------------------------------------------------------
-- AR_MatchStub: Stores all data for a single arena match
------------------------------------------------------------
AR_MatchStub = {}
AR_MatchStub.__index = AR_MatchStub

function AR_MatchStub:New()
    local self = setmetatable({}, AR_MatchStub)

    self.version    = AR.VERSION
    self.startTime  = date("%Y-%m-%d %H:%M:%S")
    self.endTime    = ""
    self.elapsed    = 0
    self.bracket    = 0  -- 2, 3, or solo shuffle
    self.result     = 0  -- 0 = unknown, 1 = win, 2 = loss, 3 = draw
    self.server     = GetRealmName() or "Unknown"
    self.map        = 0
    self.players    = {} -- keyed by GUID
    self.teams      = { [0] = {}, [1] = {} }
    self.buffs      = {}
    self.debuffs    = {}
    self.data       = {} -- recorded event messages
    self.moveIndex  = 0

    -- Detect current arena map
    local zoneName = C_Map and C_Map.GetBestMapForUnit and C_Map.GetBestMapForUnit("player")
    local zoneText = GetZoneText and GetZoneText() or ""
    if AR.Data.ARENA_MAP_LOOKUP[zoneText] then
        self.map = AR.Data.ARENA_MAP_LOOKUP[zoneText]
    end

    return self
end

------------------------------------------------------------
-- Save match data to saved variables
------------------------------------------------------------
function AR_MatchStub:SaveToVariable(matchID)
    local dest = ArenaReplayDB.matches[matchID]
    if not dest then return end
    for k, v in pairs(self) do
        if k ~= "buffs" and k ~= "debuffs" then
            dest[k] = v
        end
    end
end

------------------------------------------------------------
-- Determine bracket from player count
------------------------------------------------------------
function AR_MatchStub:SetBracket()
    local count = 0
    for _, p in pairs(self.players) do
        if p.team == 1 and p.isPlayer then
            count = count + 1
        end
    end
    self.bracket = count
end

------------------------------------------------------------
-- Add or update a player in the match
------------------------------------------------------------
function AR_MatchStub:AddPlayer(unit, team)
    local guid = UnitGUID(unit)
    if not guid then return nil end

    -- Skip if already tracked
    if self.players[guid] then
        return guid, self.players[guid]
    end

    local nextID = 0
    for _, p in pairs(self.players) do
        if p.ID >= nextID then
            nextID = p.ID + 1
        end
    end

    local _, className = UnitClass(unit)
    local _, raceName  = UnitRace(unit)
    local maxHP = AR.Util:SafeUnitHealthMax(unit)

    self.players[guid] = {
        name         = UnitName(unit) or "Unknown",
        class        = className or "WARRIOR",
        race         = raceName or "Human",
        team         = team,  -- 0 = hostile, 1 = friendly
        isPlayer     = UnitIsPlayer(unit) or false,
        spec         = "",
        ID           = nextID,
        hp           = AR.Util:SafeUnitHealth(unit),
        hpMax        = maxHP,
        startHpMax   = maxHP,
        mana         = 100,
        damageDone   = 0,
        healingDone  = 0,
        highestCrit  = 0,
        highestCritSpell = "Unknown",
        rating       = 0,
        ratingChange = 0,
        mmr          = 0,
    }

    self.buffs[nextID]   = {}
    self.debuffs[nextID] = {}

    return guid, self.players[guid]
end

------------------------------------------------------------
-- Get player ID from GUID
------------------------------------------------------------
function AR_MatchStub:GUIDToID(guid)
    local p = self.players[guid]
    if p and p.isPlayer then
        return p.ID
    end
    return nil
end

------------------------------------------------------------
-- Get GUID from player name
------------------------------------------------------------
function AR_MatchStub:NameToGUID(name)
    local unitIDs = { "party1", "party2", "party3", "party4",
                      "arena1", "arena2", "arena3", "arena4", "arena5" }
    for _, uid in ipairs(unitIDs) do
        if UnitName(uid) == name and UnitGUID(uid) then
            return UnitGUID(uid)
        end
    end
    -- Fallback: search recorded players
    for guid, p in pairs(self.players) do
        if p.name == name then
            return guid
        end
    end
    return nil
end

------------------------------------------------------------
-- GUID to unit ID helper
------------------------------------------------------------
function AR_MatchStub:GUIDToUnit(guid)
    local units = { "player", "party1", "party2", "party3", "party4",
                    "arena1", "arena2", "arena3", "arena4", "arena5" }
    for _, uid in ipairs(units) do
        if UnitGUID(uid) == guid then
            return uid
        end
    end
    return nil
end

------------------------------------------------------------
-- Add damage/healing stats
------------------------------------------------------------
function AR_MatchStub:AddStats(statType, guid, amount, spellName)
    local p = self.players[guid]
    if not p then return end

    if statType == 1 then -- damage
        p.damageDone = p.damageDone + amount
        if amount > p.highestCrit then
            p.highestCrit = amount
            p.highestCritSpell = spellName or "Unknown"
        end
    elseif statType == 2 then -- healing
        p.healingDone = p.healingDone + amount
    end
end

------------------------------------------------------------
-- Update player HP tracking; returns change flags
-- 0x0 = no change, 0x1 = health changed, 0x2 = max health changed
------------------------------------------------------------
function AR_MatchStub:GetHealthChangeFlags(unit)
    local guid = UnitGUID(unit)
    if not guid then return 0x0 end
    local p = self.players[guid]
    if not p then return 0x0 end

    local flags = 0x0
    local newHP = AR.Util:SafeUnitHealth(unit)
    local newMax = AR.Util:SafeUnitHealthMax(unit)

    if p.hp ~= newHP then
        p.hp = newHP
        flags = flags + 0x1
    end
    if p.hpMax ~= newMax then
        p.hpMax = newMax
        flags = flags + 0x2
    end
    return flags
end

------------------------------------------------------------
-- Set arena team info at match end
------------------------------------------------------------
function AR_MatchStub:SetTeam(teamIndex, name, rating, diff, mmr)
    self.teams[teamIndex] = {
        name   = name or "",
        rating = rating or 0,
        diff   = diff or 0,
        mmr    = mmr or 0,
    }
end

------------------------------------------------------------
-- Set player end-of-match data from scoreboard
------------------------------------------------------------
function AR_MatchStub:SetPlayerEndData(name, rating, damageDone, healingDone, ratingChange, mmr, spec)
    local guid = self:NameToGUID(name)
    if not guid then return end
    local p = self.players[guid]
    if not p then return end

    p.rating       = rating or p.rating
    p.damageDone   = damageDone or p.damageDone
    p.healingDone  = healingDone or p.healingDone
    p.ratingChange = ratingChange or p.ratingChange
    p.mmr          = mmr or p.mmr
    if spec and spec ~= "" then
        p.spec = spec
    end
end

------------------------------------------------------------
-- Try to detect opponent spec via API (uses Compat layer)
------------------------------------------------------------
function AR_MatchStub:SetOpponentSpec(guid, opponentIndex)
    local p = self.players[guid]
    if not p then return end
    if p.spec and p.spec ~= "" then return end

    local specID = AR.Compat.GetArenaOpponentSpec(opponentIndex)
    if specID then
        local specName = AR.Compat.GetSpecNameByID(specID)
        if specName then
            p.spec = specName
        end
    end
end

------------------------------------------------------------
-- Set match end timing from recorded data
------------------------------------------------------------
function AR_MatchStub:SetMatchEnd()
    local count = #self.data
    if count < 1 then return end

    local first = AR.Util:Split(self.data[1], ",")
    local last  = AR.Util:Split(self.data[count], ",")
    if first and last and first[1] and last[1] then
        self.elapsed = math.ceil(tonumber(last[1]) - tonumber(first[1]))
    end
end

------------------------------------------------------------
-- Record an event message
------------------------------------------------------------
function AR_MatchStub:RecordEvent(msg)
    self.moveIndex = self.moveIndex + 1
    self.data[self.moveIndex] = msg
end

------------------------------------------------------------
-- Get buffs/debuffs for a player
------------------------------------------------------------
function AR_MatchStub:GetBuffs(id)
    return self.buffs[id]
end

function AR_MatchStub:GetDebuffs(id)
    return self.debuffs[id]
end

------------------------------------------------------------
-- Get all tracked players
------------------------------------------------------------
function AR_MatchStub:GetPlayers()
    return self.players
end

function AR_MatchStub:GetTeams()
    return self.teams
end
