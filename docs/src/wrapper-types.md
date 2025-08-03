# Types

The package defines the following types which map directly to Arb
types with the corresponding name. In most cases you should not use
these types directly but use the types from the [High level
interface](interface-types.md).

``` @docs
Arblib.mag_struct
Arblib.arf_struct
Arblib.acf_struct
Arblib.arb_struct
Arblib.acb_struct
Arblib.arb_vec_struct
Arblib.acb_vec_struct
Arblib.arb_poly_struct
Arblib.acb_poly_struct
Arblib.arb_mat_struct
Arblib.acb_mat_struct
Arblib.calc_integrate_opt_struct
```

For each low-level type there is a union of types that can be
interpreted as the low-level type. These are the types that can be
given directly as arguments to the low-level methods. Below you find
these union-types.

``` @docs
Arblib.MagLike
Arblib.ArfLike
Arblib.AcfLike
Arblib.ArbLike
Arblib.AcbLike
Arblib.ArbVectorLike
Arblib.AcbVectorLike
Arblib.ArbMatrixLike
Arblib.AcbMatrixLike
Arblib.ArbPolyLike
Arblib.AcbPolyLike
```

Note that the `show` method is overloaded for these union types, this
is to make method declarations easier to read in the REPL. As an
example we can print the methods for `Arblib.sin!` and we see that it
prints `ArbLike` instead of the much longer
`Union{Ptr{Arblib.arb_struct}, Arb, ArbRef, Arblib.arb_struct}`.

``` @repl
using Arblib

methods(Arblib.sin!)
```
