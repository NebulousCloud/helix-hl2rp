
local PLUGIN = PLUGIN

netstream.Hook("ixWritingEdit", function(client, itemID, text)
	text = tostring(text):sub(1, PLUGIN.maxLength)

	local character = client:GetCharacter()
	local item = ix.item.instances[itemID]

	-- we don't check for entity since data can be changed in the player's inventory
	if (character and item and item.base == "base_writing") then
		local owner = item:GetData("owner", 0)

		if ((owner == 0 or owner == character:GetID()) and text:len() > 0) then
			item:SetText(text, character)
		end
	end
end)
