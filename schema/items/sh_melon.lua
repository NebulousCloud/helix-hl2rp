
ITEM.name = "Melon"
ITEM.model = Model("models/props_junk/watermelon01.mdl")
ITEM.width = 1
ITEM.height = 1
ITEM.description = "A green fruit, it has a hard outer shell."
ITEM.category = "Consumables"
ITEM.permit = "consumables"

ITEM.functions.Eat = {
	OnRun = function(itemTable)
		local client = itemTable.player

		client:SetHealth(math.min(client:Health() + 10, client:GetMaxHealth()))

		return true
	end,
}
