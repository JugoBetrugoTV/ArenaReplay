local _, AR = ...
local Compat = AR.Compat
local L = LibStub("AceLocale-3.0"):GetLocale("ArenaReplay")

------------------------------------------------------------
-- AceConfig Options Panel for ArenaReplay
-- Features: SharedMedia font picker, color picker, profiles,
-- LibDBIcon minimap toggle, bracket visibility, table settings
------------------------------------------------------------
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceDBOptions = LibStub("AceDBOptions-3.0")
local SharedMedia = LibStub("LibSharedMedia-3.0")

AR_Options = {}
local Options = AR_Options

-- Helper: get display settings from ArenaReplayDB (bridge target)
-- Returns the actual table or a safe empty fallback (never nil)
local EMPTY_SETTINGS = {}
local function GetSettings()
    if not ArenaReplayDB or not ArenaReplayDB.mmr or not ArenaReplayDB.mmr.display then
        return EMPTY_SETTINGS
    end
    return ArenaReplayDB.mmr.display
end

-- Helper: get AceDB profile settings (source of truth for UI prefs)
local function GetProfile()
    if AR.db and AR.db.profile then return AR.db.profile end
    return {}
end

-- Helper: write to both AceDB profile AND ArenaReplayDB bridge
local function SetDisplayOpt(key, val)
    -- Write to AceDB profile (source of truth)
    local profile = GetProfile()
    if profile.mmrDisplay then
        profile.mmrDisplay[key] = val
    end
    -- Write to ArenaReplayDB bridge (ensure table exists)
    if ArenaReplayDB and ArenaReplayDB.mmr then
        if not ArenaReplayDB.mmr.display then
            ArenaReplayDB.mmr.display = {}
        end
        ArenaReplayDB.mmr.display[key] = val
    end
end

------------------------------------------------------------
-- Build the main options table
------------------------------------------------------------
function Options:GetOptionsTable()
    local options = {
        name = "ArenaReplay",
        type = "group",
        childGroups = "tab",
        args = {
            ----------------------------------------------------------------
            -- Tab 1: Display
            ----------------------------------------------------------------
            display = {
                order = 1,
                type = "group",
                name = L.OPT_DISPLAY_SETTINGS,
                args = {
                    headerBrackets = {
                        order = 1,
                        type = "header",
                        name = L.OPT_BRACKET_VISIBILITY,
                    },
                    show2v2 = {
                        order = 10,
                        type = "toggle",
                        name = L.MMR_2V2 .. " " .. L.MMR_RATING,
                        desc = L.OPT_SHOW_BRACKET_DESC,
                        width = "normal",
                        get = function() return GetSettings().show2v2 ~= false end,
                        set = function(_, val) SetDisplayOpt("show2v2", val); AR_MMRDisplay:Update() end,
                    },
                    show3v3 = {
                        order = 11,
                        type = "toggle",
                        name = L.MMR_3V3 .. " " .. L.MMR_RATING,
                        desc = L.OPT_SHOW_BRACKET_DESC,
                        width = "normal",
                        get = function() return GetSettings().show3v3 ~= false end,
                        set = function(_, val) SetDisplayOpt("show3v3", val); AR_MMRDisplay:Update() end,
                    },
                    showShuffle = {
                        order = 12,
                        type = "toggle",
                        name = L.MMR_SHUFFLE .. " " .. L.MMR_MMR,
                        desc = L.OPT_SHOW_BRACKET_DESC,
                        width = "normal",
                        hidden = function() return not Compat.hasSoloShuffle end,
                        get = function() return GetSettings().showShuffle ~= false end,
                        set = function(_, val) SetDisplayOpt("showShuffle", val); AR_MMRDisplay:Update() end,
                    },
                    showBlitz = {
                        order = 13,
                        type = "toggle",
                        name = L.MMR_BLITZ .. " " .. L.MMR_MMR,
                        desc = L.OPT_SHOW_BRACKET_DESC,
                        width = "normal",
                        hidden = function() return not Compat.hasBlitz end,
                        get = function() return GetSettings().showBlitz ~= false end,
                        set = function(_, val) SetDisplayOpt("showBlitz", val); AR_MMRDisplay:Update() end,
                    },
                    showRBG = {
                        order = 14,
                        type = "toggle",
                        name = L.MMR_RBG .. " " .. L.MMR_RATING,
                        desc = L.OPT_SHOW_BRACKET_DESC,
                        width = "normal",
                        hidden = function() return not Compat.hasRBG end,
                        get = function() return GetSettings().showRBG ~= false end,
                        set = function(_, val) SetDisplayOpt("showRBG", val); AR_MMRDisplay:Update() end,
                    },
                    show5v5 = {
                        order = 15,
                        type = "toggle",
                        name = "5v5 " .. L.MMR_RATING,
                        desc = L.OPT_SHOW_BRACKET_DESC,
                        width = "normal",
                        hidden = function() return not Compat.has5v5 end,
                        get = function() return GetSettings().show5v5 ~= false end,
                        set = function(_, val) SetDisplayOpt("show5v5", val); AR_MMRDisplay:Update() end,
                    },

                    headerOptions = {
                        order = 20,
                        type = "header",
                        name = L.OPT_DISPLAY_SETTINGS,
                    },
                    lock = {
                        order = 21,
                        type = "toggle",
                        name = L.OPT_LOCK_DISPLAY,
                        desc = L.OPT_LOCK_DISPLAY_DESC,
                        width = "full",
                        get = function() return GetSettings().lock end,
                        set = function(_, val)
                            SetDisplayOpt("lock", val)
                            if val then AR_MMRDisplay:Lock() else AR_MMRDisplay:Unlock() end
                        end,
                    },
                    showMMRDiff = {
                        order = 22,
                        type = "toggle",
                        name = L.OPT_SHOW_BEFORE_AFTER,
                        desc = L.OPT_SHOW_BEFORE_AFTER_DESC,
                        width = "full",
                        get = function() return GetSettings().showMMRDiff ~= false end,
                        set = function(_, val) SetDisplayOpt("showMMRDiff", val); AR_MMRDisplay:Update() end,
                    },
                    showGains = {
                        order = 23,
                        type = "toggle",
                        name = L.OPT_SHOW_GAINS,
                        desc = L.OPT_SHOW_GAINS_DESC,
                        width = "full",
                        get = function() return GetSettings().showGains ~= false end,
                        set = function(_, val) SetDisplayOpt("showGains", val); AR_MMRDisplay:Update() end,
                    },
                    hideNoData = {
                        order = 24,
                        type = "toggle",
                        name = L.OPT_HIDE_NO_DATA,
                        desc = L.OPT_HIDE_NO_DATA_DESC,
                        width = "full",
                        get = function() return GetSettings().hideNoData end,
                        set = function(_, val) SetDisplayOpt("hideNoData", val); AR_MMRDisplay:Update() end,
                    },
                },
            },

            ----------------------------------------------------------------
            -- Tab 2: Appearance
            ----------------------------------------------------------------
            appearance = {
                order = 2,
                type = "group",
                name = L.OPT_APPEARANCE,
                args = {
                    fontSize = {
                        order = 1,
                        type = "range",
                        name = L.OPT_FONT_SIZE,
                        desc = L.OPT_FONT_SIZE_DESC,
                        min = 8,
                        max = 32,
                        step = 1,
                        width = "double",
                        get = function() return GetSettings().fontSize or 13 end,
                        set = function(_, val) SetDisplayOpt("fontSize", val); AR_MMRDisplay:Update() end,
                    },
                    fontFamily = {
                        order = 2,
                        type = "select",
                        dialogControl = "LSM30_Font",
                        name = L.OPT_FONT_FAMILY,
                        desc = L.OPT_FONT_FAMILY_DESC,
                        width = "double",
                        values = SharedMedia:HashTable("font"),
                        get = function()
                            return GetProfile().mmrDisplay and GetProfile().mmrDisplay.fontFamily or "Friz Quadrata TT"
                        end,
                        set = function(_, val)
                            SetDisplayOpt("fontFamily", val)
                            AR_MMRDisplay:Update()
                        end,
                    },
                    textColor = {
                        order = 3,
                        type = "color",
                        name = L.OPT_TEXT_COLOR,
                        desc = L.OPT_TEXT_COLOR_DESC,
                        hasAlpha = true,
                        width = "normal",
                        get = function()
                            local c = GetSettings().textColor or { r = 1, g = 1, b = 1, a = 1 }
                            return c.r, c.g, c.b, c.a
                        end,
                        set = function(_, r, g, b, a)
                            SetDisplayOpt("textColor", { r = r, g = g, b = b, a = a })
                            AR_MMRDisplay:Update()
                        end,
                    },
                },
            },

            ----------------------------------------------------------------
            -- Tab 3: Visibility
            ----------------------------------------------------------------
            visibility = {
                order = 3,
                type = "group",
                name = L.OPT_VISIBILITY,
                args = {
                    showOnlyInQueue = {
                        order = 1,
                        type = "toggle",
                        name = L.OPT_ONLY_IN_QUEUE,
                        desc = L.OPT_ONLY_IN_QUEUE_DESC,
                        width = "full",
                        get = function() return GetSettings().showOnlyInQueue end,
                        set = function(_, val) SetDisplayOpt("showOnlyInQueue", val); AR_MMRDisplay:Update() end,
                    },
                    showInPVP = {
                        order = 2,
                        type = "toggle",
                        name = L.OPT_SHOW_IN_PVP,
                        desc = L.OPT_SHOW_IN_PVP_DESC,
                        width = "full",
                        get = function() return GetSettings().showInPVP end,
                        set = function(_, val) SetDisplayOpt("showInPVP", val); AR_MMRDisplay:Update() end,
                    },
                    showInPVE = {
                        order = 3,
                        type = "toggle",
                        name = L.OPT_SHOW_IN_PVE,
                        desc = L.OPT_SHOW_IN_PVE_DESC,
                        width = "full",
                        get = function() return GetSettings().showInPVE ~= false end,
                        set = function(_, val) SetDisplayOpt("showInPVE", val); AR_MMRDisplay:Update() end,
                    },
                    headerMinimap = {
                        order = 10,
                        type = "header",
                        name = "Minimap",
                    },
                    hideMinimap = {
                        order = 11,
                        type = "toggle",
                        name = L.OPT_HIDE_MINIMAP,
                        desc = L.OPT_HIDE_MINIMAP_DESC,
                        width = "full",
                        get = function()
                            return GetProfile().minimap and GetProfile().minimap.hide
                        end,
                        set = function(_, val)
                            if AR.db then AR.db.profile.minimap.hide = val end
                            AR_MinimapButton:Refresh()
                        end,
                    },
                },
            },

            ----------------------------------------------------------------
            -- Tab 4: Table
            ----------------------------------------------------------------
            tableSettings = {
                order = 4,
                type = "group",
                name = L.OPT_TABLE_SETTINGS,
                args = {
                    classColors = {
                        order = 1,
                        type = "toggle",
                        name = L.OPT_CLASS_COLORS,
                        desc = L.OPT_CLASS_COLORS_DESC,
                        width = "full",
                        get = function() return GetSettings().classColors ~= false end,
                        set = function(_, val)
                            SetDisplayOpt("classColors", val)
                            if AR_MMRTable:IsShowing() then AR_MMRTable:Refresh() end
                        end,
                    },
                    winLossIcons = {
                        order = 2,
                        type = "toggle",
                        name = L.OPT_WIN_LOSS_ICONS,
                        desc = L.OPT_WIN_LOSS_ICONS_DESC,
                        width = "full",
                        get = function() return GetSettings().winLossIcons ~= false end,
                        set = function(_, val)
                            SetDisplayOpt("winLossIcons", val)
                            if AR_MMRTable:IsShowing() then AR_MMRTable:Refresh() end
                        end,
                    },
                    headerReset = {
                        order = 90,
                        type = "header",
                        name = "",
                    },
                    resetSettings = {
                        order = 91,
                        type = "execute",
                        name = L.OPT_RESET_SETTINGS,
                        desc = L.OPT_RESET_SETTINGS_DESC,
                        confirm = true,
                        confirmText = L.OPT_RESET_CONFIRM,
                        func = function()
                            -- Reset AceDB profile to defaults
                            if AR.db then
                                AR.db:ResetProfile()
                            end
                            -- Also reset ArenaReplayDB display
                            if ArenaReplayDB.mmr then
                                local games = ArenaReplayDB.mmr.games
                                ArenaReplayDB.mmr.display = nil
                                AR_MMRTracker:Init()
                                ArenaReplayDB.mmr.games = games
                            end
                            AR_MMRDisplay:Update()
                            print("|cffe392c5<ArenaReplay>|r " .. L.OPT_RESET_DONE)
                        end,
                    },
                },
            },
        },
    }

    return options
end

------------------------------------------------------------
-- Register with AceConfig and Blizzard options
------------------------------------------------------------
function Options:Init()
    AceConfig:RegisterOptionsTable("ArenaReplay", self:GetOptionsTable())
    self.optionsFrame = AceConfigDialog:AddToBlizOptions("ArenaReplay", "ArenaReplay")

    -- Register AceDB profiles tab
    if AR.db then
        local profileOptions = AceDBOptions:GetOptionsTable(AR.db)
        AceConfig:RegisterOptionsTable("ArenaReplay_Profiles", profileOptions)
        AceConfigDialog:AddToBlizOptions("ArenaReplay_Profiles", L.OPT_PROFILES, "ArenaReplay")
    end
end

------------------------------------------------------------
-- Open the settings panel
------------------------------------------------------------
function Options:Open()
    AceConfigDialog:Open("ArenaReplay")
end
