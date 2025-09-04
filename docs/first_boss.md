# Create a First Boss

In this section, we’ll create a simple boss, load it into the game,
make a small change, and then hot-reload it to see the results.

## Step 1: Create Your Mod Folder

Create a new folder inside `bx/mods`. This is where all your files will live.
For example:

``` text
bx/mods/my_mod
```

## Step 2: Write Your First Boss Script

Create a new Lua script, e.g.

``` text
bx/mods/my_mod/new_boss.lua
```

Paste the following code into the file:

``` lua { .copy title="bx/mods/my_mod/new_boss.lua" linenums="1" }
require("bx.scripts.engine")
require("bx.scripts.utils")
require("bx.scripts.helpers")

local function attack(eid, meta)
    local speed = fp(0.45)
    local v = meta.rot * Vec2.new(0, speed)

    Helper.fireStandardBulletBoss({
        firedBy = eid,
        position = Engine.component(eid, "Position").position,
        velocity = v * speed,
        radius = fp(0.015),
    })
end

local function update(eid)
    if Engine.component(eid, "BossEntrance") then
        return
    end
    local health = Engine.component(eid, "Health")
    if not health or health.hp <= 0 then
        return
    end

    local meta = Engine.component(eid, "Meta").meta

    if not meta.attackTime then
        meta.attackTime = fp(0)
    end
    if not meta.rot then
        meta.rot = Mat2.new(1)
    end
    meta.attackTime = meta.attackTime + Engine.dt
    local theta = fp(Engine.dt * fp(1.5))
    meta.rot = Mat2.rotate(theta) * meta.rot
    if meta.attackTime >= meta.attackCD then
        meta.attackTime = fp(0)
        attack(eid, meta)
    end

    if not meta.t then
        meta.t = fp(0)
    end
    meta.t = meta.t - Engine.dt * fp(2.1)

    Engine.update(eid, "Meta", { meta = meta })
end

local function create(difficulty)
    local e = Helper.createStandardBoss({ difficulty = difficulty })
    local attackCD = fpmath.clamp(fp(0.2) - fp(0.01) * difficulty, fp(0.1), fp(0.2))
    Engine.createComponent(e, "Meta", { meta = { attackCD = attackCD } })
    return e
end

return {
    boss = {
        name = "New Boss",
        create = create,
        update = update,
    }
}
```

## Step 3: Load Your Mod In-Game

1. Launch the game.
2. Open Settings and make sure:
   - **Local Mods** are *ENABLED*
   - **Steam Workshop Mods** are *DISABLED*
3. Start a singleplayer game. You should see your new boss performing its basic attack pattern.

## Step 4: Make a Live Change

Open `new_boss.lua` again (you can do this while the game is running) and edit line 6:

```diff  { title="bx/mods/my_mod/new_boss.lua" linenums="6 6" }
- local speed = fp(0.45)
+ local speed = fp(0.75)
```

## Step 5: Hot Reload Your Mod

Switch back to the game and press F5. Your boss will now fire bullets at a faster speed.

!!! success
    **Congratulations!** You’ve just completed the basic Bullethell X modding workflow.
