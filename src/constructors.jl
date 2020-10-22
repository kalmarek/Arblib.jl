## Mag
for T in (Unsigned, Base.GMP.CdoubleMax)
    @eval begin
        function Mag(x::$T)
            res = Mag()
            set!(res, x)
            return res
        end
    end
end

## Arf
for T in (arf_struct, Unsigned, Integer, Base.GMP.CdoubleMax, Mag)
    @eval begin
        function Arf(x::$T; prec::Integer = DEFAULT_PRECISION[])
            res = Arf(prec = prec)
            set!(res, x)
            return res
        end
    end
end

function Arf(x::BigFloat; prec::Integer = precision(x))
    res = Arf(prec = prec)
    set!(res, x)
    return res
end

function Arf(x::Arf; prec::Integer = precision(x))
    return Arf(x.arf, prec = prec)
end

## Arb
for T in (arb_struct, Unsigned, Integer, Base.GMP.CdoubleMax)
    @eval begin
        function Arb(x::$T; prec::Integer = DEFAULT_PRECISION[])
            res = Arb(prec = prec)
            set!(res, x)
            return res
        end
    end
end

function Arb(x::Arf; prec::Integer = precision(x))
    res = Arb(prec = prec)
    set!(res, x)
    return res
end

function Arb(x::Arb; prec::Integer = precision(x))
    return Arb(x.arb, prec = prec)
end

function Arb(str::AbstractString; prec::Integer = DEFAULT_PRECISION[])
    res = Arb(prec = prec)
    flag = set!(res, str)
    iszero(flag) || throw(ArgumentError("could not parse $str as an Arb"))
    return res
end

function Arb(x::Rational; prec::Integer = DEFAULT_PRECISION[])
    num = Arb(numerator(x); prec = prec)
    div!(num, num, denominator(x))
    return num
end

Arb(x::Real; prec::Integer = _precision(x)) = Arb(Arf(x, prec=prec))

## Acb
for T in (acb_struct, Unsigned, Integer, Base.GMP.CdoubleMax)
    @eval begin
        function Acb(x::$T; prec::Integer = DEFAULT_PRECISION[])
            res = Acb(prec = prec)
            set!(res, x)
            return res
        end
    end
end
function Acb(x::Arf; prec::Integer = precision(x))
    res = Acb(prec = prec)
    set!(realref(res), x)
    return res
end

function Acb(x::Arb; prec::Integer = precision(x))
    res = Acb(prec = prec)
    set!(res, x)
    return res
end

function Acb(x::Acb; prec::Integer = precision(x))
    return Acb(x.acb, prec = prec)
end

for T in (Integer, Base.GMP.CdoubleMax)
    @eval begin
        function Acb(re::$T, im::$T; prec::Integer = DEFAULT_PRECISION[])
            res = Acb(prec = prec)
            set!(res, re, im)
            return res
        end

        function Acb(z::Complex{<:$T}; prec::Integer = DEFAULT_PRECISION[])
            res = Acb(prec = prec)
            set!(res, real(z), imag(z))
            return res
        end
    end
end

function Acb(x::Rational; prec::Integer = DEFAULT_PRECISION[])
    Acb(Arb(x; prec = prec); prec = prec)
end

Acb(x::Real; prec::Integer = _precision(x)) = Acb(Arb(x, prec=prec))

function Acb(re::Arb, im::Arb; prec::Integer = max(precision(re), precision(im)))
    res = Acb(prec = prec)
    set!(res, re, im)
    return res
end

function Acb(z::Complex{Arb}; prec::Integer = max(precision(real(z)), precision(imag(z))))
    res = Acb(prec = prec)
    set!(res, real(z), imag(z))
    return res
end

Acb(re::Real, im::Real; prec::Integer = max(_precision(re), _precision(im))) =
    Acb(Arb(re, prec=prec), Arb(im, prec=prec))

Acb(z::Complex; prec::Integer = max(_precision(real(z)), _precision(imag(z)))) =
    Acb(real(z), imag(z), prec=prec)

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

set!(z::Union{Acb,AcbRef,Ptr{acb_struct},acb_struct}, x::Complex{<:Base.GMP.CdoubleMax}) =
    set!(z, real(x), imag(x))

function set!(z::ArbLike, x::Rational)
    z[] = numerator(x)
    div!(z, z, denominator(x))
end

function set!(z::AcbLike, x::Union{Rational,Complex{<:Rational}})
    set!(realref(z), real(x))
    set!(imagref(z), imag(x))
    z
end

# Irrationals
function Mag(::Irrational{:π})
    res = Mag()
    const_pi!(res)
    return res
end

for (irr, suffix) in ((:π, "pi"), (:ℯ, "e"), (:γ, "euler"))
    jlf = Symbol("const_$suffix", "!")
    IrrT = Irrational{irr}
    @eval begin
        function Arb(::$IrrT; prec::Integer = DEFAULT_PRECISION[])
            res = Arb(prec = prec)
            $jlf(res)
            return res
        end
    end
end

function Acb(::Irrational{:π}; prec::Integer = DEFAULT_PRECISION[])
    res = Acb(prec = prec)
    const_pi!(res)
    return res
end
