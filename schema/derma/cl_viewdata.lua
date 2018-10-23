
hook.Add("LoadFonts", "ixCombineViewData", function()
	surface.CreateFont("ixCombineViewData", {
		font = "Courier New",
		size = 16,
		antialias = true,
		weight = 400
	})
end)

local animationTime = 1
DEFINE_BASECLASS("DFrame")

local PANEL = {}

AccessorFunc(PANEL, "bCommitOnClose", "CommitOnClose", FORCE_BOOL)

function PANEL:Init()
	self:SetCommitOnClose(true)
	self:SetBackgroundBlur(true)
	self:SetSize(ScrW() / 4 > 200 and ScrW() / 4 or ScrW() / 2, ScrH() / 2 > 300 and ScrH() / 2 or ScrH())
	self:Center()

	self.nameLabel = vgui.Create("DLabel", self)
	self.nameLabel:SetFont("BudgetLabel")
	self.nameLabel:SizeToContents()
	self.nameLabel:Dock(TOP)

	self.cidLabel = vgui.Create("DLabel", self)
	self.cidLabel:SetFont("BudgetLabel")
	self.cidLabel:SizeToContents()
	self.cidLabel:Dock(TOP)

	self.lastEditLabel = vgui.Create("DLabel", self)
	self.lastEditLabel:SetFont("BudgetLabel")
	self.lastEditLabel:SizeToContents()
	self.lastEditLabel:Dock(TOP)

	self.textEntry = vgui.Create("DTextEntry", self)
	self.textEntry:SetMultiline(true)
	self.textEntry:Dock(FILL)
	self.textEntry:SetFont("ixCombineViewData")
end

function PANEL:Populate(target, cid, data, bDontShow)
	data = data or {}
	cid = cid or string.format("00000 (%s)", L("unknown")):upper()

	self.alpha = 255
	self.target = target
	self.oldText = data.text or ""

	local character = target:GetCharacter()
	local name = character:GetName()

	self:SetTitle(name)
	self.nameLabel:SetText(string.format("%s: %s", L("name"), name):upper())
	self.cidLabel:SetText(string.format("%s: #%s", L("citizenid"), cid):upper())
	self.lastEditLabel:SetText(string.format("%s: %s", L("lastEdit"), data.editor or L("unknown")):upper())
	self.textEntry:SetText(data.text or "")

	if (!hook.Run("CanPlayerEditData", LocalPlayer(), target)) then
		self.textEntry:SetEnabled(false)
	end

	if (!bDontShow) then
		self.alpha = 0
		self:SetAlpha(0)
		self:MakePopup()

		self:CreateAnimation(animationTime, {
			index = 1,
			target = {alpha = 255},
			easing = "outQuint",

			Think = function(animation, panel)
				panel:SetAlpha(panel.alpha)
			end
		})
	end
end

function PANEL:CommitChanges()
	if (IsValid(self.target)) then
		local text = string.Trim(self.textEntry:GetValue():sub(1, 1000))

		-- only update if there's something different so we can preserve the last editor if nothing changed
		if (self.oldText != text) then
			netstream.Start("ViewDataUpdate", self.target, text)
			Schema:AddCombineDisplayMessage("@cViewDataUpdate")
		end
	else
		Schema:AddCombineDisplayMessage("@cViewDataExpired", Color(255, 0, 0, 255))
	end
end

function PANEL:Close()
	if (self.bClosing) then
		return
	end

	self.bClosing = true

	if (self:GetCommitOnClose()) then
		self:CommitChanges()
	end

	self:SetMouseInputEnabled(false)
	self:SetKeyboardInputEnabled(false)

	self:CreateAnimation(animationTime, {
		target = {alpha = 0},
		easing = "outQuint",

		Think = function(animation, panel)
			panel:SetAlpha(panel.alpha)
		end,

		OnComplete = function(animation, panel)
			BaseClass.Close(panel)
		end
	})
end

vgui.Register("ixViewData", PANEL, "DFrame")
