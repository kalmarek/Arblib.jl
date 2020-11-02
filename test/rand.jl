@testset "Random" begin
    @testset "rand $T" for (T, RefT) in ((Arf, ArfRef), (Arb, ArbRef), (Acb, AcbRef))
        @test rand(T) isa T
        @test precision(rand(T)) == precision(T)
        @test rand(RefT) isa T
        @test precision(rand(RefT)) == precision(T)

        @test precision(rand(T(prec = 128))) == 128
    end
    a = rand(Arb)
    @test rand(Arblib.midref(a)) isa Arf
    z = Acb(rand(Arb, 2)...)
    @test rand(Arblib.realref(z)) isa Arb
    M = AcbVector(rand(Acb, 3))
    @test rand(Arblib.ref(M, 1)) isa Acb
end
