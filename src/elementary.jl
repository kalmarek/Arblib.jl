### Mag
rsqrt(x::MagOrRef) = rsqrt!(zero(x), x)
Base.hypot(x::MagOrRef, y::MagOrRef) = hypot!(zero(x), x, y)
root(x::MagOrRef, n::Integer) = root!(zero(x), x, convert(UInt, n))
neglog(x::MagOrRef) = neg_log!(zero(x), x)
expinv(x::MagOrRef) = expinv!(zero(x), x)
for f in [:sqrt, :log, :log1p, :exp, :expm1, :atan, :cosh, :sinh]
    @eval Base.$f(x::MagOrRef) = $(Symbol(f, :!))(zero(x), x)
end

### Arf
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
Base.hypot(x::ArbOrRef, y::ArbOrRef) = hypot!(Arb(prec = _precision(x, y)), x, y)

root(x::Union{ArbOrRef,AcbOrRef}, k::Integer) = root!(zero(x), x, convert(UInt, k))

# Unary methods in Base
for f in [
    :sqrt,
    :log,
    :log1p,
    :exp,
    :expm1,
    :sin,
    :cos,
    :tan,
    :cot,
    :sec,
    :csc,
    :atan,
    :asin,
    :acos,
    :sinh,
    :cosh,
    :tanh,
    :coth,
    :sech,
    :csch,
    :atanh,
    :asinh,
    :acosh,
]
    @eval Base.$f(x::Union{ArbOrRef,AcbOrRef}) = $(Symbol(f, :!))(zero(x), x)
end

sqrtpos(x::ArbOrRef) = sqrtpos!(zero(x), x)
sqrt1pm1(x::ArbOrRef) = sqrt1pm1!(zero(x), x)
rsqrt(x::Union{ArbOrRef,AcbOrRef}) = rsqrt!(zero(x), x)

Base.sinpi(x::Union{ArbOrRef,AcbOrRef}) = sin_pi!(zero(x), x)
Base.cospi(x::Union{ArbOrRef,AcbOrRef}) = cos_pi!(zero(x), x)
tanpi(x::Union{ArbOrRef,AcbOrRef}) = tan_pi!(zero(x), x)
cotpi(x::Union{ArbOrRef,AcbOrRef}) = cot_pi!(zero(x), x)
cscpi(x::Union{ArbOrRef,AcbOrRef}) = csc_pi!(zero(x), x)
# Julias definition of sinc is equivalent to Arbs definition of sincpi
Base.sinc(x::Union{ArbOrRef,AcbOrRef}) = sinc_pi!(zero(x), x)
Base.atan(y::ArbOrRef, x::ArbOrRef) = atan2!(Arb(prec = _precision(y, x)), y, x)

function Base.sincos(x::Union{ArbOrRef,AcbOrRef})
    s, c = zero(x), zero(x)
    sin_cos!(s, c, x)
    return (s, c)
end
function Base.sincospi(x::Union{ArbOrRef,AcbOrRef})
    s, c = zero(x), zero(x)
    sin_cos_pi!(s, c, x)
    return (s, c)
end
function sinhcosh(x::Union{ArbOrRef,AcbOrRef})
    s, c = zero(x), zero(x)
    sinh_cosh!(s, c, x)
    return (s, c)
end
