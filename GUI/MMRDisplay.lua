local _, AR = ...
local L = LibStub("AceLocale-3.0"):GetLocale("ArenaReplay")

------------------------------------------------------------
-- AR_MMRDisplay: On-screen floating MMR/Rating text display
-- Shows current ratings for enabled brackets, movable & lockable
-- Right-click to open settings when unlocked
------------------------------------------------------------
AR_MMRDisplay = {}
local Display = AR_MMRDisplay
local Compat = AR.Compat
local SharedMedia = LibStub("LibSharedMedia-3.0")

-- Resolve font path from SharedMedia name or fallback
local function GetFontPath(fontName)
    if fontName and SharedMedia then
        local path = SharedMedia:Fetch("font", fontName)
        if path then return path end
    end
    return "Fonts\\FRIZQT__.TTF"
end

local displayFrame = nil
local lines = {}  -- bracket key -> FontString

------------------------------------------------------------
-- Create the display frame
------------------------------------------------------------
function Display:Create()
    if displayFrame then return end

    local settings = ArenaReplayDB.mmr and ArenaReplayDB.mmr.display or {}

    displayFrame = CreateFrame("Frame", "ArenaReplayMMRDisplay", UIParent)
    displayFrame:SetClampedToScreen(true)
    displayFrame:SetSize(200, 10) -- auto-resized
    displayFrame:SetFrameStrata("MEDIUM")
    displayFrame:SetFrameLevel(10)

    local pos = settings.position or { "CENTER", "CENTER", 0, 200 }
    displayFrame:SetPoint(pos[1], UIParent, pos[2], pos[3], pos[4])

    -- Right-click opens settings (when unlocked)
    displayFrame:SetScript("OnMouseUp", function(_, button)
        if button == "RightButton" and AR_Options then
            AR_Options:Open()
        end
    end)

    -- Tooltip on hover (when unlocked)
    displayFrame:SetScript("OnEnter", function(f)
        if f:IsMouseEnabled() then
            GameTooltip:SetOwner(f, "ANCHOR_BOTTOM")
            GameTooltip:AddLine("ArenaReplay MMR", 0.89, 0.57, 0.77)
            GameTooltip:AddLine(L.OPT_RIGHT_CLICK, 0.7, 0.7, 0.7)
            GameTooltip:Show()
        end
    end)
    displayFrame:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    -- Movable when unlocked
    if not settings.lock then
        self:Unlock()
    else
        self:Lock()
    end
end

------------------------------------------------------------
-- Lock / Unlock
------------------------------------------------------------
function Display:Lock()
    if not displayFrame then return end
    displayFrame:SetMovable(false)
    displayFrame:EnableMouse(false)
    displayFrame:RegisterForDrag()
    displayFrame:SetScript("OnDragStart", nil)
    displayFrame:SetScript("OnDragStop", nil)
end

function Display:Unlock()
    if not displayFrame then return end
    displayFrame:SetMovable(true)
    displayFrame:EnableMouse(true)
    displayFrame:RegisterForDrag("LeftButton")
    displayFrame:SetScript("OnDragStart", function(f)
        f:StartMoving()
    end)
    displayFrame:SetScript("OnDragStop", function(f)
        f:StopMovingOrSizing()
        local a, _, b, c, d = f:GetPoint()
        if ArenaReplayDB.mmr then
            ArenaReplayDB.mmr.display.position = { a, b, c, d }
        end
    end)
end

------------------------------------------------------------
-- Update the on-screen display with current bracket data
------------------------------------------------------------
function Display:Update()
    if #AR_MMRTracker.BRACKET_ORDER == 0 then return end
    if not displayFrame then self:Create() end
    if not ArenaReplayDB.mmr then return end

    local settings = ArenaReplayDB.mmr.display

    -- Visibility checks
    if settings.showOnlyInQueue then
        if not Compat.IsInPvPQueue() then
            displayFrame:Hide()
            return
        end
    end

    -- Check instance visibility
    local inInstance, instanceType = IsInInstance()
    if inInstance then
        if (instanceType == "arena" or instanceType == "pvp") and not settings.showInPVP then
            displayFrame:Hide()
            return
        end
        if (instanceType == "party" or instanceType == "raid") and not (settings.showInPVE ~= false) then
            displayFrame:Hide()
            return
        end
    end

    displayFrame:Show()

    local bracketData = AR_MMRTracker:GetAllBracketDisplayData()
    local fontSize = settings.fontSize or 13
    local fontPath = GetFontPath(settings.fontFamily)
    local textColor = settings.textColor or { r = 1, g = 1, b = 1, a = 1 }
    local colorHex = string.format("|cff%02x%02x%02x",
        math.floor(textColor.r * 255),
        math.floor(textColor.g * 255),
        math.floor(textColor.b * 255))
    local lineIndex = 0

    for _, bracketID in ipairs(AR_MMRTracker.BRACKET_ORDER) do
        local data = bracketData[bracketID]
        local key = data.short
        local showKey = "show" .. key
        local shouldShow = settings[showKey] ~= false

        if shouldShow then
            local displayVal = data.display or 0

            -- Hide "no data" lines if setting enabled
            if settings.hideNoData and displayVal == 0 then
                if lines[key] then lines[key]:Hide() end
            else
                if not lines[key] then
                    local text = displayFrame:CreateFontString(nil, "OVERLAY")
                    text:SetFont(fontPath, fontSize, "OUTLINE")
                    text:SetShadowOffset(1, -1)
                    text:SetShadowColor(0, 0, 0, 1)
                    text:SetJustifyH("LEFT")
                    lines[key] = text
                end

                local line = lines[key]
                line:SetFont(fontPath, fontSize, "OUTLINE")

                -- Build display text
                local label = data.label or "Rating"
                local displayText = colorHex .. data.short .. " " .. label .. ": |r"

                if displayVal > 0 then
                    displayText = displayText .. colorHex .. displayVal .. "|r"

                    -- Show gains/losses from last game
                    if settings.showGains then
                        local games = AR_MMRTracker:GetGames({ bracket = data.short })
                        if games and games[1] then
                            local lastChange = games[1].change or 0
                            if lastChange > 0 then
                                displayText = displayText .. " |cff00ff00+" .. lastChange .. "|r"
                            elseif lastChange < 0 then
                                displayText = displayText .. " |cffff0000" .. lastChange .. "|r"
                            end
                        end
                    end

                    -- Show before > after
                    if settings.showMMRDiff then
                        local games = AR_MMRTracker:GetGames({ bracket = data.short })
                        if games and games[1] then
                            local g = games[1]
                            displayText = displayText .. "  |cff888888(" .. g.before .. " > " .. g.after .. ")|r"
                        end
                    end

                    -- Win rate
                    if data.wins + data.losses > 0 then
                        local wr = data.wins / (data.wins + data.losses) * 100
                        displayText = displayText .. "  |cffaaaaaa" .. string.format("%.0f%%", wr) .. "|r"
                    end

                    line:SetTextColor(textColor.r, textColor.g, textColor.b, textColor.a or 1)
                else
                    displayText = displayText .. "|cff666666" .. L.MMR_NO_DATA .. "|r"
                    line:SetTextColor(0.4, 0.4, 0.4, textColor.a or 1)
                end

                line:SetText(displayText)
                line:ClearAllPoints()

                if lineIndex == 0 then
                    line:SetPoint("TOPLEFT", displayFrame, "TOPLEFT", 0, 0)
                else
                    -- Find previous visible line
                    local prevKey = nil
                    for _, prevBID in ipairs(AR_MMRTracker.BRACKET_ORDER) do
                        if prevBID == bracketID then break end
                        local pk = AR_MMRTracker.BRACKETS[prevBID].short
                        local pShowKey = "show" .. pk
                        if settings[pShowKey] ~= false and lines[pk] and lines[pk]:IsShown() then
                            prevKey = pk
                        end
                    end
                    if prevKey and lines[prevKey] then
                        line:SetPoint("TOPLEFT", lines[prevKey], "BOTTOMLEFT", 0, -2)
                    else
                        line:SetPoint("TOPLEFT", displayFrame, "TOPLEFT", 0, 0)
                    end
                end

                line:Show()
                lineIndex = lineIndex + 1
            end
        else
            if lines[key] then
                lines[key]:Hide()
            end
        end
    end

    -- Resize frame to fit content
    local maxWidth = 0
    local totalHeight = 0
    for _, line in pairs(lines) do
        if line:IsShown() then
            local w = line:GetStringWidth() or 0
            if w > maxWidth then maxWidth = w end
            totalHeight = totalHeight + (line:GetStringHeight() or fontSize) + 2
        end
    end
    displayFrame:SetSize(math.max(maxWidth + 10, 100), math.max(totalHeight, 20))
end

------------------------------------------------------------
-- Show / Hide
------------------------------------------------------------
function Display:Show()
    -- No brackets on Classic Era, nothing to display
    if #AR_MMRTracker.BRACKET_ORDER == 0 then return end
    if not displayFrame then self:Create() end
    self:Update()
end

function Display:Hide()
    if displayFrame then displayFrame:Hide() end
end

function Display:Toggle()
    if displayFrame and displayFrame:IsShown() then
        self:Hide()
    else
        self:Show()
    end
end

------------------------------------------------------------
-- Toggle lock
------------------------------------------------------------
function Display:ToggleLock()
    if not ArenaReplayDB.mmr then return end
    local settings = ArenaReplayDB.mmr.display
    settings.lock = not settings.lock
    if settings.lock then
        self:Lock()
        print("|cffe392c5<ArenaReplay>|r MMR Display locked.")
    else
        self:Unlock()
        print("|cffe392c5<ArenaReplay>|r MMR Display unlocked. Drag to move, right-click for settings.")
    end
end
