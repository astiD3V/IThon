module.CheckFlagValidity = function(Flag, PossibleFlags, FlagIndex)
	local FlagT = {}
	
	for i = 1, string.len(Flag) do		
		local subFlag = string.sub(Flag, 1, i)
		
		if not table.find(PossibleFlags, subFlag) then 
			continue 
		end
		
		FlagT.index = FlagIndex
		FlagT.arg = string.sub(Flag, i + 1, string.len(Flag))
		FlagT.flag = subFlag
		
		if FlagT.arg == string.sub(Flag, i, i) then
			FlagT.arg = nil
		end 
	end
	
	return FlagT
end


function module:ParseCommand(Text, List)
	local TabledText = {}
	local Content = {}
	local n = 1

	while n <= string.len(Text) do
		local subbedText = string.gsub(string.sub(Text, n, -1), "^%s*(.-)%s*$", "%1")
		local FoundText = string.match(subbedText, [[^".-"]]) or string.match(subbedText, [[^'.-']]) or string.match(subbedText, [[^%S+]])

		if FoundText then
			table.insert(TabledText, FoundText)
			n += string.len(FoundText) + 1
		else
			break
		end
	end
	
	Content.Command = TabledText[1]
	
	if not table.find(List.Commands, Content.Command) then
		Content.Error = "Syntax Error: "..Content.Command.." is not a valid command"
		return Content
	end
	
	for i,v in TabledText do
		if v == " " then
			table.remove(TabledText, i)
		end
	end
	
	table.remove(TabledText, 1)
	
	local Flags = {}
	
	for i,arg in TabledText do
		if string.find(arg, "-") and string.sub(arg, 1, 1) == "-" and string.match(arg, "%a") then
			Flags[arg] = i
		end
	end
	
	local newFlags = {}
	local tempIndexs = {}
	local tempTabledText = table.clone(TabledText)
	
	for Flagg,index in Flags do
		local Flag = module.CheckFlagValidity(string.sub(Flagg, 2, string.len(Flagg)), List.Flags, table.find(TabledText, Flagg))		
		
		if not Flag or not Flag.flag then
			Content.Error = "Syntax Error: "..Flagg.." does not exist - (Index "..index..")"
			return Content
		end
		
		newFlags[Flag.flag] = Flag.arg or ""
		
		if newFlags[Flag.flag] == "" then
			tempIndexs[Flag.flag] = Flag.index
		else
			local extraText = string.sub(Flagg, #Flag.flag + 2, #Flagg)
		end	
	end
	
	for flag,index in tempIndexs do
		
		if tempTabledText[index + 1] ~= nil and table.find(TabledText, tempTabledText[index + 1]) and index + 1 < #tempTabledText then
			local flagArg = tempTabledText[index + 1]
			
			if string.find(flagArg, "-") and
				newFlags[module.CheckFlagValidity(string.sub(flagArg, 2, string.len(flagArg)), List.Flags, table.find(TabledText, flagArg)).flag]	
			then
				Content.Error = "Syntax Error: "..flagArg.." tried to become an argument of -"..flag
				return Content
			end
				
			newFlags[flag] = flagArg
			
			for i,v in TabledText do
				if v == tempTabledText[index + 1] then
					table.remove(TabledText, i)
				end
			end
			
			table.remove(TabledText, table.find(TabledText, "-"..flag))
		end
	end
	
	table.clear(tempTabledText)
	
	for flag, val in newFlags do
		for i,v in TabledText do
			if v == "-"..flag or v == "-"..flag..val then
				table.remove(TabledText, i)
			end
		end
	end
	
	Content.Flags = newFlags
	Content.Arguments = {}
	
	for _,arg in TabledText do
		table.insert(Content.Arguments, arg)
	end
	
	if not Content.Arguments[1] then
		Content.Error = "Syntax Error: Could not find any argument to parse"
	end
	
	return Content
end
