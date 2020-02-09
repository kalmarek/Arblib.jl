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
        $ArbT(t::$ArbT, prec::Integer=t.prec) = set!($ArbT(t.prec), t) # copy constructor?

        function $ArbT(si::T, prec::Integer) where T <: Integer
            promote_type(T, Int64) == Int64 && return $ArbT(Int64(si), prec)
            return $ArbT(BigInt(si), prec)
        end

        function $ArbT(d::T, prec::Integer) where T <: AbstractFloat
            promote_type(T, Float64) == Float64 && return $ArbT(Float64(d), prec)
            return $ArbT(BigFloat(d), prec)
        end

        $ArbT(d::Float64, prec::Integer) = set!($ArbT(prec), d)

        if $ArbT != Arf
            $ArbT(si::Int64, prec::Integer) = set!($ArbT(prec), si)
        end

        Base.zero(t::$ArbT) = $ArbT(0, t.prec)
        Base.one(t::$ArbT) = $ArbT(1, t.prec)
    end
end

Arf(x::BigFloat, prec::Integer) = set!(Arf(prec), x)
Arb(x::BigFloat, prec::Integer) = set!(Arb(prec), Arf(x, prec))
Acb(x::BigFloat, prec::Integer) = set!(Acb(prec), Arb(x, prec))

# fallbacks:
Arf(x::Real, prec::Integer) = set!(Arf(prec), BigFloat(x))
Arb(x::Real, prec::Integer) = set!(Arb(prec), Arf(x, prec))
Acb(x::Real, prec::Integer) = set!(Acb(prec), Arb(x, prec))

function Acb(re::Integer, im::Integer, prec::Integer)
    promote_type(T, Int64) == Int64 && return Acb(Int64(re), Int64(im), prec)
    return Acb(BigInt(re), BigInt(im), prec)
end

Acb(re::Int64, im::Int64, prec::Integer) = set!(Acb(prec), re, im)
Acb(re::Float64, im::Float64, prec::Integer) = set!(Acb(prec), re, im)
Acb(re::Arb, im::Arb, prec::Integer=min(re.prec, im.prec)) = set!(Acb(prec), re, im)

function Acb(z::Complex{T}, prec::Integer) where T
    if promote_type(T, Float64) == Float64
        return Acb(Float64(real(z)), Float64(imag(z)), prec)
    end
    return Acb(ArbReal(real(z), prec), ArbReal(imag, prec), prec)
end

#arb_set_str
