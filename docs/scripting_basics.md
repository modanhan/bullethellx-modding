# Entity Component System

Bullethell X is built around three concepts:

- **Entities and Components** which make up the **game state**, and
- **Systems**, which define the **game logic**.

## Entities

Entities are simply unique IDs. They don’t contain any data by themselves,
but they can have components attached. Each entity can only have one instance of each component type.
For example, an entity cannot have two Health components.

```lua
Engine.createComponent(eid, "Health", {hp = 5, maxHP = 5}) -- OK (1)
Engine.createComponent(eid, "Health", {hp = 3, maxHP = 5}) -- ?? (2)
Engine.destroyComponent(eid, "Health")                     -- OK (3) 
Engine.createComponent(eid, "Health", {hp = 3, maxHP = 5}) -- OK (4)
```

1. health is 5/5
2. Does nothing (already has Health)
3. Removes the Health component
4. Health is now 3/5

## Components

Components are **structs** that hold **data**.
For example, the Health component stores two fields: `hp` and `maxHP`.
Most component definitions can be found in `structs.dsl`.

```c++ title="structs.dsl"
struct Health {
    int hp;
    int maxHP;
};
```

## Systems

Systems define the game logic. They run every frame and describe how components interact with each other.

Examples:

- A `Health` component’s `hp` can never exceed its `maxHP`.

- If an entity has both `Position` and `Velocity`,
its `position` is updated: `Position` is offset by `Velocity * deltaTime`.

- If an entity has `Position`, `Radius`, and `Health`,
check for collisions against entities with `Position`, `Radius`, and `Bullet`.
If they overlap, subtract the bullet’s damage from `Health`.
If `hp <= 0`, destroy the entity.

## Example: Clamping Health to maxHP

```lua
local es = Engine.entities("Health")               -- (1)
for i = 1, #es do                                  -- (2)
    local eid = es[i]
    local health = Engine.component(eid, "Health") -- (3)
    if health.hp > health.maxHP then               -- (4)
        health.hp = health.maxHP
        Engine.update(eid, "Health", health)       -- (5)
    end
end
```

1. Find all entities with Health component
2. Iterate through them
3. Get each entity's Health component
4. Ensure `hp` can **NOT** exceed `maxHP`
5. Apply the updated value
