# Mag
Mag(x) = set!(Mag(), x)
Mag(x::Union{MagRef,ArfRef}) = Mag(mag_struct(cstruct(x)))

# Arf
Arf(x; prec::Integer = _precision(x)) = set!(Arf(prec = prec), x)
# disambiguation
Arf(x::Arf; prec::Integer = precision(x)) = set!(Arf(prec = prec), x)

#Arb
Arb(x; prec::Integer = _precision(x)) = set!(Arb(prec = prec), x)
# disambiguation
Arb(x::Arb; prec::Integer = precision(x)) = set!(Arb(prec = prec), x)

function Arb(str::AbstractString; prec::Integer = DEFAULT_PRECISION[])
    res = Arb(prec = prec)
    flag = set!(res, str)
    iszero(flag) || throw(ArgumentError("could not parse $str as an Arb"))
    return res
end

## Acb
Acb(
    x::Union{Real,arb_struct,arf_struct,Tuple{<:Real,<:Real}};
    prec::Integer = _precision(x),
) = set!(Acb(prec = prec), x)
Acb(
    re::Union{Real,arb_struct,arf_struct,Tuple{<:Real,<:Real}},
    im::Union{Real,arb_struct,arf_struct,Tuple{<:Real,<:Real}};
    prec::Integer = max(_precision(re), _precision(im)),
) = set!(Acb(prec = prec), re, im)

Acb(z::Union{AcbLike,Complex}; prec::Integer = _precision(z)) = set!(Acb(prec = prec), z)
# disambiguation
Acb(x::Acb; prec::Integer = precision(x)) = set!(Acb(prec = prec), x)

function Acb(str::AbstractString; prec::Integer = DEFAULT_PRECISION[])
    res = Acb(prec = prec)
    flag = set!(realref(res), str)
    iszero(flag) || throw(ArgumentError("could not parse $str as an Arb"))
    return res
end

function Acb(re::AbstractString, im::AbstractString; prec::Integer = DEFAULT_PRECISION[])
    res = Acb(prec = prec)
    flag = set!(realref(res), re)
    iszero(flag) || throw(ArgumentError("could not parse $str as an Arb"))
    flag = set!(imagref(res), im)
    iszero(flag) || throw(ArgumentError("could not parse $str as an Arb"))
    return res
end

Base.Int(x::ArfLike; rnd::Union{arb_rnd,RoundingMode} = RoundNearest) =
    is_int(x) ? get_si(x, rnd) : throw(InexactError(:Int64, Int64, x))

Base.Float64(x::MagLike) = get(x)
Base.Float64(x::ArfLike; rnd::Union{arb_rnd,RoundingMode} = RoundNearest) = get_d(x, rnd)
Base.Float64(x::ArbLike) = Float64(midref(x))

Base.ComplexF64(z::AcbLike) = Complex(Float64(realref(z)), Float64(imagref(z)))

function Base.BigFloat(x::Union{Arf,ArfRef})
    y = BigFloat(; precision = precision(x))
    get!(y, x)
    y
end
Base.BigFloat(x::Union{Arb,ArbRef}) = BigFloat(midref(x))

Base.zero(::Union{Mag,Type{Mag}}) = Mag(UInt64(0))
Base.one(::Union{Mag,Type{Mag}}) = Mag(UInt64(1))
Base.zero(x::T) where {T<:Union{Arf,Arb,Acb}} = T(0, prec = precision(x))
Base.one(x::T) where {T<:Union{Arf,Arb,Acb}} = T(1, prec = precision(x))

# Define these since the base implementation would create `n` copies of the same element
# I.e. only allocating **one** Arf/Arb/Acb.
Base.zeros(x::T, n::Integer) where {T<:Union{Mag,Arf,Arb,Acb}} = [zero(x) for _ = 1:n]
Base.ones(x::T, n::Integer) where {T<:Union{Mag,Arf,Arb,Acb}} = [one(x) for _ = 1:n]
Base.zeros(::Type{T}, n::Integer) where {T<:Union{Mag,Arf,Arb,Acb}} = [zero(T) for _ = 1:n]
Base.ones(::Type{T}, n::Integer) where {T<:Union{Mag,Arf,Arb,Acb}} = [one(T) for _ = 1:n]
