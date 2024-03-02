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
--- This is a MapLib Feature. It can be accessed by `MapLib:GetFeature("Lighting")`.

function LightingFeature.new(MapLib)
	local self = setmetatable({}, LightingFeature)
	self.map = MapLib.map
	self.cache = {}

	for _, v in pairs(Lighting:GetChildren()) do
		self.cache[v.Name] = v
	end

	return self
end

--[=[
	@within Lighting
	@method SetLighting
	@since 0.11
	@param properties { [string]: any }
	@param postEffects { [string]: { [string]: any } }

	This function can to be used to change the lighting of a map mid round. We discourage usage of changing lighting
	with `game.Lighting[Property] = value` cause it doesnt replicate for spectators.

	**Example:**
	```lua
	-- Changes the fog to 100 and the fog color to white
	local LightingFeature = Maplib:GetFeature("Lighting")

	LightingFeature:SetLighting({
		FogEnd = 100,
		FogColor = Color3.fromRGB(255, 255, 255)
	})
	```

	:::info
	 This function also supports lighting effects to be updated and they will be replicated to specators.
	```lua
	-- Changes the fog to 100 and the fog color to white and makes everything monochrome.
	local LightingFeature = Maplib:GetFeature("Lighting")

	LightingFeature:SetLighting({
		FogEnd = 100,
		FogColor = Color3.fromRGB(255, 255, 255)
	}, {
		ColorCorrection = {
			Saturation = -1,
		},
	})
	```

	:::
	:::caution
	For the game to be able to edit post effects they have to be correctly placed inside the lighting folder inside settings.
	If they are created in a script the game will not see these and refuse to update the lighting properties.
	:::

	:::tip
	Since atmosphere instances don't have any enabled or disabled property we can get around that by parenting the instance to ReplicatedStorage
	and then we can parent it back to lighting when we need it.

	```lua
	local LightingFeature = Maplib:GetFeature("Lighting")

	--Disables the atmosphere effect
	LightingFeature:SetLighting({}, {
		Atmosphere = {
			Parent = game.ReplicateStorage,
		},
	})

	task.wait(5)
	--Enables the atmosphere effect
	LightingFeature:SetLighting({}, {
		Atmosphere = {
			Parent = game.Lighting,
		},
	})
	```
	:::
]=]

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
