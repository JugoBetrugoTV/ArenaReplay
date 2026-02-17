--- AceEvent-3.0 - Minimal embedded version for ArenaReplay
local MAJOR, MINOR = "AceEvent-3.0", 4
local AceEvent = LibStub:NewLibrary(MAJOR, MINOR)
if not AceEvent then return end

AceEvent.frame = AceEvent.frame or CreateFrame("Frame")
AceEvent.embeds = AceEvent.embeds or {}

local eventMap = {} -- event -> { obj -> method }

AceEvent.frame:SetScript("OnEvent", function(self, event, ...)
    if eventMap[event] then
        for obj, method in pairs(eventMap[event]) do
            if type(method) == "string" then
                if obj[method] then obj[method](obj, event, ...) end
            elseif type(method) == "function" then
                method(event, ...)
            end
        end
    end
end)

local mixins = {}

function mixins:RegisterEvent(event, method)
    if not eventMap[event] then
        eventMap[event] = {}
        AceEvent.frame:RegisterEvent(event)
    end
    eventMap[event][self] = method or event
end

function mixins:UnregisterEvent(event)
    if eventMap[event] then
        eventMap[event][self] = nil
        if not next(eventMap[event]) then
            AceEvent.frame:UnregisterEvent(event)
            eventMap[event] = nil
        end
    end
end

function mixins:UnregisterAllEvents()
    for event, objs in pairs(eventMap) do
        objs[self] = nil
        if not next(objs) then
            AceEvent.frame:UnregisterEvent(event)
            eventMap[event] = nil
        end
    end
end

function mixins:RegisterMessage(message, method)
    if not eventMap["_MSG_" .. message] then
        eventMap["_MSG_" .. message] = {}
    end
    eventMap["_MSG_" .. message][self] = method or message
end

function mixins:SendMessage(message, ...)
    local key = "_MSG_" .. message
    if eventMap[key] then
        for obj, method in pairs(eventMap[key]) do
            if type(method) == "string" then
                if obj[method] then obj[method](obj, message, ...) end
            elseif type(method) == "function" then
                method(message, ...)
            end
        end
    end
end

function AceEvent:Embed(target)
    for k, v in pairs(mixins) do
        target[k] = v
    end
    self.embeds[target] = true
end
