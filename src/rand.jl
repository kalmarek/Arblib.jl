import Random

# TODO: Reduce allocations by not constructing an intermediate
# BigFloat.

function Random.Sampler(
    ::Type{<:Random.AbstractRNG},
    ::Random.SamplerType{T},
    ::Random.Repetition,
) where {T<:Union{Acf,Acb}}
    return Random.SamplerSimple(
        Random.SamplerType{T}(),
        Random.SamplerBigFloat{Random.CloseOpen01{BigFloat}}(precision(T)),
    )
end

function Random.Sampler(
    ::Type{<:Random.AbstractRNG},
    ::Random.CloseOpen01{T},
    ::Random.Repetition,
) where {T<:Union{Arf,Arb}}
    return Random.SamplerSimple(
        Random.SamplerType{T}(),
        Random.SamplerBigFloat{Random.CloseOpen01{BigFloat}}(precision(T)),
    )
end

function Random.Sampler(
    ::Type{<:Random.AbstractRNG},
    x::TOrRef,
    ::Random.Repetition,
) where {TOrRef<:Union{ArfOrRef,AcfOrRef,ArbOrRef,AcbOrRef}} #
    T = _nonreftype(TOrRef)
    return Random.SamplerSimple(
        Random.SamplerType{T}(),
        Random.SamplerBigFloat{Random.CloseOpen01{BigFloat}}(precision(x)),
    )
end

Random.rand(rng::Random.AbstractRNG, sp::Random.SamplerSimple{Random.SamplerType{Arf}}) =
    Arf(rand(rng, sp.data); sp.data.prec)

Random.rand(rng::Random.AbstractRNG, sp::Random.SamplerSimple{Random.SamplerType{Acf}}) =
    Acf(rand(rng, sp.data); sp.data.prec)

Random.rand(rng::Random.AbstractRNG, sp::Random.SamplerSimple{Random.SamplerType{Arb}}) =
    Arb(rand(rng, sp.data); sp.data.prec)

Random.rand(rng::Random.AbstractRNG, sp::Random.SamplerSimple{Random.SamplerType{Acb}}) =
    Acb(rand(rng, sp.data), rand(rng, sp.data); sp.data.prec)
