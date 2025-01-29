@testset "Random" begin
    @testset "rand $T" for T in (Arf, Acf, Arb, Acb)
        @test rand(T) isa T
        @test precision(rand(T)) == precision(T)
        @test precision(rand(T(prec = 128))) == 128
    end
    a = rand(Arb(prec = 128))
    @test rand(Arblib.midref(a)) isa Arf
    @test precision(rand(Arblib.midref(a))) == precision(a)

    z = Acb(rand(Arb(prec = 128), 2)...)
    @test rand(Arblib.realref(z)) isa Arb
    @test precision(rand(Arblib.realref(z))) == precision(z)

    V = AcbVector(rand(Acb(prec = 128), 3))
    @test rand(Arblib.ref(V, 1)) isa Acb
    @test precision(rand(Arblib.ref(V, 1))) == precision(V)

    # Similar to tests added in
    # https://github.com/JuliaLang/julia/pull/38169
    for T in (Arf, Arb)
        s = Random.Sampler(MersenneTwister, Random.CloseOpen01(T))
        old_prec = precision(Arb)
        setprecision(Arb, 100) do
            x = rand(s)
            @test precision(x) == old_prec
        end

        s = setprecision(Arb, 100) do
            Random.Sampler(MersenneTwister, Random.CloseOpen01(T))
        end
        x = rand(s) # should use precision of s
        @test precision(x) == 100
    end
end
