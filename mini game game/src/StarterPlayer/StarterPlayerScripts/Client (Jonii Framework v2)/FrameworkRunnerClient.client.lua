-- Framework Runner (Client-Sided)

-- Jonesloto (9-12-2020)

local StarterPlayer = game:GetService("StarterPlayer")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")

local CLIENT_FOLDER = StarterPlayer.StarterPlayerScripts:WaitForChild("Client (Jonii Framework v2)")
local CLIENT_SERVER_FOLDER = ReplicatedStorage:WaitForChild("Client-Server (Jonii Framework v2)")

local CLASS_FOLDER = CLIENT_FOLDER.Source.Classes
local CONTROLLER_FOLDER = CLIENT_FOLDER.Source.Controller
local CLIENT_MODULES_FOLDER = CLIENT_FOLDER.Source.Modules
local SHARED_MODULES_FOLDER = CLIENT_SERVER_FOLDER.SharedModules

local shared_assets_module = require(CLIENT_SERVER_FOLDER.Assets)

local remote_event_listeners = {}

local classes = {}
local controllers = {}
local client_modules = {}
local shared_modules = {}

local methods_injected = false

local get_remote_event_object = function() end
local get_remote_function_object = function() end
local on_client_event_callback = function() end

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

local function set_remotes(remotes_location) -- can yield
	local remote_event = remotes_location:WaitForChild("__JoniiFrameworkEventGateway")
	local remote_function = remotes_location:WaitForChild("__JoniiFrameworkFunctionGateway")
	
	get_remote_event_object = function()
		return remote_event
	end
	
	get_remote_function_object = function()
		return remote_function
	end
	
	on_client_event_callback = function(...)
		local args = {...}
		
		local action = args[1]
		
		if (not remote_event_listeners[action]) then return end
		
		table.remove(args, 1)
		
		remote_event_listeners[action](table.unpack(args))
	end
	
	remote_event.OnClientEvent:Connect(on_client_event_callback)
end

local function inject_modules(options)
	options = options or {}
	
	local injected = {}
	
	for _, module in ipairs(options) do
		-- Variables
		
		module.Player = Players.LocalPlayer
		
		module.StarterPlayer = StarterPlayer
		module.StarterGui = StarterGui
		module.Players = Players
		module.ReplicatedStorage = ReplicatedStorage
		module.Workspace = Workspace
		module.Debris = Debris
		module.TweenService = TweenService
		module.RunService = RunService
		
		module.Controllers = controllers
		module.Classes = classes
		module.Modules = client_modules
		module.Shared = shared_modules
		
		-- Injected Methods
		
		function module:signal_server(...)
			get_remote_event_object():FireServer(...)
		end
		
		function module:retrieve_from_server(...)
			local value = get_remote_function_object():InvokeServer(...) -- yields
			
			return value
		end
		
		function module:register_event(action, func)
			remote_event_listeners[action] = func
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
		CONTROLLER_FOLDER:GetChildren();
		CLIENT_MODULES_FOLDER:GetChildren();
		SHARED_MODULES_FOLDER:GetChildren();
	}
	
	for _, module in ipairs(all_modules) do
		local is_injectable = module:FindFirstChild("IS_INJECT_ENABLED")
		local required_module = require(module)
		
		if CLASS_FOLDER:FindFirstChild(module.Name) then
			classes[module.Name] = required_module
		elseif CONTROLLER_FOLDER:FindFirstChild(module.Name) then
			controllers[module.Name] = required_module
		elseif CLIENT_MODULES_FOLDER:FindFirstChild(module.Name) then
			client_modules[module.Name] = required_module
		elseif SHARED_MODULES_FOLDER:FindFirstChild(module.Name) then
			shared_modules[module.Name] = required_module
		end
		
		if (is_injectable) and (is_injectable.Value) then continue end
		
		required_module = inject_modules({required_module})
	end
	
	methods_injected = true
end

local function start_controllers()
	for _, v in pairs(controllers) do
		coroutine.wrap(v.start)(v)
	end
end

set_remotes(CLIENT_SERVER_FOLDER.Remotes)
activate_modules()

start_controllers()