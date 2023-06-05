-- Copyright (C) 2023 Tria 
-- This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
-- If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.

--< Services >--
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local SettingsModule
if RunService:IsClient() then
	SettingsModule = require(ReplicatedStorage.shared.Settings)
end

--< Main >--
local Settings = {context = "client"}
Settings.__index = Settings

--- @class Settings
--- Description goes here
--- @client
function Settings.new()
	local self = setmetatable({}, Settings)

	return self
end

--- Description
function Settings:GetSetting(settingName: string): any
	local settingsTable = SettingsModule:GetSettings()

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

return Settings
