-- Copyright (C) 2023 Tria
-- This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
-- If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.

--< Services >--
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerStates = require(ReplicatedStorage.shared.PlayerStates)

--< Main >--
local UIFeature = {}
UIFeature.context = "client"

local uiCache = {}

local function cleanUp()
	for _, v in pairs(uiCache) do
		v:Destroy()
	end
	table.clear(uiCache)
end

function UIFeature:LoadUI(uiInstance: ScreenGui)
	if uiInstance:IsA("ScreenGui") then
		local ui = uiInstance:Clone()
		ui.Parent = Players.LocalPlayer.PlayerGui
		table.insert(uiCache, ui)

		return ui
	end
end

PlayerStates.LocalStateChanged:Connect(function(newState)
	if newState == PlayerStates.SURVIVED or newState == PlayerStates.LOBBY then
		cleanUp()
	end
end)

return UIFeature
