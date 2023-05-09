-- Copyright (C) 2023 Tria
-- This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
-- If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.

--< Services >--
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerStates = require(ReplicatedStorage.shared.PlayerStates)

--< Main >--
local Players = {}
Players.__index = Players

--- @class Players
--- This is a MapLib Feature. It can be accessed by `MapLib:GetFeature("Players")`.
function Players.new()
	local self = setmetatable({}, Players)
	return self
end

--- Used to return all players in the current round.
function Players:GetPlayers(): { Player }
	return PlayerStates:GetPlayersWithState(PlayerStates.GAME)
end

--[=[
	@since 0.11
	@within Players
	This method is used to return players in the radius of the given position.
]=]

function Players:GetPlayersInRadius(position: Vector3, radius: number): { Player }
	local ret = {}

	for _, plr in pairs(self:GetPlayers()) do
		if plr and plr.Character then
			local rootPart = plr.Character:FindFirstChild("HumanoidRootPart")
			if rootPart and ((rootPart.Position - position).Magnitude <= radius) then
				table.insert(ret, plr)
			end
		end
	end

	return ret
end

return Players
