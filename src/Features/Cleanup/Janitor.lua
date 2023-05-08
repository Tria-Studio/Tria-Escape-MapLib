-- Copyright (C) 2023 Tria
-- This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
-- If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.

local RunService = game:GetService("RunService")

local Janitor = {}

Janitor.__index = Janitor
Janitor.ClassName = "Janitor"

local function getJanitors()
	return require(script.Parent).Janitors
end

--[=[
    @class Janitor
    @tag Advanced
    This is an external class which can be referenced with `MapLib:GetFeature("Cleanup").Janitor`

    Janitor is destructor based class designed to assist with clearing up connections events and references.
    :::warning
        WARNING! This is an advanced feature.
        This page assumes you are familiar, comfortable and can write Luau code.
    :::
]=]
--[=[
	@within Janitor
	@since 0.11

	@function new
	@param name string?
	@return _tasks: {[string]: any}
	@return context: string
	@return name: string?
	@return index: number | string
	@return __index: Janitor

	Constructs a new Janitor class and is cached for later use. Janitor provides an option in case you want to name your Janitor for easier reference later.
]=]
function Janitor.new(janitorName: string?)
	local self = setmetatable({}, Janitor)
	self._tasks = {}
	self.context = RunService:IsServer() and "Server" or "Client"
	self.name = janitorName

	local janitors = getJanitors()

	self.index = janitorName or #janitors + 1
	janitors[self.index] = self

	return self
end

--[=[
	@within Janitor
	@since 0.11
	@function isJanitor
	@return boolean
	Returns true if the given class is a Janitor, if not it returns false.
]=]

function Janitor.isJanitor(value: table?): boolean
	return type(value) == "table" and value.ClassName == "Janitor"
end

--[=[
	@within Janitor
	@since 0.11
	@method Give
	@param task <T>
	@return (<T>) -> <T>

	This method is used to give Janitor tasks to cleanup, these tasks can be anything, some examples include, functions, threads, coroutines or anything with a .Destroy function.
	:::tip
	Janitor allows for tables to be given in as an argument. If Janitor detects a table it will loop through the table and add anything it finds will be added to the tasks table.
	:::
]=]

function Janitor:Give(task: any)
	local function handleTask(subtask: any)
		assert(typeof(task) ~= "boolean", "Task cannot be a boolean")

		local taskId = #self._tasks + 1
		self._tasks[taskId] = subtask
		return subtask
	end

	--Task which contains multiple subTasks
	if typeof(task) == "table" then
		if not task.Destroy then
			for _, v in pairs(task) do
				handleTask(v)
			end
			return task
		else
			--Task with .Destroy method
			return handleTask(task)
		end
	end
	return handleTask(task)
end

--[=[
	@within Janitor
	@since 0.11
	@method Cleanup
	@param taskTable: table?
	@return nil

	Calls for the Janitor to cleanup up all the tasks it was given.
]=]
function Janitor:Cleanup(taskTable: table?)
	local tasks = taskTable or self._tasks

	for index, task in pairs(tasks) do
		if typeof(task) == "RBXScriptConnection" then
			tasks[index] = nil
			task:Disconnect()
		end
	end

	local index, task = next(tasks)

	while task ~= nil do
		tasks[index] = nil

		if type(task) == "function" then
			task()
		elseif typeof(task) == "thread" then
			coroutine.close(task)
		elseif typeof(task) == "RBXScriptConnection" then
			task:Disconnect()
		elseif task.Destroy then
			print(task)
			task:Destroy()
			--cancel any promises given
		elseif getmetatable(task).prototype ~= nil then
			task:cancel()
		end
		index, task = next(tasks)
	end
end

--[=[
	@within Janitor
	@since 0.11
	@method Destroy
	@return nil

	Completely destroys Janitor and all references to it. If the Janitor has tasks then those tasks are cleaned up.
]=]
function Janitor:Destroy()
	self:Cleanup()

	--clears up any save janitors inside the cleanup table
	getJanitors()[self.index] = nil

	table.clear(self)
	setmetatable(self, nil)
end

return Janitor
