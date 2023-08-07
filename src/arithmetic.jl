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
Base.inv(x::MagOrRef) = inv!(zero(x), x)

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

sqr(x::Union{ArbOrRef,AcbOrRef}) = sqr!(zero(x), x)
Base.inv(x::Union{ArbOrRef,AcbOrRef}) = inv!(zero(x), x)

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
