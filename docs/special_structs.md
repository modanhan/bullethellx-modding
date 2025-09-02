
# Special Structs

## Function

```c++
struct Function {
    string name;
};
```

`Function` is a simple defined struct, however the `name` field is required to be a ***global function*** in Lua!
This function must have exactly 1 parameter that is the entity ID which the function acts on.

E.g.

```lua

function BulletMovement(bullet_eid)
-- ...
end

function SomeGlobalFunction()
-- ...
end

local function justALocalFunction(bullet_eid)
-- ...
end

-- ...
Engine.createComponent(eid, "Function", {name="BulletMovement"})     -- OK  (1)
Engine.createComponent(eid, "Function", {name="SomeGlobalFunction"}) -- BAD (2)
Engine.createComponent(eid, "Function", {name="justALocalFunction"}) -- BAD (3)
Engine.createComponent(eid, "Function", {name="DreamFunction"})      -- BAD (4)

-- Suppose DreamFunction is in another file called dream.lua
require("bx.scripts.dream")
Engine.createComponent(eid, "Function", {name="DreamFunction"})      -- OK  (5)
```

1. `BulletMovement` will be called on `eid`.
2. But `SomeGlobalFunction` will still be called...
3. `justALocalFunction` is not accessible, game will crash.
4. `DreamFunction` does not exist, game will crash.
5. Global functions in other files are accessible as long as they're loaded.

## Metadata

You might be wondering - what if these functions need extra parameters to customize their behavior?
That’s exactly what `Metadata` is for.

`Metadata` is a special component that is ***not defined in `structs.dsl`***! This means they don't use standard Engine APIs.
Instead, they have

```lua  hl_lines="3 6 10 13"

--- @param eid integer entity ID
--- @param t table metadata
Engine.createMetadata = function(eid, t)

--- @param eid integer entity ID
Engine.metadata = function(eid)

--- @param eid integer entity ID
--- @param t table metadata
Engine.updateMetadata = function(eid, t)

--- @param eid integer entity ID
Engine.destroyMetadata = function(eid)
```

<div class="result" markdown>

```lua title="Sample Usage"
-- during initialize
    Engine.createMetadata(e, { attackCD = 0.2 })            -- (1)

-- during update
    local meta = Engine.metadata(eid)                       -- (2)
    if not meta.attackTime then meta.attackTime = fp(0) end -- (3)
    meta.attackTime = meta.attackTime + Engine.dt           -- (4)
    if meta.attackTime >= meta.attackCD then                -- (5)
        attack(eid)                                         -- (6)
        meta.attackTime = fp(0)                             -- (7)
    end
    Engine.updateMetadata(eid, meta)                        -- (8)
```

1. Set attack cooldown to 0.2 seconds
2. Access the metadata
3. Create an attack timer if we don't have one
4. Update the attack timer by delta time
5. Every 0.2 (attack cooldown) seconds
6. Do an attack
7. And reset the timer
8. Update metadata, because attack timer value has changed

</div>

!!! info
    Together with Function, they are used to achieve arbitrary logic on specific entities!
    This is the single most scriptable and powerful component of *Bullethell X*'s modding system.

## Ad-hoc

### Trail

Most bullets benefit from a trail visual component, to create this component manually,
use the `Engine.createTrail` function:

```lua  hl_lines="7"
-- Create a trail visual
--- @param eid integer
--- @param detail integer
--- @param opacity number
--- @param widthScale number | nil if nil, default to 1
--- @param cd number | nil if nil, use Engine.dt
Engine.createTrail = function(eid, detail, opacity, widthScale, cd)
```

<div class="result" markdown>
```lua title="Sample Usage in Helper.fireStandardBulletBoss" hl_lines="13"

local bulletEid = Engine.createEntity()
Engine.createComponent(bulletEid, "Color", ... )
Engine.createComponent(bulletEid, "Position", ... )
Engine.createComponent(bulletEid, "Radius", ... )
Engine.createComponent(bulletEid, "Velocity", ... )
Engine.createComponent(bulletEid, "Graphic", ... )
Engine.createComponent(bulletEid, "Circle", {})
Engine.createComponent(bulletEid, "Bullet", {
    damage = fp(1),
    firedBy = config.firedBy,
})
Engine.createComponent(bulletEid, "FactionEnemy", {})
Engine.createTrail(bulletEid, 8, 0.5, 1, Engine.dt * 2)
return bulletEid

```

</div>
