local _, AR = ...
local L = LibStub("AceLocale-3.0"):GetLocale("ArenaReplay")

------------------------------------------------------------
-- AR_MinimapButton: Minimap icon via LibDBIcon + LibDataBroker
-- Left-click: open main panel
-- Shift-click: toggle MMR display
-- Ctrl-click: toggle MMR history table
-- Right-click: open settings
------------------------------------------------------------
AR_MinimapButton = {}
local MinimapBtn = AR_MinimapButton

local LDB = LibStub("LibDataBroker-1.1")
local LDBIcon = LibStub("LibDBIcon-1.0")

local dataObj = nil

function MinimapBtn:Create()
    if dataObj then return end

    dataObj = LDB:NewDataObject("ArenaReplay", {
        type  = "launcher",
        icon  = "Interface\\Icons\\Achievement_Arena_2v2_7",
        label = "ArenaReplay",

        OnClick = function(_, button)
            if button == "LeftButton" then
                if IsShiftKeyDown() then
                    AR_MMRDisplay:Toggle()
                elseif IsControlKeyDown() then
                    AR_MMRTable:Toggle()
                else
                    if AR_TableGUI:IsShowing() then
                        AR_TableGUI:HideMatchesFrame()
                    else
                        AR_TableGUI:ShowMatchesFrame()
                    end
                end
            elseif button == "RightButton" then
                AR_Options:Open()
            end
        end,

        OnTooltipShow = function(tt)
            tt:AddLine("ArenaReplay", 0.89, 0.57, 0.77)
            tt:AddLine(" ")
            tt:AddLine("|cffffffffLeft-Click:|r " .. L.BTN_OPEN_PANEL, 0.8, 0.8, 0.8)
            tt:AddLine("|cffffffffShift-Click:|r " .. L.BTN_MMR_DISPLAY, 0.8, 0.8, 0.8)
            tt:AddLine("|cffffffffCtrl-Click:|r " .. L.BTN_MMR_HISTORY, 0.8, 0.8, 0.8)
            tt:AddLine("|cffffffffRight-Click:|r " .. L.OPT_MMR_SETTINGS, 0.8, 0.8, 0.8)
        end,
    })

    -- Register with LibDBIcon (uses AceDB profile for hide/position)
    local db = AR.db and AR.db.profile or { minimap = { hide = false } }
    LDBIcon:Register("ArenaReplay", dataObj, db.minimap)
end

function MinimapBtn:Show()
    LDBIcon:Show("ArenaReplay")
end

function MinimapBtn:Hide()
    LDBIcon:Hide("ArenaReplay")
end

function MinimapBtn:Refresh()
    if not AR.db then return end
    -- Update LibDBIcon's internal db reference to current profile's minimap table
    -- This is needed after AceDB profile switches, since LibDBIcon stores a reference
    -- to the minimap table given at Register() time, which becomes stale.
    local button = LDBIcon:GetMinimapButton("ArenaReplay")
    if button and button.db then
        -- Point LibDBIcon at the new profile's minimap table
        button.db = AR.db.profile.minimap
    end
    if AR.db.profile.minimap.hide then
        LDBIcon:Hide("ArenaReplay")
    else
        LDBIcon:Show("ArenaReplay")
    end
end
