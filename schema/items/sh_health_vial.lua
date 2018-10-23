
ITEM.name = "Health Vial"
ITEM.model = Model("models/healthvial.mdl")
ITEM.description = "A small vial with green liquid."
ITEM.category = "Medical"
ITEM.price = 40

ITEM.functions.Apply = {
	sound = "items/medshot4.wav",
	OnRun = function(itemTable)
		local client = itemTable.player

		client:SetHealth(math.min(client:Health() + 20, client:GetMaxHealth()))
	end
}
