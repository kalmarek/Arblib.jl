@testset "ArbPoly" begin
    @testset "Constructors" begin
        @test ArbPoly() ==
              ArbPoly(Arb(0)) ==
              ArbPoly(Arb[0]) ==
              zero(ArbPoly) ==
              zero(ArbPoly())
        @test ArbPoly(Arb(1)) == ArbPoly(Arb[1]) == one(ArbPoly) == one(ArbPoly())
        @test Arblib.isx(ArbPoly(Arb[0, 1]))
        @test ArbPoly(Arb[1, 2, 0]) == ArbPoly(Arb[1, 2])
    end

    @testset "Interface" begin
        for (P, l) in [(zero(ArbPoly), 0), (one(ArbPoly), 1), (ArbPoly(Arb[0, 0, 1]), 3)]
            @test length(P) == Arblib.degree(P) + 1 == l
        end

        P = ArbPoly(Arb[i for i = 0:10])
        @test all(P[i] == i for i = 0:10)
        @test P[11] == 0
        @test P[12] == 0

        P[3] = Arb(7)
        @test P[3] == 7

        @test_throws BoundsError P[-1]
    end
end
