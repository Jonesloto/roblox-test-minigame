local Assets = {}

function Assets:number_format_table()
	return {
		{1e3, "K+"},
		{1e6,"M+"},
		{1e9, "B+"},
		{1e12, "T+"},
		{1e15, "Qa+"},
		{1e18, "Quint+"},
		{1e21, "Se+"},
		{1e24, "Sep+"},
		{1e27,"Octil+"},
		{1e30, "Non+"},
		{1e100, "Googl+"}
	}
end

function Assets.create_instance(self)
	return function(string_inst, parent, properties_table)
		local inst
		
		local successful, result = pcall(function()
			inst = Instance.new(string_inst)
			
			assert(inst ~= nil, "Not a valid arguement of constructor Instance.new()")
		end)
		
		if not successful then warn(result, debug.traceback()) return end
		
		for property, value in pairs(properties_table or {}) do
			local type_check_successful, type_check_result = pcall(function()
				if inst[property] == nil then return true end
				
				assert(typeof(value) == typeof(inst[property]), 
					"Attempted to set "..tostring(property).." of "..tostring(inst).." to ("..tostring(value).."). Data types do not match..."
				)
			end)
			
			if not type_check_successful then return warn(type_check_result, debug.traceback()) end
			
			inst[property] = value
		end
		
		inst.Parent = parent or game.ServerStorage
		
		return inst
	end
end

function Assets.update_instance(self)
	return function(existing_inst, properties_table)
		local successful, result = pcall(function()
			assert(existing_inst, "Instance does not exist within the game.")
		end)
		
		if not successful then warn(result, debug.traceback()) return end
		
		for property, value in pairs(properties_table or {}) do
			local type_check_successful, type_check_result = pcall(function()
				if existing_inst[property] == nil then return true end
				
				assert(typeof(value) == typeof(existing_inst[property]), 
					"Attempted to set "..tostring(property).." of "..tostring(existing_inst).." to ("..tostring(value).."). Data types do not match..."
				)
			end)
			
			if not type_check_successful then return warn(type_check_result, debug.traceback()) end
			
			existing_inst[property] = value
		end
	end
end

return Assets
