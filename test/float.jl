@testset "float" begin
    @testset "eps" begin
        @test one(Arf) + eps(Arf) > one(Arf)
        @test one(Arf) + eps(Arf) / 2 == one(Arf)
        @test Arf(4) + eps(Arf(4)) > Arf(4)
        @test Arf(4) + eps(Arf(4)) / 2 == Arf(4)
        @test Arf(4, prec = 64) + eps(Arf(4, prec = 64)) > Arf(4)
        @test Arf(4, prec = 64) + eps(Arf(4, prec = 64)) / 2 == Arf(4)

        @test eps(Arf) == Arf(eps(BigFloat))
        @test eps(Arf(4)) == Arf(eps(BigFloat(4)))
        @test Float64(eps(Arf(1, prec = 53))) == eps()
        @test Float64(eps(Arf(4, prec = 53))) == eps(4.0)

        @test eps(Arf) == Arblib.eps!(zero(Arf), one(Arf))
        @test eps(Arf(4)) == Arblib.eps!(one(Arf), Arf(4))
        @test eps(Arb) == Arblib.eps!(zero(Arb), one(Arb))
        @test eps(Arb(4)) == Arblib.eps!(one(Arb), Arb(4))

        @test eps(Arb) == Arb(eps(Arf))

        @test eps(Arf) isa Arf
        @test eps(ArfRef) isa Arf
        @test eps(one(Arf)) isa Arf
        @test eps(Arb) isa Arb
        @test eps(ArbRef) isa Arb
        @test eps(one(Arb)) isa Arb

        @test precision(eps(Arf(1, prec = 64))) == 64
        @test precision(eps(Arb(1, prec = 64))) == 64

        # Test aliasing
        x = Arf(4)
        @test Arblib.eps!(x, x) == eps(Arf(4))
        x = Arb(4)
        @test Arblib.eps!(x, x) == eps(Arb(4))

        @test isnan(eps(zero(Arf)))
        @test isnan(eps(zero(Arb)))
        @test isnan(eps(Arf(Inf)))
        @test isnan(eps(Arb(Inf)))
        @test isnan(eps(Arf(NaN)))
        @test isnan(eps(Arb(NaN)))
    end
end
