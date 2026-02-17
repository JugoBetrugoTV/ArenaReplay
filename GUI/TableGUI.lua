local _, AR = ...

------------------------------------------------------------
-- AR_TableGUI: Match list window
-- Uses a simple scrollframe instead of lib-st to reduce dependencies
------------------------------------------------------------
AR_TableGUI = {}
local TableGUI = AR_TableGUI

local matchesFrame = nil
local matchRows = {}
local ROW_HEIGHT = 24
local MAX_VISIBLE = 20
local FRAME_WIDTH = 780
local L = LibStub("AceLocale-3.0"):GetLocale("ArenaReplay", true)

local BACKDROP_MAIN = {
    bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 },
}
local BACKDROP_TITLE = {
    bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 16, edgeSize = 20,
    insets = { left = 4, right = 4, top = 4, bottom = 4 },
}

------------------------------------------------------------
-- Create the main matches window
------------------------------------------------------------
function TableGUI:CreateMatchesFrame()
    local f = CreateFrame("Frame", "ArenaReplayMatches", UIParent, "BackdropTemplate")
    f:SetFrameStrata("HIGH")
    f:SetSize(FRAME_WIDTH, ROW_HEIGHT * MAX_VISIBLE + 80)
    f:SetPoint("CENTER", 0, 0)
    if f.SetBackdrop then f:SetBackdrop(BACKDROP_MAIN) end
    f:SetBackdropColor(0.05, 0.05, 0.05, 0.95)
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)
    f:SetClampedToScreen(true)

    -- Title
    local title = CreateFrame("Frame", "$parentTitle", f, "BackdropTemplate")
    title:SetHeight(28)
    if title.SetBackdrop then title:SetBackdrop(BACKDROP_TITLE) end
    title:SetBackdropColor(0, 0, 0, 1)
    title:SetPoint("TOP", f, "TOP", 0, 16)

    local titleText = title:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    titleText:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
    titleText:SetText("ArenaReplay: Recorded Matches")
    titleText:SetPoint("CENTER", title, 0, 0)
    title:SetWidth(titleText:GetStringWidth() + 30)
    title:SetMovable(true)
    title:RegisterForDrag("LeftButton")
    title:SetScript("OnDragStart", function() f:StartMoving() end)
    title:SetScript("OnDragStop", function() f:StopMovingOrSizing() end)

    -- Close button
    local closeBtn = CreateFrame("Button", "$parentClose", f, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", f, "TOPRIGHT", -2, -2)
    closeBtn:SetScript("OnClick", function() f:Hide() end)

    -- Column headers
    local headers = { "Date", "Duration", "Map", "Matchup", "Result", "Rating", "" }
    local widths  = { 130, 60, 130, 200, 55, 85, 50 }
    local xOff = 10
    for i, hdr in ipairs(headers) do
        local ht = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        ht:SetText(hdr)
        ht:SetPoint("TOPLEFT", f, "TOPLEFT", xOff, -10)
        ht:SetWidth(widths[i])
        ht:SetJustifyH("LEFT")
        xOff = xOff + widths[i] + 5
    end

    -- Scroll frame
    local scroll = CreateFrame("ScrollFrame", "$parentScroll", f, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", f, "TOPLEFT", 8, -35)
    scroll:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -28, 8)

    local content = CreateFrame("Frame", nil, scroll)
    content:SetSize(FRAME_WIDTH - 40, 1)
    scroll:SetScrollChild(content)

    f.scroll = scroll
    f.content = content
    matchesFrame = f
end

------------------------------------------------------------
-- Create a single match row
------------------------------------------------------------
local function CreateRow(parent, index)
    local row = CreateFrame("Button", nil, parent)
    row:SetSize(FRAME_WIDTH - 50, ROW_HEIGHT)
    row:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, -((index - 1) * ROW_HEIGHT))

    -- Highlight
    local hl = row:CreateTexture(nil, "HIGHLIGHT")
    hl:SetAllPoints(row)
    hl:SetColorTexture(1, 1, 1, 0.1)

    local widths  = { 130, 60, 130, 200, 55, 85, 50 }
    local fields = {}
    local xOff = 0
    for i = 1, 7 do
        local fs = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        fs:SetPoint("LEFT", row, "LEFT", xOff, 0)
        fs:SetWidth(widths[i])
        fs:SetJustifyH("LEFT")
        fs:SetText("")
        fields[i] = fs
        xOff = xOff + widths[i] + 5
    end

    row.fields = fields
    return row
end

------------------------------------------------------------
-- Fill/refresh match data
------------------------------------------------------------
function TableGUI:FillMatchData()
    if not matchesFrame then return end
    local content = matchesFrame.content

    -- Clear existing rows
    for _, row in ipairs(matchRows) do
        row:Hide()
    end

    local matches = ArenaReplayDB and ArenaReplayDB.matches or {}
    if #matches == 0 then
        if not matchRows[1] then
            matchRows[1] = CreateRow(content, 1)
        end
        matchRows[1].fields[1]:SetText(L.CONF_NOMATCHES)
        matchRows[1]:Show()
        matchRows[1]:SetScript("OnClick", nil)
        content:SetHeight(ROW_HEIGHT)
        return
    end

    content:SetHeight(#matches * ROW_HEIGHT)

    for i, match in ipairs(matches) do
        if not matchRows[i] then
            matchRows[i] = CreateRow(content, i)
        end
        local row = matchRows[i]

        -- Date
        row.fields[1]:SetText(match.startTime or "")

        -- Duration
        row.fields[2]:SetText(AR.Util:FormatTime(match.elapsed or 0))

        -- Map
        row.fields[3]:SetText(AR.Data.ARENA_MAPS[match.map or 0] or "Unknown")

        -- Matchup
        local vs = ""
        if match.teams and match.teams[0] then
            vs = "vs " .. (match.teams[0].name or "?")
        end
        row.fields[4]:SetText(vs)

        -- Result
        if match.result == 1 then
            row.fields[5]:SetText("|cff00ff00WIN|r")
        elseif match.result == 2 then
            row.fields[5]:SetText("|cffff0000LOSS|r")
        elseif match.result == 3 then
            row.fields[5]:SetText("|cffffff00DRAW|r")
        else
            row.fields[5]:SetText("???")
        end

        -- Rating
        local ratingText = ""
        if match.teams and match.teams[1] then
            ratingText = tostring(match.teams[1].rating or "")
        end
        row.fields[6]:SetText(ratingText)

        -- Delete button
        row.fields[7]:SetText("|cffff0000X|r")

        -- Click handlers
        local matchIndex = i
        row:SetScript("OnClick", function(self, button)
            if button == "LeftButton" then
                -- Check if click was on the delete column area
                local cx = self:GetRight() - GetCursorPosition() / self:GetEffectiveScale()
                if cx < 55 then
                    -- Delete match
                    table.remove(ArenaReplayDB.matches, matchIndex)
                    TableGUI:FillMatchData()
                    print("|cffe392c5<ArenaReplay>|r " .. L.CONF_MATCH_DELETED)
                else
                    -- Play match
                    matchesFrame:Hide()
                    if AR.Core then
                        AR.Core:PlayMatch(matchIndex)
                    end
                end
            end
        end)

        row:Show()
    end
end

------------------------------------------------------------
-- Show matches window
------------------------------------------------------------
function TableGUI:ShowMatchesFrame()
    if not matchesFrame then
        self:CreateMatchesFrame()
    end
    self:FillMatchData()
    matchesFrame:Show()
end

------------------------------------------------------------
-- Hide matches window
------------------------------------------------------------
function TableGUI:HideMatchesFrame()
    if matchesFrame then matchesFrame:Hide() end
end

------------------------------------------------------------
-- Is the frame showing
------------------------------------------------------------
function TableGUI:IsShowing()
    return matchesFrame and matchesFrame:IsShown()
end

------------------------------------------------------------
-- Refresh if showing
------------------------------------------------------------
function TableGUI:RefreshIfShowing()
    if self:IsShowing() then
        self:FillMatchData()
    end
end
