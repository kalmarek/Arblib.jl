export radius, midpoint, lbound, ubound, abs_lbound, abs_ubound, getinterval, getball

"""
    radius([T, ] x::ArbOrRef)

Returns the radius of `x` as a `Mag`. If `T` is given convert to this
type, supports `Mag`, `Arf` and `Arb`.
"""
radius(::Type{Mag}, x::ArbOrRef) = Mag(radref(x))
radius(::Type{Arf}, x::ArbOrRef) = Arf(radref(x), prec = precision(x))
radius(::Type{Arb}, x::ArbOrRef) = Arb(radref(x), prec = precision(x))
radius(x::ArbOrRef) = radius(Mag, x)

"""
    midpoint([T, ] x::ArbOrRef)

Returns the midpoint of `x` as an `Arf`. If `T` is given convert to this
type, supports `Arf` and `Arb`.
"""
midpoint(::Type{Arf}, x::ArbOrRef) = Arf(midref(x))
midpoint(::Type{Arb}, x::ArbOrRef) = Arb(midref(x))
midpoint(x::ArbOrRef) = midpoint(Arf, x)

"""
    lbound([T, ] x::ArbOrRef)

Returns a lower bound of `x` as an `Arf`. If `T` is given convert to
this type, supports `Arf` and `Arb`.

If `x` contains `NaN` it returns `NaN`.
"""
lbound(::Type{Arf}, x::ArbOrRef) = get_lbound!(Arf(prec = precision(x)), x)
function lbound(::Type{Arb}, x::ArbOrRef)
    res = zero(x)
    get_lbound!(midref(res), x)
    return res
end
lbound(x::ArbOrRef) = lbound(Arf, x)

"""
    ubound([T, ] x::ArbOrRef)

Returns an upper bound of `x` as an `Arf`. If `T` is given convert to
this type, supports `Arf` and `Arb`.

If `x` contains `NaN` it returns `NaN`.
"""
ubound(::Type{Arf}, x::ArbOrRef) = get_ubound!(Arf(prec = precision(x)), x)
function ubound(::Type{Arb}, x::ArbOrRef)
    res = zero(x)
    get_ubound!(midref(res), x)
    return res
end
ubound(x::ArbOrRef) = ubound(Arf, x)

"""
    abs_lbound([T, ] x::Union{ArbOrRef,AcbOrRef})

Returns a lower bound of `abs(x)` as an `Arf`. If `T` is given convert
to this type, supports `Arf` and `Arb`.

If `x` contains `NaN` it returns `NaN`.
"""
abs_lbound(::Type{Arf}, x::Union{ArbOrRef,AcbOrRef}) =
    get_abs_lbound!(Arf(prec = precision(x)), x)
function abs_lbound(::Type{Arb}, x::Union{ArbOrRef,AcbOrRef})
    res = Arb(prec = precision(x))
    get_abs_lbound!(midref(res), x)
    return res
end
abs_lbound(x::Union{ArbOrRef,AcbOrRef}) = abs_lbound(Arf, x)

"""
    abs_ubound([T, ] x::Union{ArbOrRef,AcbOrRef})

Returns an upper bound of `abs(x)` as an `Arf`. If `T` is given
convert to this type, supports `Arf` and `Arb`.

If `x` contains `NaN` it returns `NaN`.
"""
abs_ubound(::Type{Arf}, x::Union{ArbOrRef,AcbOrRef}) =
    get_abs_ubound!(Arf(prec = precision(x)), x)
function abs_ubound(::Type{Arb}, x::Union{ArbOrRef,AcbOrRef})
    res = Arb(prec = precision(x))
    get_abs_ubound!(midref(res), x)
    return res
end
abs_ubound(x::Union{ArbOrRef,AcbOrRef}) = abs_ubound(Arf, x)

"""
    getinterval([T, ] x::ArbOrRef)

Returns a tuple `(l, u)` representing an interval `[l, u]` enclosing
the ball `x`, both of them are of type `Arf`. If `T` is given convert
to this type, supports `Arf`, `BigFloat` and `Arb`.

If `x` contains `NaN` both `l` and `u` will be `NaN`.

See also [`getball`](@ref).
"""
function getinterval(::Type{Arf}, x::ArbOrRef)
    l, u = Arf(prec = precision(x)), Arf(prec = precision(x))
    get_interval!(l, u, x)
    return (l, u)
end
function getinterval(::Type{BigFloat}, x::ArbOrRef)
    l, u = BigFloat(precision = precision(x)), BigFloat(precision = precision(x))
    get_interval!(l, u, x)
    return (l, u)
end
function getinterval(::Type{Arb}, x::ArbOrRef)
    l, u = zero(x), zero(x)
    get_interval!(midref(l), midref(u), x)
    return (l, u)
end
getinterval(x::ArbOrRef) = getinterval(Arf, x)

"""
    getball([T, ] x::ArbOrRef)

Returns a tuple `(m::Arf, r::Mag)` where `m` is the midpoint of the
ball and `r` is the radius. If `T` is given convert both `m` and `r`
to this type, supports `Arb`.

See also [`setball`](@ref) and [`getinterval`](@ref). #
"""
getball(x::ArbOrRef) = (Arf(midref(x)), Mag(radref(x)))
getball(::Type{Arb}, x::ArbOrRef) = (Arb(midref(x)), Arb(radref(x), prec = precision(x)))

"""
    union(x::ArbOrRef, y::ArbOrRef)
    union(x::AcbOrRef, y::AcbOrRef)
    union(x, y, z...)

`union(x, y)` returns a ball containing the union of `x` and `y`.

`union(x, y, z...)` returns a ball containing the union of all given
balls.
"""
Base.union(x::ArbOrRef, y::ArbOrRef) = union!(Arb(prec = _precision(x, y)), x, y)
Base.union(x::AcbOrRef, y::AcbOrRef) = union!(Acb(prec = _precision(x, y)), x, y)
# TODO: Could be optimized, both for performance and enclosure
Base.union(x::ArbOrRef, y::ArbOrRef, z::ArbOrRef, xs...) =
    foldl(union, xs, init = union(union(x, y), z))
Base.union(x::AcbOrRef, y::AcbOrRef, z::AcbOrRef, xs...) =
    foldl(union, xs, init = union(union(x, y), z))

"""
    intersect(x::ArbOrRef, y::ArbOrRef)
    intersect(x::AcbOrRef, y::AcbOrRef)
    intersect(x, y, z...)

`intersect(x, y)` returns a ball containing the intersection of `x`
and `y`. If `x` and `y` do not overlap (as given by `overlaps(a, b)`)
throws an `ArgumentError`.

`intersect(x, y, z...)` returns a ball containing the intersection of
all given balls. If all the balls do not overlap throws an
`ArgumentError`.
"""
function Base.intersect(x::ArbOrRef, y::ArbOrRef)
    overlaps(x, y) ||
        throw(ArgumentError("intersection of non-intersecting balls not allowed"))
    res = Arb(prec = _precision(x, y))
    intersection!(res, x, y)
    return res
end
# TODO: Could be optimized, both for performance and enclosure
Base.intersect(x::ArbOrRef, y::ArbOrRef, z::ArbOrRef, xs...) =
    foldl(intersect, xs, init = intersect(intersect(x, y), z))
