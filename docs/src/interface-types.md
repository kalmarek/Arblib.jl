# Types

The package defines a number of types for the high level interface.

## Basic
These types directly map to corresponding Arb types.

``` @docs
Mag
Arf
Arb
Acb
ArbVector
AcbVector
ArbPoly
AcbPoly
ArbMatrix
AcbMatrix
```

## Series
The package defines two series types, which are wrapper for the
polynomial types with a specified degree.

``` @docs
ArbSeries
AcbSeries
```

## Ref
In addition to these there are a number of `Ref` types, which allow
for non-allocating access in a number of cases.

``` @docs
MagRef
ArfRef
ArbRef
AcbRef
ArbRefVector
AcbRefVector
ArbRefMatrix
AcbRefMatrix
```

## Correspondence between types
We have the following table for the correspondence with between the
[Low level wrapper types](wrapper-types.md) and the high level
interface types.

| Arb      | Wrapper          | High level  | Ref            |
|----------|------------------|-------------|----------------|
| `mag_t`  | `mag_struct`     | `Mag`       | `MagRef`       |
| `arf_t`  | `arf_struct`     | `Arf`       | `ArfRef`       |
| `arb_t`  | `arb_struct`     | `Arb`       | `ArbRef`       |
| `acb_t`  | `acb_struct`     | `Acb`       | `AcbRef`       |
| `arb_t*` | `arb_vec_struct` | `ArbVector` | `ArbRefVector` |
| `acb_t*` | `acb_vec_struct` | `AcbVector` | `AcbRefVector` |
| `arb_poly_t` | `arb_poly_struct` | `ArbPoly` or `ArbSeries` | |
| `acb_poly_t` | `acb_poly_struct` | `AcbPoly` or `AcbSeries` | |
| `arb_mat_t` | `arb_mat_struct` | `ArbMatrix` | `ArbRefMatrix` |
| `acb_mat_t` | `acb_mat_struct` | `AcbMatrix` | `AcbRefMatrix` |
