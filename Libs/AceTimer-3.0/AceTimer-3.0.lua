--- AceTimer-3.0 - Minimal embedded version for ArenaReplay
local MAJOR, MINOR = "AceTimer-3.0", 6
local AceTimer = LibStub:NewLibrary(MAJOR, MINOR)
if not AceTimer then return end

AceTimer.embeds = AceTimer.embeds or {}
local activeTimers = {}
local timerFrame = CreateFrame("Frame")
local timerID = 0

timerFrame:SetScript("OnUpdate", function(self, elapsed)
    for id, timer in pairs(activeTimers) do
        timer.elapsed = timer.elapsed + elapsed
        if timer.elapsed >= timer.delay then
            timer.elapsed = timer.elapsed - timer.delay
            if type(timer.callback) == "string" then
                if timer.obj[timer.callback] then
                    timer.obj[timer.callback](timer.obj)
                end
            elseif type(timer.callback) == "function" then
                timer.callback()
            end
            if not timer.repeating then
                activeTimers[id] = nil
            end
        end
    end
end)

local mixins = {}

function mixins:ScheduleTimer(callback, delay, ...)
    timerID = timerID + 1
    activeTimers[timerID] = {
        obj = self,
        callback = callback,
        delay = delay,
        elapsed = 0,
        repeating = false,
    }
    return timerID
end

function mixins:ScheduleRepeatingTimer(callback, delay, ...)
    timerID = timerID + 1
    activeTimers[timerID] = {
        obj = self,
        callback = callback,
        delay = delay,
        elapsed = 0,
        repeating = true,
    }
    return timerID
end

function mixins:CancelTimer(id)
    if id then
        activeTimers[id] = nil
    end
end

function mixins:CancelAllTimers()
    for id, timer in pairs(activeTimers) do
        if timer.obj == self then
            activeTimers[id] = nil
        end
    end
end

function AceTimer:Embed(target)
    for k, v in pairs(mixins) do
        target[k] = v
    end
    self.embeds[target] = true
end
