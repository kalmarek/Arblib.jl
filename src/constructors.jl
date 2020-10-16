# Mag
Mag(x::Union{Unsigned,Base.GMP.CdoubleMax}) = set!(Mag(), x)

# Arf
Arf(
    x::Union{arf_struct,Unsigned,Integer,Base.GMP.CdoubleMax,Mag};
    prec::Integer = DEFAULT_PRECISION[],
) = set!(Arf(prec = prec), x)
Arf(x::Union{Arf,BigFloat}; prec::Integer = precision(x)) = set!(Arf(prec = prec), x)

# Arb
Arb(
    x::Union{arb_struct,Unsigned,Integer,Base.GMP.CdoubleMax};
    prec::Integer = DEFAULT_PRECISION[],
) = set!(Arb(prec = prec), x)
Arb(x::Union{Arf,Arb}; prec::Integer = precision(x)) = set!(Arb(prec = prec), x)

function Arb(x::BigFloat; prec::Integer = precision(x))
    res = Arb(prec = prec)
    set!(midref(res), x)
    return res
end

function Arb(str::AbstractString; prec::Integer = DEFAULT_PRECISION[])
    res = Arb(prec = prec)
    flag = set!(res, str)
    iszero(flag) || throw(ArgumentError("could not parse $str as an Arb"))
    return res
end

function Arb(x::Rational; prec::Integer = DEFAULT_PRECISION[])
    num = Arb(numerator(x); prec = prec)
    denom = Arb(denominator(x); prec = prec)
    div!(num, num, denom)
    return num
end

## Acb
# From real part
Acb(
    x::Union{acb_struct,Unsigned,Integer,Base.GMP.CdoubleMax};
    prec::Integer = DEFAULT_PRECISION[],
) = set!(Acb(prec = prec), x)
Acb(x::Union{Arb,Acb}; prec::Integer = precision(x)) = set!(Acb(prec = prec), x)

function Acb(x::Arf; prec::Integer = precision(x))
    res = Acb(prec = prec)
    set!(realref(res), x)
    return res
end

function Acb(x::BigFloat; prec::Integer = precision(x))
    res = Acb(prec = prec)
    set!(midref(realref(res)), x)
    return res
end

# Fallback version
# TODO: We could get rid of the allocation of one Arb in many cases by
# directly manipulating the real part of the Acb. For example when x
# is a string, a rational or certain irrationals.
Acb(x::Union{Real,AbstractString}; prec::Integer = DEFAULT_PRECISION[]) =
    Acb(Arb(x, prec = prec), prec = prec)

# From real and imaginary part separately
Acb(
    re::T,
    im::T;
    prec::Integer = DEFAULT_PRECISION[],
) where {T<:Union{arb_struct,Integer,Base.GMP.CdoubleMax}} = set!(Acb(prec = prec), re, im)
Acb(re::Arb, im::Arb; prec::Integer = max(precision(re), precision(im))) =
    set!(Acb(prec = prec), re, im)

function Acb(re::Arf, im::Union{Arf}; prec::Integer = max(precision(re), precision(im)))
    res = Acb(prec = prec)
    set!(realref(res), re)
    set!(imagref(res), im)
    return res
end

function Acb(
    re::BigFloat,
    im::Union{BigFloat};
    prec::Integer = max(precision(re), precision(im)),
)
    res = Acb(prec = prec)
    set!(midref(realref(res)), re)
    set!(midref(imagref(res)), im)
    return res
end

# Fallback version
# TODO: Similar for the one with only real part above we could get rid
# of two allocations of Arb in many cases.
# TODO: Handle the case when the inputs have a precision we want to
# use
Acb(
    re::Union{Real,AbstractString},
    im::Union{Real,AbstractString};
    prec::Integer = DEFAULT_PRECISION[],
) = Acb(Arb(re, prec = prec), Arb(im, prec = prec), prec = prec)

# From complex
set!(z::AcbLike, x::Complex{<:Union{ArbLike,Integer,Base.GMP.CdoubleMax}}) =
    set!(z, real(x), imag(x))

Acb(z::Complex{Arb}; prec::Integer = max(precision(real(z)), precision(imag(z)))) =
    set!(Acb(prec = prec), real(z), imag(z))

Acb(
    z::Complex{<:Union{Arf,BigFloat}};
    prec::Integer = max(precision(real(z)), precision(imag(z))),
) = Acb(real(z), imag(z), prec = prec)

# TODO: Handle the case when the inputs have a precision we want to
# use
Acb(z::Complex; prec::Integer = DEFAULT_PRECISION[]) = Acb(real(z), imag(z), prec = prec)

Base.zero(::Union{Mag,Type{Mag}}) = Mag(UInt64(0))
Base.one(::Union{Mag,Type{Mag}}) = Mag(UInt64(1))
Base.zero(x::T) where {T<:Union{Arf,Arb,Acb}} = T(0, prec = precision(x))
Base.one(x::T) where {T<:Union{Arf,Arb,Acb}} = T(1, prec = precision(x))
Base.zero(x::AcbRef) = Acb(0, prec = precision(x))
Base.one(x::AcbRef) = Acb(1, prec = precision(x))
Base.zero(x::ArbRef) = Arb(0, prec = precision(x))
Base.one(x::ArbRef) = Arb(1, prec = precision(x))
# Define these since the base implementation would create `n` copies of the same element
# I.e. only allocating **one** Arf/Arb/Acb.
Base.zeros(x::T, n::Integer) where {T<:Union{Arf,Arb,Acb}} = [zero(x) for _ = 1:n]
Base.ones(x::T, n::Integer) where {T<:Union{Arf,Arb,Acb}} = [one(x) for _ = 1:n]
Base.zeros(x::Type{T}, n::Integer) where {T<:Union{Arf,Arb,Acb}} = [zero(T) for _ = 1:n]
Base.ones(x::Type{T}, n::Integer) where {T<:Union{Arf,Arb,Acb}} = [one(T) for _ = 1:n]

# Irrationals
Mag(::Irrational{:π}) = const_pi!(Mag())

for (irr, suffix) in ((:π, "pi"), (:ℯ, "e"), (:γ, "euler"), (:catalan, "catalan"))
    jlf = Symbol("const_$suffix", "!")
    IrrT = Irrational{irr}
    @eval begin
        Arb(::$IrrT; prec::Integer = DEFAULT_PRECISION[]) = $jlf(Arb(prec = prec))
    end
end

function Arb(::Irrational{:φ}; prec::Integer = DEFAULT_PRECISION[])
    res = Arb(5, prec = prec)
    sqrt!(res, res)
    add!(res, res, 1)
    div!(res, res, 2)
    return res
end


Acb(::Irrational{:π}; prec::Integer = DEFAULT_PRECISION[]) = const_pi!(Acb(prec = prec))
