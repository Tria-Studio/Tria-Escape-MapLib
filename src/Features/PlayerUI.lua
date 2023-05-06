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
--- This is the documentation of PlayerUI-related methods.
--- @client

--- @prop cleanup {ScreenGUI}
--- @readonly
--- @private
--- @within PlayerUI
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

--- This function is used to load a `ScreenGui` instance.
function PlayerUI:LoadUI(gui: ScreenGui): ScreenGui
	assert(gui:IsA("ScreenGui"), "':LoadUI' must be passed a 'ScreenGUI'")

	gui.Parent = Players.LocalPlayer.PlayerGui
	table.insert(self.cleanup, gui)
	return gui
end

return PlayerUI
