# Arblib.jl

This package is a thin, efficient wrapper around [Arb](http://arblib.org) - a C library for arbitrary-precision ball arithmetic.

## Installation

```julia
using Pkg
pkg"add https://github.com/kalmarek/Arblib.jl.git"
```

## What is Arb?
From the Arb documentation:

>  Arb is a C library for rigorous real and complex arithmetic with arbitrary precision. Arb tracks numerical errors automatically using ball arithmetic, a form of interval arithmetic based on a midpoint-radius representation. On top of this, Arb provides a wide range of mathematical functionality, including polynomials, power series, matrices, integration, root-finding, and many transcendental functions. Arb is designed with efficiency as a primary goal, and is usually competitive with or faster than other arbitrary-precision packages.


## Supported types

| Arb  | Julia  |
|---|--- |
| `mag_t`  | `Mag` |
| `arf_t`  | `Arf`  |
| `arb_t`  | `Arb`  |
| `acb_t`  | `Acb`  |
| `arb_t*`  | `ArbVector` |
| `acb_t* ` | `AcbVector` |
| `arb_mat_t`  | `ArbMatrix` |
| `acb_mat_t` | `AcbMatrix` |
| `arb_poly_t`  | `ArbPoly` |
| `acb_poly_t`  | `AcbPoly` |
| `arb_poly_t`  | `ArbSeries` |
| `acb_poly_t`  | `AcbSeries` |
```
