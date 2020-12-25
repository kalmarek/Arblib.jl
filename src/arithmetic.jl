### Mag
for (jf, af) in [(:+, :add!), (:-, :sub!), (:*, :mul!), (:/, :div!)]
    @eval Base.$jf(x::MagOrRef, y::MagOrRef) = $af(zero(x), x, y)
end
Base.:+(x::MagOrRef, y::Integer) = add!(zero(x), x, convert(UInt, y))
Base.:+(x::Integer, y::MagOrRef) = add!(zero(y), y, convert(UInt, x))
Base.:*(x::MagOrRef, y::Integer) = mul!(zero(x), x, convert(UInt, y))
Base.:*(x::Integer, y::MagOrRef) = mul!(zero(y), y, convert(UInt, x))
Base.:/(x::MagOrRef, y::Integer) = div!(zero(x), x, convert(UInt, y))

Base.inv(x::MagOrRef) = inv!(zero(x), x)
Base.:(^)(x::MagOrRef, e::Integer) = pow!(zero(x), x, convert(UInt, e))
Base.sqrt(x::MagOrRef) = sqrt!(zero(x), x)
rsqrt(x::MagOrRef) = rsqrt!(zero(x), x)
Base.hypot(x::MagOrRef, y::MagOrRef) = hypot!(zero(x), x, y)
root(x::MagOrRef, n::Integer) = root!(zero(x), x, convert(UInt, n))
Base.log(x::MagOrRef) = log!(zero(x), x)
neglog(x::MagOrRef) = neg_log!(zero(x), x)
Base.log1p(x::MagOrRef) = log1p!(zero(x), x)
Base.exp(x::MagOrRef) = exp!(zero(x), x)
expinv(x::MagOrRef) = expinv!(zero(x), x)
Base.expm1(x::MagOrRef) = expm1!(zero(x), x)
Base.atan(x::MagOrRef) = atan!(zero(x), x)
Base.cosh(x::MagOrRef) = cosh!(zero(x), x)
Base.sinh(x::MagOrRef) = sinh!(zero(x), x)

Base.min(x::MagOrRef, y::MagOrRef) = min!(zero(x), x, y)
Base.max(x::MagOrRef, y::MagOrRef) = max!(zero(x), x, y)
Base.minmax(x::MagOrRef, y::MagOrRef) = (min(x, y), max(x, y))

### Arf, Arb and Acb
for (jf, af) in [(:+, :add!), (:-, :sub!), (:*, :mul!), (:/, :div!)]
    @eval function Base.$jf(x::T, y::T) where {T<:Union{Arf,ArfRef,Arb,ArbRef,Acb,AcbRef}}
        z = T(prec = max(precision(x), precision(y)))
        $af(z, x, y)
        z
    end
end
function Base.:(-)(x::T) where {T<:Union{Arf,ArfRef,Arb,ArbRef,Acb,AcbRef}}
    z = T(prec = precision(x))
    neg!(z, x)
    z
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
