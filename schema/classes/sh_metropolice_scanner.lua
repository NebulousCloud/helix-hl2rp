CLASS.name = "Metropolice Scanner"
CLASS.description = "A metropolice scanner, it utilises Combine technology."
CLASS.faction = FACTION_MPF

function CLASS:CanSwitchTo(client)
	return Schema:IsCombineRank(client:Name(), "SCN") or Schema:IsCombineRank(client:Name(), "SHIELD")
end

function CLASS:OnSpawn(client)
	if (IsValid(client.ixScanner) and !client.ixScanner.bPendingRemove) then
		client.ixScanner.position = client:GetPos()
		client.ixScanner.bPendingRemove = true
		client.ixScanner:Remove()
	else
		Schema:CreateScanner(client, Schema:IsCombineRank(client:Name(), "SHIELD") and "npc_clawscanner" or nil)
	end
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
