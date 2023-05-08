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

--[=[
	@class Cleanup

	This is the MapLib Feature. It can be accessed by `MapLib:GetFeature("Cleanup")`.

	Description of what this holds
	:::tip
		hi
	:::
]=]

--[=[
	@within Cleanup
	@since 0.11
	@function Janitor.new
	@param name string?
	@return Janitor

]=]

--< Main >--
local Cleanup = {}

Cleanup.Janitors = {}
Cleanup.Janitor = require(script.Janitor)

--[=[
	@since 0.2.4
	@return Janitor
	This method returns the specified Janitor class.
]=]
function Cleanup:GetJanitor(janitorName: string?)
	if self.Janitors[janitorName] then
		return self.Janitors[janitorName]
	else
		return self.Janitors[#self.Janitors]
	end
end

--[=[
	@since 0.2.4
	This method returns all the active Janitor classes.
	@return {Janitor}
]=]
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
