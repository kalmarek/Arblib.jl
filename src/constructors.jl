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

function set!(res::Arb, str::AbstractString)
    flag = ccall(@libarb(arb_set_str), Cint, (Ref{Arb}, Cstring, Int), res, str, precision(res))
    iszero(flag) || throw(ArgumentError("arblib could not parse $str as an Arb"))
    return res
end

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
        $ArbT(t::$ArbT; prec::Integer=precision(t)) = set!($ArbT(prec=prec), t)

        function $ArbT(si::T; prec::Integer=DEFAULT_PRECISION[]) where T <: Integer
            promote_type(T, Int64) == Int64 && return $ArbT(Int64(si), prec)
            return $ArbT(BigInt(si), prec)
        end

        function $ArbT(d::T; prec::Integer=DEFAULT_PRECISION[]) where T <: AbstractFloat
            promote_type(T, Float64) == Float64 && return $ArbT(Float64(d), prec)
            return $ArbT(BigFloat(d), prec)
        end

        $ArbT(d::Float64; prec::Integer=DEFAULT_PRECISION[]) = set!($ArbT(prec=prec), d)

        if $ArbT != Arf
            $ArbT(si::Int64; prec::Integer=DEFAULT_PRECISION[]) = set!($ArbT(prec=prec), si)
        end

        Base.zero(t::$ArbT) = $ArbT(0; prec = precision(t))
        Base.one(t::$ArbT) = $ArbT(1; prec = precision(t))
    end
end

Arf(x::BigFloat; prec::Integer=precision(x)) = set!(Arf(prec=prec), x)
Arb(x::BigFloat; prec::Integer=precision(x)) = set!(Arb(prec=prec), Arf(x, prec=prec))
Acb(x::BigFloat; prec::Integer=precision(x)) = set!(Acb(prec=prec), Arb(x, prec=prec))

# fallbacks:
Arf(x::Real; prec::Integer=DEFAULT_PRECISION[]) = set!(Arf(prec=prec), BigFloat(x))
Arb(x::Real; prec::Integer=DEFAULT_PRECISION[]) = set!(Arb(prec=prec), Arf(x, prec=prec))
Acb(x::Real; prec::Integer=DEFAULT_PRECISION[]) = set!(Acb(prec=prec), Arb(x, prec=prec))

# string input
Arb(str::AbstractString; prec::Integer=DEFAULT_PRECISION[]) = set!(Arb(prec=prec), str)

function Acb(re::Integer, im::Integer; prec::Integer=DEFAULT_PRECISION[])
    promote_type(T, Int64) == Int64 && return Acb(Int64(re), Int64(im), prec=prec)
    return Acb(BigInt(re), BigInt(im), prec=prec)
end

Acb(re::Int64, im::Int64; prec::Integer=DEFAULT_PRECISION[]) = set!(Acb(prec=prec), re, im)
Acb(re::Float64, im::Float64; prec::Integer=DEFAULT_PRECISION[]) = set!(Acb(prec=prec), re, im)
Acb(re::Arb, im::Arb; prec::Integer=min(precision(re), precision(im))) = set!(Acb(prec=prec), re, im)

function Acb(z::Complex{T}; prec::Integer=DEFAULT_PRECISION[]) where T
    if promote_type(T, Float64) == Float64
        return Acb(Float64(real(z)), Float64(imag(z)), prec=prec)
    end
    return Acb(ArbReal(real(z), prec=prec), ArbReal(imag, prec=prec), prec=prec)
end

# Irrationals
for (irr, suffix) in ((:π, "pi"), (:ℯ, "e"), (:γ, "euler"))
    arbf = Symbol("arb_const_", suffix)
    jlf = Symbol("const_$suffix", "!")
    IrrT = Irrational{irr}
    @eval begin
        function $(jlf)(res::Arb)
            ccall(@libarb($arbf), Cvoid, (Ref{Arb}, Clong,), res, precision(res))
            return res
        end
        Arb(::$IrrT; prec::Integer=DEFAULT_PRECISION[])= $jlf(Arb(prec=prec))
    end
end

Acb(::Irrational{:π}; prec::Integer=DEFAULT_PRECISION[]) = const_pi!(Acb(prec=prec))

function const_pi!(res::Acb)
    ccall(@libarb(acb_const_pi), Cvoid, (Ref{Acb}, Clong,), res, precision(res=prec))
    return res
end
