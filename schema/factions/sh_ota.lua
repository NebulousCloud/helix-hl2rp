
FACTION.name = "Overwatch Transhuman Arm"
FACTION.description = "A transhuman Overwatch soldier produced by the Combine."
FACTION.color = Color(150, 50, 50, 255)
FACTION.pay = 40
FACTION.models = {"models/combine_soldier.mdl"}
FACTION.isDefault = false
FACTION.isGloballyRecognized = true
FACTION.runSounds = {[0] = "NPC_CombineS.RunFootstepLeft", [1] = "NPC_CombineS.RunFootstepRight"}

function FACTION:OnCharacterCreated(client, character)
	local inventory = character:GetInventory()

	inventory:Add("pistol", 1)
	inventory:Add("pistolammo", 2)

	inventory:Add("ar2", 1)
	inventory:Add("ar2ammo", 2)
end

function FACTION:GetDefaultName(client)
	return "OTA-ECHO.OWS-" .. Schema:ZeroNumber(math.random(1, 99999), 5), true
end

function FACTION:OnTransfered(client)
	local character = client:GetCharacter()

	character:SetName(self:GetDefaultName())
	character:SetModel(self.models[1])
end

function FACTION:OnNameChanged(client, oldValue, value)
	local character = client:GetCharacter()

	if (!Schema:IsCombineRank(oldValue, "OWS") and Schema:IsCombineRank(value, "OWS")) then
		character:JoinClass(CLASS_OWS)
	elseif (!Schema:IsCombineRank(oldValue, "EOW") and Schema:IsCombineRank(value, "EOW")) then
		character:JoinClass(CLASS_EOW)
	end
end

FACTION_OTA = FACTION.index
