
hook.Add("LoadFonts", "ixCombineViewObjectives", function()
	surface.CreateFont("ixCombineViewObjectives", {
		font = "Courier New",
		size = 16,
		antialias = true,
		weight = 400
	})
end)

DEFINE_BASECLASS("DFrame")

local PANEL = {}

local animationTime = 1
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

	self.dateLabel = vgui.Create("DLabel", self)
	self.dateLabel:SetFont("BudgetLabel")
	self.dateLabel:SizeToContents()
	self.dateLabel:Dock(TOP)

	self.textEntry = vgui.Create("DTextEntry", self)
	self.textEntry:SetMultiline(true)
	self.textEntry:Dock(FILL)
	self.textEntry:SetFont("ixCombineViewObjectives")
end

function PANEL:Populate(data, bDontShow)
	data = data or {}

	self.oldText = data.text or ""
	self.alpha = 255

	local date = data.lastEditDate and ix.date.Construct(data.lastEditDate):format("%Y/%m/%d - %H:%M:%S") or L("unknown")

	self:SetTitle(L("objectivesTitle"))
	self.nameLabel:SetText(string.format("%s: %s", L("lastEdit"), data.lastEditPlayer or L("unknown")):upper())
	self.dateLabel:SetText(string.format("%s: %s", L("lastEditDate"), date):upper())
	self.textEntry:SetText(data.text or "")

	if (!hook.Run("CanPlayerEditObjectives", LocalPlayer())) then
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
	local text = string.Trim(self.textEntry:GetValue():sub(1, 2000))

	-- only update if there's something different so we can preserve the last editor if nothing changed
	if (self.oldText != text) then
		netstream.Start("ViewObjectivesUpdate", text)
		Schema:AddCombineDisplayMessage("@cViewObjectivesUpdate")
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

vgui.Register("ixViewObjectives", PANEL, "DFrame")
