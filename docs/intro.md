---
sidebar_position: 1
---

# Basics of scripting in ROBLOX Studio and TRIA.os

Welcome to the scripting documentation of TRIA.os!<br></br>
By default we assume you have some knowledge of general scripting in ROBLOX Studio so the documents will sound a bit nerdy, but if you don't have the neccessary information, you can consult this page.

## Booleans

Boolean is an easy-to-understand data type which one has two values: `true` or `false`. Think of it like a light switch, there are only two states a light bulb can be which is on or off.<br></br>
In [conditional statements](https://create.roblox.com/docs/scripting/luau/control-structures#if-statements), if a boolean isn't `false` or `nil`, Luau (the scripting language used for Studio) will assume the boolean as `true`.<br></br>

## Strings

String is a data type used to store text data, such as letters, numbers and symbols.<br></br>
To declare a string, type out anything you want and then wrap that thing in double quotes (`"`) or single quotes (`'`).<br></br>
Example:<br></br>
```lua
message = "Hello world!"
```
Combining (or concatenating) strings is quite simple, add two periods (`..`) between those strings. Concatenating strings won't insert a space between them so you'll have to put one yourself at the end of the first string and beginning of the next string or concatenate a space (` `) between the strings<br></br>Example:<br></br>
```lua
message1 = "Hello"
message2 = "world!"
message2WithSpaceAtTheBeginning = " world!"
print(message1 .. " " .. message2) -- Hello world!
print(message1 .. message2WithSpaceAtTheBeginning) -- Hello world!
print(message1 .. message2) -- Helloworld! (this is not a typo)
```
<br></br>