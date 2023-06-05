-- Copyright (C) 2023 Tria
-- This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
-- If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")

local Round
local PlayerStates = require(ReplicatedStorage.shared.PlayerStates)

if RunService:IsServer() then
	Round = require(ServerScriptService.server.Services.RoundService.Round)
end

--< Main >--
local Cleanup = {}
Cleanup.Janitors = {}

Cleanup.Janitor = require(script.Janitor)

function Cleanup:GetJanitor(janitorName: string?)
	if self.Janitors[janitorName] then
		return self.Janitors[janitorName]
	else
		return self.Janitors[#self.Janitors]
	end
end

function Cleanup:GetJanitors()
	return self.Janitors
end

local function cleanup()
	for _, v in pairs(Cleanup:GetJanitors()) do
		if v.ClassName == "Janitor" then
			v:Destroy()
		end
	end
end

if RunService:IsClient() then
	Players.LocalPlayer.Character.Humanoid.Died:Connect(cleanup)

	PlayerStates.LocalStateChanged:Connect(function(newState)
		if newState == PlayerStates.SURVIVED then
			cleanup()
		end
	end)
else
	Round.RoundEnding:Connect(cleanup)
end

return Cleanup
