--!strict

-- Copyright (C) 2023 Tria
-- This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
-- If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local camera = workspace.CurrentCamera
local remotes = ReplicatedStorage.Remotes.Features

local Teleport = {}

--- @class Teleport
--- This is a MapLib Feature. It can be accessed by `MapLib:GetFeature("Teleport")`.

--[=[
	@within Teleport
	@method Teleport
	@since 0.11
	@client
	@param player { Player? } | Player
	@param endingPosition CFrame | Vector3
	@param faceFront boolean
	This function can be used to teleport players.

	**Example:**
	```lua
	--Teleports all players ingame to map.Destination and makes the camera face the front.
	local PlayersFeature = Maplib:GetFeature("Players")
	local TeleportFeature = Maplib:GetFeature("Teleport")

	for _, player in pairs(PlayersFeature:GetPlayers()) do
		TeleportFeature:Teleport(player, map.Destination.Position, true)
	end
	```
]=]

local function teleport(player: { Player? } | Player, pos: CFrame | Vector3, faceFront: boolean)
	if RunService:IsServer() then
		--If server, fire a remote to all the clients
		if typeof(player) ~= "table" then
			player = { player }
		end

		for _, v in pairs(player) do
			remotes.Teleport:FireClient(v, v, pos, faceFront)
		end
	else
		-- Client teleporting fired from a remote
		local character = player.Character
		local isCFrame = typeof(pos) == "CFrame"

		character:PivotTo(isCFrame and CFrame.lookAt(pos.Position, pos.Position + pos.LookVector) or CFrame.new(pos))

		if faceFront then
			local offset = isCFrame and pos.Position or pos

			camera.CFrame = CFrame.fromOrientation(
				-math.pi / 4,
				(select(2, character.HumanoidRootPart.CFrame:ToOrientation())),
				0
			) + offset
		end
	end
end

function Teleport:Teleport(player: Player, pos: CFrame | Vector3, faceFront: boolean)
	teleport(player, pos, faceFront)
end

if RunService:IsClient() then
	remotes.Teleport.OnClientEvent:Connect(function(...: any)
		teleport(...)
	end)
end

return Teleport
