
Schema.CombineObjectives = Schema.CombineObjectives or {}

function Schema:AddCombineDisplayMessage(text, color, exclude, ...)
	color = color or color_white

	local arguments = {...}
	local receivers = {}

	-- we assume that exclude will be part of the argument list if we're using
	-- a phrase and exclude is a non-player argument
	if (type(exclude) != "Player") then
		table.insert(arguments, 1, exclude)
	end

	for _, v in ipairs(player.GetAll()) do
		if (v:IsCombine() and v != exclude) then
			receivers[#receivers + 1] = v
		end
	end

	netstream.Start(receivers, "CombineDisplayMessage", text, color, arguments)
end

-- data saving
function Schema:SaveRationDispensers()
	local data = {}

	for _, v in ipairs(ents.FindByClass("ix_rationdispenser")) do
		data[#data + 1] = {v:GetPos(), v:GetAngles(), v:GetEnabled()}
	end

	ix.data.Set("rationDispensers", data)
end

function Schema:SaveVendingMachines()
	local data = {}

	for _, v in ipairs(ents.FindByClass("ix_vendingmachine")) do
		data[#data + 1] = {v:GetPos(), v:GetAngles(), v:GetAllStock()}
	end

	ix.data.Set("vendingMachines", data)
end

function Schema:SaveCombineLocks()
	local data = {}

	for _, v in ipairs(ents.FindByClass("ix_combinelock")) do
		if (IsValid(v.door)) then
			data[#data + 1] = {
				v.door:MapCreationID(),
				v.door:WorldToLocal(v:GetPos()),
				v.door:WorldToLocalAngles(v:GetAngles()),
				v:GetLocked()
			}
		end
	end

	ix.data.Set("combineLocks", data)
end

function Schema:SaveForceFields()
	local data = {}

	for _, v in ipairs(ents.FindByClass("ix_forcefield")) do
		data[#data + 1] = {v:GetPos(), v:GetAngles(), v:GetMode()}
	end

	ix.data.Set("forceFields", data)
end

-- data loading
function Schema:LoadRationDispensers()
	for _, v in ipairs(ix.data.Get("rationDispensers") or {}) do
		local dispenser = ents.Create("ix_rationdispenser")

		dispenser:SetPos(v[1])
		dispenser:SetAngles(v[2])
		dispenser:Spawn()
		dispenser:SetEnabled(v[3])
	end
end

function Schema:LoadVendingMachines()
	for _, v in ipairs(ix.data.Get("vendingMachines") or {}) do
		local vendor = ents.Create("ix_vendingmachine")

		vendor:SetPos(v[1])
		vendor:SetAngles(v[2])
		vendor:Spawn()
		vendor:SetStock(v[3])
	end
end

function Schema:LoadCombineLocks()
	for _, v in ipairs(ix.data.Get("combineLocks") or {}) do
		local door = ents.GetMapCreatedEntity(v[1])

		if (IsValid(door) and door:IsDoor()) then
			local lock = ents.Create("ix_combinelock")

			lock:SetPos(door:GetPos())
			lock:Spawn()
			lock:SetDoor(door, door:LocalToWorld(v[2]), door:LocalToWorldAngles(v[3]))
			lock:SetLocked(v[4])
		end
	end
end

function Schema:LoadForceFields()
	for _, v in ipairs(ix.data.Get("forceFields") or {}) do
		local field = ents.Create("ix_forcefield")

		field:SetPos(v[1])
		field:SetAngles(v[2])
		field:Spawn()
		field:SetMode(v[3])
	end
end

function Schema:CreateScanner(client, class)
	class = class or "npc_cscanner"

	local entity = ents.Create(class)

	if (!IsValid(entity)) then
		return
	end

	entity:SetPos(client:GetPos())
	entity:SetAngles(client:GetAngles())
	entity:SetColor(client:GetColor())
	entity:Spawn()
	entity:Activate()
	entity.ixPlayer = client
	entity:SetNetVar("player", client) -- Draw the player info when looking at the scanner.
	entity:CallOnRemove("ScannerRemove", function()
		if (IsValid(client)) then
			local position = entity.position or client:GetPos()

			client:UnSpectate()
			client:SetViewEntity(NULL)

			if (entity:Health() > 0) then
				client:Spawn()
			else
				client:KillSilent()
			end

			timer.Simple(0, function()
				client:SetPos(position)
			end)
		end
	end)

	local uniqueID = "ix_Scanner" .. client:UniqueID()
	entity.name = uniqueID
	entity.ixCharacterID = client:GetCharacter():GetID()

	local target = ents.Create("path_track")
	target:SetPos(entity:GetPos())
	target:Spawn()
	target:SetName(uniqueID)
	entity:CallOnRemove("RemoveTarget", function()
		if (IsValid(target)) then
			target:Remove()
		end
	end)

	entity:SetHealth(client:Health())
	entity:SetMaxHealth(client:GetMaxHealth())
	entity:Fire("setfollowtarget", uniqueID)
	entity:Fire("inputshouldinspect", false)
	entity:Fire("setdistanceoverride", "48")
	entity:SetKeyValue("spawnflags", 8208)

	client.ixScanner = entity
	client:Spectate(OBS_MODE_CHASE)
	client:SpectateEntity(entity)
	entity:CallOnRemove("RemoveThink", function()
		timer.Remove(uniqueID)
	end)

	timer.Create(uniqueID, 0.33, 0, function()
		if (!IsValid(client) or !IsValid(entity) or client:GetCharacter():GetID() != entity.ixCharacterID) then
			if (IsValid(entity)) then
				entity:Remove()
			end

			timer.Remove(uniqueID)
			return
		end

		local factor = 128

		if (client:KeyDown(IN_SPEED)) then
			factor = 64
		end

		if (client:KeyDown(IN_FORWARD)) then
			target:SetPos((entity:GetPos() + client:GetAimVector() * factor) - Vector(0, 0, 64))
			entity:Fire("setfollowtarget", uniqueID)
		elseif (client:KeyDown(IN_BACK)) then
			target:SetPos((entity:GetPos() + client:GetAimVector() * -factor) - Vector(0, 0, 64))
			entity:Fire("setfollowtarget", uniqueID)
		elseif (client:KeyDown(IN_JUMP)) then
			target:SetPos(entity:GetPos() + Vector(0, 0, factor))
			entity:Fire("setfollowtarget", uniqueID)
		elseif (client:KeyDown(IN_DUCK)) then
			target:SetPos(entity:GetPos() - Vector(0, 0, factor))
			entity:Fire("setfollowtarget", uniqueID)
		end

		client:SetPos(entity:GetPos())
	end)

	return entity
end

function Schema:SearchPlayer(client, target)
	if (!target:GetCharacter() or !target:GetCharacter():GetInventory()) then
		return false
	end

	local name = hook.Run("GetDisplayedName", target) or target:Name()
	local inventory = target:GetCharacter():GetInventory()

	ix.storage.Open(client, inventory, {
		entity = target,
		name = name
	})

	return true
end
