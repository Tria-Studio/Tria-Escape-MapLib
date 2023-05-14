---
sidebar_position: 1
---

# Seamless Spectate
# Making spectating seamless
When you make a map you might notice that certain things may cause spectating to act strangely, this can be caused by various things that are documented below.

## Anchoring the player
When you anchor the player it stops the replication of the player, when the player is unanchored it takes a second for the replication to start again which makes it looks like the player is lagging for other players.

### Mitigation
If you want to anchor the player but you also want the effect to be seamless then you need to set the players client position to the desired position every heartbeat.
Example:
```lua
local RunService = game:GetService("RunService")

-- Put the players CFrame into a variable
local anchorPoint = humanoidRootPart.CFrame

-- Begin the anchor
local heartbeat = RunService.Heartbeat:Connect(function()
    -- Set the characters Velocity to 0
	humanoidRootPart.AssemblyLinearVelocity = Vector3.new()
    -- Set the characters CFrame to the saved point
	humanoidRootPart.CFrame = anchorPoint
end)

-- End the anchor
heartbeat:Disconnect()
```

## Changing the characters position on the server
When you change the position of the character on the server it takes over replication from the client, this causes similar effects to anchoring the player

### Mitigation
To make the effect seamless all you need to do is make the teleportation happen on the client, not only will this make the teleportation seamless to other players it will also make the effect more seamless for the player as well.
