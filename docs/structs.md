# Struct Definitions

You’ll find all struct definitions in `structs.dsl`.
These types are fixed: scripts can’t change their layout or add new structs.

Some examples:

=== "#1"

    ```c++ title="structs.dsl"

    struct Radius {
        sf r;
    };

    struct Position {
        vec2 position;
    };

    struct Velocity {
        vec2 v;
    };

    ```

=== "#2"

    ```c++ title="structs.dsl"
    struct Bullet {
        sf damage;
        eid firedBy;
    };
    
    struct Graphic {
        sf layer;
        string texture;
    };
    ```
    
=== "#3"

    ```c++ title="structs.dsl"
    struct PlayerInput {
        int frame;
        int playerIdx;
        vec2 movement;
        int ping;
    };
    ```

## Struct Fields

Structs can contain fields of the following types:

| Type Name      | Description        | Technical Details
| :----------    | :----------------  | :-
| `int`          | Integer            | 64-bit signed
| `sf`           | Decimal number     | Interally a fixed point number with 6 digits of precision
| `eid`          | Entity ID          | 64-bit signed integer
| `eids`         | List of Entity ID  | Lua table of 64-bit signed integers
| `string`       | String             | At most 64 characters
| `vec2`         | 2D vector          | Internal data is decimal numbers
| `vec3`         | 3D vector          | Internal data is decimal numbers
| `vec4`         | 4D vector          | Internal data is decimal numbers
| `mat2`         | 2x2 matrix         | Internal data is decimal numbers
| `mat3`         | 3x3 matrix         | Internal data is decimal numbers
| `mat4`         | 4x4 matrix         | Internal data is decimal numbers
