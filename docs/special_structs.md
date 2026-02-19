
# Functions and Metadata

## Function

```c++
struct Function {
    string name;
};
```

`Function` is a simple defined struct, however the `name` field is required to be a
***referenceable function***!
This function should have exactly 1 parameter that is the entity ID which the function acts on.

A ***referenceable function*** is either

1. A global function. In this case, it can be referenced simply using its name.
2. A named field in a table returned by a Lua file. In this case, it is referenced
by `folder_name.file_name:field_name`.

### Global Function Example

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
Engine.createComponent(eid, "Function", {name="SomeGlobalFunction"}) -- ??? (2)
Engine.createComponent(eid, "Function", {name="justALocalFunction"}) -- BAD (3)
Engine.createComponent(eid, "Function", {name="DreamFunction"})      -- BAD (4)

-- Suppose DreamFunction is in another file called dream.lua
require("bx.scripts.dream")
Engine.createComponent(eid, "Function", {name="DreamFunction"})      -- OK  (5)
```

1. `BulletMovement` will be called on `eid`.
2. `SomeGlobalFunction` will still be called...
3. `justALocalFunction` is not accessible, game will crash.
4. `DreamFunction` does not exist, game will crash.
5. Global functions in other files are accessible as long as they're loaded.

### Returned Function Example

```lua title="spoons/my_mod/special_bullet.lua"
local function crazyBullet(eid)
-- ...
end

return {
    bulletFunction = crazyBullet,
}
```

```lua title="spoons/my_mod/my_boss.lua"
Engine.createComponent(eid, "Function", {name="crazyBullet"}) -- BAD (1)
Engine.createComponent(eid, "Function",
    {name="spoons.my_mod.special_bullet:bulletFunction"}) -- OK! (2)
Engine.createComponent(eid, "Function",
    {name="spoons.my_mod.special_bullet:crazyBullet"}) -- Bad (3)
```

1. `bulletTrajectory` is **local** to `special_bullet.lua` and not visible to `my_boss.lua`.
2. The file is correctly refrenced! All folder names, the file name and field name are correct.
3. Even though the defined function is named `crazyBullet`, this name is invisible.
The field is `bulletFunction`.

!!! important
    `Function` is designed for entities that have truly unique behaviors and are small in number,
    e.g. bosses and players.

    Running a custom script on a large number entities is slow, even if the function is simple.
    If you attach `Function` to bullets and there is a massive number of bullets,
    the game will most likely lag.

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
    if not meta.attackTime then meta.attackTime = 0) end -- (3
    meta.attackTime = meta.attackTime + Engine.dt(eid)      -- (4)
    if meta.attackTime >= meta.attackCD then                -- (5)
        attack(eid)                                         -- (6)
        meta.attackTime = 0)                             -- (7
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

!!! important
    Together with Function, they are used to achieve arbitrary logic on specific entities!
    This is the single most scriptable and powerful component of *Bullethell X*'s modding system.

A Metadata is a Lua table with ***valid*** fields. A ***valid*** field is a named field that is either

1. A struct field (int, sf, string, vec2, etc.) ***except `eids`***!!!
2. A Lua table with ***valid*** fields, i.e. sub-metadtata/nested metadata.

### Examples

``` lua
tbl = {}
tbl.timer = 4
tbl.name = "attacker"
tbl.attack = {
    cooldown = 1.5,
    damage = 5,
    name = "basic attack",
}
tbl.ability = {
    cooldown = 10,
    shield = {
        absorb_amount = 100,
        timer = 5,
    },
}
```

<div class="result" markdown>
This is a valid metadata; `Engine.createMetadata(eid, tbl)` will work.
</div>

```lua
tbl = {"ability", 5), "attack", fp(10}
```

<div class="result" markdown>
This is not a valid metadata; this is a list i.e. fields are not named.
</div>

```lua
tbl = {
    name = "barrage",
    cooldown = 12,
}
tbl.targets = {15, 262, 313, 623, 982}
```

<div class="result" markdown>
This is not a valid metadata; one of the fields (namely `targets`) is a list.
</div>
