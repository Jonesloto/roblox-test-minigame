-- Framework Runner (Server-Sided)

-- Jonesloto (9-11-2020)

local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local SERVER_FOLDER = ServerScriptService:WaitForChild("Server (Jonii Framework v2)")
local CLIENT_SERVER_FOLDER = ReplicatedStorage:WaitForChild("Client-Server (Jonii Framework v2)")

local CLASS_FOLDER = SERVER_FOLDER.Source.Classes
local SERVICE_FOLDER = SERVER_FOLDER.Source.Services
local SERVER_MODULES_FOLDER = SERVER_FOLDER.Source.Modules
local SHARED_MODULES_FOLDER = CLIENT_SERVER_FOLDER.SharedModules

local shared_assets_module = require(CLIENT_SERVER_FOLDER.Assets)

local remote_event_listeners = {}
local remote_function_listeners = {}

local classes = {}
local services = {}
local server_modules = {}
local shared_modules = {}

local methods_injected = false

local get_remote_event_object = function() end
local get_remote_function_object = function() end
local on_server_event_callback = function() end
local on_server_invoke_callback = function() end

local function merge_tables(options) -- arguement must be an array
	local all_tables = {}
	
	for _, arg in ipairs(options) do
		if (not typeof(arg) == "table") then continue end
		
		for _, v in ipairs(arg) do
			table.insert(all_tables, v)
		end	
	end
	
	return all_tables
end

local function set_remotes(remotes_location)	
	local remote_event = Instance.new("RemoteEvent")
	local remote_function = Instance.new("RemoteFunction")
	
	remote_event.Name = "__JoniiFrameworkEventGateway"
	remote_function.Name = "__JoniiFrameworkFunctionGateway"
	
	get_remote_event_object = function()
		return remote_event
	end
	
	get_remote_function_object = function()
		return remote_function
	end
	
	on_server_event_callback = function(...)
		local args = {...}
		
		local player = args[1]
		local action = args[2]
		
		if (not remote_event_listeners[action]) then return end
		
		table.remove(args, 2)
		
		remote_event_listeners[action](table.unpack(args))
	end
	
	on_server_invoke_callback = function(...)
		local args = {...}
		
		local player = args[1]
		local action = args[2]
		
		if (not remote_function_listeners[action]) then return end
		
		table.remove(args, 2)
		
		local value_to_be_returned = remote_function_listeners[action](table.unpack(args))
		
		return value_to_be_returned
	end
	
	remote_event.OnServerEvent:Connect(on_server_event_callback)
	
	remote_function.OnServerInvoke = on_server_invoke_callback
	
	remote_event.Parent = remotes_location
	remote_function.Parent = remotes_location
end

local function inject_modules(options)
	options = options or {}
	
	local injected = {}
	
	for _, module in ipairs(options) do
		-- Variables
		
		module.ServerScriptService = ServerScriptService
		module.Players = Players
		module.ReplicatedStorage = ReplicatedStorage
		module.Workspace = Workspace
		module.Debris = Debris
		module.TweenService = TweenService
		module.RunService = RunService
		
		module.Services = services
		module.Classes = classes
		module.Modules = server_modules
		module.Shared = shared_modules
		
		-- Injected Methods
		
		function module:signal_client(...)
			get_remote_event_object():FireClient(...)
		end
		
		function module:signal_all_clients(...)
			get_remote_event_object():FireAllClients(...)
		end
		
		function module:register_event(action, func)
			remote_event_listeners[action] = func
		end
		
		function module:register_function(action, func)
			remote_function_listeners[action] = func
		end
		
		function module:create_instance(...)
			local func = shared_assets_module:create_instance()
			
			return func(...)
		end
		
		function module:update_instance(...)
			local func = shared_assets_module:update_instance()
			
			func(...)
		end
		
		function module:inject_children(script_object)
			for _, v in ipairs(script_object:GetChildren()) do
				if v:IsA("ModuleScript") then
					module.Children[v.Name] = require(v)
					
					module.Children[v.Name] = inject_modules({module.Children[v.Name]})
				end
			end
		end
		
		table.insert(injected, module)
	end
	
	return table.unpack(injected)
end

local function activate_modules()
	if methods_injected then return {} end
	
	local all_modules = merge_tables {
		CLASS_FOLDER:GetChildren();
		SERVICE_FOLDER:GetChildren();
		SERVER_MODULES_FOLDER:GetChildren();
		SHARED_MODULES_FOLDER:GetChildren();
	}
	
	for _, module in ipairs(all_modules) do
		local is_not_injectable = module:FindFirstChild("IS_INJECT_DISABLED")
		local required_module = require(module)
		
		if CLASS_FOLDER:FindFirstChild(module.Name) then
			classes[module.Name] = required_module
		elseif SERVICE_FOLDER:FindFirstChild(module.Name) then
			services[module.Name] = required_module
		elseif SERVER_MODULES_FOLDER:FindFirstChild(module.Name) then
			server_modules[module.Name] = required_module
		elseif SHARED_MODULES_FOLDER:FindFirstChild(module.Name) then
			shared_modules[module.Name] = required_module
		end
		
		if (is_not_injectable) and (is_not_injectable.Value) then continue end
		
		required_module = inject_modules({required_module})
	end
	
	methods_injected = true
end

local function start_services()
	for _, v in pairs(services) do	
		coroutine.wrap(v.start)(v)
	end
end

set_remotes(CLIENT_SERVER_FOLDER.Remotes)
activate_modules()

start_services()