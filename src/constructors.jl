export setball

# Mag
Mag(x) = set!(Mag(), x)
# Can't be defined inside Mag due to MagRef and ArfRef being defined
# later.
Mag(x::Union{MagRef,ArfRef}) = Mag(cstruct(x))
Mag(x, y) = set!(Mag(), x, y)
# disambiguation
Mag(x::Complex) = set!(Mag(), x)

# Arf
Arf(x; prec::Integer = _precision(x)) = set!(Arf(; prec), x)
# disambiguation
Arf(x::Arf; prec::Integer = precision(x)) = set!(Arf(; prec), x)
Arf(x::Rational; prec::Integer = _precision(x)) = set!(Arf(; prec), x)
Arf(x::Complex; prec::Integer = _precision(x)) = set!(Arf(; prec), x)

# Acf
Acf(z; prec::Integer = _precision(z)) = set!(Acf(; prec), z)
Acf(re, im; prec::Integer = max(_precision(re), _precision(im))) = set!(Acf(; prec), re, im)
# disambiguation
Acf(x::Acf; prec::Integer = precision(x)) = set!(Acf(; prec), x)

#Arb
Arb(x; prec::Integer = _precision(x)) = set!(Arb(; prec), x)
# disambiguation
Arb(x::Arb; prec::Integer = precision(x)) = set!(Arb(; prec), x)
Arb(x::Rational; prec::Integer = _precision(x)) = set!(Arb(; prec), x)
Arb(x::Complex; prec::Integer = _precision(x)) = set!(Arb(; prec), x)

function Arb(str::AbstractString; prec::Integer = _current_precision())
    res = Arb(; prec)
    flag = set!(res, str)
    iszero(flag) || throw(ArgumentError("could not parse $str as an Arb"))
    return res
end

"""
    setball(::Type{Arb}, m, r; prec = _precision(m))

Returns an `Arb` with the midpoint and radius set to `m` and `r`
respectively.

Note that the `m` is converted to an `Arf` and therefore rounded. So
for example `setball(1 // 3, 0)` will not contain ``1 / 3``.

See also [`getball`](@ref) and [`add_error`](@ref).
"""
function setball(::Type{Arb}, m, r; prec = _precision(m))
    res = Arb(; prec)
    Arblib.set!(Arblib.midref(res), m)
    Arblib.set!(Arblib.radref(res), r)
    return res
end

## Acb
Acb(z; prec::Integer = _precision(z)) = set!(Acb(; prec), z)
Acb(re, im; prec::Integer = max(_precision(re), _precision(im))) = set!(Acb(; prec), re, im)
# disambiguation
Acb(x::Acb; prec::Integer = precision(x)) = set!(Acb(; prec), x)

function Acb(str::AbstractString; prec::Integer = _current_precision())
    res = Acb(; prec)
    flag = set!(realref(res), str)
    iszero(flag) || throw(ArgumentError("could not parse $str as an Arb"))
    return res
end

function Acb(re::AbstractString, im::AbstractString; prec::Integer = _current_precision())
    res = Acb(; prec)
    flag = set!(realref(res), re)
    iszero(flag) || throw(ArgumentError("could not parse $str as an Arb"))
    flag = set!(imagref(res), im)
    iszero(flag) || throw(ArgumentError("could not parse $str as an Arb"))
    return res
end

Base.zero(::Union{Mag,Type{Mag}}) = Mag(UInt64(0))
Base.one(::Union{Mag,Type{Mag}}) = Mag(UInt64(1))
Base.zero(x::T) where {T<:Union{Arf,Acf,Arb,Acb}} = T(0, prec = precision(x))
Base.one(x::T) where {T<:Union{Arf,Acf,Arb,Acb}} = T(1, prec = precision(x))

# Define these since the base implementation would create `n` copies of the same element
# I.e. only allocating **one** Arf/Arb/Acb.
Base.zeros(x::T, n::Integer) where {T<:Union{Mag,Arf,Acf,Arb,Acb}} = [zero(x) for _ = 1:n]
Base.ones(x::T, n::Integer) where {T<:Union{Mag,Arf,Acf,Arb,Acb}} = [one(x) for _ = 1:n]
Base.zeros(::Type{T}, n::Integer) where {T<:Union{Mag,Arf,Acf,Arb,Acb}} =
    [zero(T) for _ = 1:n]
Base.ones(::Type{T}, n::Integer) where {T<:Union{Mag,Arf,Acf,Arb,Acb}} =
    [one(T) for _ = 1:n]
