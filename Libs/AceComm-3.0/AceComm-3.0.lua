--- AceComm-3.0 - Minimal embedded version for ArenaReplay
local MAJOR, MINOR = "AceComm-3.0", 12
local AceComm = LibStub:NewLibrary(MAJOR, MINOR)
if not AceComm then return end

AceComm.embeds = AceComm.embeds or {}
local commCallbacks = {} -- prefix -> { obj -> method }

local mixins = {}

function mixins:RegisterComm(prefix, method)
    if not commCallbacks[prefix] then
        commCallbacks[prefix] = {}
        C_ChatInfo.RegisterAddonMessagePrefix(prefix)
    end
    commCallbacks[prefix][self] = method or prefix
end

function mixins:UnregisterComm(prefix)
    if commCallbacks[prefix] then
        commCallbacks[prefix][self] = nil
    end
end

function mixins:SendCommMessage(prefix, text, distribution, target, prio, callbackFn)
    if not distribution then return end
    -- Use C_ChatInfo in 12.0
    if C_ChatInfo and C_ChatInfo.SendAddonMessage then
        C_ChatInfo.SendAddonMessage(prefix, text, distribution, target)
    end
end

-- Register the event handler for incoming addon messages
local commFrame = CreateFrame("Frame")
commFrame:RegisterEvent("CHAT_MSG_ADDON")
commFrame:SetScript("OnEvent", function(self, event, prefix, msg, dist, sender)
    if commCallbacks[prefix] then
        for obj, method in pairs(commCallbacks[prefix]) do
            if type(method) == "function" then
                method(prefix, msg, dist, sender)
            elseif type(method) == "string" then
                if obj[method] then
                    obj[method](obj, prefix, msg, dist, sender)
                end
            end
        end
    end
end)

function AceComm:Embed(target)
    for k, v in pairs(mixins) do
        target[k] = v
    end
    self.embeds[target] = true
end
