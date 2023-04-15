-- Copyright (C) 2023 Tria 
-- This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
-- If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.

--< Main >--
local SkillsFeature = {}

function SkillsFeature.new(MapLib)
	local self = setmetatable({}, SkillsFeature)
	self.map = MapLib.map

	return SkillsFeature
end

function SkillsFeature:AllowSliding(bool)
	local skills = self.map:FindFirstChild("Settings") and self.map.Settings:FindFirstChild("Skills")
	if skills then
		skills:SetAttribute("AllowSliding", bool)
	end
end

return SkillsFeature
