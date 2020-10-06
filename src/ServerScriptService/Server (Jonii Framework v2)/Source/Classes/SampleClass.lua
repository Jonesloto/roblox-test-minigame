-- Server Module --

-- Made by: (User - UserID) 

-- Date: 9-11-2020

-- "Injected" Variables:

--- self.ServerScriptService = ServerScriptService
--- self.Players = Players
--- self.ReplicatedStorage = ReplicatedStorage
--- self.Workspace = Workspace
--- self.Debris = Debris
--- self.TweenService = TweenService
--- self.RunService = RunService

-- "Injected" Methods:

--- self:signal_client(player, action_string)
--- self:signal_all_clients(action_string)
--- self:register_event(action, func)
--- self:register_function(action, func)
--- self:create_instance(inst_name, parent, properties_table)
--- self:update_instance(inst, properties_table)
--- self:inject_children(script)

-- Variable Naming Scheme:

--- local ServerScriptService -- Services: PascalCase
--- local THIS_CONSTANT -- Constants: UPPER_SNAKE_CASE
--- local this_module -- Modules using require(): snake_case
--- local this_variabe -- Variables & functions: snake_case
--- local MyClass -- Classes: PascalCase 
--- local this_method -- Object Methods: snake_case

local SampleClass = {}
SampleClass.__index = SampleClass

function SampleClass.new(options)
	options = options or {}
	
	local my_object = {}
	
	return setmetatable(my_object, SampleClass)
end

return SampleClass