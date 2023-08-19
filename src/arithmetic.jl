const _BitInteger = (Int == Int64 ? Base.BitInteger64 : Base.BitInteger32)
const _BitSigned = (Int == Int64 ? Base.BitSigned64 : Base.BitSigned32)
const _BitUnsigned = (Int == Int64 ? Base.BitUnsigned64 : Base.BitUnsigned32)

### +, -, *, /
for (jf, af) in [(:+, :add!), (:-, :sub!), (:*, :mul!), (:/, :div!)]
    @eval Base.$jf(x::MagOrRef, y::MagOrRef) = $af(zero(x), x, y)

    @eval function Base.$jf(x::ArfOrRef, y::Union{ArfOrRef,_BitInteger})
        z = Arf(prec = _precision(x, y))
        $af(z, x, y)
        return z
    end

    @eval Base.$jf(x::ArbOrRef, y::Union{ArbOrRef,ArfOrRef,_BitInteger}) =
        $af(Arb(prec = _precision(x, y)), x, y)

    @eval Base.$jf(x::AcbOrRef, y::Union{AcbOrRef,ArbOrRef,_BitInteger}) =
        $af(Acb(prec = _precision(x, y)), x, y)

    # Avoid one allocation for operations on irrationals
    @eval function Base.$jf(x::Union{ArbOrRef,AcbOrRef}, y::Irrational)
        z = zero(x)
        z[] = y
        return $af(z, x, z)
    end

    if jf == :+ || jf == :*
        # Addition and multiplication is commutative
        @eval Base.$jf(x::_BitInteger, y::ArfOrRef) = $jf(y, x)

        @eval Base.$jf(x::Union{ArfOrRef,_BitInteger,Irrational}, y::ArbOrRef) = $jf(y, x)

        @eval Base.$jf(x::Union{ArbOrRef,_BitInteger,Irrational}, y::AcbOrRef) = $jf(y, x)
    else
        @eval function Base.$jf(x::Irrational, y::Union{ArbOrRef,AcbOrRef})
            z = zero(y)
            z[] = x
            return $af(z, z, y)
        end
    end
end

Base.:-(x::Union{ArfOrRef,ArbOrRef,AcbOrRef}) = neg!(zero(x), x)
Base.inv(x::Union{MagOrRef,ArbOrRef,AcbOrRef}) = inv!(zero(x), x)

Base.:+(x::MagOrRef, y::Integer) = add!(zero(x), x, convert(UInt, y))
Base.:+(x::Integer, y::MagOrRef) = y + x
Base.:*(x::MagOrRef, y::Integer) = mul!(zero(x), x, convert(UInt, y))
Base.:*(x::Integer, y::MagOrRef) = y * x
Base.:/(x::MagOrRef, y::Integer) = div!(zero(x), x, convert(UInt, y))

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

Base.:(/)(x::_BitUnsigned, y::ArbOrRef) = ui_div!(zero(y), x, y)

function Base.:*(x::AcbOrRef, y::Complex{Bool})
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
Base.:*(x::Complex{Bool}, y::AcbOrRef) = y * x

### fma and muladd
function Base.fma(x::ArfOrRef, y::ArfOrRef, z::ArfOrRef)
    res = zero(x)
    fma!(res, x, y, z)
    return res
end
Base.fma(x::ArbOrRef, y::ArbOrRef, z::ArbOrRef) = fma!(zero(x), x, y, z)
Base.fma(x::ArbOrRef, y::Union{_BitInteger,ArfOrRef}, z::ArbOrRef) = fma!(zero(x), x, y, z)
Base.fma(x::Union{_BitInteger,ArfOrRef}, y::ArbOrRef, z::ArbOrRef) = fma(y, x, z)

Base.muladd(x::ArfOrRef, y::ArfOrRef, z::ArfOrRef) = fma(x, y, z)
Base.muladd(x::ArbOrRef, y::ArbOrRef, z::ArbOrRef) = fma(x, y, z)
Base.muladd(x::ArbOrRef, y::Union{_BitInteger,ArfOrRef}, z::ArbOrRef) = fma(x, y, z)
Base.muladd(x::Union{_BitInteger,ArfOrRef}, y::ArbOrRef, z::ArbOrRef) = fma(x, y, z)

### signbit, sign and abs
Base.signbit(x::MagOrRef) = false
Base.signbit(x::ArfOrRef) = !isnan(x) && sgn(x) < 0
Base.signbit(x::ArbOrRef) = isnegative(x)

# For Arf sign of NaN is undefined, we follow Julia and return NaN
Base.sign(x::MagOrRef) = iszero(x) ? zero(x) : one(x)
Base.sign(x::ArfOrRef) = isnan(x) ? nan!(zero(x)) : Arf(sgn(x), prec = _precision(x))
Base.sign(x::Union{ArbOrRef,AcbRef}) = sgn!(zero(x), x)

Base.abs(x::MagOrRef) = copy(x)
Base.abs(x::Union{ArfOrRef,ArbOrRef}) = abs!(zero(x), x)
Base.abs(z::AcbOrRef) = abs!(Arb(prec = _precision(z)), z)

### ^

Base.:^(x::MagOrRef, e::Integer) = pow!(zero(x), x, convert(UInt, e))
Base.:^(x::ArbOrRef, y::ArbOrRef) = pow!(Arb(prec = _precision(x, y)), x, y)
function Base.:^(x::ArbOrRef, y::_BitInteger)
    z = zero(x)
    x, n = (y >= 0 ? (x, y) : (inv!(z, x), -y))
    return pow!(z, x, convert(UInt, n))
end
Base.:^(x::AcbOrRef, y::Union{AcbOrRef,ArbOrRef,_BitInteger}) =
    pow!(Acb(prec = _precision(x, y)), x, y)

sqr(x::Union{ArbOrRef,AcbOrRef}) = sqr!(zero(x), x)
cube(x::AcbOrRef) = cube!(zero(x), x)

# We define the same special cases as Arb does, this avoids some overhead
Base.literal_pow(::typeof(^), x::AcbOrRef, ::Val{-3}) = (y = inv(x); cube!(y, y))
Base.literal_pow(::typeof(^), x::Union{ArbOrRef,AcbOrRef}, ::Val{-2}) =
    (y = inv(x); sqr!(y, y))
#Base.literal_pow(::typeof(^), x::Union{ArbOrRef,AcbOrRef}, ::Val{-1}) - implemented in Base.intfuncs.jl
Base.literal_pow(::typeof(^), x::Union{ArbOrRef,AcbOrRef}, ::Val{0}) = one(x)
Base.literal_pow(::typeof(^), x::Union{ArbOrRef,AcbOrRef}, ::Val{1}) = copy(x)
Base.literal_pow(::typeof(^), x::Union{ArbOrRef,AcbOrRef}, ::Val{2}) = sqr(x)
Base.literal_pow(::typeof(^), x::AcbOrRef, ::Val{3}) = cube(x)

### real, imag, conj

Base.real(z::AcbOrRef) = get_real!(Arb(prec = _precision(z)), z)
Base.imag(z::AcbOrRef) = get_imag!(Arb(prec = _precision(z)), z)
Base.conj(z::AcbOrRef) = conj!(zero(z), z)
