CLASS.name = "Metropolice Scanner"
CLASS.description = "A metropolice scanner, it utilises Combine technology."
CLASS.faction = FACTION_MPF

function CLASS:OnCanBe(client)
	return Schema:IsCombineRank(client:Name(), "SCN") or Schema:IsCombineRank(client:Name(), "SHIELD")
end

function CLASS:OnLeave(client)
	if (IsValid(client.ixScanner)) then
		local data = {}
			data.start = client.ixScanner:GetPos()
			data.endpos = data.start - Vector(0, 0, 1024)
			data.filter = {client, client.ixScanner}
		local position = util.TraceLine(data).HitPos

		client.ixScanner.position = position
		client.ixScanner:Remove()
	end
end

CLASS_MPS = CLASS.index
