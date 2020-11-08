import Random

# TODO: remove Random.CloseOpen01{BigFloat} parameters
# TODO: remove setprecision
# possibly fixed by https://github.com/JuliaLang/julia/pull/38169

function Random.Sampler(
    RNG::Type{<:Random.AbstractRNG},
    st::Random.SamplerType{T},
    n::Random.Repetition,
) where {T<:Union{Arf,Arb,Acb}}
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

Random.rand(rng::Random.AbstractRNG, sp::Random.SamplerSimple{Random.SamplerType{Arf}}) =
    setprecision(BigFloat, sp.data.prec) do
        Arf(rand(rng, sp.data), prec = sp.data.prec)
    end

Random.rand(rng::Random.AbstractRNG, sp::Random.SamplerSimple{Random.SamplerType{Arb}}) =
    setprecision(BigFloat, sp.data.prec) do
        Arb(rand(rng, sp.data), prec = sp.data.prec)
    end

Random.rand(rng::Random.AbstractRNG, sp::Random.SamplerSimple{Random.SamplerType{Acb}}) =
    setprecision(BigFloat, sp.data.prec) do
        Acb(rand(rng, sp.data), rand(rng, sp.data), prec = sp.data.prec)
    end
