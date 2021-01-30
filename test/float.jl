@testset "float" begin
    @testset "eps" begin
        @test one(Arf) + eps(Arf) > one(Arf)
        @test one(Arf) + eps(Arf) / 2 == one(Arf)
        @test Arf(4) + eps(Arf(4)) > Arf(4)
        @test Arf(4) + eps(Arf(4)) / 2 == Arf(4)
        @test Arf(4, prec = 64) + eps(Arf(4, prec = 64)) > Arf(4)
        @test Arf(4, prec = 64) + eps(Arf(4, prec = 64)) / 2 == Arf(4)
        @test eps(Arf) isa Arf
        @test eps(ArfRef) isa Arf
        @test eps(one(Arf)) isa Arf

        @test eps(Arb) == Arb(eps(Arf))
        @test eps(Arb) isa Arb
        @test eps(ArbRef) isa Arb
        @test eps(one(Arb)) isa Arb

        @test eps(Acb) == Acb(eps(Arf))
        @test eps(Acb) isa Acb
        @test eps(AcbRef) isa Acb
        @test eps(one(Acb)) isa Acb
    end
end
