-- Copyright (C) 2023 Tria
-- This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
-- If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.

--< Services >--
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerStates = require(ReplicatedStorage.shared.PlayerStates)

--< Main >--
local Players = {}
Players.__index = Players

function Players.new()
	local self = setmetatable({}, Players)
	return self
end

--- Description
function Players:GetPlayers()
	return PlayerStates:GetPlayersWithState(PlayerStates.GAME)
end

--- Description
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
