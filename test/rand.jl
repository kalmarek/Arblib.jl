@testset "Random" begin
    @testset "rand $T" for T in (Arf, Arb, Acb)
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
end
