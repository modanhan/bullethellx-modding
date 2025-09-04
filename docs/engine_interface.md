# The Engine Interface

All game functionality is accessed through the engine interface.

## Engine.createEntity

``` lua title="createEntity"
--- @return integer eid entity ID of the created entity
Engine.createEntity = function()
```

<div class="result" markdown>

```lua title="Sample Usage"
local eid = Engine.createEntity()
```

</div>

## Engine.createComponent

``` lua title="createComponent"
--- @param eid integer entity ID
--- @param t string component type
--- @param c table component data, fields must match definition in struct.dsl
Engine.createComponent = function(eid, t, c)
```

<div class="result" markdown>

```lua title="Sample Usage"
Engine.createComponent(eid, "Health", {hp = 4, maxHP = 7}) -- OK
Engine.createComponent(eid, "Health", {hp = 5})            -- BAD (1)
Engine.createComponent(eid, "Health",
    {hp = 4, maxHP = 7, somethingElse = "hello"})          -- ??  (2)
```

1. `maxHP` is not defined!
2. OK, but `somethingElse` does nothing.

</div>

!!! tip "Important!"
    When creating a component, all of its fields must be defined!
    To see which fields a component has, see `structs.dsl`!

## Engine.entities

``` lua title="entities"
--- @param ... string component types
--- @return table
Engine.entities = function(...)
```

<div class="result" markdown>

```lua title="Sample Usage"
local es = Engine.entities("Health", "Enemy")      --     (1)
local es = Engine.entities("Position")             --     (2)
local es = Engine.entities("NonExistentGibberish") -- BAD (3)
```

1. Get all the entities that have a `Health` and `Enemy` component.
2. Get all the entities that have a `Position` component.
3. Can **NOT** get components that don't exist!

</div>

!!! tip
    You can specify any number of components!
    This function will return a list of entities that have **all of the components**.
    If no such entity exists, an empty list is returned.

## Engine.component

``` lua title="component"
--- @param eid integer entity ID
--- @param t string component type
--- @return table | nil component data or nil if not found
Engine.component = function(eid, t)
```

<div class="result" markdown>

```lua title="Sample Usage"
local es = Engine.entities("Health", "Enemy")
for i = 1, #es do
    local eid = es[i]
    local health = Engine.component(eid, "Health") -- OK (1)
end
```

1. Guaranteed to exist! (Because we queried entities with Health)

</div>

!!! tip
    If you call `component()` immediately on an entity from a list returned by `entities()`
    (where the component is one of the arguments),
    the requested component is guaranteed to exist.

    Otherwise, you can use `component()` to test whether a component exists
    by checking the result being `nil`.

## Engine.update

``` lua title="update"
--- @param eid integer entity ID
--- @param t string component type
--- @param c table component data, fields must match definition in struct.dsl
Engine.update = function(eid, t, c)
```

<div class="result" markdown>

```lua title="Sample Usage"
local es = Engine.entities("Health", "Enemy")
for i = 1, #es do
    local eid = es[i]
    local health = Engine.component(eid, "Health")
    health.maxHP = 1
    Engine.update(eid, "Health", health)               -- OK  (1)
    
    Engine.update(eid, "Health", {hp = 1, maxHP = 10}) -- OK  (2)
    Engine.update(eid, "Health", {hp = 1})             -- BAD (3)
end
```

1. Every enemy has `maxHP` of 1 now.
2. Every enemy has `1/10` health now.
3. `maxHP` is not defined.

</div>

!!! tip "Important!"
    Similar to `createComponent()`, all of its fields must be defined!

## Engine.destroyComponent

``` lua title="destroyComponent"
--- @param eid integer entity ID
--- @param t string component type
Engine.destroyComponent = function(eid, t)
```

<div class="result" markdown>

```lua title="Sample Usage"
local es = Engine.entities("IFrame", "Enemy")
for i = 1, #es do
    local eid = es[i]
    Engine.destroyComponent(eid, "IFrame")       -- OK  (1)
    Engine.destroyComponent(eid, "IFrame")       -- ??  (2)
    Engine.destroyComponent(eid, "DoesNotExist") -- BAD (3)
end
```

1. Destroy all enemy `IFrames`.
2. `IFrames` is already destroyed, does nothing.
3. `DoesNotExist` is not a struct, game will crash.

</div>

## Engine.destroyEntity

``` lua title="destroyEntity"
--- @param eid integer entity ID
Engine.destroyEntity = function(eid)
```

<div class="result" markdown>

```lua title="Sample Usage"
local es = Engine.entities("Enemy")
for i = 1, #es do
    local eid = es[i]
    Engine.destroyEntity(eid)                -- OK (1)
    Engine.destroyEntity(eid)                -- ?? (2)
    Engine.destroyComponent(eid, "Enemy")    -- ?? (3)
    Engine.createComponent(eid, "Enemy", {}) -- ?? (4)
end
```

1. Destroy all enemies (and associated components)!
2. Does nothing, the first `destroyEntity()` invalidates `eid`.
3. Does nothing, `eid` is already invalid.
4. Does nothing, `eid` is already invalid.

</div>
