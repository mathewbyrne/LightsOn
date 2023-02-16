
local BORDER_WIDTH = 1

LightsOn_Icon = {};
LightsOn_Icon.__index = LightsOn_Icon

local ICON_FONT = "Interface\\AddOns\\ElvUI\\Core\\Media\\Fonts\\Expressway.ttf"

function LightsOn_Icon.new(spellName, parent)
    local self = {}
    setmetatable(self, LightsOn_Icon)

    local frame = CreateFrame("Frame", nil, parent)
    frame:SetPoint("CENTER")

    local texture = frame:CreateTexture(nil, "BACKGROUND")
    texture:SetPoint("CENTER")
    texture:SetTexture(select(3, GetSpellInfo(spellName)))

    local progress = frame:CreateTexture(nil, "OVERLAY")
    progress:SetPoint("BOTTOM")
    progress:SetColorTexture(1.0,0.0,0.0,0.5)
    progress:Hide()

    local timer = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal");
    timer:SetPoint("CENTER")
    timer:SetTextColor(1.0, 1.0, 1.0)

    self.frame = frame
    self.texture = texture
    self.timer = timer
    self.progress = progress

    self:disable()

    return self
end

function LightsOn_Icon:setSize(size)
    self.size = size
    self.frame:SetSize(size, size)
    self.texture:SetSize(size, size)
    self.progress:SetSize(size, 0)
    self.timer:SetFont(ICON_FONT, math.ceil(size / 2), "OUTLINE")
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
