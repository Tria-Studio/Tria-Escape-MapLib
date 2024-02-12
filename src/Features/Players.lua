--!strict

-- Copyright (C) 2023 Tria
-- This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
-- If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.

--< Services >--
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerStates = require(ReplicatedStorage.shared.PlayerStates)

--< Main >--
local Players = {}

--- @class Players
--- This is a MapLib Feature. It can be accessed by `MapLib:GetFeature("Players")`.

--[=[
	@within Players
	@method GetPlayers
	@return {Player?}

	This function can be used to get all players in the current round.

	**Example:**
	```lua
	--Teleports all players ingame to map.Destination.
	local PlayersFeature = MapLib:GetFeature("Players")
	local TeleportFeature = MapLib:GetFeature("Teleport")

	for _, player in pairs(PlayersFeature:GetPlayers()) do
		TeleportFeature:Teleport(player, map.Destination.Position)
	end
	```	
]=]

function Players:GetPlayers(): { Player }
	return PlayerStates:GetPlayersWithState(PlayerStates.GAME)
end

--[=[
	@within Players
	@method GetPlayersInRadius
	@since 0.11
	@param position Vector3
	@param radius number
	@return {Player?}

	This function can be used to get all the players which are in a radius from a position.

	**Example:**
	```lua
	--Teleports all players that are within 5 studs from map.Spawn.
	local PlayersFeature = MapLib:GetFeature("Players")
	local TeleportFeature = MapLib:GetFeature("Teleport")

	for _, player in pairs(PlayersFeature:GetPlayersInRadius(map.Spawn.Position, 5)) do
		TeleportFeature:Teleport(player, map.Destination.Position)
	end
	```	
]=]

function Players:GetPlayersInRadius(position: Vector3, radius: number): { Player }
	local ret = {}

	for _, plr in pairs(self:GetPlayers()) do
		if plr and plr.Character then
			local rootPart = plr.Character:FindFirstChild("HumanoidRootPart") :: Instance
			if rootPart and ((rootPart.Position - position).Magnitude <= radius) then
				table.insert(ret, plr)
			end
		end
	end

	return ret
end

return Players
