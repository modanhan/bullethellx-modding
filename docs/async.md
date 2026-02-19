# AsyncFunction

`AsyncFunction` is very similar to `Function`.
Both execute a named function for their associated entity.

The key difference is that `AsyncFunction` is scheduled on a thread pool.
Multiple instances can run in parallel, which generally makes it much faster
(about 4× faster on 10 threads) than a regular Function.

Because it runs concurrently, `AsyncFunction` has strict requirements to avoid race conditions:

- It must **never** create or destroy entities or components.

- In general, it may only read other entities’ components if those entities **do not** have an `AsyncFunction`
(unless you can guarantee the component will not be modified during async execution).

- In general, it may not modify other entities’ components
(unless you can guarantee that no two entities will modify the same target, e.g. in a strict 1-to-1 relationship).

- It may query entities.

- It may generally query and update its **own** components
(e.g. not someone else modifies this component during async execution).

- If it updates metadata, the new metadata must **not** contain more fields than the old one.
Be especially careful when using sub-metadata APIs.

If any of these limitations are violated, race conditions may occur.
This can lead to memory corruption, undefined behavior, desyncing,
or crashes. Note in all of these cases, there are no tools available to help debug.

!!! warning
    `AsyncFunction` is an advanced and unsafe feature if used incorrectly.

    If you are unsure about any of the requirements above,
    or cannot guarantee all of them with full confidence, do not use `AsyncFunction`.

    Code with race conditions often appear to work correctly—sometimes 99% of the time.
    But when the remaining 1% fails, it is impossible to debug.
    
    Ensuring all requirements are met is entirely the programmer’s responsibility;
    the engine cannot detect or enforce this for you.

!!! note
    `AsyncFunction` is designed for cases like custom bullet trajectories:
    many instances run simultaneously and only need to read or update their own state.

## Example: Exploding bullet

An `AsyncFunction` for a bullet that stops moving after X seconds
and then splits into N sub-bullets arranged in a circle

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
