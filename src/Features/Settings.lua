-- Copyright (C) 2023 Tria 
-- This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
-- If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.

--< Services >--
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Settings
if RunService:IsClient() then
	Settings = require(ReplicatedStorage.shared.Settings)
end

--< Main >--
local SettingsFeature = {}
SettingsFeature.context = "client"

function SettingsFeature:GetSetting(settingName: string)
	local settingsTable = Settings:GetSettings()

	local setting
	for i = 1, #settingsTable do
		if settingsTable[i]["description"] == settingName then
			setting = settingsTable[i]
			break
		end
	end

	if setting then
		return setting.value._value
	else
		error(("Cannot find '%s' setting"):format(settingName), 2)
		return nil
	end
end

return SettingsFeature
