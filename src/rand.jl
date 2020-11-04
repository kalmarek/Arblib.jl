import Random

# TODO: remove Random.CloseOpen01{BigFloat} parameters
# TODO: remove setprecision
# possibly fixed by

function Random.Sampler(
    RNG::Type{<:Random.AbstractRNG},
    st::Random.SamplerType{TOrRef},
    n::Random.Repetition,
) where {TOrRef<:Union{Arf,ArfRef,Arb,ArbRef,Acb,AcbRef}}

    T = _nonreftype(TOrRef)
    return Random.SamplerSimple(
        Random.SamplerType{T}(),
        Random.SamplerBigFloat{Random.CloseOpen01{BigFloat}}(precision(T)),
    )
end

function Random.Sampler(
    RNG::Type{<:Random.AbstractRNG},
    x::TOrRef,
    n::Random.Repetition,
) where {TOrRef<:Union{Arf,ArfRef,Arb,ArbRef,Acb,AcbRef}}
    T = _nonreftype(TOrRef)
    return Random.SamplerSimple(
        Random.SamplerType{T}(),
        Random.SamplerBigFloat{Random.CloseOpen01{BigFloat}}(precision(x)),
    )
end

Random.rand(rng::Random.AbstractRNG, sp::Random.SamplerSimple{A,B,Arf}) where {A,B} =
    setprecision(BigFloat, sp.data.prec) do
        Arf(rand(rng, sp.data), prec = sp.data.prec)
    end

Random.rand(rng::Random.AbstractRNG, sp::Random.SamplerSimple{A,B,Arb}) where {A,B} =
    setprecision(BigFloat, sp.data.prec) do
        Arb(rand(rng, sp.data), prec = sp.data.prec)
    end
Random.rand(rng::Random.AbstractRNG, sp::Random.SamplerSimple{A,B,Acb}) where {A,B} =
    setprecision(BigFloat, sp.data.prec) do
        Acb(rand(rng, sp.data), rand(rng, sp.data), prec = sp.data.prec)
    end
