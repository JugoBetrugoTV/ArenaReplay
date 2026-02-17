local _, AR = ...

------------------------------------------------------------
-- AR_MMRTracker: Tracks MMR and Rating across all PvP brackets
-- Version-aware: brackets vary by expansion
------------------------------------------------------------
AR_MMRTracker = {}
local MMR = AR_MMRTracker
local Compat = AR.Compat

------------------------------------------------------------
-- Bracket definitions (version-dependent)
-- PvP bracket IDs: 1=2v2, 2=3v3, 4=5v5, 3=RBG, 6=Shuffle, 8=Blitz
------------------------------------------------------------
local ALL_BRACKETS = {
    [1] = { id = 1, name = "2v2",     hasMMR = false, short = "2v2" },
    [2] = { id = 2, name = "3v3",     hasMMR = false, short = "3v3" },
    [4] = { id = 4, name = "5v5",     hasMMR = false, short = "5v5" },
    [3] = { id = 3, name = "RBG",     hasMMR = false, short = "RBG" },
    [6] = { id = 6, name = "Shuffle", hasMMR = true,  short = "Shuffle" },
    [8] = { id = 8, name = "Blitz",   hasMMR = true,  short = "Blitz" },
}

-- Build version-specific bracket tables
if Compat.isRetail then
    -- Midnight: 2v2, 3v3, RBG, Solo Shuffle, Blitz
    MMR.BRACKETS = {
        [1] = ALL_BRACKETS[1],
        [2] = ALL_BRACKETS[2],
        [3] = ALL_BRACKETS[3],
        [6] = ALL_BRACKETS[6],
        [8] = ALL_BRACKETS[8],
    }
    MMR.BRACKET_ORDER = { 1, 2, 3, 6, 8 }
elseif Compat.isMoP then
    -- MoP Classic: 2v2, 3v3, 5v5, RBG
    MMR.BRACKETS = {
        [1] = ALL_BRACKETS[1],
        [2] = ALL_BRACKETS[2],
        [4] = ALL_BRACKETS[4],
        [3] = ALL_BRACKETS[3],
    }
    MMR.BRACKET_ORDER = { 1, 2, 4, 3 }
else
    -- BCC Anniversary: 2v2, 3v3, 5v5
    MMR.BRACKETS = {
        [1] = ALL_BRACKETS[1],
        [2] = ALL_BRACKETS[2],
        [4] = ALL_BRACKETS[4],
    }
    MMR.BRACKET_ORDER = { 1, 2, 4 }
end

------------------------------------------------------------
-- Time filter modes
------------------------------------------------------------
MMR.TIME_FILTERS = {
    { id = "all",       name = "All Time" },
    { id = "today",     name = "Today" },
    { id = "yesterday", name = "Yesterday" },
    { id = "week",      name = "This Week" },
    { id = "lastweek",  name = "Last Week" },
    { id = "month",     name = "This Month" },
    { id = "lastmonth", name = "Last Month" },
    { id = "season",    name = "This Season" },
}

------------------------------------------------------------
-- Initialize MMR tracking
------------------------------------------------------------
function MMR:Init()
    if not ArenaReplayDB.mmr then
        ArenaReplayDB.mmr = {
            games = {},
            display = {},
        }
    end
    -- Ensure games table exists
    if not ArenaReplayDB.mmr.games then
        ArenaReplayDB.mmr.games = {}
    end
    -- Ensure display sub-table exists (may be nil after settings reset)
    if not ArenaReplayDB.mmr.display then
        ArenaReplayDB.mmr.display = {}
    end
    -- Fill in missing display defaults
    local displayDefaults = {
        show2v2     = true,
        show3v3     = true,
        show5v5     = Compat.has5v5 or false,
        showRBG     = Compat.hasRBG or false,
        showShuffle = Compat.hasSoloShuffle or false,
        showBlitz   = Compat.hasBlitz or false,
        showMMRDiff = true,
        showGains   = true,
        hideNoData  = false,
        lock        = false,
        position    = { "CENTER", "CENTER", 0, 200 },
        fontSize    = 13,
        fontFamily  = "Friz Quadrata TT",
        textColor   = { r = 1, g = 1, b = 1, a = 1 },
        showOnlyInQueue = false,
        showInPVP   = false,
        showInPVE   = true,
        classColors  = true,
        winLossIcons = true,
    }
    for k, v in pairs(displayDefaults) do
        if ArenaReplayDB.mmr.display[k] == nil then
            ArenaReplayDB.mmr.display[k] = v
        end
    end
end

------------------------------------------------------------
-- Get current rating/MMR for a bracket (uses Compat wrappers)
-- Returns: rating, mmr, seasonWins, seasonLosses
------------------------------------------------------------
function MMR:GetBracketData(bracketID)
    local rating, mmr, wins, losses = 0, 0, 0, 0

    -- Solo Shuffle (bracket 6) and Blitz (bracket 8) use dedicated MMR APIs
    if bracketID == 6 then
        mmr = Compat.GetSoloShuffleMMR()
    elseif bracketID == 8 then
        mmr = Compat.GetBlitzMMR()
    end

    -- Get rating info from standard API
    local r, _mmr, w, l = Compat.GetPersonalRatedInfo(bracketID)
    rating = r
    if _mmr > 0 then mmr = _mmr end
    wins = w
    losses = l

    return rating, mmr, wins, losses
end

------------------------------------------------------------
-- Record a PvP match result
------------------------------------------------------------
function MMR:RecordMatch(bracketID, spec, mapName, beforeRating, afterRating, beforeMMR, afterMMR, won)
    self:Init()

    local ratingChange = afterRating - beforeRating
    local mmrChange = afterMMR - beforeMMR
    local bracketInfo = self.BRACKETS[bracketID]
    if not bracketInfo then return end

    -- Use MMR for shuffle/blitz, rating for others
    local before, after, change
    if bracketInfo.hasMMR and beforeMMR > 0 then
        before = beforeMMR
        after  = afterMMR
        change = mmrChange
    else
        before = beforeRating
        after  = afterRating
        change = ratingChange
    end

    -- Store class token for class-colored display
    local _, classToken = UnitClass("player")

    local entry = {
        bracket    = bracketID,
        name       = bracketInfo.name,
        spec       = spec or "",
        classToken = classToken or "",
        map        = mapName or "",
        before     = before,
        change     = change,
        after      = after,
        won        = won,
        date       = date("%Y-%m-%d %H:%M:%S"),
        timestamp  = time(),
        character  = UnitName("player") .. "-" .. GetRealmName(),
        region     = GetCurrentRegion and GetCurrentRegion() or 1,
    }

    table.insert(ArenaReplayDB.mmr.games, 1, entry) -- newest first
end

------------------------------------------------------------
-- Snapshot current ratings (call before match starts)
------------------------------------------------------------
local preMatchRatings = {}

function MMR:SnapshotPreMatch()
    preMatchRatings = {}
    for _, bracketID in ipairs(self.BRACKET_ORDER) do
        local rating, mmr = self:GetBracketData(bracketID)
        preMatchRatings[bracketID] = {
            rating = rating,
            mmr    = mmr,
        }
    end
end

function MMR:GetPreMatchData(bracketID)
    return preMatchRatings[bracketID]
end

------------------------------------------------------------
-- Process match completion (called from Core.lua on PVP_MATCH_COMPLETE)
------------------------------------------------------------
function MMR:OnMatchComplete()
    -- Determine which bracket we were in
    local bracketID = nil
    local inInstance, instanceType = IsInInstance()
    if not inInstance then return end

    -- Detect bracket from active rated match
    for _, bid in ipairs(self.BRACKET_ORDER) do
        local rating, mmr = self:GetBracketData(bid)
        local pre = self:GetPreMatchData(bid)
        if pre then
            -- If rating or MMR changed, this is our bracket
            if (rating ~= pre.rating) or (mmr ~= pre.mmr) then
                bracketID = bid
                break
            end
        end
    end

    -- Fallback: detect from arena bracket size
    if not bracketID then
        if instanceType == "arena" then
            local numPlayers = GetNumGroupMembers() or 0
            if numPlayers <= 2 then bracketID = 1
            elseif numPlayers <= 3 then bracketID = 2
            else bracketID = 6 end -- assume shuffle for larger
        elseif instanceType == "pvp" then
            bracketID = 3 -- RBG
        end
    end

    if not bracketID then return end

    local pre = self:GetPreMatchData(bracketID)
    if not pre then
        pre = { rating = 0, mmr = 0 }
    end

    local afterRating, afterMMR = self:GetBracketData(bracketID)

    -- Determine win/loss
    local won = false
    local winner = Compat.GetBattlefieldWinner()
    if winner == 0 then
        won = true
    end

    -- Get spec
    local spec = Compat.GetPlayerSpec()

    -- Get map
    local mapName = GetZoneText and GetZoneText() or ""

    -- Record the match
    self:RecordMatch(bracketID, spec, mapName, pre.rating, afterRating, pre.mmr, afterMMR, won)

    -- Print to chat
    local bracketInfo = self.BRACKETS[bracketID]
    local change = afterRating - pre.rating
    if bracketInfo.hasMMR and pre.mmr > 0 then
        change = afterMMR - pre.mmr
    end

    local changeStr
    if change > 0 then
        changeStr = "|cff00ff00+" .. change .. "|r"
    elseif change < 0 then
        changeStr = "|cffff0000" .. change .. "|r"
    else
        changeStr = "|cffffff00+0|r"
    end

    local displayVal = bracketInfo.hasMMR and afterMMR or afterRating
    local displayLabel = bracketInfo.hasMMR and "MMR" or "Rating"
    print("|cffe392c5<ArenaReplay>|r " .. bracketInfo.name .. " " ..
          displayLabel .. ": " .. displayVal .. " (" .. changeStr .. ")")
end

------------------------------------------------------------
-- Get all recorded games, optionally filtered
------------------------------------------------------------
function MMR:GetGames(filters)
    self:Init()

    local games = ArenaReplayDB.mmr.games
    if not filters then return games end

    local result = {}
    for _, game in ipairs(games) do
        local pass = true

        -- Bracket filter
        if filters.bracket and filters.bracket ~= "all" then
            local bracketInfo = self.BRACKETS[game.bracket]
            if bracketInfo and bracketInfo.short ~= filters.bracket then
                pass = false
            end
        end

        -- Character filter
        if pass and filters.character and filters.character ~= "all" then
            if game.character ~= filters.character then
                pass = false
            end
        end

        -- Spec filter
        if pass and filters.spec and filters.spec ~= "all" then
            if game.spec ~= filters.spec then
                pass = false
            end
        end

        -- Map filter
        if pass and filters.map and filters.map ~= "all" then
            if game.map ~= filters.map then
                pass = false
            end
        end

        -- Time filter
        if pass and filters.time and filters.time ~= "all" then
            pass = self:PassesTimeFilter(game.timestamp, filters.time)
        end

        if pass then
            table.insert(result, game)
        end
    end

    return result
end

------------------------------------------------------------
-- Time filter evaluation
------------------------------------------------------------
function MMR:PassesTimeFilter(timestamp, filterID)
    if not timestamp then return true end

    local now = time()
    local todayMidnight = time({
        year = date("*t").year,
        month = date("*t").month,
        day = date("*t").day,
        hour = 0, min = 0, sec = 0
    })

    if filterID == "today" then
        return timestamp >= todayMidnight
    elseif filterID == "yesterday" then
        local yesterdayStart = todayMidnight - 86400
        return timestamp >= yesterdayStart and timestamp < todayMidnight
    elseif filterID == "week" then
        local wday = date("*t").wday
        local weekStart = todayMidnight - ((wday - 2) % 7) * 86400 -- Monday start
        return timestamp >= weekStart
    elseif filterID == "lastweek" then
        local wday = date("*t").wday
        local weekStart = todayMidnight - ((wday - 2) % 7) * 86400
        local lastWeekStart = weekStart - 7 * 86400
        return timestamp >= lastWeekStart and timestamp < weekStart
    elseif filterID == "month" then
        local monthStart = time({
            year = date("*t").year,
            month = date("*t").month,
            day = 1, hour = 0, min = 0, sec = 0
        })
        return timestamp >= monthStart
    elseif filterID == "lastmonth" then
        local dt = date("*t")
        local thisMonthStart = time({ year = dt.year, month = dt.month, day = 1, hour = 0, min = 0, sec = 0 })
        local lastMonth = dt.month - 1
        local lastYear = dt.year
        if lastMonth < 1 then lastMonth = 12; lastYear = lastYear - 1 end
        local lastMonthStart = time({ year = lastYear, month = lastMonth, day = 1, hour = 0, min = 0, sec = 0 })
        return timestamp >= lastMonthStart and timestamp < thisMonthStart
    elseif filterID == "season" then
        -- Approximate: current PvP season (roughly 4 months)
        local seasonStart = todayMidnight - (120 * 86400)
        return timestamp >= seasonStart
    end

    return true
end

------------------------------------------------------------
-- Get summary stats for a bracket
------------------------------------------------------------
function MMR:GetBracketSummary(bracketID, filters)
    local games = self:GetGames(filters)
    local totalGames, wins, losses = 0, 0, 0
    local totalGain, totalLoss = 0, 0
    local bestWin, worstLoss = 0, 0
    local currentStreak, bestStreak = 0, 0

    for _, game in ipairs(games) do
        if game.bracket == bracketID then
            totalGames = totalGames + 1
            if game.won then
                wins = wins + 1
                currentStreak = currentStreak + 1
                if currentStreak > bestStreak then bestStreak = currentStreak end
                if game.change > 0 then
                    totalGain = totalGain + game.change
                    if game.change > bestWin then bestWin = game.change end
                end
            else
                losses = losses + 1
                currentStreak = 0
                if game.change < 0 then
                    totalLoss = totalLoss + math.abs(game.change)
                    if math.abs(game.change) > worstLoss then worstLoss = math.abs(game.change) end
                end
            end
        end
    end

    local winRate = totalGames > 0 and (wins / totalGames * 100) or 0

    return {
        total     = totalGames,
        wins      = wins,
        losses    = losses,
        winRate   = winRate,
        totalGain = totalGain,
        totalLoss = totalLoss,
        netChange = totalGain - totalLoss,
        bestWin   = bestWin,
        worstLoss = worstLoss,
        bestStreak = bestStreak,
    }
end

------------------------------------------------------------
-- Get current ratings for all brackets (for display)
------------------------------------------------------------
function MMR:GetAllBracketDisplayData()
    local result = {}
    for _, bracketID in ipairs(self.BRACKET_ORDER) do
        local rating, mmr, wins, losses = self:GetBracketData(bracketID)
        local bracketInfo = self.BRACKETS[bracketID]
        result[bracketID] = {
            name    = bracketInfo.name,
            short   = bracketInfo.short,
            hasMMR  = bracketInfo.hasMMR,
            rating  = rating,
            mmr     = mmr,
            wins    = wins,
            losses  = losses,
            display = bracketInfo.hasMMR and mmr or rating,
            label   = bracketInfo.hasMMR and "MMR" or "Rating",
        }
    end
    return result
end

------------------------------------------------------------
-- Get unique filter values from recorded games
------------------------------------------------------------
function MMR:GetFilterOptions()
    self:Init()

    local characters = {}
    local specs = {}
    local maps = {}

    for _, game in ipairs(ArenaReplayDB.mmr.games) do
        if game.character and game.character ~= "" then
            characters[game.character] = true
        end
        if game.spec and game.spec ~= "" then
            specs[game.spec] = true
        end
        if game.map and game.map ~= "" then
            maps[game.map] = true
        end
    end

    return characters, specs, maps
end
