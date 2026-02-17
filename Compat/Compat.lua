local _, AR = ...

------------------------------------------------------------
-- AR.Compat: Multi-version compatibility layer
-- Detects WoW client version and provides unified API wrappers
-- so the rest of the addon doesn't need version-specific branches.
------------------------------------------------------------
AR.Compat = {}
local C = AR.Compat

------------------------------------------------------------
-- Version detection
-- Supported clients:
--   Midnight (Retail)         = WOW_PROJECT_MAINLINE (1)
--   BCC Anniversary Edition   = WOW_PROJECT_BURNING_CRUSADE_CLASSIC (5)
--   MoP Classic               = WOW_PROJECT_MISTS_CLASSIC (19)
------------------------------------------------------------
local _, build, _, tocVersion = GetBuildInfo()
tocVersion = tocVersion or 0

local projectID = WOW_PROJECT_ID or 1

C.isRetail     = (projectID == (WOW_PROJECT_MAINLINE or 1))
C.isTBC        = (projectID == (WOW_PROJECT_BURNING_CRUSADE_CLASSIC or 5))
C.isMoP        = (projectID == (WOW_PROJECT_MISTS_CLASSIC or 19))

-- Catch-all for any Classic client
C.isClassicAny = not C.isRetail

-- Interface version number for fine-grained checks
C.tocVersion = tocVersion

------------------------------------------------------------
-- Feature flags
------------------------------------------------------------
C.hasArenas         = true
C.hasRatedPvP       = true
C.hasSoloShuffle    = C.isRetail
C.hasBlitz          = C.isRetail
C.hasRBG            = C.isRetail or C.isMoP
C.has5v5            = C.isTBC or C.isMoP
C.hasSpecAPI        = C.isRetail or C.isMoP  -- GetSpecialization() exists in MoP+
C.hasSecretValues   = C.isRetail and (tocVersion >= 110000)
C.hasBackdropMixin  = C.isRetail
C.hasC_Spell        = C.isRetail and (tocVersion >= 110000)
C.hasC_PvP          = C.isRetail
C.hasNewAuraAPI     = C.isRetail and (tocVersion >= 100000)
C.hasC_Map          = (C_Map and C_Map.GetBestMapForUnit) ~= nil

------------------------------------------------------------
-- Version string for display
------------------------------------------------------------
function C.GetVersionTag()
    if C.isRetail then return "Midnight" end
    if C.isMoP    then return "MoP Classic" end
    if C.isTBC    then return "BCC Anniversary" end
    return "Unknown"
end

------------------------------------------------------------
-- API Wrappers: Spell Info
------------------------------------------------------------
function C.GetSpellInfo(spellID)
    if not spellID or spellID == 0 then
        return nil, nil, nil
    end
    -- Retail 11.0+: C_Spell.GetSpellInfo returns a table
    if C.hasC_Spell and C_Spell and C_Spell.GetSpellInfo then
        local info = C_Spell.GetSpellInfo(spellID)
        if info then
            return info.name, info.iconID, info.castTime
        end
    end
    -- Classic / older Retail: GetSpellInfo returns multiple values
    if GetSpellInfo then
        local name, _, icon, castTime = GetSpellInfo(spellID)
        return name, icon, castTime
    end
    return nil, nil, nil
end

------------------------------------------------------------
-- API Wrappers: Unit Health (handles secret values in Retail)
------------------------------------------------------------
if C.hasSecretValues then
    local issecretvalue = issecretvalue or function() return false end

    function C.SafeUnitHealth(unit)
        local ok, hp = pcall(UnitHealth, unit)
        if ok and hp and type(hp) == "number" and not issecretvalue(hp) then
            return hp
        end
        return 0
    end

    function C.SafeUnitHealthMax(unit)
        local ok, hp = pcall(UnitHealthMax, unit)
        if ok and hp and type(hp) == "number" and not issecretvalue(hp) then
            return hp
        end
        return 1
    end
else
    function C.SafeUnitHealth(unit)
        return UnitHealth(unit) or 0
    end

    function C.SafeUnitHealthMax(unit)
        return UnitHealthMax(unit) or 1
    end
end

------------------------------------------------------------
-- API Wrappers: Backdrop (BackdropTemplate mixin vs legacy)
------------------------------------------------------------
function C.ApplyBackdrop(frame, backdrop)
    if not frame then return end
    if frame.SetBackdrop then
        frame:SetBackdrop(backdrop)
    end
end

function C.CreateFrameWithBackdrop(frameType, name, parent)
    if C.hasBackdropMixin then
        return CreateFrame(frameType, name, parent, "BackdropTemplate")
    else
        return CreateFrame(frameType, name, parent)
    end
end

------------------------------------------------------------
-- API Wrappers: Arena / PvP
------------------------------------------------------------
function C.GetArenaOpponentSpec(index)
    if not GetArenaOpponentSpec then return nil end
    local ok, specID = pcall(GetArenaOpponentSpec, index)
    if ok and specID and type(specID) == "number" and specID > 0 then
        return specID
    end
    return nil
end

function C.GetBattlefieldWinner()
    if not GetBattlefieldWinner then return nil end
    local ok, winner = pcall(GetBattlefieldWinner)
    if ok then return winner end
    return nil
end

function C.GetBattlefieldTeamInfo(teamIndex)
    if not GetBattlefieldTeamInfo then return nil end
    local ok, name, oldRating, newRating, mmr = pcall(GetBattlefieldTeamInfo, teamIndex)
    if ok and name then
        return name, oldRating, newRating, mmr
    end
    return nil
end

function C.GetNumBattlefieldScores()
    if not GetNumBattlefieldScores then return 0 end
    local ok, num = pcall(GetNumBattlefieldScores)
    if ok and num then return num end
    return 0
end

function C.GetBattlefieldScore(index)
    if not GetBattlefieldScore then return nil end
    local ok, name, _, _, _, _, _, _, _, _, _, dmg, heal, _, _, _, rating, ratingChange, mmr, spec =
        pcall(GetBattlefieldScore, index)
    if ok and name then
        return name, rating, dmg, heal, ratingChange, mmr, spec
    end
    return nil
end

------------------------------------------------------------
-- API Wrappers: MMR / Rating
------------------------------------------------------------
local issecretvalue = issecretvalue or function() return false end

function C.GetPersonalRatedInfo(bracketID)
    if not GetPersonalRatedInfo then return 0, 0, 0, 0 end
    local ok, r, seasonPlayed, seasonWon, weeklyPlayed, weeklyWon, _mmr =
        pcall(GetPersonalRatedInfo, bracketID)
    local rating, mmr, wins, losses = 0, 0, 0, 0
    if ok then
        if r and type(r) == "number" and not issecretvalue(r) then rating = r end
        if _mmr and type(_mmr) == "number" and not issecretvalue(_mmr) then mmr = _mmr end
        if seasonPlayed and seasonWon
            and type(seasonPlayed) == "number" and type(seasonWon) == "number"
            and not issecretvalue(seasonPlayed) and not issecretvalue(seasonWon) then
            wins = seasonWon
            losses = seasonPlayed - seasonWon
        end
    end
    return rating, mmr, wins, losses
end

function C.GetSoloShuffleMMR()
    if not C.hasSoloShuffle then return 0 end
    if C_PvP and C_PvP.GetRatedSoloShuffleMMR then
        local ok, result = pcall(C_PvP.GetRatedSoloShuffleMMR)
        if ok and result and type(result) == "number" and not issecretvalue(result) then
            return result
        end
    end
    return 0
end

function C.GetBlitzMMR()
    if not C.hasBlitz then return 0 end
    if C_PvP and C_PvP.GetRatedSoloRBGMMR then
        local ok, result = pcall(C_PvP.GetRatedSoloRBGMMR)
        if ok and result and type(result) == "number" and not issecretvalue(result) then
            return result
        end
    end
    return 0
end

------------------------------------------------------------
-- API Wrappers: Specialization
------------------------------------------------------------
function C.GetPlayerSpec()
    if GetSpecialization and GetSpecializationInfo then
        local specIndex = GetSpecialization()
        if specIndex then
            local _, specName = GetSpecializationInfo(specIndex)
            return specName or ""
        end
    end
    -- BCC Anniversary: no spec API
    return ""
end

function C.GetSpecNameByID(specID)
    if not specID or specID <= 0 then return nil end
    if GetSpecializationInfoByID then
        local _, specName = GetSpecializationInfoByID(specID)
        return specName
    end
    return nil
end

------------------------------------------------------------
-- API Wrappers: Queue / Battlefield status
------------------------------------------------------------
function C.IsInPvPQueue()
    if not GetMaxBattlefieldID then return false end
    local ok, maxID = pcall(GetMaxBattlefieldID)
    if not ok or not maxID then return false end
    for i = 1, maxID do
        local ok2, status = pcall(GetBattlefieldStatus, i)
        if ok2 and (status == "queued" or status == "confirm") then
            return true
        end
    end
    return false
end
