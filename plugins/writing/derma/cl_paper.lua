
local PLUGIN = PLUGIN

local PANEL = {}

AccessorFunc(PANEL, "bEditable", "Editable", FORCE_BOOL)
AccessorFunc(PANEL, "itemID", "ItemID", FORCE_NUMBER)

function PANEL:Init()
	if (IsValid(PLUGIN.panel)) then
		PLUGIN.panel:Remove()
	end

	self:SetSize(256, 318)
	self:Center()
	self:SetBackgroundBlur(true)
	self:SetDeleteOnClose(true)
	self:SetTitle(L("paper"))

	self.close = self:Add("DButton")
	self.close:Dock(BOTTOM)
	self.close:DockMargin(0, 4, 0, 0)
	self.close:SetText(L("close"))
	self.close.DoClick = function()
		if (self.bEditable) then
			netstream.Start("ixWritingEdit", self.itemID, self.text:GetValue():sub(1, PLUGIN.maxLength))
		end

		self:Close()
	end

	self.text = self:Add("DTextEntry")
	self.text:SetMultiline(true)
	self.text:SetEditable(false)
	self.text:SetDisabled(true)
	self.text:Dock(FILL)

	self:MakePopup()

	self.bEditable = false
	PLUGIN.panel = self
end

function PANEL:Think()
	local text = self.text:GetValue()

	if (text:len() > PLUGIN.maxLength) then
		local newText = text:sub(1, PLUGIN.maxLength)

		self.text:SetValue(newText)
		self.text:SetCaretPos(newText:len())

		surface.PlaySound("common/talk.wav")
	end
end

function PANEL:SetEditable(bValue)
	bValue = tobool(bValue)

	if (bValue == self.bEditable) then
		return
	end

	if (bValue) then
		self.close:SetText(L("save"))
		self.text:SetEditable(true)
		self.text:SetDisabled(false)
	else
		self.close:SetText(L("close"))
		self.text:SetEditable(false)
		self.text:SetDisabled(true)
	end

	self.bEditable = bValue
end

function PANEL:SetText(text)
	self.text:SetValue(text)
end

function PANEL:OnRemove()
	PLUGIN.panel = nil
end

vgui.Register("ixPaper", PANEL, "DFrame")
