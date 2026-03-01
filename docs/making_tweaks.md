# Customizing the Boss

Experiment with a few more tweaks to see how they change the gameplay! Here are some ideas to get you started...

## Adjust Bullet Radius

```diff  { title="boss.lua" linenums="35 35" }
-       fire(eid, pos, v * speed, 0.02, _k + meta.n)
+       fire(eid, pos, v * speed, 0.04, _k + meta.n)
```

## Randomize Bullet Radius

```diff  { title="boss.lua" linenums="35 35" }
-       fire(eid, pos, v * speed, 0.02, _k + meta.n)
+       local radius = Mix(0.02, 0.08, meta.rng:nextFP())
+       fire(eid, pos, v * speed, radius, _k + meta.n)
```

## Adjust Multishot

```diff  { title="boss.lua" linenums="28 28" }
-    local radialCount = 18
+    local radialCount = 24
```

## Adjust Bullet Speed

```diff  { title="boss.lua" linenums="27 27" }
-    local speed = 0.35
+    local speed = 0.55
```

## Next Steps

!!! hint "Challenge"
    Can you make more changes to create a unique attack pattern?

Next, we’ll look at how to customize individual bullet trajectories and
create truly wild attack patterns.
