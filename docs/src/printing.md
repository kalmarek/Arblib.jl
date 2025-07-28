# Printing
The task of printing an [`Arb`](@ref) value in a human readable format
is surprisingly tricky. See for example the issues
[#84](https://github.com/kalmarek/Arblib.jl/issues/84),
[#208](https://github.com/kalmarek/Arblib.jl/issues/208) and
[#217](https://github.com/kalmarek/Arblib.jl/issues/217) which all are
examples of confusions coming from the way [`Arb`](@ref) values are
printed by default.

The main source of confusion is the convention that the output is
rounded so that **the printed midpoint is correct to within 1 ulp
(unit in the last decimal place)**. Compare

``` @repl
using Arblib # hide

Arb(π, prec = 64)

string(Arb(π, prec = 64), digits = 50, more = true)

Arb(π, prec = 128)
```

Where we have manually used the [`string`](@ref) function with the
`more` flag to force it to print more digits of the midpoint in the
second case. In all cases the output is correct, in the sense that the
printed enclosure indeed is an enclosure of $\pi$. The second case is
however rather misleading, since it shows a lot of digits that are not
in the actual value for $\pi$.

This convention can give confusing behavior when the radius is too
large for even the first digit to be known to 1 ulp. In this case, no
digits of the midpoints are printed and instead the value is printed
in the format `[+/- R]` where `R` is an upper bound for the absolute
value of the input. As above, the `more` argument to [`string`](@ref)
can then be used to print more (possibly incorrect) digits.

``` @repl
using Arblib # hide

x = setball(Arb, 5, 2) # The interval is too wide to know the first digit to 1 ulp

string(x, more = true)

string(x, digits = 5, more = true)
```

In general the radius in the printed value will be larger than the
actual value. This effect is particularly noticeable for wide values,
but occurs otherwise as well. The effect is reduced by printing more
(possibly incorrect) digits, but still persists (in part because the
radius is rounded to 2 digits in the printing). For example we can
consider the printed radius for an enclosure of $\pi$.

``` @repl
using Arblib # hide

x = Arb(π, prec = 64)

string(x, digits = 50, more = true)

radius(x)
```

Even for exact values a radius is printed if the number of digits
requested is not enough to represent the value exactly.

``` @repl
using Arblib # hide

x = 1 / Arb(2^55, prec = 64) # Set x to the exact value 2^-55

Arblib.isexact(x) # The value is indeed exact, even though it is printed with a radius

string(x, digits = 39) # We need at least 39 digits to print the exact value
```

# Serialization
As apparent from the above discussion, printing an [`Arb`](@ref) value
as a decimal string is a lossy operation. If you want to convert to a
string as an intermediate formation you can serialize the value as a
string using the [`Arblib.dump_string`](@ref) function. The result can
then be read back using [`Arblib.load_string`](@ref).

``` @repl
using Arblib # hide

x = Arb(π)

str = Arblib.dump_string(x)

y = Arblib.load_string(Arb, str)

isequal(x, y) # x and y are exactly the same
```

## API

``` @docs
string
Arblib.dump_string
Arblib.load_string
```
