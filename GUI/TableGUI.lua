local _, AR = ...

------------------------------------------------------------
-- AR_TableGUI: Match list window with button toolbar
-- Replaces slash commands with clickable buttons
------------------------------------------------------------
AR_TableGUI = {}
local TableGUI = AR_TableGUI

local matchesFrame = nil
local matchRows = {}
local toolbarButtons = {}
local ROW_HEIGHT = 24
local MAX_VISIBLE = 18
local FRAME_WIDTH = 780
local TOOLBAR_HEIGHT = 62
local BTN_HEIGHT = 22
local BTN_GAP = 4
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
local BACKDROP_BTN = {
    bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 12,
    insets = { left = 2, right = 2, top = 2, bottom = 2 },
}
local BACKDROP_TOOLBAR = {
    bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 12,
    insets = { left = 3, right = 3, top = 3, bottom = 3 },
}

------------------------------------------------------------
-- Confirmation popups
------------------------------------------------------------
StaticPopupDialogs["ARENAREPLAY_CONNECT"] = {
    text = L.POPUP_CONNECT or "Enter broadcaster name:",
    button1 = L.POPUP_CONNECT_BTN or "Connect",
    button2 = L.POPUP_CANCEL or "Cancel",
    hasEditBox = true,
    OnAccept = function(self)
        local name = self.editBox:GetText()
        if name and name ~= "" then
            AR_Comm:ConnectTo(name)
        end
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

StaticPopupDialogs["ARENAREPLAY_DELETE_ALL"] = {
    text = L.POPUP_DELETE_ALL or "Delete ALL recorded matches?",
    button1 = L.POPUP_DELETE_BTN or "Delete",
    button2 = L.POPUP_CANCEL or "Cancel",
    OnAccept = function()
        if ArenaReplayDB then
            ArenaReplayDB.matches = {}
            TableGUI:FillMatchData()
            print("|cffe392c5<ArenaReplay>|r All matches deleted.")
        end
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

StaticPopupDialogs["ARENAREPLAY_RESET_MMR"] = {
    text = L.POPUP_RESET_MMR or "Reset all MMR history data?",
    button1 = L.POPUP_RESET_BTN or "Reset",
    button2 = L.POPUP_CANCEL or "Cancel",
    OnAccept = function()
        if ArenaReplayDB and ArenaReplayDB.mmr then
            ArenaReplayDB.mmr.games = {}
            AR_MMRTable:Refresh()
            print("|cffe392c5<ArenaReplay>|r MMR history cleared.")
        end
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

------------------------------------------------------------
-- Button creation helpers
------------------------------------------------------------
local function CreateToolbarButton(parent, text, width)
    local btn = CreateFrame("Button", nil, parent, "BackdropTemplate")
    btn:SetSize(width, BTN_HEIGHT)
    if btn.SetBackdrop then
        btn:SetBackdrop(BACKDROP_BTN)
    end
    btn:SetBackdropColor(0.15, 0.15, 0.15, 0.9)
    btn:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)

    local label = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    label:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
    label:SetPoint("CENTER")
    label:SetText(text)
    label:SetTextColor(0.85, 0.85, 0.85)
    btn.label = label

    btn:SetScript("OnEnter", function(self)
        self:SetBackdropColor(0.3, 0.3, 0.3, 1)
    end)
    btn:SetScript("OnLeave", function(self)
        if self.RefreshState then
            self:RefreshState()
        else
            self:SetBackdropColor(0.15, 0.15, 0.15, 0.9)
        end
    end)

    return btn
end

local function MakeToggle(btn, getStateFn, textOn, textOff)
    btn.RefreshState = function(self)
        if getStateFn() then
            self:SetBackdropColor(0.05, 0.35, 0.05, 0.9)
            self:SetBackdropBorderColor(0.2, 0.7, 0.2, 1)
            self.label:SetText(textOn)
            self.label:SetTextColor(0.4, 1, 0.4)
        else
            self:SetBackdropColor(0.35, 0.05, 0.05, 0.9)
            self:SetBackdropBorderColor(0.7, 0.2, 0.2, 1)
            self.label:SetText(textOff)
            self.label:SetTextColor(1, 0.4, 0.4)
        end
    end
    btn:RefreshState()
end

local function MakeDestructive(btn)
    btn:SetBackdropColor(0.25, 0.08, 0.08, 0.9)
    btn:SetBackdropBorderColor(0.6, 0.2, 0.2, 1)
    btn.label:SetTextColor(1, 0.5, 0.5)

    btn:SetScript("OnLeave", function(self)
        self:SetBackdropColor(0.25, 0.08, 0.08, 0.9)
        self:SetBackdropBorderColor(0.6, 0.2, 0.2, 1)
    end)
end

------------------------------------------------------------
-- Create the toolbar with all control buttons
------------------------------------------------------------
local function CreateToolbar(parent)
    local toolbar = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    toolbar:SetPoint("TOPLEFT", parent, "TOPLEFT", 6, -8)
    toolbar:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -6, -8)
    toolbar:SetHeight(TOOLBAR_HEIGHT)
    if toolbar.SetBackdrop then
        toolbar:SetBackdrop(BACKDROP_TOOLBAR)
    end
    toolbar:SetBackdropColor(0.08, 0.08, 0.08, 0.7)
    toolbar:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.5)

    local x, y
    local pad = 6

    -- Row 1: Recording & Spectating
    x = pad
    y = -pad

    -- Record toggle
    local btnRecord = CreateToolbarButton(toolbar, "", 120)
    btnRecord:SetPoint("TOPLEFT", toolbar, "TOPLEFT", x, y)
    MakeToggle(btnRecord,
        function() return ArenaReplayDB and ArenaReplayDB.recording end,
        L.BTN_RECORD_ON or "Record: ON",
        L.BTN_RECORD_OFF or "Record: OFF")
    btnRecord:SetScript("OnClick", function(self)
        if AR.Core then AR.Core:ToggleRecording() end
        self:RefreshState()
    end)
    toolbarButtons.record = btnRecord
    x = x + 120 + BTN_GAP

    -- Broadcast toggle
    local btnBroadcast = CreateToolbarButton(toolbar, "", 140)
    btnBroadcast:SetPoint("TOPLEFT", toolbar, "TOPLEFT", x, y)
    MakeToggle(btnBroadcast,
        function() return ArenaReplayDB and ArenaReplayDB.broadcasting end,
        L.BTN_BROADCAST_ON or "Broadcast: ON",
        L.BTN_BROADCAST_OFF or "Broadcast: OFF")
    btnBroadcast:SetScript("OnClick", function(self)
        if AR.Core then AR.Core:ToggleBroadcast() end
        self:RefreshState()
    end)
    toolbarButtons.broadcast = btnBroadcast
    x = x + 140 + BTN_GAP

    -- Find Broadcasts
    local btnLookup = CreateToolbarButton(toolbar, L.BTN_FIND_BROADCASTS or "Find Broadcasts", 130)
    btnLookup:SetPoint("TOPLEFT", toolbar, "TOPLEFT", x, y)
    btnLookup:SetScript("OnClick", function()
        AR_Comm:Lookup()
    end)
    x = x + 130 + BTN_GAP

    -- Connect
    local btnConnect = CreateToolbarButton(toolbar, L.BTN_CONNECT or "Connect", 100)
    btnConnect:SetPoint("TOPLEFT", toolbar, "TOPLEFT", x, y)
    btnConnect:SetScript("OnClick", function()
        StaticPopup_Show("ARENAREPLAY_CONNECT")
    end)
    x = x + 100 + BTN_GAP

    -- Spectators
    local btnSpectators = CreateToolbarButton(toolbar, L.BTN_SPECTATORS or "Spectators", 110)
    btnSpectators:SetPoint("TOPLEFT", toolbar, "TOPLEFT", x, y)
    btnSpectators:SetScript("OnClick", function()
        local specs = AR_Comm:GetSpectators()
        print("|cffe392c5<ArenaReplay>|r Spectators (" .. #specs .. "):")
        for _, name in ipairs(specs) do
            print("  - " .. name)
        end
    end)

    -- Row 2: MMR & Management
    x = pad
    y = -(BTN_HEIGHT + BTN_GAP + pad + 4)

    -- MMR Display toggle
    local btnMMR = CreateToolbarButton(toolbar, L.BTN_MMR_DISPLAY or "MMR Display", 120)
    btnMMR:SetPoint("TOPLEFT", toolbar, "TOPLEFT", x, y)
    btnMMR:SetScript("OnClick", function()
        AR_MMRDisplay:Toggle()
    end)
    x = x + 120 + BTN_GAP

    -- MMR History
    local btnMMRHistory = CreateToolbarButton(toolbar, L.BTN_MMR_HISTORY or "MMR History", 120)
    btnMMRHistory:SetPoint("TOPLEFT", toolbar, "TOPLEFT", x, y)
    btnMMRHistory:SetScript("OnClick", function()
        AR_MMRTable:Toggle()
    end)
    x = x + 120 + BTN_GAP

    -- Lock MMR toggle
    local btnLock = CreateToolbarButton(toolbar, "", 120)
    btnLock:SetPoint("TOPLEFT", toolbar, "TOPLEFT", x, y)
    MakeToggle(btnLock,
        function()
            return ArenaReplayDB and ArenaReplayDB.mmr
                and ArenaReplayDB.mmr.display
                and ArenaReplayDB.mmr.display.lock
        end,
        L.BTN_MMR_LOCK or "Lock MMR",
        L.BTN_MMR_UNLOCK or "Unlock MMR")
    btnLock:SetScript("OnClick", function(self)
        AR_MMRDisplay:ToggleLock()
        self:RefreshState()
    end)
    toolbarButtons.mmrLock = btnLock
    x = x + 120 + BTN_GAP

    -- Reset MMR (destructive)
    local btnResetMMR = CreateToolbarButton(toolbar, L.BTN_MMR_RESET or "Reset MMR", 110)
    btnResetMMR:SetPoint("TOPLEFT", toolbar, "TOPLEFT", x, y)
    MakeDestructive(btnResetMMR)
    btnResetMMR:SetScript("OnClick", function()
        StaticPopup_Show("ARENAREPLAY_RESET_MMR")
    end)
    x = x + 110 + BTN_GAP

    -- Delete All (destructive)
    local btnDeleteAll = CreateToolbarButton(toolbar, L.BTN_DELETE_ALL or "Delete All", 110)
    btnDeleteAll:SetPoint("TOPLEFT", toolbar, "TOPLEFT", x, y)
    MakeDestructive(btnDeleteAll)
    btnDeleteAll:SetScript("OnClick", function()
        StaticPopup_Show("ARENAREPLAY_DELETE_ALL")
    end)

    parent.toolbar = toolbar
end

------------------------------------------------------------
-- Refresh toggle button states
------------------------------------------------------------
function TableGUI:RefreshToolbar()
    for _, btn in pairs(toolbarButtons) do
        if btn.RefreshState then
            btn:RefreshState()
        end
    end
end

------------------------------------------------------------
-- Create the main matches window
------------------------------------------------------------
function TableGUI:CreateMatchesFrame()
    local f = CreateFrame("Frame", "ArenaReplayMatches", UIParent, "BackdropTemplate")
    f:SetFrameStrata("HIGH")
    f:SetSize(FRAME_WIDTH, ROW_HEIGHT * MAX_VISIBLE + 80 + TOOLBAR_HEIGHT)
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
    titleText:SetText("ArenaReplay")
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

    -- Toolbar with control buttons
    CreateToolbar(f)

    -- Column headers (shifted down by toolbar)
    local headers = { "Date", "Duration", "Map", "Matchup", "Result", "Rating", "" }
    local widths  = { 130, 60, 130, 200, 55, 85, 50 }
    local xOff = 10
    for i, hdr in ipairs(headers) do
        local ht = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        ht:SetText(hdr)
        ht:SetPoint("TOPLEFT", f, "TOPLEFT", xOff, -(10 + TOOLBAR_HEIGHT))
        ht:SetWidth(widths[i])
        ht:SetJustifyH("LEFT")
        xOff = xOff + widths[i] + 5
    end

    -- Scroll frame (shifted down by toolbar)
    local scroll = CreateFrame("ScrollFrame", "$parentScroll", f, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", f, "TOPLEFT", 8, -(35 + TOOLBAR_HEIGHT))
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
    self:RefreshToolbar()
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
        self:RefreshToolbar()
        self:FillMatchData()
    end
end
