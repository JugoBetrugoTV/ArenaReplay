local _, AR = ...

------------------------------------------------------------
-- AR_Seeker: Timeline / playback control bar
------------------------------------------------------------
AR_Seeker = {}
AR_Seeker.__index = AR_Seeker

function AR_Seeker:New(parent)
    local self = setmetatable({}, AR_Seeker)

    self.bar  = AR_GUI:CreateSeekerBar(parent)
    self.tick = AR_GUI:CreateSeekerText(self.bar)

    return self
end

function AR_Seeker:SetRange(minVal, maxVal)
    self.bar:SetMinMaxValues(minVal or 0, maxVal or 100)
end

function AR_Seeker:SetValue(val)
    self.bar:SetValue(val or 0)
end

function AR_Seeker:GetValue()
    return self.bar:GetValue()
end

function AR_Seeker:SetTimeText(text)
    self.tick:SetText(text or "00:00")
end

function AR_Seeker:GetSpeed()
    local speed = self.bar.speed:GetValue()
    return (speed or 100) / 100
end

function AR_Seeker:SetOnValueChanged(callback)
    self.bar:SetScript("OnValueChanged", callback)
end

function AR_Seeker:SetSpeedCallback(callback)
    self.bar.speed:SetScript("OnValueChanged", function(s, val)
        self.bar.speedLabel:SetText(math.floor(val) .. "%")
        if callback then callback(val / 100) end
    end)
end

function AR_Seeker:Hide()
    self.bar:Hide()
end

function AR_Seeker:Show()
    self.bar:Show()
end
