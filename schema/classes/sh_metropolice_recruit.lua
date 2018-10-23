CLASS.name = "Metropolice Recruit"
CLASS.faction = FACTION_MPF
CLASS.isDefault = true

function CLASS:OnCanBe(client)
	return Schema:IsCombineRank(client:Name(), "RCT")
end

CLASS_MPR = CLASS.index