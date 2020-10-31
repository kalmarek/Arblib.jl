Base.promote_rule(::Type{<:MagLike}, ::Type{<:Union{Float64, MagLike}}) = Mag
Base.promote_rule(::Type{<:ArfLike}, ::Type{<:Union{AbstractFloat,Integer, MagLike}}) = Arf
Base.promote_rule(
    ::Type{<:ArbLike},
    ::Type{<:Union{AbstractFloat,Integer,Rational,ArfLike,ArbRef}},
) = Arb
Base.promote_rule(
    ::Type{<:AcbLike},
    ::Type{
        <:Union{
            AbstractFloat,
            Integer,
            Rational,
            Complex{<:Union{AbstractFloat,Integer,Rational}},
            ArfLike,
            ArbLike,
            AcbRef,
        },
    },
) = Acb

for (jf, af) in [(:+, :add!), (:-, :sub!), (:*, :mul!), (:/, :div!)]
    @eval function Base.$jf(x::T, y::T) where {T<:Union{Mag, MagRef}}
        z = T()
        $af(z, x, y)
        z
    end
end

function Base.:(^)(x::T, k::Integer) where {T<:Union{Mag, MagRef}}
    z = T()
    pow!(z, x, convert(UInt, k))
    z
end

for (jf, af) in [(:+, :add!), (:-, :sub!), (:*, :mul!), (:/, :div!)]
    @eval function Base.$jf(x::T, y::T) where {T<:Union{Arf,Arb,ArbRef,Acb,AcbRef}}
        z = T(prec = max(precision(x), precision(y)))
        $af(z, x, y)
        z
    end
end
function Base.:(-)(x::T) where {T<:Union{Arf,Arb,ArbRef,Acb,AcbRef}}
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
