# EffectScript

EffectScript is a localscript inside of the Tria.OS Map Making Kit, it should be used as an alternative to the LocalMapScript if you want your code to be replicated to other spectators.
 
In order for the EffectScript to communicate we use RemoteEvents which are fired from the MapScript to the EffectScript.
 
When a round starts all the old EffectScripts are deleted and if a new EffectScript is present, the script will be inserted into the Players PlayerGui, this is to prevent the EffectScript from being deleted if the player dies.

If you wish to manually edit the EffectScript the location of it is `game.Players.LocalPlayer.PlayerGui`
Keep in mind that reparenting the EffectScript will cause the EffectScript not to be deleted on the next round and can potentially cause memory leaks.

## Example of usage

The EffectScript uses the same methods as the MapScript to get the MapLib, being 
`local MapLib = game.GetMapLib:Invoke()()`

Below is a simple example of how to use the EffectScript, in this example we will make a laser effect similar to Dystopia.

MapScript
```lua
local MapLib = game.GetMapLib:Invoke()()
local map = MapLib.map

task.wait(10)
map.StartLaser:FireAllClients()

task.wait(10)
map.StopLaser:FireAllClients()
```

EffectScript
```lua
local MapLib = game.GetMapLib:Invoke()()
local map = MapLib.map

local RunService = game:GetService("RunService")

local connection

map.StartLaser.OnClientEvent:Connect(function()
    connection = RunService.Heartbeat:Connnect(function()
        laser.CFrame *= CFrame.Angles(math.rad(1), 0, 0)
    end)
end)

map.StopLaser.OnClientEvent:Connect(function()
   if connection then
        connection:Disconnect()
     end
end)
```






