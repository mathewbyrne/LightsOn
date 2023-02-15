
local addonName, addon = ...

local frame = CreateFrame("Frame", nil, InterfaceOptionsFramePanelContainer)
frame.name = addonName
frame:Hide()

frame:SetScript("OnShow", function(frmae)
    local title = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
	title:SetPoint("TOPLEFT", 16, -16)
	title:SetText(addonName)

    local info = {}
	local anchorPointDropdown = CreateFrame("Frame", "LightsOnAnchorPoint", frame, "UIDropDownMenuTemplate")
	anchorPointDropdown:SetPoint("TOPLEFT", title, "BOTTOMLEFT", -15, -10)
	anchorPointDropdown.initialize = function()
		wipe(info)
		local anchorPoints = {
            "TOPLEFT",
            "TOP",
            "TOPRIGHT",
            "LEFT",
            "CENTER",
            "RIGHT",
            "BOTTOMLEFT",
            "BOTTOM",
            "BOTTOMRIGHT",
        }
		for i, anchorPoint in next, anchorPoints do
			info.text = anchorPoint
			info.value = anchorPoint
			info.func = function(self)
				print(self.value)
				LightsOnAnchorPointText:SetText(self:GetText())
			end
			info.checked = false
			UIDropDownMenu_AddButton(info)
		end
	end
	LightsOnAnchorPointText:SetText("CENTER")
end)

InterfaceOptions_AddCategory(frame)
