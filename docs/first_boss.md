# Creating a Boss

In this section, we’ll create a simple boss, load it into the game,
make a small change, and then hot-reload it to see the results.

## Step 1: Create Your Workspace

Browse the game’s local install directory and create a folder under `bx/mods`,
We recommend naming the folder after yourself or something easily recognizable.
For example: `bx/mods/spoons`.

We’ll call our first project `example_boss`.
Inside your folder, create a new directory with that name,
and inside it create a script file called `boss.lua`.

Your folder structure should now look like this:
`bx/mods/your_user_name/example_boss/boss.lua`.

## Step 2: Copy the Template Boss Script

Copy the script below:

```lua {.copy}
require("bx.scripts.engine")
require("bx.scripts.utils")
require("bx.scripts.helpers")

---@diagnostic disable: need-check-nil, inject-field, undefined-field

local themeColor = Vec4.new(0.32, 0.38, 0.5, 1)
local bulletColor = themeColor * 1.5

local function fire(eid, pos, v, radius, k)
    local bulletEid = Engine.createEntity()
    Engine.createComponent(bulletEid, "Color", { color = bulletColor })
    Engine.createComponent(bulletEid, "Position", pos)
    Engine.createComponent(bulletEid, "Radius", { r = radius })
    Engine.createComponent(bulletEid, "Velocity", { v = v })
    Engine.createComponent(bulletEid, "Graphic", Graphic.stdPixelatedBullet())
    Engine.createComponent(bulletEid, "Circle", {})
    Engine.createComponent(bulletEid, "Bullet", {
        damage = 1,
        firedBy = eid,
    })
    Engine.createComponent(bulletEid, "FactionEnemy", {})
    Engine.createTrail(bulletEid, 5, 0.5, 1.05, 0.06)
end

local function attack(eid, meta, pos)
    local speed = 0.35
    local radialCount = 18
    local theta = fpmath.pi *2 / radialCount
    local rot = Mat2.rotate(theta)
    local v = Vec2.new(0, 1)
    v = Mat2.rotate(fpmath.gr* meta.n) *v
    for _k = 1, radialCount do
        v = rot* v
        fire(eid, pos, v * speed, 0.02,_k + meta.n)
        meta.n = meta.n + 1
    end
end

local function updateAttack(eid, dt, meta)
    if not meta then
        return
    end
    meta.t = meta.t + dt * 0.6
    if meta.t >= 1 then
        meta.t = meta.t - 1
        attack(eid, meta, Engine.component(eid, "Position"))
    end
end

local function update(eid)
    local dt = Engine.dt(eid)

    local meta = Engine.metadata(eid)
    if not meta.animationLoop then meta.animationLoop = 0 end
    meta.animationLoop = meta.animationLoop + dt * 1.2
    if meta.animationLoop >= 1 then
        meta.animationLoop = meta.animationLoop - 1
    end

    if Engine.component(eid, "BossEntrance") then
        Engine.updateMetadata(eid, meta)
        return
    end
    local health = Engine.component(eid, "Health")
    if not health or health.hp <= 0 then
        return
    end

    Engine.updateMetadata(eid, "animationLoop", meta.animationLoop)

    updateAttack(eid, dt, meta.attack)
    Engine.updateMetadata(eid, "attack", meta.attack)
end

local function create()
    local difficulty = Helper.difficulty()

    local e = Engine.createEntity()
    Engine.createComponent(e, "Unit", {})
    Engine.createComponent(e, "FactionEnemy", {})
    Engine.createComponent(e, "Radius", { r = 0.16 })
    Engine.createComponent(e, "GraphicFunction", { name = "example_boss.boss:graphics", layer = GraphicLayer.enemy })
    Engine.createComponent(e, "Position", { position = Vec2.new(0) })
    Engine.createComponent(e, "Velocity", { v = Vec2.new(0) })
    Engine.createComponent(e, "BossEntrance", { duration = 2.5, t = 0 })
    Engine.createComponent(e, "IFrame", { duration = 2.5, t = 0 })

    local attack = {
        difficulty = difficulty,
        t = 0.8,
        n = 0,
        rng = Grng.new(difficulty),
    }
    local meta = {
        difficulty = difficulty,
        attack = attack,
    }
    Engine.createMetadata(e, meta)
    local hp = Helper.stdHP(difficulty)
    Engine.createComponent(e, "Health", { maxHp = hp, hp = hp, _s = hp })
    Engine.createComponent(e, "SpawnUpgrades",
        { count = Helper.stdUpgradeCount(difficulty), spawned = 0, rng = Grng.new(difficulty) })

    return e
end

local _ex_boss_t = 0
local function graphics(eid)
    local pos = Engine.component(eid, "Position").position
    local alpha = 1
    local deathAnimation = Engine.component(eid, "DeathAnimation")
    if deathAnimation then
        alpha = 1 - Smoothstep(deathAnimation.tbegin, deathAnimation.tend, deathAnimation.t)
    end
    local meta = Engine.metadata(eid)
    local animationLoop = meta.animationLoop

    local color = Colors.scale(Vec4.new(1), 3, alpha)
    Render.spriteSheet(pos + Vec2.new(0, math.cos(animationLoop * math.pi * 2) * 0.04), Vec2.new(0.2),
        color,
        "bx/data/black_bird_team/oneeye1_idle.png", {
            rows = 4,
            columns = 4,
            idx = _ex_boss_t,
        })
    _ex_boss_t = _ex_boss_t + Render.dt * 30
    _ex_boss_t = _ex_boss_t % 16
end

table.insert(Engine.stages, 1, "example_boss.boss")

local boss = {
    name = "Ring of Bullets",
    create = create,
    update = update,
    themeColor = themeColor,
    bulletColor = bulletColor,
}

return {
    stage = {
        boss = boss,
    },
    graphics = graphics,
}

```

Note the modding/scripting system (and a lot of the game logic itself)
in Bullethell X is written in [Lua](https://www.lua.org/)!

- If you have some programming experience, Lua is a lightweight language that is easy to pick up!
- And if you’re new to programming, this is a great place to start!

## Step 3: Load Your Mod In-Game

1. Launch the game.
2. Press *Backspace* to toggle mod settings and make sure:
    - **Local Mods** are *ENABLED*.
    - **Steam Workshop Mods** are *DISABLED*.
    - You can see these settings on the top left corner.
3. Start a singleplayer game. You should see your new boss (Ring of Bullets) performing its basic attack pattern.

## Step 4: Make a Live Change

Open `boss.lua` (you can do this while the game is running!) and edit line 44:

```diff  { title="boss.lua" linenums="44 44" }
-     meta.t = meta.t + dt * 0.6
+     meta.t = meta.t + dt * 1.2
```

## Step 5: Hot Reload Your Mod

Switch back to the game and press **F5** - this hot reloads the scripts.
Your boss should now have a much higher attack speed.

!!! success
    **Congratulations!** You’ve just completed the basic Bullethell X modding workflow.
