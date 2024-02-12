--!strict

-- Copyright (C) 2023 Tria
-- This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
-- If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.

--< Main >--
local Skills = {}
Skills.__index = Skills

--- @class Skills
--- This is a MapLib Feature. It can be accessed by `MapLib:GetFeature("Skills")`.

function Skills.new(MapLib)
	local self = setmetatable({}, Skills)
	self.map = MapLib.map

	return self
end

--[=[
	@within Skills
	@method ToggleSliding
	@since 0.11
	@param value boolean

	This function can be used for toggling sliding on or off during a map.

	**Example:**
	```lua
	local SkillsFeature = MapLib:GetFeature("Skills")

	SkillsFeature:ToggleSliding(false)
	task.wait(5)
	SkillsFeature:ToggleSliding(true)
	```	
]=]
function Skills:ToggleSliding(value: boolean): ()
	local skills = self.map:FindFirstChild("Settings") and self.map.Settings:FindFirstChild("Skills")
	if skills then
		skills:SetAttribute("AllowSliding", value)
	end
end

--[=[
	@within Skills
	@method ToggleAirDive
	@since 0.11
	@param value boolean

	This function can be used for toggling airdive on or off during a map.

	**Example:**
	```lua
	local SkillsFeature = MapLib:GetFeature("Skills")

	SkillsFeature:ToggleAirDive(false)
	task.wait(5)
	SkillsFeature:ToggleAirDive(true)
	```	
]=]
function Skills:ToggleAirDive(value: boolean): ()
	local skills = self.map:FindFirstChild("Settings") and self.map.Settings:FindFirstChild("Skills")
	if skills then
		skills:SetAttribute("AllowAirDive", value)
	end
end


return Skills
