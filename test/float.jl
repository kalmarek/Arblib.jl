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

    @testset "typemin/typemax" begin
        @test typemin(Mag) == typemin(Mag(5)) == Mag(0)
        @test typemax(Mag) == typemax(Mag(5)) == Mag(Inf)

        @test typemin(Arf) == typemin(Arf(5)) == Arf(-Inf)
        @test typemax(Arf) == typemax(Arf(5)) == Arf(Inf)
        @test precision(typemin(Arf(prec = 80))) == 80
        @test precision(typemax(Arf(prec = 80))) == 80

        @test typemin(Arb) == typemin(Arb(5)) == Arb(-Inf)
        @test typemax(Arb) == typemax(Arb(5)) == Arb(Inf)
        @test precision(typemin(Arb(prec = 80))) == 80
        @test precision(typemax(Arb(prec = 80))) == 80
    end

    @testset "frexp/ldexp" begin
        @test frexp(Arf(12.3)) == frexp(12.3)
        @test frexp(Arf(-12.3)) == frexp(-12.3)
        @test frexp(Arf(0)) == frexp(0.0)
        @test frexp(Arf(Inf)) == frexp(Inf)
        @test precision(frexp(Arf(1, prec = 80))[1]) == 80
        @test frexp(Arf(1)) isa Tuple{Arf,BigInt}

        @test frexp(Arb(12.3)) == frexp(12.3)
        @test frexp(Arb(-12.3)) == frexp(-12.3)
        @test frexp(Arb(0)) == frexp(0.0)
        @test frexp(Arb(Inf)) == frexp(Inf)
        @test isequal(frexp(Arb(π))[1], Arblib.mul_2exp!(Arb(), Arb(π), -2))
        @test precision(frexp(Arb(1, prec = 80))[1]) == 80
        @test frexp(Arb(1)) isa Tuple{Arb,BigInt}

        @test ldexp(Arf(1.1), 2) == Arf(1.1) * 2^2
        @test ldexp(Arf(1.1), -10) == Arf(1.1) / 2^10
        @test ldexp(Arb(1.1), 2) == Arb(1.1) * 2^2
        @test ldexp(Arb(1.1), -10) == Arb(1.1) / 2^10
        @test precision(ldexp(Arf(1, prec = 80), 1)) == 80
        @test precision(ldexp(Arb(1, prec = 80), 1)) == 80
    end
end
