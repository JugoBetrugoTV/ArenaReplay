local _, AR = ...

------------------------------------------------------------
-- AR_Comm: Broadcasting and spectating via AceComm
------------------------------------------------------------
AR_Comm = {}
local Comm = AR_Comm
local L = LibStub("AceLocale-3.0"):GetLocale("ArenaReplay", true)

local broadcasters = {}  -- { name = version }
local spectators   = {}  -- { name = true }
local connectedTo  = nil
local receiveBuffer = {}

------------------------------------------------------------
-- Initialize communication channels
------------------------------------------------------------
function Comm:Init(aceAddon)
    self.addon = aceAddon
    if aceAddon.RegisterComm then
        aceAddon:RegisterComm(AR.Data.COMM_PREFIX_LOOKUP, function(prefix, msg, dist, sender)
            Comm:OnLookupMessage(prefix, msg, dist, sender)
        end)
        aceAddon:RegisterComm(AR.Data.COMM_PREFIX_HANDLE, function(prefix, msg, dist, sender)
            Comm:OnHandleMessage(prefix, msg, dist, sender)
        end)
    end
end

------------------------------------------------------------
-- Send a message via the appropriate channel
------------------------------------------------------------
function Comm:Send(prefix, msg, channel)
    if not self.addon or not self.addon.SendCommMessage then return end
    channel = channel or self:GetChannel()
    if channel then
        self.addon:SendCommMessage(prefix, msg, channel)
    end
end

function Comm:GetChannel()
    if IsInRaid() then return "RAID" end
    if IsInGroup() then return "PARTY" end
    if IsInGuild() then return "GUILD" end
    return nil
end

------------------------------------------------------------
-- Broadcast Lookup (discovery)
------------------------------------------------------------
function Comm:Lookup()
    self:Send(AR.Data.COMM_PREFIX_LOOKUP, AR.Data.COMM.VERSION_CHECK .. ":" .. AR.VERSION)
    broadcasters = {}
    print("|cffe392c5<ArenaReplay>|r Looking for broadcasts...")
end

function Comm:OnLookupMessage(prefix, msg, dist, sender)
    if sender == UnitName("player") then return end

    local parts = AR.Util:Split(msg, ":")
    if not parts or #parts < 2 then return end

    local cmd = parts[1]

    -- Version check / broadcast announcement
    if cmd == AR.Data.COMM.VERSION_CHECK then
        -- Respond with our version
        self:Send(AR.Data.COMM_PREFIX_LOOKUP, AR.Data.COMM.VERSION_CHECK .. ":" .. AR.VERSION)

    elseif cmd == AR.Data.COMM.BROADCAST_ON then
        broadcasters[sender] = parts[2] or AR.VERSION
        print("|cffe392c5<ArenaReplay>|r " .. L.NEW_BROADCASTER .. sender)

    elseif cmd == AR.Data.COMM.BROADCAST_OFF then
        broadcasters[sender] = nil
    end
end

------------------------------------------------------------
-- Connect to a broadcaster
------------------------------------------------------------
function Comm:ConnectTo(name)
    if not broadcasters[name] then
        print("|cffe392c5<ArenaReplay>|r Broadcaster '" .. name .. "' not found.")
        return
    end
    connectedTo = name
    self:Send(AR.Data.COMM_PREFIX_HANDLE, AR.Data.COMM.SPECTATE_REQ .. ":" .. UnitName("player"))
    print("|cffe392c5<ArenaReplay>|r " .. L.CONNECTED_TO .. name .. ". " .. L.WAITING_DATA)
end

------------------------------------------------------------
-- Handle match data messages
------------------------------------------------------------
function Comm:OnHandleMessage(prefix, msg, dist, sender)
    if not connectedTo and sender ~= UnitName("player") then
        -- We might be a broadcaster receiving spectate requests
        local parts = AR.Util:Split(msg, ":")
        if parts and parts[1] == AR.Data.COMM.SPECTATE_REQ then
            local specName = parts[2]
            if specName then
                spectators[specName] = true
                print("|cffe392c5<ArenaReplay>|r " .. L.NEW_SPECTATOR .. specName)
            end
        end
        return
    end

    -- We are spectating: process incoming data
    if sender ~= connectedTo then return end

    local parts = AR.Util:Split(msg, ":")
    if not parts or #parts < 1 then return end

    local cmd = parts[1]

    if cmd == AR.Data.COMM.MATCH_HEADER then
        -- New match starting; clear buffer
        receiveBuffer = { header = msg }

    elseif cmd == AR.Data.COMM.MATCH_DATA then
        table.insert(receiveBuffer, msg)

    elseif cmd == AR.Data.COMM.MATCH_END then
        -- Match finished, could reconstruct and play
        receiveBuffer.footer = msg

    elseif cmd == AR.Data.COMM.PLAYER_INFO then
        -- Player info update during broadcast
        receiveBuffer.playerInfo = receiveBuffer.playerInfo or {}
        table.insert(receiveBuffer.playerInfo, msg)
    end
end

------------------------------------------------------------
-- Broadcasting: send match events to spectators
------------------------------------------------------------
function Comm:BroadcastEvent(eventMsg)
    if not ArenaReplayDB or not ArenaReplayDB.broadcasting then return end
    self:Send(AR.Data.COMM_PREFIX_HANDLE, AR.Data.COMM.MATCH_DATA .. ":" .. eventMsg)
end

function Comm:BroadcastStart(matchStub)
    if not ArenaReplayDB or not ArenaReplayDB.broadcasting then return end
    -- Announce broadcast availability
    self:Send(AR.Data.COMM_PREFIX_LOOKUP, AR.Data.COMM.BROADCAST_ON .. ":" .. AR.VERSION)
    -- Send match header with player info
    local header = AR.Data.COMM.MATCH_HEADER .. ":" .. (matchStub.map or 0) .. ":" .. (matchStub.bracket or 0)
    self:Send(AR.Data.COMM_PREFIX_HANDLE, header)
end

function Comm:BroadcastEnd()
    if not ArenaReplayDB or not ArenaReplayDB.broadcasting then return end
    self:Send(AR.Data.COMM_PREFIX_HANDLE, AR.Data.COMM.MATCH_END)
end

------------------------------------------------------------
-- Get current broadcaster/spectator state
------------------------------------------------------------
function Comm:GetBroadcasters()
    return broadcasters
end

function Comm:GetSpectators()
    local list = {}
    for name in pairs(spectators) do
        table.insert(list, name)
    end
    return list
end

function Comm:Disconnect()
    connectedTo = nil
    receiveBuffer = {}
end
