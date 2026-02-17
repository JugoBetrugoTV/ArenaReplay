local _, AR = ...

------------------------------------------------------------
-- AR_MMRTable: Match history table with bracket tabs and filters
-- Displays recorded MMR/Rating data in a scrollable table
------------------------------------------------------------
AR_MMRTable = {}
local MMRTable = AR_MMRTable

local tableFrame = nil
local dataRows = {}
local summaryFrame = nil

local ROW_HEIGHT = 22
local MAX_VISIBLE = 20
local FRAME_WIDTH = 820
local FRAME_HEIGHT = ROW_HEIGHT * MAX_VISIBLE + 140

local BACKDROP_MAIN = {
    bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 },
}

local activeFilters = {
    bracket   = "all",
    character = "all",
    spec      = "all",
    map       = "all",
    time      = "all",
}

local TABS = {
    { id = "all",     label = "All" },
    { id = "2v2",     label = "2v2" },
    { id = "3v3",     label = "3v3" },
    { id = "Shuffle", label = "Shuffle" },
    { id = "Blitz",   label = "Blitz" },
    { id = "RBG",     label = "RBG" },
}

------------------------------------------------------------
-- Create the main table frame
------------------------------------------------------------
function MMRTable:Create()
    if tableFrame then return end

    tableFrame = CreateFrame("Frame", "ArenaReplayMMRTable", UIParent, "BackdropTemplate")
    tableFrame:SetFrameStrata("HIGH")
    tableFrame:SetSize(FRAME_WIDTH, FRAME_HEIGHT)
    tableFrame:SetPoint("CENTER", 0, 0)
    if tableFrame.SetBackdrop then tableFrame:SetBackdrop(BACKDROP_MAIN) end
    tableFrame:SetBackdropColor(0.05, 0.05, 0.05, 0.95)
    tableFrame:SetMovable(true)
    tableFrame:EnableMouse(true)
    tableFrame:RegisterForDrag("LeftButton")
    tableFrame:SetScript("OnDragStart", tableFrame.StartMoving)
    tableFrame:SetScript("OnDragStop", tableFrame.StopMovingOrSizing)
    tableFrame:SetClampedToScreen(true)

    -- Title
    local titleText = tableFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    titleText:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
    titleText:SetText("ArenaReplay - MMR Tracker")
    titleText:SetPoint("TOP", tableFrame, "TOP", 0, -8)

    -- Close button
    local closeBtn = CreateFrame("Button", nil, tableFrame, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", tableFrame, "TOPRIGHT", -2, -2)
    closeBtn:SetScript("OnClick", function() tableFrame:Hide() end)

    -- Bracket tabs
    self:CreateTabs()

    -- Column headers
    self:CreateColumnHeaders()

    -- Scroll frame
    local scroll = CreateFrame("ScrollFrame", "$parentScroll", tableFrame, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", tableFrame, "TOPLEFT", 8, -85)
    scroll:SetPoint("BOTTOMRIGHT", tableFrame, "BOTTOMRIGHT", -28, 55)

    local content = CreateFrame("Frame", nil, scroll)
    content:SetSize(FRAME_WIDTH - 40, 1)
    scroll:SetScrollChild(content)

    tableFrame.scroll = scroll
    tableFrame.content = content

    -- Summary bar at bottom
    self:CreateSummaryBar()

    -- Filter dropdowns row
    self:CreateFilterBar()
end

------------------------------------------------------------
-- Bracket tabs
------------------------------------------------------------
function MMRTable:CreateTabs()
    local tabButtons = {}
    local xOff = 10
    for i, tab in ipairs(TABS) do
        local btn = CreateFrame("Button", nil, tableFrame)
        btn:SetSize(65, 24)
        btn:SetPoint("TOPLEFT", tableFrame, "TOPLEFT", xOff, -28)

        local bg = btn:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints(btn)
        bg:SetColorTexture(0.2, 0.2, 0.2, 0.8)
        btn.bg = bg

        local text = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        text:SetText(tab.label)
        text:SetPoint("CENTER", btn, "CENTER", 0, 0)
        btn.text = text

        btn:SetScript("OnClick", function()
            activeFilters.bracket = tab.id
            self:UpdateTabHighlights(tabButtons, i)
            self:Refresh()
        end)

        -- Highlight
        local hl = btn:CreateTexture(nil, "HIGHLIGHT")
        hl:SetAllPoints(btn)
        hl:SetColorTexture(1, 1, 1, 0.1)

        tabButtons[i] = btn
        xOff = xOff + 70
    end

    tableFrame.tabButtons = tabButtons
    self:UpdateTabHighlights(tabButtons, 1)
end

function MMRTable:UpdateTabHighlights(buttons, activeIndex)
    for i, btn in ipairs(buttons) do
        if i == activeIndex then
            btn.bg:SetColorTexture(0.4, 0.2, 0.5, 0.9)
            btn.text:SetTextColor(1, 1, 1)
        else
            btn.bg:SetColorTexture(0.2, 0.2, 0.2, 0.8)
            btn.text:SetTextColor(0.7, 0.7, 0.7)
        end
    end
end

------------------------------------------------------------
-- Column headers
------------------------------------------------------------
function MMRTable:CreateColumnHeaders()
    local headers = { "Date", "Map", "Spec", "Bracket", "Before", "+/-", "After", "W/L" }
    local widths  = { 140, 130, 90, 65, 65, 55, 65, 40 }
    local xOff = 10

    for i, hdr in ipairs(headers) do
        local ht = tableFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        ht:SetText("|cffcccccc" .. hdr .. "|r")
        ht:SetPoint("TOPLEFT", tableFrame, "TOPLEFT", xOff, -62)
        ht:SetWidth(widths[i])
        ht:SetJustifyH("LEFT")
        xOff = xOff + widths[i] + 8
    end
end

------------------------------------------------------------
-- Filter bar (time filter dropdown)
------------------------------------------------------------
function MMRTable:CreateFilterBar()
    -- Time filter as simple buttons
    local filterRow = CreateFrame("Frame", nil, tableFrame)
    filterRow:SetSize(FRAME_WIDTH - 20, 22)
    filterRow:SetPoint("BOTTOMLEFT", tableFrame, "BOTTOMLEFT", 10, 30)

    local label = filterRow:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    label:SetText("|cffaaaaaaTime:|r")
    label:SetPoint("LEFT", filterRow, "LEFT", 0, 0)

    local xOff = 40
    for _, tf in ipairs(AR_MMRTracker.TIME_FILTERS) do
        local btn = CreateFrame("Button", nil, filterRow)
        btn:SetSize(70, 18)
        btn:SetPoint("LEFT", filterRow, "LEFT", xOff, 0)

        local txt = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        txt:SetText(tf.name)
        txt:SetPoint("CENTER", btn, "CENTER", 0, 0)
        txt:SetTextColor(0.7, 0.7, 0.7)

        local hl = btn:CreateTexture(nil, "HIGHLIGHT")
        hl:SetAllPoints(btn)
        hl:SetColorTexture(1, 1, 1, 0.1)

        btn:SetScript("OnClick", function()
            activeFilters.time = tf.id
            self:Refresh()
        end)

        xOff = xOff + 75
    end
end

------------------------------------------------------------
-- Summary bar
------------------------------------------------------------
function MMRTable:CreateSummaryBar()
    summaryFrame = CreateFrame("Frame", nil, tableFrame)
    summaryFrame:SetSize(FRAME_WIDTH - 20, 20)
    summaryFrame:SetPoint("BOTTOMLEFT", tableFrame, "BOTTOMLEFT", 10, 8)

    summaryFrame.text = summaryFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    summaryFrame.text:SetPoint("LEFT", summaryFrame, "LEFT", 0, 0)
    summaryFrame.text:SetJustifyH("LEFT")
end

function MMRTable:UpdateSummary(games)
    if not summaryFrame then return end

    local wins, losses, totalGain, totalLoss = 0, 0, 0, 0
    for _, g in ipairs(games) do
        if g.won then
            wins = wins + 1
            if g.change > 0 then totalGain = totalGain + g.change end
        else
            losses = losses + 1
            if g.change < 0 then totalLoss = totalLoss + math.abs(g.change) end
        end
    end

    local total = wins + losses
    local wr = total > 0 and (wins / total * 100) or 0
    local net = totalGain - totalLoss

    local netStr
    if net > 0 then netStr = "|cff00ff00+" .. net .. "|r"
    elseif net < 0 then netStr = "|cffff0000" .. net .. "|r"
    else netStr = "|cffffff000|r" end

    summaryFrame.text:SetText(string.format(
        "|cffccccccGames: %d  |  W: |cff00ff00%d|r  L: |cffff0000%d|r  |  Win Rate: %.1f%%  |  Net: %s  |  Gained: |cff00ff00+%d|r  Lost: |cffff0000-%d|r|r",
        total, wins, losses, wr, netStr, totalGain, totalLoss
    ))
end

------------------------------------------------------------
-- Create a data row
------------------------------------------------------------
local function CreateDataRow(parent, index)
    local row = CreateFrame("Button", nil, parent)
    row:SetSize(FRAME_WIDTH - 50, ROW_HEIGHT)
    row:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, -((index - 1) * ROW_HEIGHT))

    -- Alternating background
    local bg = row:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(row)
    if index % 2 == 0 then
        bg:SetColorTexture(0.12, 0.12, 0.12, 0.5)
    else
        bg:SetColorTexture(0.08, 0.08, 0.08, 0.3)
    end

    local hl = row:CreateTexture(nil, "HIGHLIGHT")
    hl:SetAllPoints(row)
    hl:SetColorTexture(1, 1, 1, 0.08)

    local widths = { 140, 130, 90, 65, 65, 55, 65, 40 }
    local fields = {}
    local xOff = 0
    for i = 1, 8 do
        local fs = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        fs:SetPoint("LEFT", row, "LEFT", xOff, 0)
        fs:SetWidth(widths[i])
        fs:SetJustifyH("LEFT")
        fs:SetText("")
        fields[i] = fs
        xOff = xOff + widths[i] + 8
    end

    row.fields = fields
    return row
end

------------------------------------------------------------
-- Refresh the table data
------------------------------------------------------------
function MMRTable:Refresh()
    if not tableFrame then return end

    local content = tableFrame.content

    -- Clear rows
    for _, row in ipairs(dataRows) do
        row:Hide()
    end

    local games = AR_MMRTracker:GetGames(activeFilters)

    if #games == 0 then
        if not dataRows[1] then
            dataRows[1] = CreateDataRow(content, 1)
        end
        dataRows[1].fields[1]:SetText("|cff666666No matches recorded yet.|r")
        for i = 2, 8 do dataRows[1].fields[i]:SetText("") end
        dataRows[1]:Show()
        content:SetHeight(ROW_HEIGHT)
        self:UpdateSummary({})
        return
    end

    content:SetHeight(#games * ROW_HEIGHT)

    for i, game in ipairs(games) do
        if not dataRows[i] then
            dataRows[i] = CreateDataRow(content, i)
        end
        local row = dataRows[i]

        -- Date
        row.fields[1]:SetText(game.date or "")

        -- Map
        row.fields[2]:SetText(game.map or "")

        -- Spec
        row.fields[3]:SetText(game.spec or "")

        -- Bracket
        row.fields[4]:SetText(game.name or "")

        -- Before
        row.fields[5]:SetText(tostring(game.before or 0))

        -- Change (+/-)
        local change = game.change or 0
        if change > 0 then
            row.fields[6]:SetText("|cff00ff00+" .. change .. "|r")
        elseif change < 0 then
            row.fields[6]:SetText("|cffff0000" .. change .. "|r")
        else
            row.fields[6]:SetText("|cffffff000|r")
        end

        -- After
        row.fields[7]:SetText(tostring(game.after or 0))

        -- Win/Loss
        if game.won then
            row.fields[8]:SetText("|cff00ff00W|r")
        else
            row.fields[8]:SetText("|cffff0000L|r")
        end

        row:Show()
    end

    self:UpdateSummary(games)
end

------------------------------------------------------------
-- Show / Hide / Toggle
------------------------------------------------------------
function MMRTable:Show()
    if not tableFrame then self:Create() end
    self:Refresh()
    tableFrame:Show()
end

function MMRTable:Hide()
    if tableFrame then tableFrame:Hide() end
end

function MMRTable:Toggle()
    if tableFrame and tableFrame:IsShown() then
        self:Hide()
    else
        self:Show()
    end
end

function MMRTable:IsShowing()
    return tableFrame and tableFrame:IsShown()
end
