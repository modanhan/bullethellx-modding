# Sub-metadata

By default, a single metadata update call replaces **all fields** in a metadata object.

This means that if your metadata contains 200 fields and you modify just one of them,
calling a full update will still rewrite the remaining 199 fields.
While correct, this can result in unnecessary work and reduced performance.

To address this, the engine provides a more advanced API that allows you to
**query and update sub-metadata**. This is especially useful when working with
large or frequently updated metadata structures.

## Query

This function allows you to query either the entire metadata table or a specific sub-field using dot notation.

``` lua
--- @param eid integer entity ID
--- @param f string|nil field name
Engine.metadata = function(eid, f) 
```

<div class="result" markdown>

```lua title="Sample Usage"
-- Suppose we have metadata
{
    name = "crazy_boss",
    bonus_xp = 100,
    attack1 = {
        cooldown = 3,
        multishot = 12,
        aim = 5,
    },
    attack2 = {
        name = "dash_strike",
        config = {
            distance = 3.0,
            speed = 10.0,
            iframe = 0.5,
        },
    },
}

Engine.metadata(eid)                         -- (1)
Engine.metadata(eid, "attack1")              -- (2)
Engine.metadata(eid, "name")                 -- (3)
Engine.metadata(eid, "bonus_xp")             -- (4)
Engine.metadata(eid, "attack1.cooldown")     -- (5)
Engine.metadata(eid, "attack2.name")         -- (6)
Engine.metadata(eid, "attack2.config")       -- (7)
Engine.metadata(eid, "attack2.config.speed") -- (8)

```

1. Standard metadata query, returns the entire table.
2. Sub-metadata query, returns `attack1`, i.e. `"{cooldown = 3,multishot = 12,aim = 5}"`.
3. Sub-metadata query, returns `"crazy_boss"`.
4. Sub-metadata query, returns `100`.
5. Sub-metadata query, returns `3`.
6. Sub-metadata query, returns `"dash_strike"`.
7. Sub-metadata query, returns `"{distance = 3.0),speed = fp(10.0),iframe = fp(0.5,}"`.
8. Sub-metadata query, returns `"10.0"`.

</div>

## Update

This API mirrors Engine.metadata, allowing updates at any depth within the metadata hierarchy.

``` lua
--- @param eid integer entity ID
--- @param f string|nil|any field name, update entire metadata if nil
--- @param m any metadata
Engine.updateMetadata = function(eid, f, m)
```

<div class="result" markdown>

```lua title="Updates the entire attack1 table while leaving the rest of the metadata unchanged." hl_lines="2 11"
Engine.updateMetadata(eid, "attack1", {
    cooldown = 999,
    multishot = 12,
    aim = 5,
})
assert_eq(Engine.metadata(eid),
    {
        name = "crazy_boss",
        bonus_xp = 100,
        attack1 = {
            cooldown = 999,
            multishot = 12,
            aim = 5,
        },
        attack2 = {
            name = "dash_strike",
            config = {
                distance = 3.0,
                speed = 10.0,
                iframe = 0.5,
            },
        },
    }
)
```

```lua title="Updates a single nested field without touching sibling fields." hl_lines="1 8"
Engine.updateMetadata(eid, "attack1.multishot", 1)
assert_eq(Engine.metadata(eid),
    {
        name = "crazy_boss",
        bonus_xp = 100,
        attack1 = {
            cooldown = 999,
            multishot = 1,
            aim = 5,
        },
        attack2 = {
            name = "dash_strike",
            config = {
                distance = 3.0,
                speed = 10.0,
                iframe = 0.5,
            },
        },
    }
)
```

```lua title="Replaces the attack1 table entirely." hl_lines="2 9"
Engine.updateMetadata(eid, "attack1", {
    disabled = 1,
})
assert_eq(Engine.metadata(eid),
    {
        name = "crazy_boss",
        bonus_xp = 100,
        attack1 = {
            disabled = 1,
        },
        attack2 = {
            name = "dash_strike",
            config = {
                distance = 3.0,
                speed = 10.0,
                iframe = 0.5,
            },
        },
    }
)
```

```lua title="Passing an empty table removes the sub-metadata." hl_lines="2 6"
Engine.updateMetadata(eid, "attack1", {})
assert_eq(Engine.metadata(eid),
    {
        name = "crazy_boss",
        bonus_xp = 100,

        attack2 = {
            name = "dash_strike",
            config = {
                distance = 3.0,
                speed = 10.0,
                iframe = 0.5,
            },
        },
    }
)
```

```lua title="Adds a new sub-metadata entry." hl_lines="1 14 15 16"
Engine.updateMetadata(eid, "attack3", {name="temporary ability"})
assert_eq(Engine.metadata(eid),
    {
        name = "crazy_boss",
        bonus_xp = 100,
        attack2 = {
            name = "dash_strike",
            config = {
                distance = 3.0,
                speed = 10.0,
                iframe = 0.5,
            },
        },
        attack3 = {
            name = "temporary ability",
        }
    }
)
```

</div>

## Practical Example

Let’s revisit our first boss and update only the parts of the metadata that actually change.

```diff  { title="bx/mods/my_mod/new_boss.lua" linenums="71 71" }
         meta.t = 0
     end
     meta.t = meta.t - dt * 0.8
+    Engine.updateMetadata(eid, "t", meta.t)
+    Engine.updateMetadata(eid, "animationLoop", meta.animationLoop)

     updateAttack(eid, dt, meta.attack)
-
-    Engine.updateMetadata(eid, meta)
+    Engine.updateMetadata(eid, "attack", meta.attack)
 end

 local function create()
```

These changes do not affect gameplay behavior,
but they ensure that only the necessary metadata updates are committed.

!!! note
    If you queried the entire metadata table, it’s fine to update the entire metadata-
    just make sure you do it only once.

    If you only need to modify a sub-metadata, you likely only needed to query that sub-metadata.

    As a rule of thumb, query **X** and update **X**:
    `Engine.metadata(eid, "X") ... Engine.updateMetadata(eid, "X", ...)`
