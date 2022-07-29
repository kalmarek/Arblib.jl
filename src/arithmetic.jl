const _BitInteger = (Int == Int64 ? Base.BitInteger64 : Base.BitInteger32)
const _BitSigned = (Int == Int64 ? Base.BitSigned64 : Base.BitSigned32)
const _BitUnsigned = (Int == Int64 ? Base.BitUnsigned64 : Base.BitUnsigned32)

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

Base.min(x::MagOrRef, y::MagOrRef) = Arblib.min!(zero(x), x, y)
Base.max(x::MagOrRef, y::MagOrRef) = Arblib.max!(zero(x), x, y)
Base.minmax(x::MagOrRef, y::MagOrRef) = (min(x, y), max(x, y))

### Arf
function Base.sign(x::ArfOrRef)
    isnan(x) && return Arf(NaN) # Follow Julia and return NaN
    return Arf(sgn(x))
end

Base.abs(x::ArfOrRef) = abs!(zero(x), x)
Base.:(-)(x::ArfOrRef) = neg!(zero(x), x)
for (jf, af) in [(:+, :add!), (:-, :sub!), (:*, :mul!), (:/, :div!)]
    @eval function Base.$jf(x::ArfOrRef, y::Union{ArfOrRef,_BitInteger})
        z = Arf(prec = _precision(x, y))
        $af(z, x, y)
        return z
    end
end
function Base.:+(x::_BitInteger, y::ArfOrRef)
    z = zero(y)
    add!(z, y, x)
    return z
end
function Base.:*(x::_BitInteger, y::ArfOrRef)
    z = zero(y)
    mul!(z, y, x)
    return z
end
function Base.:/(x::_BitUnsigned, y::ArfOrRef)
    z = zero(y)
    ui_div!(z, x, y)
    return z
end
function Base.:/(x::_BitSigned, y::ArfOrRef)
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

Base.min(x::ArfOrRef, y::ArfOrRef) = Arblib.min!(zero(x), x, y)
Base.max(x::ArfOrRef, y::ArfOrRef) = Arblib.max!(zero(x), x, y)
Base.minmax(x::ArfOrRef, y::ArfOrRef) = (min(x, y), max(x, y))

### Arb and Acb
for (jf, af) in [(:+, :add!), (:-, :sub!), (:*, :mul!), (:/, :div!)]
    @eval Base.$jf(x::ArbOrRef, y::Union{ArbOrRef,ArfOrRef,_BitInteger}) =
        $af(Arb(prec = _precision(x, y)), x, y)
    @eval Base.$jf(x::AcbOrRef, y::Union{AcbOrRef,ArbOrRef,_BitInteger}) =
        $af(Acb(prec = _precision(x, y)), x, y)
    if jf == :(+) || jf == :(*)
        @eval Base.$jf(x::Union{ArfOrRef,_BitInteger}, y::ArbOrRef) =
            $af(Arb(prec = _precision(x, y)), y, x)
        @eval Base.$jf(x::Union{ArbOrRef,_BitInteger}, y::AcbOrRef) =
            $af(Acb(prec = _precision(x, y)), y, x)
    end
end

Base.:(-)(x::Union{ArbOrRef,AcbOrRef}) = neg!(zero(x), x)
Base.abs(x::ArbOrRef) = abs!(zero(x), x)
Base.:(/)(x::_BitUnsigned, y::ArbOrRef) = ui_div!(zero(y), x, y)

Base.:(^)(x::ArbOrRef, y::ArbOrRef) = pow!(Arb(prec = _precision(x, y)), x, y)
function Base.:(^)(x::ArbOrRef, y::_BitInteger)
    z = zero(x)
    x, n = (y >= 0 ? (x, y) : (inv!(z, x), -y))
    return pow!(z, x, convert(UInt, n))
end
Base.:(^)(x::AcbOrRef, y::Union{AcbOrRef,ArbOrRef,_BitInteger}) =
    pow!(Acb(prec = _precision(x, y)), x, y)

# We define the same special cases as Arb does, this avoids some
# overhead
Base.literal_pow(::typeof(^), x::Union{ArbOrRef,AcbOrRef}, ::Val{-2}) =
    (y = inv(x); sqr!(y, y))
#Base.literal_pow(::typeof(^), x::Union{ArbOrRef,AcbOrRef}, ::Val{-1}) - implemented in Base.intfuncs.jl
Base.literal_pow(::typeof(^), x::Union{ArbOrRef,AcbOrRef}, ::Val{0}) = one(x)
Base.literal_pow(::typeof(^), x::Union{ArbOrRef,AcbOrRef}, ::Val{1}) = copy(x)
Base.literal_pow(::typeof(^), x::Union{ArbOrRef,AcbOrRef}, ::Val{2}) = sqr(x)

Base.hypot(x::ArbOrRef, y::ArbOrRef) = hypot!(Arb(prec = _precision(x, y)), x, y)

root(x::Union{ArbOrRef,AcbOrRef}, k::Integer) = root!(zero(x), x, convert(UInt, k))

# Unary methods in Base
for f in [
    :inv,
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
sqr(x::Union{ArbOrRef,AcbOrRef}) = sqr!(zero(x), x)

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

Base.min(x::ArbOrRef, y::ArbOrRef) = Arblib.min!(zero(x), x, y)
Base.max(x::ArbOrRef, y::ArbOrRef) = Arblib.max!(zero(x), x, y)
Base.minmax(x::ArbOrRef, y::ArbOrRef) = (min(x, y), max(x, y))

### Acb
function Base.:(*)(x::AcbOrRef, y::Complex{Bool})
    if real(y)
        if imag(y)
            z = mul_onei!(zero(x), x)
            return add!(z, x, z)
        else
            return Acb(x)
        end
    end
    imag(y) && return mul_onei!(zero(x), x)
    return zero(x)
end
Base.:(*)(x::Complex{Bool}, y::AcbOrRef) = y * x

Base.real(z::AcbLike; prec = _precision(z)) = get_real!(Arb(; prec), z)
Base.imag(z::AcbLike; prec = _precision(z)) = get_imag!(Arb(; prec), z)
Base.conj(z::AcbLike) = conj!(Acb(prec = _precision(z)), z)
Base.abs(z::AcbLike) = abs!(Arb(prec = _precision(z)), z)

### minimum and maximum
# The default implemented in Julia have several issues for Arb types.
# See https://github.com/JuliaLang/julia/issues/45932.
# Note that it works fine for Mag and Arf.

# Before 1.8.0 there is no way to fix the implementation in Base.
# Instead we define a new method. Note that this doesn't fully fix the
# problem, there is no way to dispatch on for example
# minimum(x -> Arb(x), [1, 2, 3, 4]) or an array with only some Arb.
if VERSION < v"1.8.0-rc3"
    function Base.minimum(A::AbstractArray{<:ArbOrRef})
        isempty(A) &&
            throw(ArgumentError("reducing over an empty collection is not allowed"))
        res = copy(first(A))
        for x in Iterators.drop(A, 1)
            Arblib.min!(res, res, x)
        end
        return res
    end

    function Base.maximum(A::AbstractArray{<:ArbOrRef})
        isempty(A) &&
            throw(ArgumentError("reducing over an empty collection is not allowed"))
        res = copy(first(A))
        for x in Iterators.drop(A, 1)
            Arblib.max!(res, res, x)
        end
        return res
    end
end

# Since 1.8.0 it is possible to fix the Base implementation by
# overloading some internal methods. This also works before 1.8.0 but
# doesn't solve the full problem.

# The default implementation in Base is not correct for Arb
Base._fast(::typeof(min), x::Arb, y::Arb) = min(x, y)
Base._fast(::typeof(min), x::Arb, y) = min(x, y)
Base._fast(::typeof(min), x, y::Arb) = min(x, y)
Base._fast(::typeof(max), x::Arb, y::Arb) = max(x, y)
Base._fast(::typeof(max), x::Arb, y) = max(x, y)
Base._fast(::typeof(max), x, y::Arb) = max(x, y)

# Mag, Arf and Arb don't have signed zeros
Base.isbadzero(::typeof(min), x::Union{Mag,Arf,Arb}) = false
Base.isbadzero(::typeof(max), x::Union{Mag,Arf,Arb}) = false
