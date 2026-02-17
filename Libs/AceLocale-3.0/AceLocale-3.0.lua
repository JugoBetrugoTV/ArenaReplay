--- AceLocale-3.0 - Minimal embedded version for ArenaReplay
local MAJOR, MINOR = "AceLocale-3.0", 6
local AceLocale = LibStub:NewLibrary(MAJOR, MINOR)
if not AceLocale then return end

local locales = {}
local defaultLocale = nil

function AceLocale:NewLocale(addon, locale, isDefault, silent)
    if not locales[addon] then
        locales[addon] = {}
    end
    if not locales[addon][locale] then
        locales[addon][locale] = {}
    end

    if isDefault then
        defaultLocale = defaultLocale or {}
        defaultLocale[addon] = locale
        -- Return a table that records assignments and allows reading
        return setmetatable(locales[addon][locale], {
            __newindex = function(self, key, value)
                rawset(self, key, value)
            end,
        })
    end

    -- Check if this locale matches the client locale
    local clientLocale = GetLocale and GetLocale() or "enUS"
    if locale ~= clientLocale then
        return nil -- skip non-matching locales
    end

    return setmetatable(locales[addon][locale], {
        __newindex = function(self, key, value)
            rawset(self, key, value)
        end,
    })
end

function AceLocale:GetLocale(addon, silent)
    local clientLocale = GetLocale and GetLocale() or "enUS"

    -- Try client locale first
    if locales[addon] and locales[addon][clientLocale] then
        local default = defaultLocale and defaultLocale[addon]
        local fallback = default and locales[addon][default] or {}
        return setmetatable(locales[addon][clientLocale], { __index = fallback })
    end

    -- Fall back to default locale
    if defaultLocale and defaultLocale[addon] and locales[addon] then
        local defLoc = defaultLocale[addon]
        if locales[addon][defLoc] then
            return locales[addon][defLoc]
        end
    end

    -- Return empty table as last resort
    if not silent then
        -- In production this would error, but we return empty for robustness
    end
    return setmetatable({}, { __index = function(t, k) return k end })
end
