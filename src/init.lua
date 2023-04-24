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
--- This is the documentation of MapLib methods.

--- @prop map Model
--- @readonly
--- @within MapLib
--- This is the map model reference property of the MapLib, usable for code that go in LocalMapScript (the script will be parented to the PlayerGUI in a round which will need a reference to the map model if you want to tamper with the map's objects)

--- @prop MapEnded RBXScriptSignal
--- @readonly
--- @within MapLib

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
	@server
	@since 0.2
	This method can be used to send a message to everyone. The message can be customized by color and duration.

	`Example:`
	```lua
	MapLib:Alert("Hello world!", Color3.new(255, 255, 255), 3) -- Creates a message with the given message string (in this case "Hello world!") with the Color3 value which in this case is white and the message will last for 3 seconds
	```
	:::tip
	You can pass the color argument as string and it'll still work, just make sure to use the correct color name!
	```lua
	MapLib:Alert("Hello world!", "red", 3)
	:::
]=]
function MapLib:Alert(message: string, color: Color3?, length: number?): nil
	if IS_SERVER then
		ReplicatedStorage.Remotes.Misc.SendAlert:FireAllClients(message, color, length, true)
	else
		Alert.new(message, color, length, true)
	end
end

--[=[
	@server
	This method can be used to change the current music playing in maps, this also replicates to spectators.

	`Example:`
	```lua
	MapLib:ChangeMusic(12245541717, 1, 5) -- Changes the currently playing music to Tokyo Music Walker - My Itinerary at normal volume and starts at 0:05
]=]
function MapLib:ChangeMusic(musicId: number, volume: number, startTick: number?): nil
	if IS_SERVER then
		ReplicatedStorage.Remotes.Misc.ChangeMusic:FireAllClients(musicId, volume, (startTick or 0))
	else
		Sound:ChangeMusic(musicId, volume, startTick)
	end
end

--[=[
	@server
	This method can be used to run functions once the specific button has been pressed.

	`Example:`
	```lua
	MapLib:GetButtonEvent(5):Connect(function(player)
		MapLib:Alert("Button 5 was pressed!", Color3.fromRGB(255, 255, 255), 4)
	end)
	-- When the 5th button is pressed, send the message "Button 5 was pressed!" which has the color white and lasts for 4 seconds to everyone
	-- The "player" value here is the player that pressed the button
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
	This method can be used to make the player survive the match without touching ExitRegion.

	`Example:`
	```lua
	local maplib = game.GetMapLib:Invoke()()
	local player = game.Players:GetPlayerFromCharacter(other.Parent)
	if (player ~= nil) then 
		maplib:Survive(player)
	end
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
	@server
	This method can be used to change the state of a liquid. There are 3 default types you can choose, these are "water", "acid" and "lava".
	You can made your own liquid type in your map's Settings.Liquids folder.

	`Example:`
	```lua
	MapLib:SetLiquidType(map.LiquidWater, "lava")
	-- Changes the liquidType of map.LiquidWater (the liquid) to lava
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


local function move(moveable: PVInstance, movement: Vector3, duration: number?, relative: boolean?)
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
	@server
	Used to move PVInstances (BaseParts, Models, ...), replicates to all clients (visible to all players).

	`Example:`
	```lua
	MapLib:Move(map.MovingPart1, Vector3.new(12, 0, 0), 3)
	-- Moves the instance given (map.MovingPart1) with the increment along the X axis of +12 studs and finishes moving after 3 seconds
]=]
function MapLib:Move(moveable: PVInstance, movement: Vector3, duration: number): nil
	task.spawn(move, moveable, movement, duration)
end

--[=[
	@client
	Used to move PVInstances, does not replicate to all clients (only visible to the player that the script is running for).

	`Example:`
	```lua
	
	local maplib = game.GetMapLib:Invoke()()
	local map = maplib.map
	MapLib:Move(map.MovingPart2, Vector3.new(-12, 0, 0), 5)
	-- Moves the instance given (map.MovingPart2) with the increment along the X axis of -12 studs and finishes moving after 5 seconds
]=]
function MapLib:MoveRelative(moveable: PVInstance, movement: Vector3, duration: number): nil
	task.spawn(move, moveable, movement, duration, true)
end

--- @class Move
--- MapLib:MovePart() and MapLib:MoveModel() is merged into Maplib:Move(), but you can still use these functions.
--- MapLib:MovePartLocal() and MapLib:MoveModelLocal() is merged into Maplib:MoveRelative(), but you can still use these functions.
MapLib.MovePart = MapLib.Move
MapLib.MovePartLocal = MapLib.MoveRelative
MapLib.MoveModel = MapLib.Move
MapLib.MoveModelLocal = MapLib.MoveRelative


--[=[
	This method returns a tuple/table containing players currently in a map.

]=]
function MapLib:GetPlayers(): {Player}
	return PlayerStates:GetPlayersWithState(PlayerStates.GAME)
end

--- This method is used to get any features listed in the features list.
--- @param name string
function MapLib:GetFeature(name)
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
