export radius,
    midpoint, lbound, ubound, abs_lbound, abs_ubound, getinterval, getball, add_error #

"""
    radius([T, ] x::ArbOrRef)

Returns the radius of `x` as a `Mag`. If `T` is given convert to this
type, supports `Mag`, `Arf`, `Arb` and `Float64`.
"""
radius(::Type{Mag}, x::ArbOrRef) = Mag(radref(x))
radius(::Type{Arf}, x::ArbOrRef) = Arf(radref(x), prec = precision(x))
radius(::Type{Arb}, x::ArbOrRef) = Arb(radref(x), prec = precision(x))
radius(::Type{Float64}, x::ArbOrRef) = Float64(radref(x))
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
    midpoint([T, ] z::AcbOrRef)

Returns the midpoint of `z` as a `Complex{Arf}`. If `T` is given and
equal to `Arf` or `Arb`, convert to `Complex{T}`. If `T` is equal to
`Acf` or `Acb` then convert to that.

!!! note "Default type"
    For compatability reasons this functions returns `Complex{Arf}` if
    `T` is omitted. In a future version the default might change to
    `Acf`.
"""
midpoint(::Type{Acb}, z::AcbOrRef) = Acb(midref(realref(z)), midref(imagref(z)))
midpoint(T::Type{<:Union{Arf,Arb}}, z::AcbOrRef) =
    Complex(midpoint(T, realref(z)), midpoint(T, imagref(z)))
midpoint(T::Type{Acf}, z::AcbOrRef) = Acf(midref(realref(z)), midref(imagref(z)))
midpoint(z::AcbOrRef) = midpoint(Arf, z)

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
to this type, supports `Arf` and `Arb`.

See also [`setball`](@ref) and [`getinterval`](@ref).
"""
getball(x::ArbOrRef) = (Arf(midref(x)), Mag(radref(x)))
getball(::Type{Arf}, x::ArbOrRef) = (Arf(midref(x)), Arf(radref(x), prec = precision(x)))
getball(::Type{Arb}, x::ArbOrRef) = (Arb(midref(x)), Arb(radref(x), prec = precision(x)))

"""
    union(x::ArbOrRef, y::ArbOrRef)
    union(x::AcbOrRef, y::AcbOrRef)
    union(x::T, y::T) where {T<:Union{ArbPoly,AcbPoly,ArbSeries,AcbSeries}}
    union(x, y, z...)

Returns a ball containing the union of `x` and `y`. For polynomials
and series the union is taken coefficient-wise.

`union(x, y, z...)` returns a ball containing the union of all given
balls.
"""
union(x::ArbOrRef, y::ArbOrRef) = union!(Arb(prec = _precision(x, y)), x, y)
union(x::AcbOrRef, y::AcbOrRef) = union!(Acb(prec = _precision(x, y)), x, y)
union(x::T, y::T) where {T<:Union{ArbPoly,AcbPoly}} =
    _union!(T(prec = _precision(x, y)), x, y)
function union(x::T, y::T) where {T<:Union{ArbSeries,AcbSeries}}
    degree(x) == degree(y) || throw(ArgumentError("union of series requires same degree"))
    res = T(degree = degree(x), prec = _precision(x, y))
    _union!(res.poly, x.poly, y.poly)
    return res
end

function union(x::ArbOrRef, y::ArbOrRef, z::ArbOrRef, xs...)
    res = union(y, z, xs...)
    return union!(res, res, x)
end
function union(x::AcbOrRef, y::AcbOrRef, z::AcbOrRef, xs...)
    res = union(y, z, xs...)
    return union!(res, res, x)
end
function union(x::T, y::T, z::T, xs...) where {T<:Union{ArbPoly,AcbPoly}}
    res = union(y, z, xs...)
    return _union!(res, res, x)
end
function union(x::T, y::T, z::T, xs...) where {T<:Union{ArbSeries,AcbSeries}}
    res = union(y, z, xs...)
    degree(res) == degree(x) || throw(ArgumentError("union of series requires same degree"))
    _union!(res.poly, res.poly, x.poly)
    return res
end

# Used internally by union
function _union!(res::T, x::T, y::T) where {T<:Union{ArbPoly,AcbPoly}}
    res_length = max(length(x), length(y))
    common_degree = min(degree(x), degree(y))

    fit_length!(res, res_length)

    for i = 0:common_degree
        union!(ref(res, i), ref(x, i), ref(y, i))
    end

    if common_degree + 1 < res_length
        z = zero(eltype(T))
        # At most one of the below loops will run
        for i = (common_degree+1):degree(x)
            union!(ref(res, i), ref(x, i), z)
        end
        for i = (common_degree+1):degree(y)
            union!(ref(res, i), ref(y, i), z)
        end
    end

    set_length!(res, res_length)

    return res
end

"""
    intersection(x::ArbOrRef, y::ArbOrRef)
    intersection(x::T, y::T) where {T<:Union{ArbPoly,ArbSeries}}
    intersection(x, y, z...)

`intersection(x, y)` returns a ball containing the intersection of `x`
and `y`. If `x` and `y` do not overlap (as given by `overlaps(a, b)`)
throws an `ArgumentError`. For polynomials and series the intersection
is taken coefficient-wise.

`intersection(x, y, z...)` returns a ball containing the intersection
of all given balls. If all the balls do not overlap throws an
`ArgumentError`.
"""
function intersection(x::ArbOrRef, y::ArbOrRef)
    res = Arb(prec = _precision(x, y))
    sucess = intersection!(res, x, y)
    iszero(sucess) &&
        throw(ArgumentError("intersection of non-intersecting balls not allowed"))
    return res
end
intersection(x::ArbPoly, y::ArbPoly) =
    _intersection!(ArbPoly((prec = _precision(x, y))), x, y)
function intersection(x::ArbSeries, y::ArbSeries)
    degree(x) == degree(y) ||
        throw(ArgumentError("intersection of series requires same degree"))
    res = ArbSeries(degree = degree(x), prec = _precision(x, y))
    _intersection!(res.poly, x.poly, y.poly)
    return res
end

function intersection(x::ArbOrRef, y::ArbOrRef, z::ArbOrRef, xs...)
    res = intersection(y, z, xs...)
    sucess = intersection!(res, res, x)
    iszero(sucess) &&
        throw(ArgumentError("intersection of non-intersecting balls not allowed"))
    return res
end
function intersection(x::ArbPoly, y::ArbPoly, z::ArbPoly, xs...)
    res = intersection(y, z, xs...)
    return _intersection!(res, res, x)
end
function intersection(x::ArbSeries, y::ArbSeries, z::ArbSeries, xs...)
    res = intersection(y, z, xs...)
    degree(res) == degree(x) ||
        throw(ArgumentError("intersection of series requires same degree"))
    _intersection!(res.poly, res.poly, x.poly)
    return res
end

# Used internally by intersection
function _intersection!(res::ArbPoly, x::ArbPoly, y::ArbPoly)
    res_length = max(length(x), length(y))
    common_degree = min(degree(x), degree(y))

    fit_length!(res, res_length)

    for i = 0:common_degree
        sucess = intersection!(ref(res, i), ref(x, i), ref(y, i))
        if iszero(sucess)
            set_length!(res, res_length)
            normalise!(res)
            throw(ArgumentError("intersection of non-intersecting balls not allowed"))
        end
    end

    if common_degree + 1 < res_length
        # At most one of the below loops will run
        for i = (common_degree+1):degree(x)
            xi = ref(x, i)
            contains_zero(xi) ||
                throw(ArgumentError("intersection of non-intersecting balls not allowed"))
            isnan(midref(xi)) && indeterminate!(ref(res, i))
        end
        for i = (common_degree+1):degree(y)
            yi = ref(y, i)
            contains_zero(yi) ||
                throw(ArgumentError("intersection of non-intersecting balls not allowed"))
            isnan(midref(yi)) && indeterminate!(ref(res, i))
        end
    end

    set_length!(res, res_length)
    normalise!(res)

    return res
end

"""
    add_error(x, err)

Returns a copy of `x` with the absolute value of `err` added to the radius.

For complex `x` it adds the error to both the real and imaginary
parts. For matrices it adds it elementwise.

See also [`setball`](@ref).
"""
add_error(x::Union{ArbOrRef,AcbOrRef}, err::Union{MagOrRef,ArfOrRef,ArbOrRef}) =
    add_error!(copy(x), err)
add_error(x::Union{ArbMatrixOrRef,AcbMatrixOrRef}, err::MagOrRef) = add_error!(copy(x), err)
