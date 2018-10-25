
function Schema:PopulateCharacterInfo(client, character, tooltip)
	if (client:GetNetVar("restricted")) then
		local panel = tooltip:AddRowAfter("name", "ziptie")
		panel:SetBackgroundColor(derma.GetColor("Warning", tooltip))
		panel:SetText(L("tiedUp"))
		panel:SizeToContents()
	elseif (client:GetNetVar("tying")) then
		local panel = tooltip:AddRowAfter("name", "ziptie")
		panel:SetBackgroundColor(derma.GetColor("Warning", tooltip))
		panel:SetText(L("beingTied"))
		panel:SizeToContents()
	elseif (client:GetNetVar("untying")) then
		local panel = tooltip:AddRowAfter("name", "ziptie")
		panel:SetBackgroundColor(derma.GetColor("Warning", tooltip))
		panel:SetText(L("beingUntied"))
		panel:SizeToContents()
	end
end

local COMMAND_PREFIX = "/"

function Schema:ChatTextChanged(text)
	if (LocalPlayer():IsCombine()) then
		local key = nil

		if (text == COMMAND_PREFIX .. "radio ") then
			key = "r"
		elseif (text == COMMAND_PREFIX .. "w ") then
			key = "w"
		elseif (text == COMMAND_PREFIX .. "y ") then
			key = "y"
		elseif (text:sub(1, 1):match("%w")) then
			key = "t"
		end

		if (key) then
			netstream.Start("PlayerChatTextChanged", key)
		end
	end
end

function Schema:FinishChat()
	netstream.Start("PlayerFinishChat")
end

function Schema:CanPlayerJoinClass(client, class, info)
	return false
end

function Schema:CharacterLoaded(character)
	if (character:IsCombine()) then
		vgui.Create("ixCombineDisplay")
	elseif (IsValid(ix.gui.combine)) then
		ix.gui.combine:Remove()
	end
end

function Schema:PlayerFootstep(client, position, foot, soundName, volume)
	return true
end

local COLOR_BLACK_WHITE = {
	["$pp_colour_addr"] = 0,
	["$pp_colour_addg"] = 0,
	["$pp_colour_addb"] = 0,
	["$pp_colour_brightness"] = 0,
	["$pp_colour_contrast"] = 1.5,
	["$pp_colour_colour"] = 0,
	["$pp_colour_mulr"] = 0,
	["$pp_colour_mulg"] = 0,
	["$pp_colour_mulb"] = 0
}

local combineOverlay = ix.util.GetMaterial("effects/combine_binocoverlay")
local scannerFirstPerson = false

function Schema:RenderScreenspaceEffects()
	local colorModify = {}
	colorModify["$pp_colour_colour"] = 0.77

	if (system.IsWindows()) then
		colorModify["$pp_colour_brightness"] = -0.02
		colorModify["$pp_colour_contrast"] = 1.2
	else
		colorModify["$pp_colour_brightness"] = 0
		colorModify["$pp_colour_contrast"] = 1
	end

	if (scannerFirstPerson) then
		COLOR_BLACK_WHITE["$pp_colour_brightness"] = 0.05 + math.sin(RealTime() * 10) * 0.01
		colorModify = COLOR_BLACK_WHITE
	end

	DrawColorModify(colorModify)

	if (LocalPlayer():IsCombine()) then
		render.UpdateScreenEffectTexture()

		combineOverlay:SetFloat("$alpha", 0.5)
		combineOverlay:SetInt("$ignorez", 1)

		render.SetMaterial(combineOverlay)
		render.DrawScreenQuad()
	end
end

function Schema:PreDrawOpaqueRenderables()
	local viewEntity = LocalPlayer():GetViewEntity()

	if (IsValid(viewEntity) and viewEntity:GetClass():find("scanner")) then
		self.LastViewEntity = viewEntity
		self.LastViewEntity:SetNoDraw(true)

		scannerFirstPerson = true
		return
	end

	if (self.LastViewEntity != viewEntity) then
		if (IsValid(self.LastViewEntity)) then
			self.LastViewEntity:SetNoDraw(false)
		end

		self.LastViewEntity = nil
		scannerFirstPerson = false
	end
end

function Schema:ShouldDrawCrosshair()
	if (scannerFirstPerson) then
		return false
	end
end

function Schema:AdjustMouseSensitivity()
	if (scannerFirstPerson) then
		return 0.3
	end
end

-- creates labels in the status screen
function Schema:CreateCharacterInfo(panel)
	if (LocalPlayer():Team() == FACTION_CITIZEN) then
		panel.cid = panel:Add("ixListRow")
		panel.cid:SetList(panel.list)
		panel.cid:Dock(TOP)
		panel.cid:DockMargin(0, 0, 0, 8)
	end
end

-- populates labels in the status screen
function Schema:UpdateCharacterInfo(panel)
	if (LocalPlayer():Team() == FACTION_CITIZEN) then
		panel.cid:SetLabelText(L("citizenid"))
		panel.cid:SetText(string.format("##%s", LocalPlayer():GetCharacter():GetData("cid") or "UNKNOWN"))
		panel.cid:SizeToContents()
	end
end

function Schema:BuildBusinessMenu(panel)
	local bHasItems = false

	for k, _ in pairs(ix.item.list) do
		if (hook.Run("CanPlayerUseBusiness", LocalPlayer(), k) != false) then
			bHasItems = true

			break
		end
	end

	return bHasItems
end

function Schema:PopulateHelpMenu(tabs)
	tabs["voices"] = function(container)
		for k, v in SortedPairs(Schema.voices.stored) do
			local class = container:Add("DLabel")
			class:SetFont("ixMenuButtonFont")
			class:SetText(string.upper(k))
			class:Dock(TOP)
			class:SetTextColor(ix.config.Get("color"))
			class:SetExpensiveShadow(1, color_black)
			class:SizeToContents()
			class:DockMargin(0, 0, 0, 8)

			for k2, v2 in SortedPairs(v) do
				local command = container:Add("DLabel")
				command:SetFont("ixMediumFont")
				command:SetText(string.upper(k2))
				command:Dock(TOP)
				command:SetTextColor(color_white)
				command:SetExpensiveShadow(1, color_black)
				command:SetWrap(true)
				command:SetAutoStretchVertical(true)
				command:SizeToContents()

				local phrase = container:Add("DLabel")
				phrase:SetFont("ixMediumLightFont")
				phrase:SetText(v2.text)
				phrase:Dock(TOP)
				phrase:SetTextColor(color_white)
				phrase:SetExpensiveShadow(1, color_black)
				phrase:SetWrap(true)
				phrase:SetAutoStretchVertical(true)
				phrase:SizeToContents()
				phrase:DockMargin(0, 0, 0, 8)
			end
		end
	end
end

netstream.Hook("CombineDisplayMessage", function(text, color, arguments)
	if (IsValid(ix.gui.combine)) then
		ix.gui.combine:AddLine(text, color, nil, unpack(arguments))
	end
end)

netstream.Hook("PlaySound", function(sound)
	surface.PlaySound(sound)
end)

netstream.Hook("Frequency", function(oldFrequency)
	Derma_StringRequest("Frequency", "What would you like to set the frequency to?", oldFrequency, function(text)
		ix.command.Send("SetFreq", text)
	end)
end)

netstream.Hook("ViewData", function(target, cid, data)
	Schema:AddCombineDisplayMessage("@cViewData")
	vgui.Create("ixViewData"):Populate(target, cid, data)
end)

netstream.Hook("ViewObjectives", function(data)
	Schema:AddCombineDisplayMessage("@cViewObjectives")
	vgui.Create("ixViewObjectives"):Populate(data)
end)
