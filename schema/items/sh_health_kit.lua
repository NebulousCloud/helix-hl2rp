
ITEM.name = "Health Kit"
ITEM.model = Model("models/items/healthkit.mdl")
ITEM.description = "A white packet filled with medication."
ITEM.category = "Medical"
ITEM.price = 65

ITEM.functions.Apply = {
	sound = "items/medshot4.wav",
	OnRun = function(itemTable)
		local client = itemTable.player

		client:SetHealth(math.min(client:Health() + 50, 100))
	end
}
