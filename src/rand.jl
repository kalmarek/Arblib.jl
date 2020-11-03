import Random

function Random.Sampler(
    RNG::Type{<:Random.AbstractRNG},
    st::Random.SamplerType{TOrRef},
    n::Random.Repetition,
) where {TOrRef<:Union{Arf,ArfRef,Arb,ArbRef,Acb,AcbRef}}
    T = _nonreftype(TOrRef)
    # return Random.SamplerSimple(
    #     Random.SamplerType{T}(),
    #     Random.SamplerBigFloat(precision(T)),
    # )
    res = setprecision(BigFloat, precision(T)) do
        Random.SamplerSimple(Random.SamplerType{T}(), Random.Sampler(RNG, BigFloat, n))
    end
    return res
end

Random.rand(rng::Random.AbstractRNG, sp::Random.SamplerSimple{A,B,Arf}) where {A,B} =
    Arf(rand(rng, sp.data), prec = sp.data.prec)
Random.rand(rng::Random.AbstractRNG, sp::Random.SamplerSimple{A,B,Arb}) where {A,B} =
    Arb(rand(rng, sp.data), prec = sp.data.prec)
Random.rand(rng::Random.AbstractRNG, sp::Random.SamplerSimple{A,B,Acb}) where {A,B} =
    Acb(rand(rng, sp.data), rand(rng, sp.data), prec = sp.data.prec)

function Random.rand(
    rng::Random.AbstractRNG,
    st::Random.SamplerTrivial{A,A},
) where {A<:ArfOrRef}
    # TODO: Arf(rand(rng, Random.SamplerBigFloat(precision(st[]))))
    x = setprecision(BigFloat, precision(st[])) do
        rand(rng, BigFloat)
    end
    return Arf(x, prec = precision(st[]))
end

function Random.rand(
    rng::Random.AbstractRNG,
    st::Random.SamplerTrivial{A,A},
) where {A<:ArbOrRef}
    # TODO: Arb(rand(rng, Random.SamplerBigFloat(precision(st[]))))
    x = setprecision(BigFloat, precision(st[])) do
        rand(rng, BigFloat)
    end
    # randomize radius?
    return Arb(x, prec = precision(st[]))
end

function Random.rand(
    rng::Random.AbstractRNG,
    st::Random.SamplerTrivial{A,A},
) where {A<:AcbOrRef}
    # TODO: rand(rng, Random.SamplerBigFloat(precision(st[])), 2)
    re, im = setprecision(BigFloat, precision(st[])) do
        rand(rng, BigFloat, 2)
    end
    return Acb(re, im; prec = precision(st[]))
end
