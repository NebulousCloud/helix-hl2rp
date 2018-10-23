
ITEM.name = "Chinese Takeout"
ITEM.model = Model("models/props_junk/garbage_takeoutcarton001a.mdl")
ITEM.width = 1
ITEM.height = 1
ITEM.description = "A takeout carton, it's filled with cold noodles."
ITEM.category = "Consumables"
ITEM.permit = "consumables"

ITEM.functions.Eat = {
	OnRun = function(itemTable)
		local client = itemTable.player

		client:SetHealth(math.min(client:Health() + 10, 100))

		return true
	end,
}
