
import Random

for (T, RefT) in ((Arf, ArfOrRef), (Arb, ArbOrRef), (Acb, AcbOrRef))
    @eval begin
        function Random.Sampler(
            RNG::Type{<:Random.AbstractRNG},
            st::Random.SamplerType{<:$RefT},
            n::Random.Repetition,
        )
            #     TODO: SamplerBigFloat(precision(Arf))
            #     return Random.SamplerSimple(
            #         Random.SamplerType{Arf}(),
            #         Random.SamplerBigFloat(precision(Arf))
            #     )
            res = setprecision(BigFloat, precision($T)) do
                Random.SamplerSimple(Random.SamplerType{$T}(), Random.Sampler(RNG, BigFloat, n))
            end
            return res
        end
    end
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
    # TODO: Arf(Random.SamplerBigFloat(precision(st[])))
    x = setprecision(BigFloat, precision(st[])) do
        rand(rng, BigFloat)
    end
    return Arf(x, prec = precision(st[]))
end

function Random.rand(
    rng::Random.AbstractRNG,
    st::Random.SamplerTrivial{A,A},
) where {A<:ArbOrRef}
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
    re, im = setprecision(BigFloat, precision(st[])) do
        rand(rng, BigFloat, 2) # TODO: Random.SamplerBigFloat(precision(st[]))
    end # TODO: Random.SamplerBigFloat(precision(st[]))
    return Acb(re, im; prec = precision(st[]))
end
