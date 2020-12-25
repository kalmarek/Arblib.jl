### Mag
for (jf, af) in [(:+, :add!), (:-, :sub!), (:*, :mul!), (:/, :div!)]
    @eval Base.$jf(x::MagOrRef, y::MagOrRef) = $af(zero(x), x, y)
end
Base.:+(x::MagOrRef, y::Integer) = add!(zero(x), x, convert(UInt, y))
Base.:+(x::Integer, y::MagOrRef) = add!(zero(y), y, convert(UInt, x))
Base.:*(x::MagOrRef, y::Integer) = mul!(zero(x), x, convert(UInt, y))
Base.:*(x::Integer, y::MagOrRef) = mul!(zero(y), y, convert(UInt, x))
Base.:/(x::MagOrRef, y::Integer) = div!(zero(x), x, convert(UInt, y))

Base.:(^)(x::MagOrRef, e::Integer) = pow!(zero(x), x, convert(UInt, e))
rsqrt(x::MagOrRef) = rsqrt!(zero(x), x)
Base.hypot(x::MagOrRef, y::MagOrRef) = hypot!(zero(x), x, y)
root(x::MagOrRef, n::Integer) = root!(zero(x), x, convert(UInt, n))
neglog(x::MagOrRef) = neg_log!(zero(x), x)
expinv(x::MagOrRef) = expinv!(zero(x), x)
for f in [:inv, :sqrt, :log, :log1p, :exp, :expm1, :atan, :cosh, :sinh]
    @eval Base.$f(x::MagOrRef) = $(Symbol(f, :!))(zero(x), x)
end

Base.min(x::MagOrRef, y::MagOrRef) = min!(zero(x), x, y)
Base.max(x::MagOrRef, y::MagOrRef) = max!(zero(x), x, y)
Base.minmax(x::MagOrRef, y::MagOrRef) = (min(x, y), max(x, y))

### Arf
function Base.sign(x::ArfOrRef)
    isnan(x) && return Arf(NaN) # Follow Julia and return NaN
    return Arf(sgn(x))
end
Base.min(x::ArfOrRef, y::ArfOrRef) = min!(Arf(prec = _precision((x, y))), x, y)
Base.max(x::ArfOrRef, y::ArfOrRef) = max!(Arf(prec = _precision((x, y))), x, y)
Base.minmax(x::ArfOrRef, y::ArfOrRef) = (min(x, y), max(x, y))

Base.abs(x::ArfOrRef) = abs!(zero(x), x)
Base.:(-)(x::ArfOrRef) = neg!(zero(x), x)
for (jf, af) in [(:+, :add!), (:-, :sub!), (:*, :mul!), (:/, :div!)]
    @eval function Base.$jf(x::ArfOrRef, y::Union{ArfOrRef,UInt,Int})
        z = Arf(prec = _precision((x, y)))
        $af(z, x, y)
        return z
    end
end
function Base.:+(x::Union{UInt,Int}, y::ArfOrRef)
    z = zero(y)
    add!(z, y, x)
    return z
end
function Base.:*(x::Union{UInt,Int}, y::ArfOrRef)
    z = zero(y)
    mul!(z, y, x)
    return z
end
function Base.:/(x::UInt, y::ArfOrRef)
    z = zero(y)
    ui_div!(z, x, y)
    return z
end
function Base.:/(x::Int, y::ArfOrRef)
    z = zero(y)
    si_div!(z, x, y)
    return z
end

function Base.sqrt(x::ArfOrRef)
    y = zero(x)
    sqrt!(y, x)
    return y
end
function rsqrt(x::ArfOrRef)
    y = zero(x)
    rsqrt!(y, x)
    return y
end
function root(x::ArfOrRef, k::Integer)
    y = zero(x)
    root!(y, x, convert(UInt, k))
    return y
end

### Arb and Acb
for (jf, af) in [(:+, :add!), (:-, :sub!), (:*, :mul!), (:/, :div!)]
    @eval Base.$jf(x::ArbOrRef, y::Union{ArbOrRef,ArfOrRef,Int,UInt}) =
        $af(Arb(prec = _precision((x, y))), x, y)
    @eval Base.$jf(x::AcbOrRef, y::Union{AcbOrRef,ArbOrRef,ArfOrRef,Int,UInt}) =
        $af(Acb(prec = _precision((x, y))), x, y)
    if jf == :(+) || jf == :(*)
        @eval Base.$jf(x::Union{ArfOrRef,Int,UInt}, y::ArbOrRef) =
            $af(Arb(prec = _precision((x, y))), y, x)
        @eval Base.$jf(x::Union{ArbOrRef,ArfOrRef,Int,UInt}, y::AcbOrRef) =
            $af(Acb(prec = _precision((x, y))), y, x)
    end
end

function Base.:(^)(x::T, k::Integer) where {T<:Union{Arb,ArbRef,Acb,AcbRef}}
    z = T(prec = precision(x))
    pow!(z, x, convert(UInt, k))
    z
end

for f in [
    :sqrt,
    :exp,
    :expm1,
    :log,
    :log1p,
    :sin,
    :cos,
    :tan,
    :cot,
    :asin,
    :acos,
    :atan,
    :acot,
    :sinc,
    :sinh,
    :cosh,
    :tanh,
    :asinh,
    :acosh,
    :atanh,
    :sec,
    :asec,
    :sech,
    :asech,
]
    @eval function Base.$f(x::T) where {T<:Union{Arb,ArbRef,Acb,AcbRef}}
        z = T(prec = precision(x))
        $(Symbol(f, :!))(z, x)
        z
    end
end

Base.real(z::AcbLike; prec = _precision(z)) = get_real!(Arb(prec = prec), z)
Base.imag(z::AcbLike; prec = _precision(z)) = get_imag!(Arb(prec = prec), z)
Base.conj(z::AcbLike) = conj!(Acb(prec = _precision(z)), z)
Base.abs(z::AcbLike) = abs!(Arb(prec = _precision(z)), z)
