local _, AR = ...

------------------------------------------------------------
-- AR_MinimapButton: Minimap icon for ArenaReplay
------------------------------------------------------------
AR_MinimapButton = {}
local MinimapBtn = AR_MinimapButton

local button = nil
local ICON_TEXTURE = "Interface\\Icons\\Achievement_Arena_2v2_7"

function MinimapBtn:Create()
    if button then return end

    local f = CreateFrame("Button", "ArenaReplayMinimapButton", Minimap)
    f:SetSize(32, 32)
    f:SetFrameStrata("MEDIUM")
    f:SetFrameLevel(8)
    f:SetClampedToScreen(true)
    f:SetMovable(true)

    -- Icon
    local overlay = f:CreateTexture(nil, "OVERLAY")
    overlay:SetSize(53, 53)
    overlay:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    overlay:SetPoint("TOPLEFT")

    local icon = f:CreateTexture(nil, "BACKGROUND")
    icon:SetSize(20, 20)
    icon:SetTexture(ICON_TEXTURE)
    icon:SetPoint("CENTER", f, "CENTER", 0, 1)

    -- Positioning on minimap
    local angle = ArenaReplayDB and ArenaReplayDB.minimapAngle or 220
    f:SetPoint("CENTER", Minimap, "CENTER",
        52 * math.cos(math.rad(angle)),
        52 * math.sin(math.rad(angle)))

    -- Drag to reposition
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", function(self)
        self:SetScript("OnUpdate", function(self)
            local mx, my = Minimap:GetCenter()
            local cx, cy = GetCursorPosition()
            local scale = Minimap:GetEffectiveScale()
            cx, cy = cx / scale, cy / scale
            local a = math.deg(math.atan2(cy - my, cx - mx))
            self:SetPoint("CENTER", Minimap, "CENTER",
                52 * math.cos(math.rad(a)),
                52 * math.sin(math.rad(a)))
            if ArenaReplayDB then
                ArenaReplayDB.minimapAngle = a
            end
        end)
    end)
    f:SetScript("OnDragStop", function(self)
        self:SetScript("OnUpdate", nil)
    end)

    -- Click handlers
    f:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    f:SetScript("OnClick", function(self, btn)
        if btn == "LeftButton" then
            if AR_TableGUI:IsShowing() then
                AR_TableGUI:HideMatchesFrame()
            else
                AR_TableGUI:ShowMatchesFrame()
            end
        elseif btn == "RightButton" then
            MinimapBtn:ShowMenu(self)
        end
    end)

    f:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:AddLine("ArenaReplay", 1, 1, 1)
        GameTooltip:AddLine("Left-click: Show matches", 0.8, 0.8, 0.8)
        GameTooltip:AddLine("Right-click: Options", 0.8, 0.8, 0.8)
        GameTooltip:Show()
    end)
    f:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    button = f
end

------------------------------------------------------------
-- Context menu
------------------------------------------------------------
function MinimapBtn:ShowMenu(anchor)
    local menuItems = {
        { text = "ArenaReplay", isTitle = true, notCheckable = true },
        {
            text = "Show Matches",
            notCheckable = true,
            func = function() AR_TableGUI:ShowMatchesFrame() end,
        },
        {
            text = "Toggle Recording",
            notCheckable = true,
            func = function()
                if AR.Core then AR.Core:ToggleRecording() end
            end,
        },
        {
            text = "Toggle Broadcasting",
            notCheckable = true,
            func = function()
                if AR.Core then AR.Core:ToggleBroadcast() end
            end,
        },
        { text = " ", isTitle = true, notCheckable = true },
        { text = "MMR Tracker", isTitle = true, notCheckable = true },
        {
            text = "Toggle MMR Display",
            notCheckable = true,
            func = function() AR_MMRDisplay:Toggle() end,
        },
        {
            text = "MMR Match History",
            notCheckable = true,
            func = function() AR_MMRTable:Toggle() end,
        },
        {
            text = "Lock/Unlock MMR Position",
            notCheckable = true,
            func = function() AR_MMRDisplay:ToggleLock() end,
        },
        { text = " ", isTitle = true, notCheckable = true },
        {
            text = "Delete All Matches",
            notCheckable = true,
            func = function()
                if ArenaReplayDB then
                    ArenaReplayDB.matches = {}
                    AR_TableGUI:RefreshIfShowing()
                    print("|cffe392c5<ArenaReplay>|r All matches deleted.")
                end
            end,
        },
        { text = "Cancel", notCheckable = true },
    }

    local menuFrame = CreateFrame("Frame", "ArenaReplayMinimapMenu", UIParent, "UIDropDownMenuTemplate")
    EasyMenu(menuItems, menuFrame, anchor, 0, 0, "MENU")
end

function MinimapBtn:Show()
    if button then button:Show() end
end

function MinimapBtn:Hide()
    if button then button:Hide() end
end
