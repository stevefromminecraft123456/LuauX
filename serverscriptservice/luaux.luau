--Release 1.0.0
local compile = game.ReplicatedStorage.Compile

-- Your client script must include a copy of the Loadstring module (you can clone the copy inside this script) inside it.
-- And, you must run LuauX code like this: require(script.Loadstring)(compile:InvokeServer(...))().
compile.OnServerInvoke = function(_, code: string)
	-- Transforms "x := y(z)" to "x = x:y(z)"
	local luaux = code:gsub("(%w+)%s*:=%s*(%w+)%s*(%b())", function(var, func, args)
		return `{var} = {var}:{func}{args}`
	end)
	-- Transforms "endif" to "end if"
	luaux = luaux:gsub("endif", "end if")
	-- Transforms "try-catch-end" into "pcall"
	luaux = luaux:gsub("try%s*(.-)%s*catch%s*(.-)%s*end", function(try, catch)
		return string.format([[
		local success, result = pcall(function()
			%s
		end)
		if not success then
			local error = result
			%s
		end
		]], try, catch)
	end)
	luaux = luaux:gsub("%*%*", "^")
	luaux = luaux:gsub("(%d+)%s*<<%s*(%d+)", "bit32.lshift(%1, %2)")
	luaux = luaux:gsub("(%d+)%s*>>%s*(%d+)", "bit32.rshift(%1, %2)")
	
	print("\n"..luaux)

	return luaux
end
-----------------------------------------
--wind's luaux suggestions: (1/4 done)
--❎ lambda expressions (given up on it[sorry :( ) --wide mouth
--❎ set and frozenset (as far as i know its impossible to create constants [unchangeable variables])
--✅ try and execpt instead of pcall (completed)
--❎ match statement (given up on it sorry again :( )
-----------------------------------------'
