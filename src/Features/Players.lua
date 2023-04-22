-- This script is getting deleted soon
-- lmao
return {
	GetPlayers = function()
		return require(game:GetService("ReplicatedStorage").shared.PlayerStates):GetPlayersWithState(1)
	end,
}
