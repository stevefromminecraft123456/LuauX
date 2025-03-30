--beta 1.0.3, unstable
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
	-- frozenset
	luaux = luaux:gsub("frozenset%((.-)%)", "table.freeze(%1)")
	-- set
	luaux = luaux:gsub("set%((.-)%)", function(elements)
		local table_elements = elements:match("^(.-)$") or ""
		return `local set = {table_elements}; for k in pairs(set) do set[k] = true end`
	end)
	-- inline functions
	--	 local x = inline(args) ... end
	luaux = luaux:gsub("inline%((.-)%)", "function(%1)")
	--	 inline x(args) ... end
	luaux = luaux:gsub("inline (.-)", "function %1")
	-- match
	-- WIP
	
	print("\n"..luaux)

	return luaux
end

-----------------------------------------
--wind's luaux suggestions: (3.5/4 done)
-- (changed lambda expressions to inline functions)
--✅ inline functions (completed)
--✅ set and frozenset (completed)
--✅ try and execpt instead of pcall (completed)
--❎ match statement (work in progress)
-----------------------------------------
