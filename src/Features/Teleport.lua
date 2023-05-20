--!strict

-- Copyright (C) 2023 Tria
-- This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
-- If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.

local camera = workspace.CurrentCamera

--< Main >--
local Teleport = {}

--- @class Teleport
--- This is a MapLib Feature. It can be accessed by `MapLib:GetFeature("Teleport")`.

--[=[
	@within Teleport
	@method Teleport
	@since 0.11
	@client
	@param gui ScreenGui
	This function is used to

	**Example:**
	```lua
	```
]=]

function Teleport:Teleport(player: Player, position: Vector3, faceFront: boolean)
	local character = player.Character

	character:PivotTo(CFrame.new(
		position
		--position + otherPart.Destination.CFrame.LookVector
	))
	if camera then
		camera.CFrame = CFrame.fromOrientation(
			-math.pi / 4,
			(select(2, character.humanoidRootPart.CFrame:ToOrientation())),
			0
		) + position
	end
end

return Teleport
