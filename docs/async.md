
# AsyncFunction

`AsyncFunction` is almost the same as `Function`.
They both run a function defined by their names for their entity.

The difference is `AsyncFunction`
is scheduled to run in a thread pool, multiple instances of it run in parallel
so it is generally much faster (about 4x faster on 10 threads) than Function.

The function however has many requirements to prevent race conditions:

- It can NOT create or destroy any entity or component, EVER!
- In general, it can only query other's components if other does NOT have an AsyncFunction
(unless programmer can guarantee that component is not modified during their async function calls)!
- In general, it can NOT update other's components
(unless programmer can guarantees no 2 entities modify the same other entity,
which is possible e.g. there is a 1-1 relationship)!
- It can query entities.
- In general, it can query and update self.

If any limitations are breached, there can be race conditions,
memory can be corrupted and there can be undefined behavior,
in the worst case the game crashes.

!!! note
    AsyncFunction is designed for e.g. custom bullet trajectories;
    there are many instances of such bullets, they only need to query/update self.

## Example: Exploding bullet

`AsyncFunction` of a bullet that stops moving after X seconds,
and splits into N sub-bullets in a circular pattern.

### Approach 1

Entity is created with Metadata, which initially contains variables `X` and `N`,
as well as an `triggered` flag set to 0.

Entity has an `AsyncFunction` and a `Function` component.

`AsyncFunction` does the following:
After `X` seconds, set flag `triggered` to `1`.

`Function` does the following: if `triggered` is set to 1,

- remove the `AsyncFunction` component,
- remove the `Function` component,
- and fire `N` bullets.

### Approach 2

Entity is created the same way as in approach 1,
except `Function`'s `name` is initially `""` (empty string).

`AsyncFunction` does the following:
After `X` seconds, update `Function`'s `name` to a proper function name.

That `Function` then does the following:

- remove the `AsyncFunction` component,
- removes the `Function` component,
- and fire `N` bullets.

!!! remark

    Notice in both approaches, the AsyncFunction never creates new entities (e.g.firing bullets)
    or new components (a new Function).
    It updates existing fields or metadata, and lets a regular Function takes care of the rest.

## Conclusion

Any Function that meets these requirements can be changed to AsyncFunction;
the game should behave the exact same and get the performance improvements for free.
