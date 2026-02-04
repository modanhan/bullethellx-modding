# Running Commands

You’ve already tried hot reloading scripts,
but there’s another very useful development tool: **commands**.

Commands are scripts that run once per button press (**F8**).
Other than how they’re triggered, they are just like regular game scripts.

## Your First Command

To get started, create a file called `command.lua` in `bx/mods` and add the following:

```lua title="bx/mods/command.lua"
function Command()
    print("Hello World!")
end
```

Start a game and press **F8**. You should see `Hello World`! printed in the console.

## A More Useful Example

Let’s do something a bit more interesting. Try the following script:

```lua title="bx/mods/command.lua"
require("bx.scripts.engine")
require("bx.scripts.utils")
require("lua_glm")

local function healAllPlayers()
    local playerEids = Engine.entities("Player")
    for _, eid in ipairs(playerEids) do
        local health = Engine.component(eid, "Health")
        health.hp = health.maxHp
        Engine.update(eid, "Health", health)
        Engine.destroyComponent(eid, "DeathAnimation")
    end
end

function Command()
    healAllPlayers()
end
```

This is as a simple cheat that instantly restores all players to full health.
You can use it to replay the boss fight.

## Loading Stages

Commands can be very useful to speed up gameplay iteration.
The example below lets you quickly load a specific boss and jump straight into a fight:

```lua title="bx/mods/command.lua"
require("bx.scripts.engine")
require("bx.scripts.utils")
require("lua_glm")

local function loadStage(name, stage)
    local toDestroy = {
        "FactionEnemy",
        "Bullet",
        "ShopItem",
    }
    for _, compName in ipairs(toDestroy) do
        local es = Engine.entities(compName)
        for i = 1, #es do Engine.destroyEntity(es[i]) end
    end

    local stageManagerEid = Engine.entities("StageManager")[1]
    local stageManager = Engine.component(stageManagerEid, "StageManager")
    stageManager.state = "boss"
    stageManager.stage = stage
    Engine.update(stageManagerEid, "StageManager", stageManager)

    local ok, script = pcall(require, name)
    if not ok then
        Log.e("Error loading boss script for " .. name .. ": " .. tostring(script))
    else
        local boss = script.stage.boss
        local bossEid = boss.create()
        Engine.createComponent(bossEid, "Boss",
            { bossType = name, themeColor = boss.themeColor, bulletColor = boss.bulletColor })
        Engine.createComponent(bossEid, "CullingThreshold", { m = fp(2) })
        Engine.createComponent(bossEid, "Circle", {})
        Log.d("Spawning boss " .. boss.name .. " (stage " .. stage .. ")")
    end
end

function Command()
    loadStage("example_boss.stage", 1)
end

```

This command clears the current encounter and immediately spawns the specified boss.

You can also control which stage the boss is loaded at.
Higher stages should result in significantly more difficult attack patterns.

For example:

```lua
function Command()
    loadStage("example_boss.stage", 5)
end
```

or:

```lua
function Command()
    loadStage("example_boss.stage", 10)
end
```

!!! remark
    Combining `healAllPlayers` and `loadStage` is the quickest way to playtest something
    and is my go to practice for rapid iteration!

```lua
function Command()
    healAllPlayers()
    loadStage("example_boss.stage", 10)
end
```

## Next Steps

Once you're happy with your customization of the first boss,
let's go upload this mod onto Steam as a Workshop Item!

*This is ****optional****! You can also choose to to keep it private!*
