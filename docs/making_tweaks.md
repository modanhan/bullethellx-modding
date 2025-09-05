# Customizing the Boss

Experiment with a few more tweaks to see how they change the gameplay! Here are some ideas to get you started...

## Firing Angle

```diff  { title="bx/mods/my_mod/new_boss.lua" linenums="35 35" }
-   local theta = fp(Engine.dt * fp(1.5))
+   local theta = fp(Engine.dt * fp(25))
```

## Bullet Radius

```diff  { title="bx/mods/my_mod/new_boss.lua" linenums="13 17" }
    Helper.fireStandardBulletBoss({
        firedBy = eid,
        position = Engine.component(eid, "Position").position,
        velocity = v * speed,
-       radius = fp(0.015),
+       radius = fp(0.005),
    })
```

## Attack Speed

```diff  { title="bx/mods/my_mod/new_boss.lua" linenums="34 34" }
-   meta.attackTime = meta.attackTime + Engine.dt
+   meta.attackTime = meta.attackTime + Engine.dt * 5
```

## Multishot

```diff  { title="bx/mods/my_mod/new_boss.lua" linenums="5" }
local function attack(eid, meta)
    local speed = fp(0.75)
    local v = meta.rot * Vec2.new(0, speed)
+   local n = 5
+   local rot = Mat2.rotate(fpmath.pi * fp(2) / fp(5))
+   for _ = 1, n do
+       v = rot * v
        Helper.fireStandardBulletBoss({
            firedBy = eid,
            position = Engine.component(eid, "Position").position,
            velocity = v * speed,
            radius = fp(0.015),
        })
+   end
end
```

## Next Steps

!!! hint "Challenge"
    Can you make more changes to create a truly unique attack pattern?

Once you're happy with your customization of the first boss,
let's go upload this mod onto Steam as a Workshop Item!

*You can choose to to keep it private!*
