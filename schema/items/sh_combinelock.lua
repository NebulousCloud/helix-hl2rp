
ITEM.name = "Combine Lock"
ITEM.description = "A metal apparatus applied to doors."
ITEM.model = Model("models/props_combine/combine_lock01.mdl")
ITEM.width = 1
ITEM.height = 2
ITEM.iconCam = {
	pos = Vector(-0.5, 50, 2),
	ang = Angle(0, 270, 0),
	fov = 25.29
}

ITEM.functions.Place = {
	OnRun = function(itemTable)
		local client = itemTable.player
		local data = {}
			data.start = client:GetShootPos()
			data.endpos = data.start + client:GetAimVector() * 96
			data.filter = client

		local lock = scripted_ents.Get("ix_combinelock"):SpawnFunction(client, util.TraceLine(data))

		if (IsValid(lock)) then
			client:EmitSound("physics/metal/weapon_impact_soft2.wav", 75, 80)
		else
			return false
		end
	end
}
