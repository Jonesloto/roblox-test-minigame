local GameTestingService = {}

function GameTestingService:start()
	print("Hello World!")

	self.Players.PlayerAdded:Connect(function(player)
		print(player.Name .. " has just joined the game!")
	end)
end

return GameTestingService