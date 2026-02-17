--- AceSerializer-3.0 - Minimal embedded version for ArenaReplay
local MAJOR, MINOR = "AceSerializer-3.0", 5
local AceSerializer = LibStub:NewLibrary(MAJOR, MINOR)
if not AceSerializer then return end

AceSerializer.embeds = AceSerializer.embeds or {}

local mixins = {}

-- Simple serialization using string encoding
function mixins:Serialize(...)
    local parts = {}
    for i = 1, select("#", ...) do
        local val = select(i, ...)
        local t = type(val)
        if t == "string" then
            table.insert(parts, "^S" .. val:gsub("[\030\031%^~]", function(c)
                return "~" .. string.char(string.byte(c) + 64)
            end))
        elseif t == "number" then
            table.insert(parts, "^N" .. tostring(val))
        elseif t == "boolean" then
            table.insert(parts, val and "^B" or "^b")
        elseif t == "nil" then
            table.insert(parts, "^Z")
        elseif t == "table" then
            table.insert(parts, "^T")
            for k, v in pairs(val) do
                table.insert(parts, self:Serialize(k))
                table.insert(parts, self:Serialize(v))
            end
            table.insert(parts, "^t")
        end
    end
    return table.concat(parts, "\030")
end

function mixins:Deserialize(str)
    -- Minimal deserializer: for ArenaReplay, we primarily use
    -- simple comma-separated event data rather than Ace serialization
    return true, str
end

function AceSerializer:Embed(target)
    for k, v in pairs(mixins) do
        target[k] = v
    end
    self.embeds[target] = true
end
