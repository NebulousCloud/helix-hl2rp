
netstream.Hook("ixViewPaper", function(itemID, text, bEditable)
	bEditable = tobool(bEditable)

	local panel = vgui.Create("ixPaper")
	panel:SetText(text)
	panel:SetEditable(bEditable)
	panel:SetItemID(itemID)
end)
