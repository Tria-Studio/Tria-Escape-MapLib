export type MapLib = {
	map: Model,

	new: (any, any) -> MapLib,
	Alert: (MapLib, string, Color3?, number?) -> nil,
	ChangeMusic: (MapLib, number, number?, number?) -> nil,
	GetButtonEvent: (MapLib, number | string) -> RBXScriptSignal,
	Survive: (MapLib, Player) -> nil,
	SetLiquidType: (MapLib, BasePart, string) -> nil,
	Move: (MapLib, PVInstance, Vector3, number?) -> nil,
	MoveRelative: (MapLib, PVInstance, Vector3, number?) -> nil,
	GetPlayers: (MapLib) -> { Player },
	GetFeature:
        ((MapLib, "Players") -> PlayersFeature) &
        ((MapLib, "Settings") -> SettingsFeature) &
		((MapLib, "Skills") -> SkillsFeature) & 
		((MapLib, "PlayerUI") -> GUIFeature)
}

export type Feature<F> = {
    context: ("server" | "client")?,
} & F

export type PlayersFeature = {
	GetPlayers: () -> { Player },
}

export type SettingsFeature = {
	GetSetting: (string) -> any?,
}

return nil
