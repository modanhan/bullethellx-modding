# Customizing the Boss

Experiment with a few more tweaks to see how they change the gameplay! Here are some ideas to get you started...

## Adjust Bullet Radius

```diff  { title="bx/mods/my_mod/new_boss.lua" linenums="35 35" }
-       fire(eid, pos, v * speed, fp(0.02))
+       fire(eid, pos, v * speed, fp(0.04))
```

## Randomize Bullet Radius

```diff  { title="bx/mods/my_mod/new_boss.lua" linenums="35 35" }
-       fire(eid, pos, v * speed, fp(0.02))
+       local radius = Mix(fp(0.02), fp(0.08), meta.rng:nextFP())
+       fire(eid, pos, v * speed, radius)
```

## Adjust Multishot

```diff  { title="bx/mods/my_mod/new_boss.lua" linenums="28 28" }
-    local radialCount = 18
+    local radialCount = 24
```

## Adjust Bullet Speed

```diff  { title="bx/mods/my_mod/new_boss.lua" linenums="27 27" }
-    local speed = fp(0.35)
+    local speed = fp(0.55)
```

## Next Steps

!!! hint "Challenge"
    Can you make more changes to create a unique attack pattern?

Next, we’ll look at another useful tool for rapidly iterating on your designs.
