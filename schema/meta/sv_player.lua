local playerMeta = FindMetaTable("Player")

function playerMeta:IsScanner()
	return IsValid(self.ixScanner)
end

function playerMeta:AddCombineDisplayMessage(text, color, ...)
	if (self:IsCombine()) then
		netstream.Start(self, "CombineDisplayMessage", text, color or false, {...})
	end
end
