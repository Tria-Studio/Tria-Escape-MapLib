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

	return self
end

--- This function is used to toggle the sliding function on or off.
function LightingFeature:ChangeLighting(values: { [string]: any }): ()
	if RunService:IsClient() then
		for property, value in pairs(values) do
			Lighting[property] = value
		end
	end
end

if RunService:IsServer() then
	remote.OnServerEvent:Connect(function(playercalled: Player, values: { [string]: any }): ()
		if typeof(values) == "table" and next(values) ~= nil then
			for _, v in pairs(Players:GetPlayers()) do
				if not v == playercalled then
					remote:FireClient(v, playercalled, values)
				end
			end
		end
	end)
end

return LightingFeature

--[[

Player1 [playing]
Player2 [spectator]

On lighting change (in proper practice shouldnt be called too exccuesively)
update lighting for Player1
fire a remote to the server which fires all clients except Player1 with 2 data values
since we are going from client-server-client ensure proper sanity checks

---Name of Player spectating
---Tables of new lighting values

when the client receives data, store in a table inside the (LIGHTING SCRIPT)

when we need to request the lighting values
check if lightingcache has a value

if
lightingcache[name] then return lightingcache[name]
else
assume this map doesnt use changelighting and continue as normal by getting the lighting values

mapending / wipeout the lightingcache table

remoteusage connections from server/client should be here to promote isolation from the main game scripts.


Pros:
Promotes isolation since everything can be done here without needing major edits to core scripts
1 "Remote call pattern" per lighting change, orginal used InvokeServer requesting lighting changes
Since this method requires going through the server we can safely enable for the function to be used on the server and it will work the same by changing the clients lighting
Gives something people have wanted for years now

-]]
