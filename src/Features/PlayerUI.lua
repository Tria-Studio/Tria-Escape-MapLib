--!strict

-- Copyright (C) 2023 Tria
-- This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
-- If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.

--< Services >--
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerStates = require(ReplicatedStorage.shared.PlayerStates)

--< Main >--
local PlayerUI = { context = "client" }
PlayerUI.__index = PlayerUI

--- @class PlayerUI
--- This is a MapLib Feature. It can be accessed by `MapLib:GetFeature("PlayerUI")`.
--- @client

function PlayerUI.new()
	local self = setmetatable({}, PlayerUI)

	self.cleanup = {}

	PlayerStates.LocalStateChanged:Connect(function(newState)
		if newState == PlayerStates.SURVIVED or newState == PlayerStates.LOBBY then
			for _, v in pairs(self.cleanup) do
				v:Destroy()
			end
			table.clear(self.cleanup)
		end
	end)

	return self
end

--[=[
	@within PlayerUI
	@method LoadUI
	@since 0.11
	@client
	@param gui ScreenGui
	This function can be used to load a `ScreenGui` from the map into the players PlayerGUI.

	**Example:**
	```lua
	-- Loads an UI for everyone in the round
	local PlayersFeature = MapLib:GetFeature("Players")
	local PlayerUI = MapLib:GetFeature("PlayerUI")

	local ui = map:WaitForChild("MyGUI")

	for _, player in pairs(PlayersFeature:GetPlayers()) do
		if player and player.Character then
			PlayerUI:LoadUI(ui)
		end
	end
	```
]=]

function PlayerUI:LoadUI(gui: ScreenGui): ()
	assert(gui:IsA("ScreenGui"), "':LoadUI' must be passed a 'ScreenGUI'")

	local clonedUI = gui:Clone()
	clonedUI.Parent = Players.LocalPlayer.PlayerGui

	table.insert(self.cleanup, clonedUI)
end

return PlayerUI
