local _, AR = ...

------------------------------------------------------------
-- AR_TeamStats: End-of-match stats display
------------------------------------------------------------
AR_TeamStats = {}
AR_TeamStats.__index = AR_TeamStats

function AR_TeamStats:New(parent, teamIndex)
    local self = setmetatable({}, AR_TeamStats)

    self.teamIndex = teamIndex
    self.parent    = parent
    self.entries   = {}

    -- Team header
    local yBase = (teamIndex == 0) and -5 or -90
    self.header = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    self.header:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
    self.header:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, yBase)
    self.header:SetText("")

    -- Create up to 5 entry rows
    for i = 1, 5 do
        local entry = AR_GUI:CreateDetailEntry(parent, yBase - (i * 20))
        entry:Hide()
        self.entries[i] = entry
    end

    return self
end

function AR_TeamStats:HideAll()
    self.header:SetText("")
    for _, e in ipairs(self.entries) do
        e:Hide()
    end
end

function AR_TeamStats:SetValue(matchData, teamIndex)
    self:HideAll()

    if not matchData then return end

    local teams = matchData.teams
    if teams and teams[teamIndex] then
        local teamName = teams[teamIndex].name or "Team " .. (teamIndex + 1)
        self.header:SetText(teamName)
    end

    -- Collect players for this team
    local teamPlayers = {}
    for guid, p in pairs(matchData.players or {}) do
        if p.team == teamIndex and p.isPlayer then
            table.insert(teamPlayers, p)
        end
    end

    table.sort(teamPlayers, function(a, b) return a.ID < b.ID end)

    for i, p in ipairs(teamPlayers) do
        if i > 5 then break end
        local entry = self.entries[i]

        -- Class icon
        entry.icon:SetTexture("Interface\\Icons\\ClassIcon_" .. (p.class or "Warrior"))

        -- Colored name
        entry.nameText:SetText(AR.Util:ClassColoredName(p.name or "?", p.class or "WARRIOR"))

        -- Damage done
        entry.dmg:SetText(AR.Util:AbbreviateNumber(p.damageDone or 0))

        -- Highest crit
        local critText = AR.Util:AbbreviateNumber(p.highestCrit or 0)
        local critSpell = p.highestCritSpell or ""
        if #critSpell > 13 then critSpell = critSpell:sub(1, 13) .. ".." end
        entry.crit:SetText(critText)

        -- Healing done
        entry.heal:SetText(AR.Util:AbbreviateNumber(p.healingDone or 0))

        -- Rating
        local ratingStr = tostring(p.rating or 0)
        local change = p.ratingChange or 0
        if change > 0 then
            ratingStr = ratingStr .. " |cff00ff00+" .. change .. "|r"
        elseif change < 0 then
            ratingStr = ratingStr .. " |cffff0000" .. change .. "|r"
        end
        entry.rating:SetText(ratingStr)

        -- MMR
        entry.mmr:SetText(tostring(p.mmr or 0))

        entry:Show()
    end
end
