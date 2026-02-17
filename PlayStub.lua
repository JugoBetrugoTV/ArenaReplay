local _, AR = ...

------------------------------------------------------------
-- AR_PlayStub: Match playback / replay controller
------------------------------------------------------------
AR_PlayStub = {}
AR_PlayStub.__index = AR_PlayStub

local C = AR.GUI_CONST

function AR_PlayStub:New()
    local self = setmetatable({}, AR_PlayStub)

    self.matchData  = nil
    self.data       = nil   -- event data array
    self.entities   = {}    -- AR_PlayerEntity objects, keyed by ID
    self.frame      = nil   -- main player frame
    self.seeker     = nil   -- AR_Seeker
    self.statsFrame = nil
    self.teamStats  = {}    -- AR_TeamStats objects
    self.showStats  = false

    -- Playback state
    self.playing     = false
    self.elapsed     = 0
    self.speed       = 1.0
    self.dataIndex   = 1
    self.startTime   = 0

    -- Animation pools
    self.combatTexts = {}
    self.skills      = {}
    self.crowds      = {}
    self.cooldowns   = {}

    return self
end

------------------------------------------------------------
-- Initialize playback with match data
------------------------------------------------------------
function AR_PlayStub:Init(matchData)
    self.matchData = matchData
    self.data      = matchData.data
    self.elapsed   = 0
    self.dataIndex = 1
    self.playing   = false
    self.showStats = false

    -- Determine start time from first event
    if self.data and self.data[1] then
        local parts = AR.Util:Split(self.data[1], ",")
        if parts and parts[1] then
            self.startTime = tonumber(parts[1]) or 0
        end
    end

    -- Create main frame
    if not self.frame then
        self.frame = AR_GUI:CreatePlayerFrame()
    end

    -- Create seeker
    if not self.seeker then
        self.seeker = AR_Seeker:New(self.frame)
    end
    self.seeker:SetRange(0, matchData.elapsed or 100)
    self.seeker:SetValue(0)
    self.seeker:SetTimeText("00:00")

    -- Seeker drag callback
    self.seeker:SetOnValueChanged(function(slider, val)
        if not self.playing then
            self:SeekTo(val)
        end
    end)

    -- Speed callback
    self.seeker:SetSpeedCallback(function(newSpeed)
        self.speed = newSpeed
    end)

    -- Stats frame
    if not self.statsFrame then
        self.statsFrame = AR_GUI:CreateStatsFrame(self.frame)
    end

    -- Team stats
    if not self.teamStats[0] then
        self.teamStats[0] = AR_TeamStats:New(self.statsFrame, 0)
    end
    if not self.teamStats[1] then
        self.teamStats[1] = AR_TeamStats:New(self.statsFrame, 1)
    end

    -- Create player entities
    self:CreateEntities()

    -- Stats/Match toggle button
    if not self.toggleBtn then
        local btn = CreateFrame("Button", nil, self.frame, "GameMenuButtonTemplate")
        btn:SetSize(90, 22)
        btn:SetPoint("TOPRIGHT", self.frame, "TOPRIGHT", -40, -5)
        btn:SetText(LibStub("AceLocale-3.0"):GetLocale("ArenaReplay", true).VIEW_STATS)
        btn:SetScript("OnClick", function()
            self.showStats = not self.showStats
            if self.showStats then
                self.statsFrame:Show()
                self.teamStats[0]:SetValue(self.matchData, 0)
                self.teamStats[1]:SetValue(self.matchData, 1)
                btn:SetText(LibStub("AceLocale-3.0"):GetLocale("ArenaReplay", true).VIEW_MATCH)
            else
                self.statsFrame:Hide()
                btn:SetText(LibStub("AceLocale-3.0"):GetLocale("ArenaReplay", true).VIEW_STATS)
            end
        end)
        self.toggleBtn = btn
    end

    -- Map title
    local mapName = AR.Data.ARENA_MAPS[matchData.map or 0] or "Unknown"
    self.frame.titleText:SetText("ArenaReplay - " .. mapName)

    self.frame:Show()
end

------------------------------------------------------------
-- Create entity frames from match player data
------------------------------------------------------------
function AR_PlayStub:CreateEntities()
    -- Clear old entities
    for _, e in pairs(self.entities) do
        e:Hide()
    end
    self.entities = {}

    if not self.matchData or not self.matchData.players then return end

    -- Separate into teams and sort by ID
    local friendly = {}
    local hostile  = {}
    for guid, p in pairs(self.matchData.players) do
        if p.isPlayer then
            if p.team == 1 then
                table.insert(friendly, p)
            else
                table.insert(hostile, p)
            end
        end
    end

    table.sort(friendly, function(a, b) return a.ID < b.ID end)
    table.sort(hostile,  function(a, b) return a.ID < b.ID end)

    for i, p in ipairs(friendly) do
        local entity = AR_PlayerEntity:New(self.frame, p, i - 1, p.startHpMax or p.hpMax)
        entity:SetValue(p.class, p.name, p.startHpMax or p.hpMax, p)
        self.entities[p.ID] = entity
    end

    for i, p in ipairs(hostile) do
        local entity = AR_PlayerEntity:New(self.frame, p, i - 1, p.startHpMax or p.hpMax)
        entity:SetValue(p.class, p.name, p.startHpMax or p.hpMax, p)
        self.entities[p.ID] = entity
    end
end

------------------------------------------------------------
-- Start/stop playback
------------------------------------------------------------
function AR_PlayStub:Play()
    self.playing = true
    self.frame:SetScript("OnUpdate", function(f, elapsed)
        self:OnUpdate(elapsed)
    end)
end

function AR_PlayStub:Stop()
    self.playing = false
    if self.frame then
        self.frame:SetScript("OnUpdate", nil)
    end
end

function AR_PlayStub:Toggle()
    if self.playing then
        self:Stop()
    else
        self:Play()
    end
end

------------------------------------------------------------
-- Seek to a specific time in the match
------------------------------------------------------------
function AR_PlayStub:SeekTo(targetTime)
    -- Reset all visuals
    self:ResetVisuals()
    self.elapsed   = targetTime
    self.dataIndex = 1

    -- Find the data index for targetTime
    if self.data then
        for i, msg in ipairs(self.data) do
            local parts = AR.Util:Split(msg, ",")
            if parts and parts[1] then
                local t = (tonumber(parts[1]) or 0) - self.startTime
                if t > targetTime then
                    self.dataIndex = i
                    break
                end
                -- Apply HP events up to this point
                self:ProcessEvent(parts, true) -- silent mode
            end
            self.dataIndex = i + 1
        end
    end

    self.seeker:SetTimeText(AR.Util:FormatTime(math.floor(targetTime)))
end

------------------------------------------------------------
-- Reset visual elements
------------------------------------------------------------
function AR_PlayStub:ResetVisuals()
    for _, ct in ipairs(self.combatTexts) do ct:Hide() end
    self.combatTexts = {}

    for _, sk in ipairs(self.skills) do sk:Hide() end
    self.skills = {}

    for _, cc in ipairs(self.crowds) do cc:SetDead() end
    self.crowds = {}

    for _, cd in ipairs(self.cooldowns) do
        cd.frame:Hide()
    end
    self.cooldowns = {}

    for _, e in pairs(self.entities) do
        e:RemoveAllAuras()
        e:RemoveAllCooldowns()
    end
end

------------------------------------------------------------
-- Main update loop
------------------------------------------------------------
function AR_PlayStub:OnUpdate(elapsed)
    if not self.playing or not self.data then return end

    local dt = elapsed * self.speed
    self.elapsed = self.elapsed + dt

    -- Process events up to current elapsed time
    while self.dataIndex <= #self.data do
        local msg = self.data[self.dataIndex]
        local parts = AR.Util:Split(msg, ",")
        if not parts or not parts[1] then
            self.dataIndex = self.dataIndex + 1
        else
            local eventTime = (tonumber(parts[1]) or 0) - self.startTime
            if eventTime <= self.elapsed then
                self:ProcessEvent(parts, false)
                self.dataIndex = self.dataIndex + 1
            else
                break
            end
        end
    end

    -- Update seeker
    self.seeker:SetValue(self.elapsed)
    self.seeker:SetTimeText(AR.Util:FormatTime(math.floor(self.elapsed)))

    -- Animate combat text
    for i = #self.combatTexts, 1, -1 do
        local ct = self.combatTexts[i]
        ct:MoveText(dt)
        if ct:IsDead() then
            ct:Hide()
            table.remove(self.combatTexts, i)
        end
    end

    -- Animate skill icons
    for i = #self.skills, 1, -1 do
        local sk = self.skills[i]
        sk:MoveSkill(dt)
        if sk:IsDead() then
            sk:Hide()
            table.remove(self.skills, i)
        end
    end

    -- Update crowd control overlays
    for i = #self.crowds, 1, -1 do
        local cc = self.crowds[i]
        cc:Update(dt)
        if cc:IsDead() then
            table.remove(self.crowds, i)
        end
    end

    -- Update cooldowns
    for _, e in pairs(self.entities) do
        for i = #e.cooldowns, 1, -1 do
            local cd = e.cooldowns[i]
            cd:Update(dt)
            if cd:IsDead() then
                cd.frame:Hide()
                table.remove(e.cooldowns, i)
            end
        end
        e:ArrangeCooldowns()
    end

    -- Check if playback finished
    if self.dataIndex > #self.data then
        self:Stop()
    end
end

------------------------------------------------------------
-- Process a single recorded event
-- parts: split message array
-- silent: if true, only apply state changes (no visuals)
------------------------------------------------------------
function AR_PlayStub:ProcessEvent(parts, silent)
    if not parts or #parts < 2 then return end

    local eventType = parts[2]

    -- HP = health update: time,HP,entityID,currentHP,maxHP
    if eventType == "HP" then
        local id    = tonumber(parts[3])
        local hp    = tonumber(parts[4]) or 0
        local maxHP = tonumber(parts[5]) or 1
        local entity = self.entities[id]
        if entity then
            entity.bar:SetMinMaxValues(0, maxHP)
            entity.bar:SetValue(hp)
            entity:UpdateHealthText()
        end

    -- D = damage: time,D,sourceID,destID,amount,spellID,crit
    elseif eventType == "D" then
        local sourceID = tonumber(parts[3])
        local destID   = tonumber(parts[4])
        local amount   = tonumber(parts[5]) or 0
        local spellID  = tonumber(parts[6]) or 0
        local crit     = tonumber(parts[7]) or 0
        local entity   = self.entities[destID]
        if entity and not silent then
            local ct = AR_CombatText:New(entity.bar, entity.team, 1, amount, crit)
            table.insert(self.combatTexts, ct)
        end
        -- Show skill used
        if not silent and spellID > 0 then
            self:ShowSkillUsed(sourceID, spellID, false, destID)
        end

    -- H = heal: time,H,sourceID,destID,amount,spellID,crit
    elseif eventType == "H" then
        local sourceID = tonumber(parts[3])
        local destID   = tonumber(parts[4])
        local amount   = tonumber(parts[5]) or 0
        local spellID  = tonumber(parts[6]) or 0
        local crit     = tonumber(parts[7]) or 0
        local entity   = self.entities[destID]
        if entity and not silent then
            local ct = AR_CombatText:New(entity.bar, entity.team, 2, amount, crit)
            table.insert(self.combatTexts, ct)
        end
        if not silent and spellID > 0 then
            self:ShowSkillUsed(sourceID, spellID, false, destID)
        end

    -- SC = spell cast: time,SC,sourceID,spellID,isCast
    elseif eventType == "SC" then
        local sourceID = tonumber(parts[3])
        local spellID  = tonumber(parts[4]) or 0
        local isCast   = (parts[5] == "1")
        if not silent and spellID > 0 then
            self:ShowSkillUsed(sourceID, spellID, isCast, nil)
        end

    -- AA = aura applied: time,AA,entityID,spellID,type(1=buff/2=debuff),duration
    elseif eventType == "AA" then
        local entityID = tonumber(parts[3])
        local spellID  = tonumber(parts[4]) or 0
        local auraType = tonumber(parts[5]) or 1
        local duration = tonumber(parts[6]) or 0
        local entity   = self.entities[entityID]
        if entity then
            entity:AddAura(spellID, auraType, duration)

            -- Check if this is an important CC skill
            if not silent and AR.Data.IMPORTANT_SKILLS[spellID] and AR.Data.IMPORTANT_SKILLS[spellID] == 3 then
                self:ShowCC(entityID, spellID, duration)
            end
        end

    -- AR = aura removed: time,AR,entityID,spellID,type
    elseif eventType == "AR" then
        local entityID = tonumber(parts[3])
        local spellID  = tonumber(parts[4]) or 0
        local auraType = tonumber(parts[5]) or 1
        local entity   = self.entities[entityID]
        if entity then
            entity:RemoveAura(spellID, auraType)
        end

    -- CD = cooldown used: time,CD,entityID,spellID,duration
    elseif eventType == "CD" then
        if not silent then
            local entityID = tonumber(parts[3])
            local spellID  = tonumber(parts[4]) or 0
            local duration = tonumber(parts[5]) or 0
            local entity   = self.entities[entityID]
            if entity then
                local cd = AR_Cooldown:New(entity.cdrange)
                cd.position = #entity.cooldowns
                cd:SetValue(spellID, duration, entityID, entity.cdrange)
                entity:AddCooldown(cd)
            end
        end

    -- X = death: time,X,entityID
    elseif eventType == "X" then
        local entityID = tonumber(parts[3])
        local entity   = self.entities[entityID]
        if entity then
            entity.bar:SetValue(0)
            entity:UpdateHealthText()
            entity:SetOpacity(0.5)
        end

    -- I = interrupt: time,I,sourceID,destID,spellID
    elseif eventType == "I" then
        if not silent then
            local destID  = tonumber(parts[4])
            -- Mark most recent skill of dest as interrupted
            for i = #self.skills, 1, -1 do
                local sk = self.skills[i]
                if sk.entityID == destID and sk:IsCasting() then
                    if not sk.interrupt then
                        sk.interrupt = AR_GUI:CreateInterruptFrame(sk.frame)
                    end
                    sk.interrupt:Show()
                    sk.isCast = false
                    break
                end
            end
        end

    -- MP = mana update: time,MP,entityID,manaPct
    elseif eventType == "MP" then
        local entityID = tonumber(parts[3])
        local manaPct  = tonumber(parts[4]) or 100
        local entity   = self.entities[entityID]
        if entity and entity.mana then
            entity.mana:SetValue(manaPct)
        end
    end
end

------------------------------------------------------------
-- Show a skill-used icon on a player entity
------------------------------------------------------------
function AR_PlayStub:ShowSkillUsed(sourceID, spellID, isCast, targetID)
    local entity = self.entities[sourceID]
    if not entity then return end

    local targetData = nil
    if targetID and self.entities[targetID] then
        targetData = self.entities[targetID].data
    end

    -- Slide existing skills right
    for _, sk in ipairs(self.skills) do
        if sk.entityID == sourceID then
            sk:SlideRight()
        end
    end

    local sk = AR_UsedSkill:New(entity.srange, spellID, isCast, 0, targetData)
    sk.entityID = sourceID
    table.insert(self.skills, sk)
end

------------------------------------------------------------
-- Show CC overlay on entity
------------------------------------------------------------
function AR_PlayStub:ShowCC(entityID, spellID, duration)
    local entity = self.entities[entityID]
    if not entity then return end

    local _, icon = AR.Util:GetSpellInfo(spellID)
    if not icon then return end

    local cc = AR_Crowd:New(entity.crange, entityID)
    cc:SetValue(spellID, entityID, icon, entity.crange, duration, 0, entity.crange:GetFrameLevel() + 1)
    table.insert(self.crowds, cc)
end

------------------------------------------------------------
-- Close the replay viewer
------------------------------------------------------------
function AR_PlayStub:Close()
    self:Stop()
    self:ResetVisuals()
    if self.frame then
        self.frame:Hide()
    end
end
