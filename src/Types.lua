-- Copyright (C) 2023 Tria
-- This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
-- If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.

export type MapLib = {

	__index: MapLib,
	map: Model,
	Map: Model,
	_MapHandler: any,
	new: (any, any) -> MapLib,
	Alert: (MapLib, string, Color3?, number?) -> nil,
	ChangeMusic: (MapLib, number, number?, number?) -> nil,
	GetButtonEvent: (MapLib, number | string) -> RBXScriptSignal,
	Survive: (MapLib, Player) -> nil,
	SetLiquidType: (MapLib, BasePart, string) -> nil,
	Move: (MapLib, PVInstance, Vector3, number?) -> nil,
	MoveRelative: (MapLib, PVInstance, Vector3, number?) -> nil,
	GetPlayers: (MapLib) -> { Player },
	GetFeature: ((MapLib, "Players") -> PlayersFeature)
		& ((MapLib, "Settings") -> SettingsFeature)
		& ((MapLib, "Skills") -> SkillsFeature)
		& ((MapLib, "PlayerUI") -> GUIFeature),
}

export type PlayersFeature = {
	GetPlayers: () -> { Player },
}

export type SettingsFeature = {
	GetSetting: (string) -> any?,
}

return nil
