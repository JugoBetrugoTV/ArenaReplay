--- AceAddon-3.0 - Minimal embedded version for ArenaReplay
-- Full version: https://www.wowace.com/projects/ace3/pages/api/ace-addon-3-0

local MAJOR, MINOR = "AceAddon-3.0", 13
local AceAddon, oldminor = LibStub:NewLibrary(MAJOR, MINOR)
if not AceAddon then return end

AceAddon.addons = AceAddon.addons or {}
AceAddon.initializequeue = AceAddon.initializequeue or {}
AceAddon.enablequeue = AceAddon.enablequeue or {}

local function Embed(target, ...)
    for i = 1, select("#", ...) do
        local mixin = select(i, ...)
        local lib = LibStub(mixin, true)
        if lib then
            if lib.Embed then
                lib:Embed(target)
            end
        end
    end
end

function AceAddon:NewAddon(name, ...)
    if self.addons[name] then return self.addons[name] end
    local addon = {}
    addon.name = name
    addon.modules = {}
    self.addons[name] = addon
    Embed(addon, ...)
    table.insert(self.initializequeue, addon)
    table.insert(self.enablequeue, addon)
    _G[name] = addon
    return addon
end

function AceAddon:GetAddon(name)
    return self.addons[name]
end

-- Fire initialization on ADDON_LOADED
local initFrame = CreateFrame("Frame")
initFrame:RegisterEvent("PLAYER_LOGIN")
initFrame:SetScript("OnEvent", function()
    for _, addon in ipairs(AceAddon.initializequeue) do
        if addon.OnInitialize then
            addon:OnInitialize()
        end
    end
    AceAddon.initializequeue = {}
    for _, addon in ipairs(AceAddon.enablequeue) do
        if addon.OnEnable then
            addon:OnEnable()
        end
    end
    AceAddon.enablequeue = {}
end)
