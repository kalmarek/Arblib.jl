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
for T in (Unsigned, Integer, Base.GMP.CdoubleMax, Mag)
    @eval begin
        function Arf(x::$T; prec::Integer=DEFAULT_PRECISION[])
            res = Arf(prec=prec)
            set!(res, x)
            return res
        end
    end
end

for T in (BigFloat, Arf)
    @eval begin
        function Arf(x::$T; prec::Integer=precision(x))
            res = Arf(prec=prec)
            set!(res, x)
            return res
        end
    end
end

## Arb
for T in (Unsigned, Integer, Base.GMP.CdoubleMax)
    @eval begin
        function Arb(x::$T; prec::Integer=DEFAULT_PRECISION[])
            res = Arb(prec=prec)
            set!(res, x)
            return res
        end
    end
end

for T in (Arf, Arb)
    @eval begin
        function Arb(x::$T; prec::Integer=precision(x))
            res = Arb(prec=prec)
            set!(res, x)
            return res
        end
    end
end

function Arb(str::AbstractString; prec::Integer=DEFAULT_PRECISION[])
    res = Arb(prec=prec)
    flag = set!(res, str)
    iszero(flag) || throw(ArgumentError("could not parse $str as an Arb"))
    return res
end

## Acb
for T in (Unsigned, Integer, Base.GMP.CdoubleMax)
    @eval begin
        function Acb(x::$T; prec::Integer=DEFAULT_PRECISION[])
            res = Acb(prec=prec)
            set!(res, x)
            return res
        end
    end
end

for T in (Arb, Acb)
    @eval begin
        function Acb(x::$T; prec::Integer=precision(x))
            res = Acb(prec=prec)
            set!(res, x)
            return res
        end
    end
end

for T in (Integer, Base.GMP.CdoubleMax)
    @eval begin
        function Acb(re::$T, im::$T; prec::Integer=DEFAULT_PRECISION[])
            res = Acb(prec=prec)
            set!(res, re, im)
            return res
        end

        function Acb(z::Complex{<:$T}; prec::Integer=DEFAULT_PRECISION[])
            res = Acb(prec=prec)
            set!(res, real(z), imag(z))
            return res
        end
    end
end

function Acb(re::Arb, im::Arb; prec::Integer=max(precision(re), precision(im)))
    res = Acb(prec=prec)
    set!(res, re, im)
    return res
end

function Acb(z::Complex{Arb}; prec::Integer=max(precision(real(z)), precision(imag(z))))
    res = Acb(prec=prec)
    set!(res, real(z), imag(z))
    return res
end

Base.zero(::Union{Mag, Type{Mag}}) = Mag(UInt64(0))
Base.one(::Union{Mag, Type{Mag}}) = Mag(UInt64(1))
Base.zero(x::T) where {T <: Union{Arf, Arb, Acb}} = T(0, prec = precision(x))
Base.one(x::T) where {T <: Union{Arf, Arb, Acb}} = T(1, prec = precision(x))

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
        function Arb(::$IrrT; prec::Integer=DEFAULT_PRECISION[])
            res=Arb(prec=prec)
            $jlf(res)
            return res
        end
    end
end

function Acb(::Irrational{:π}; prec::Integer=DEFAULT_PRECISION[])
    res = Acb(prec=prec)
    const_pi!(res)
    return res
end
