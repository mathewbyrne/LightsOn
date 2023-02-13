
local BORDER_WIDTH = 1

LightsOn_Icon = {};
LightsOn_Icon.__index = LightsOn_Icon

function LightsOn_Icon.new(spellName, parent, size)
    local self = {}
    setmetatable(self, LightsOn_Icon)

    local frame = CreateFrame("Frame", nil, parent)
    frame:SetSize(size, size)
    frame:SetPoint("CENTER")

    local texture = frame:CreateTexture(nil, "BACKGROUND")
    texture:SetPoint("CENTER")
    texture:SetSize(size, size)
    texture:SetTexture(select(3, GetSpellInfo(spellName)))

    local progress = frame:CreateTexture(nil, "OVERLAY")
    progress:SetSize(size,0)
    progress:SetPoint("BOTTOM")
    progress:SetColorTexture(1.0,0.0,0.0,0.5)
    progress:Hide()

    local timer = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal");
    timer:SetPoint("CENTER")
    timer:SetTextColor(1.0, 1.0, 1.0)
    timer:SetFont("Interface\\AddOns\\ElvUI\\Core\\Media\\Fonts\\Expressway.ttf", math.ceil(size / 2), "OUTLINE")

    self.size = size
    self.frame = frame
    self.texture = texture
    self.timer = timer
    self.progress = progress

    self:disable()

    return self
end

function LightsOn_Icon:disable()
    self.texture:SetDesaturated(true)
    self.frame:SetAlpha(0.5)
    self.timer:Hide()
end

function LightsOn_Icon:enable(value)
    self.texture:SetDesaturated(false)
    self.frame:SetAlpha(1.0)
    self.timer:Show()
    self.timer:SetText(math.ceil(value))
end

-- should be a value between 0..1
function LightsOn_Icon:setProgress(progress)
    if progress > 0 then
        self.progress:Show()
        self.progress:SetSize(self.size, self.size*progress)
        self.progress:SetPoint("BOTTOM")
    else
        self.progress:Hide()
    end
end
