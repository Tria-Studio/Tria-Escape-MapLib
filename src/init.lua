-- Copyright (C) 2023 Tria
-- This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
-- If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local SettingsHandler = require(ReplicatedStorage.shared.OSLib.SettingsHandler)
local PlayerStates = require(ReplicatedStorage.shared.PlayerStates)
local Types = require(script.Types)

local CONTEXT_ERROR = "'%s' Cannot be called from the %s" -- Error which shows up when a function is ran on the wrong context
local IS_SERVER = RunService:IsServer()
local LIQUID_COLORS = {
	water = Color3.fromRGB(33, 84, 185),
	acid = Color3.fromRGB(0, 255, 0),
	lava = Color3.fromRGB(255, 0, 0),
}

local Alert, Sound, Signal
if IS_SERVER then
	Signal = require(ReplicatedStorage.Packages.Signal)
else
	Alert = require(game.Players.LocalPlayer.PlayerScripts.client.Alert)
	Sound = require(game.Players.LocalPlayer.PlayerScripts.client.Sound)
end

--- @class MapLib
--- This page contains all the common and beginner scripting methods with appropriate examples when necessary.

--[=[
	@since 0.5
	@readonly
	@within MapLib
	@prop map Model
	This is the map reference.
]=]

--[=[
	@since 0.7
	@within MapLib
	@prop RoundEnding RBXScriptSignal
	This `RBXScriptSignal` is fired when a map ends.

	**Example:**
	```lua
	MapLib.MapEnded:Connect(function()
		MapLib:Alert("The round has ended", Color3.new(0, 255, 0), 2.5)
	end)
	```
]=]

--- @prop _MapHandler any
--- @readonly
--- @private
--- @within MapLib

local MapLib: Types.MapLib = {}
MapLib.__index = MapLib

function MapLib.new(map, MapHandler)
	local self: Types.MapLib = setmetatable({}, MapLib)

	self.map = map
	self.Map = map
	self._MapHandler = MapHandler

	return self
end

--[=[
	@return nil
	@since 0.2.4
	This method can be used to send an alert, these alerts can be customized by color and duration.

	**Example:**
	```lua
	MapLib:Alert("Hello world!", Color3.new(255, 255, 255), 3)
	-- Creates an alert with the given message with the color white and the duration of 3 seconds.
	```
	:::tip
	You can pass the color argument as string and it'll still work, just make sure to use a common color name!
	```lua
	MapLib:Alert("Hello world!", "red", 3)
	:::
]=]
function MapLib:Alert(message: string, color: Color3 | string, length: number?): nil
	if IS_SERVER then
		ReplicatedStorage.Remotes.Misc.SendAlert:FireAllClients(message, color, length, true)
	else
		Alert.new(message, color, length, true)
	end
end

--[=[
	@since 0.4
	This method can be used to change the current music playing in a map, this also replicates to people spectating.

	**Example:**
	```lua
	MapLib:ChangeMusic(12245541717, 1, 5)
	-- Changes the currently playing music to volume 1 and starts at 5 seconds in.
]=]
function MapLib:ChangeMusic(musicId: number, volume: number, startTick: number): nil
	if IS_SERVER then
		ReplicatedStorage.Remotes.Misc.ChangeMusic:FireAllClients(musicId, volume, (startTick or 0))
	else
		Sound:ChangeMusic(musicId, volume, startTick)
	end
end

--[=[
	@server
	@since 0.2.4
	This method can be used to run functions once a specific button has been pressed.

	**Example:**
	```lua
	MapLib:GetButtonEvent(5):Connect(function(player: Player?)
		MapLib:Alert("Button 5 was pressed!", Color3.fromRGB(255, 255, 255), 4)
	end)
	```
	:::note
	The `player` argument here is the player that pressed the button or nil if the button was activated automatically.
	:::
	:::tip
	Path buttons work the same as normal buttons, you just need to give a valid button ID in quotation marks (e.g. "6A")

	**Example:**
	```lua
	MapLib:GetButtonEvent("6A"):Connect(function(player: Player?)
		MapLib:Alert("Button 6A was pressed!", Color3.fromRGB(255, 0, 0), 5)
	end)
	```
	:::
]=]
function MapLib:GetButtonEvent(buttonId: number | string): RBXScriptSignal?
	if IS_SERVER then
		if tonumber(buttonId) then
			-- Normal button
			return self._MapHandler.ButtonHandler:GetButton(buttonId).Activated
		else
			-- Path button
			local event = Signal.new()
			self._MapHandler.ButtonHandler
				:GetButton(tonumber(buttonId:sub(1, #buttonId - 1))).Activated
				:Connect(function(player, isLastButton, longId)
					event:Fire(player, isLastButton, longId)
				end)
			return event
		end
	else
		error(CONTEXT_ERROR:format("MapLib:GetButtonEvent", "client"), 2)
	end
end

--[=[
	@server
	@since 0.8
	This method can be used to make a player survive the round without touching the ExitRegion.

	**Example:**
	```lua
	local Players = game:GetService("Players")
	local MapLib = game.GetMapLib:Invoke()()

	script.Parent.Touched:Connect(function(other)
		local player = Players:GetPlayerFromCharacter(other.Parent)
		if player then
			MapLib:Survive(player)
		end
	end)
]=]
function MapLib:Survive(player: Player): nil
	if IS_SERVER then
		if not player then
			return error("Player does not exist", 2)
		end
		PlayerStates:SetPlayerState(player, PlayerStates.SURVIVED)
		ReplicatedStorage.Remotes.Misc.SendAlert:FireClient(player, "Survived", "green", 2.5)
	else
		error(CONTEXT_ERROR:format("MapLib:SurvivePlayer", "client"), 2)
	end
end

--[=[
	@since 0.2.4
	This method can be used to change the state of a liquid. There are 3 default types you can choose, these are `water`, `acid` and `lava`.

	**Example:**
	```lua
	MapLib:SetLiquidType(map.Liquid1, "lava")
	-- Changes the liquidType of map.Liquid1 to lava.
	```
	:::tip
	You can make your own liquid type in your map's `Settings.Liquids` folder. For example a custom liquid type named "bromine" will have the usage:
	```lua
	MapLib:SetLiquidType(map.LiquidWater, "bromine")
	```
	:::
]=]
function MapLib:SetLiquidType(liquid: BasePart, liquidType: string): nil
	task.spawn(function()
		local color = LIQUID_COLORS[liquidType]
		if self.map and not color then
			local custom = self.map.Settings.Liquids:FindFirstChild(liquidType)
			color = custom and SettingsHandler:GetValue(custom, "Color") or Color3.new()
		end

		TweenService:Create(liquid, TweenInfo.new(1), { Color = color }):Play()
		task.wait(1)
		SettingsHandler:SetValue(liquid, "Type", liquidType)
	end)
end

local function move(moveable: PVInstance, movement: Vector3, duration: number?, relative: boolean?): nil | null
	if duration == 0 or duration == nil then
		return moveable:PivotTo(
			relative and moveable:GetPivot() * CFrame.new(movement) or moveable:GetPivot() + movement
		)
	end

	local moved = Vector3.zero
	local move = movement / duration
	local endTick = tick() + duration
	local connection
	connection = RunService.PreSimulation:Connect(function(deltaTime)
		if tick() < endTick then
			moved += move * deltaTime
			moveable:PivotTo(
				relative and moveable:GetPivot() * CFrame.new(move * deltaTime)
					or moveable:GetPivot() + (move * deltaTime)
			)
		else
			connection:Disconnect()
			moveable:PivotTo(
				relative and moveable:GetPivot() * CFrame.new(movement - moved)
					or moveable:GetPivot() + (movement - moved)
			)
		end
	end)
end

--[=[
	@since 0.9
	Used to move `PVInstances`.

	**Example:**
	```lua
	MapLib:Move(map.MovingPart1, Vector3.new(12, 0, 0), 3)
	-- Moves map.MovingPart1 along the X axis 12 studs and finishes moving after 3 seconds
	```
]=]
function MapLib:Move(moveable: PVInstance, movement: Vector3, duration: number): nil
	task.spawn(move, moveable, movement, duration)
end

--[=[
	@since 0.9
	Used to move `PVInstances`.

	**Example:**
	```lua
	MapLib:MoveRelative(map.MovingPart2, Vector3.new(12, 0, 0), 5)
	--- Moves map.MovingPart2 relative to its rotation.
	```
]=]
function MapLib:MoveRelative(moveable: PVInstance, movement: Vector3, duration: number): nil
	task.spawn(move, moveable, movement, duration, true)
end

MapLib.MovePart = MapLib.Move
MapLib.MovePartLocal = MapLib.MoveRelative
MapLib.MoveModel = MapLib.Move
MapLib.MoveModelLocal = MapLib.MoveRelative

--[=[
	@since 0.9
	This method returns a table containing players currently in a map.
]=]
function MapLib:GetPlayers(): { Player }
	return PlayerStates:GetPlayersWithState(PlayerStates.GAME)
end

--[=[
	@since 0.5.6
	@param name string
	This method is used to get any features listed in the features list.
]=]
function MapLib:GetFeature(name: string): any
	local m = script.Features:FindFirstChild(name)
	local feature = m and require(m)
	if feature then
		if feature.context == "client" and IS_SERVER or feature.context == "server" and not IS_SERVER then
			error(("Feature '%s' can only be used on the '%s'"):format(name, feature.context), 2)
		end
		if feature.new then
			return feature.new(MapLib)
		else
			warn(("Using deprecated feature '%s'"):format(name))
			return feature
		end
	else
		error(("Cannot find feature '%s'"):format(name), 2)
	end
end

return MapLib
