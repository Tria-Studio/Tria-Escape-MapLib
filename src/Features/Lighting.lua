--!strict

-- Copyright (C) 2023 Tria
-- This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
-- If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.

--< Services >--
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

--< Main >--
local LightingFeature = {}
LightingFeature.__index = LightingFeature

local remote = ReplicatedStorage.Remotes.Features.ChangeLighting

--- @class Lighting
--- This is a MapLib Feature. It can be accessed by `MapLib:GetFeature("LightingFeature")`.

function LightingFeature.new(MapLib)
	local self = setmetatable({}, LightingFeature)
	self.map = MapLib.map
	self.cache = {}

	for _, v in pairs(Lighting:GetChildren()) do
		self.cache[v.Name] = v
	end

	return self
end

--- This function is used to toggle the sliding function on or off.
function LightingFeature:SetLighting(properties: { [string]: any }, postEffects: { [string]: { [string]: any } })
	if RunService:IsClient() then
		for property, value in pairs(properties) do
			Lighting[property] = value
		end

		if postEffects then
			--Update for client
			for name, v in pairs(postEffects) do
				for prop, value in pairs(v) do
					local instance = self.cache[name]

					if instance then
						instance[prop] = value
					end
				end
			end
		end
		remote:FireServer({
			Values = properties,
			Effects = postEffects,
		})
	end
end

if RunService:IsServer() then
	remote.OnServerEvent:Connect(function(player: Player, values: { [string]: any }): ()
		for _, v in pairs(Players:GetPlayers()) do
			if v ~= player then
				remote:FireClient(v, player, values)
			end
		end
	end)
end

return LightingFeature
