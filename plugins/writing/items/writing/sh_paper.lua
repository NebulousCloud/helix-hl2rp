
local PLUGIN = PLUGIN

ITEM.name = "Paper"
ITEM.description = "A scrap piece of paper, %s."
ITEM.price = 2
ITEM.model = Model("models/props_c17/paper01.mdl")
ITEM.width = 1
ITEM.height = 1
ITEM.classes = {CLASS_EOW}
ITEM.business = true
ITEM.bAllowMultiCharacterInteraction = true

function ITEM:GetDescription()
	return self:GetData("owner", 0) == 0
		and string.format(self.description, "it's tattered and dirty.")
		or string.format(self.description, "it has been written on.")
end

function ITEM:SetText(text, character)
	text = tostring(text):sub(1, PLUGIN.maxLength)

	self:SetData("text", text, false, false, true)
	self:SetData("owner", character and character:GetID() or 0)
end

ITEM.functions.View = {
	OnRun = function(item)
		netstream.Start(item.player, "ixViewPaper", item:GetID(), item:GetData("text", ""), 0)
		return false
	end,

	OnCanRun = function(item)
		local owner = item:GetData("owner", 0)

		return owner != 0
	end
}

ITEM.functions.Edit = {
	OnRun = function(item)
		netstream.Start(item.player, "ixViewPaper", item:GetID(), item:GetData("text", ""), 1)
		return false
	end,

	OnCanRun = function(item)
		local owner = item:GetData("owner", 0)

		return owner == 0 or owner == item.player:GetCharacter():GetID() and item:GetData("text", "") == ""
	end
}

ITEM.functions.take.OnCanRun = function(item)
	local owner = item:GetData("owner", 0)

	return IsValid(item.entity) and (owner == 0 or owner == item.player:GetCharacter():GetID())
end
