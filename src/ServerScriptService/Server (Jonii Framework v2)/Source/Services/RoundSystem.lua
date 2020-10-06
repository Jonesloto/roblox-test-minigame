local MIN_PLAYERS = 2 -- const
local INTERMISSION_LENGTH = 20 -- const

local player_count = 0

local RoundSystem = {}

function RoundSystem:init_round_system()
	while wait(1) do
		player_count = #self.Players:GetPlayers()
		
		if player_count >= MIN_PLAYERS then
			self:on_intermission()
		end
	end
end

function RoundSystem:on_intermission()
	for i = INTERMISSION_LENGTH, 0, -1 do
		print("Round Begins in " .. i)
	end
end

function RoundSystem:on_map_select()
	-- TODO: needs to be worked on some way some how.... (maybe a game asset manager service to keep things organized).
end

function RoundSystem:start()
	print("Hello World!")

	self.Players.PlayerAdded:Connect(function(player)
		print(player.Name .. " has just joined the game!")
	end)
end

return RoundSystem