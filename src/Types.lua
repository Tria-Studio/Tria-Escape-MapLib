-- Copyright (C) 2023 Tria
-- This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
-- If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.

export type MapLib = {
	__index: MapLib,
	map: Model,
	Map: Model,
	_MapHandler: any,
	new: (any, any) -> MapLib,
	Alert: (MapLib, string, Color3 | string, number?) -> (),
	ChangeMusic: (MapLib, number, number?, number?) -> (),
	GetButtonEvent: (MapLib, number | string) -> RBXScriptSignal?,
	Survive: (MapLib, Player) -> (),
	SetLiquidType: (MapLib, BasePart, string) -> (),

	Move: (MapLib, PVInstance, Vector3, number?) -> (),
	MoveModel: (MapLib, PVInstance, Vector3, number?) -> (),
	MovePart: (MapLib, PVInstance, Vector3, number?) -> (),
	MoveRelative: (MapLib, PVInstance, Vector3, number?) -> (),
	MoveModelLocal: (MapLib, PVInstance, Vector3, number?) -> (),
	MovePartLocal: (MapLib, PVInstance, Vector3, number?) -> (),

	GetPlayers: (MapLib) -> { Player },
	GetFeature: ((MapLib, string) -> any),
}

return nil
