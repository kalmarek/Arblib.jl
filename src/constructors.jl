for (T, args) in (
    (Mag, ((Float64, Cdouble, :d), (UInt, Culong, :ui))),
    (
     Arf, (
     (Float64, Cdouble, :d),
     (Mag, Ref{Mag}, :mag),
     (BigFloat, Ref{BigFloat}, :mpfr),
     (Int, Clong, :si),
     (UInt, Culong, :ui)),
    ),
    (
     Arb, (
     (Arf, Ref{Arf}, :arf),
     (Float64, Cdouble, :d),
     (Int, Clong, :si),
     (UInt, Culong, :ui)),
    ),
    (
     Acb, (
     (Arb, Ref{Arb}, :arb),
     (Float64, Cdouble, :d),
     (Int, Clong, :si),
     (UInt, Culong, :ui)),
    ),
)
    arbf = Symbol(cprefix(T), :_set)
    @eval begin
        function set!(res::$T, x::$T)
            ccall(@libarb($arbf), Cvoid, (Ref{$T}, Ref{$T}), res, x)
            return res
        end
    end
    for (jlT, cT, suffix) in args
        arbf = Symbol(cprefix(T), :_set_, suffix)
        @eval begin
            function set!(res::$T, x::$jlT)
                ccall(@libarb($arbf), Cvoid, (Ref{$T}, $cT), res, x)
                return res
            end
        end
    end
end

set!(res::Arb, str::AbstractString) =
    ccall(@libarb(arb_set_str), Cint, (Ref{Arb}, Cstring, Int), res, str, precision(res))

for (jlT, cT, suffix) in (
    (Arb, Ref{Arb}, :arb_arb),
    (Float64, Cdouble, :d_d),
    (Int, Clong, :si_si),
)
    T = Acb
    arbf = Symbol(cprefix(T), :_set_, suffix)
    @eval begin
        function set!(res::$T, re::$jlT, im::$jlT)
            ccall(@libarb($arbf), Cvoid, (Ref{$T}, $cT, $cT), res, re, im)
            return res
        end
    end
end

for ArbT in (:Arf, :Arb, :Acb, :Mag)
    @eval begin
        function $ArbT(t::$ArbT; prec::Integer=precision(t))
            res = $ArbT(prec=prec)
            set!(res, t)
        end

        function $ArbT(si::T; prec::Integer=DEFAULT_PRECISION[]) where T <: Integer
            promote_type(T, Int64) == Int64 && return $ArbT(Int64(si), prec)
            return $ArbT(BigInt(si), prec)
        end

        function $ArbT(d::T; prec::Integer=DEFAULT_PRECISION[]) where T <: AbstractFloat
            promote_type(T, Float64) == Float64 && return $ArbT(Float64(d), prec)
            return $ArbT(BigFloat(d), prec)
        end

        function $ArbT(d::Base.GMP.CdoubleMax; prec::Integer=DEFAULT_PRECISION[])
            res = $ArbT(prec=prec)
            set!(res, d)
            return res
        end

        if $ArbT != Arf
            function $ArbT(si::Base.GMP.ClongMax; prec::Integer=DEFAULT_PRECISION[])
                res = $ArbT(prec=prec)
                set!(res, si)
                return res
            end
        end

        Base.zero(t::$ArbT) = $ArbT(0; prec = precision(t))
        Base.one(t::$ArbT) = $ArbT(1; prec = precision(t))
    end
end

function Arf(x::BigFloat; prec::Integer=precision(x))
    res = Arf(prec=prec)
    set!(res, x)
    return res
end
function Arb(x::BigFloat; prec::Integer=precision(x))
    res = Arb(prec=prec)
    set!(res, Arf(x, prec=prec))
    return res
end
function Acb(x::BigFloat; prec::Integer=precision(x))
    res = Acb(prec=prec)
    set!(res, Arb(x, prec=prec))
    return res
end

# fallbacks:
Arf(x::Real; prec::Integer=DEFAULT_PRECISION[]) = Arf(BigFloat(x); prec=prec)
Arb(x::Real; prec::Integer=DEFAULT_PRECISION[]) = Arb(Arf(x, prec=prec))
Acb(x::Real; prec::Integer=DEFAULT_PRECISION[]) = Acb(Arb(x, prec=prec))

# string input
function Arb(str::AbstractString; prec::Integer=DEFAULT_PRECISION[])
    res = Arb(prec=prec)
    flag = set!(res, str)
    iszero(flag) || throw(ArgumentError("arblib could not parse $str as an Arb"))
    return res
end

function Acb(re::T, im::T; prec::Integer=DEFAULT_PRECISION[]) where T<:Integer
    promote_type(T, Int64) == Int64 && return Acb(Int64(re), Int64(im), prec=prec)
    return Acb(BigInt(re), BigInt(im), prec=prec)
end

for T in (Integer, Base.GMP.CdoubleMax, Arb)
    @eval begin
        function Acb(re::$T, im::$T; prec::Integer=DEFAULT_PRECISION[])
            res = Acb(prec=prec)
            set!(res, re, im)
            return res
        end
    end
end

function Acb(z::Complex{T}; prec::Integer=DEFAULT_PRECISION[]) where T
    if promote_type(T, Float64) == Float64
        return Acb(Float64(real(z)), Float64(imag(z)), prec=prec)
    end
    return Acb(ArbReal(real(z), prec=prec), ArbReal(imag, prec=prec), prec=prec)
end

# Irrationals
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
