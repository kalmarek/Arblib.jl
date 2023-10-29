# Arblib.jl Documentation

This package is a wrapper around [Arb](http://arblib.org) - a C
library for arbitrary-precision ball arithmetic. Since 2023 Arb is
part of [Flint](https://flintlib.org/). Other wrappers of Arb/Flint
for Julia include [Nemo](https://github.com/Nemocas/Nemo.jl) and
[ArbNumerics.jl](https://github.com/JeffreySarnoff/ArbNumerics.jl).

The **goal** of Arblib.jl is to supply a **low lever wrapper** of the
methods in Arb as well as a **high level interface**. The low level
wrapper should allow for writing methods using mutability and with
performance very close to that of those written in C. The high level
interface should make it easy to use in generic Julia code, similarly
to how `BigFloat` is a wrapper around the MPFR library. In addition it
should be possible to seamlessly switch between the high level
interface and the low level wrapper when needed.

The above goals can be put into contrast with Nemo, whose high level
interface is made for use in the
[AbstractAlgebra.jl](https://github.com/Nemocas/AbstractAlgebra.jl)
universe and not general Julia code.
