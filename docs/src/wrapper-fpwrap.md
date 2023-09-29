# Floating point wrapper

The functions in the
[`arb_fpwrap`](https://www.arblib.org/arb_fpwrap.html) module of Arb
are handled different from other functions. The methods for them are
generated using

``` @docs
Arblib.ArbCall.@arbfpwrapcall_str
Arblib.ArbCall.ArbFPWrapFunction
Arblib.ArbCall.jlcode(af::Arblib.ArbCall.ArbFPWrapFunction)
```

The name for the generated method is given by removing the `arb`
prefix and the `double` or `cdouble` in the middle of the name.

The `flag` argument that the C functions take are split into several
keyword arguments in Julia. For the `double` type this is
`correct_rounding::Bool = false` and `work_limit::Integer = 8`. For
the `cdouble` type it also includes `accurate_parts::Bool = false`.
The default values correspond to setting the flag to 0 in C.

The C functions return an `int` flag indicating the status. If the
return flag is `FPWRAP_SUCCESS` the computed value is returned. If the
return flag is `FPWRAP_UNABLE` it throws an error if the keyword
argument `error_on_failure` is true and returns `NaN` otherwise. The
default value for `error_on_failure` is handled by the following two
methods

``` @docs
Arblib.ArbCall.fpwrap_error_on_failure_default
Arblib.ArbCall.fpwrap_error_on_failure_default_set
```
