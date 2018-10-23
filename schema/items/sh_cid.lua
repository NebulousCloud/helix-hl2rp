
ITEM.name = "Citizen ID"
ITEM.model = Model("models/gibs/metal_gib4.mdl")
ITEM.description = "A citizen identification card with ID #%s, assigned to %s."

function ITEM:GetDescription()
	return string.format(self.description, self:GetData("id", "00000"), self:GetData("name", "nobody"))
end
