@testset "Poly: $TPoly" for (TPoly, T) in [(ArbPoly, Arb), (AcbPoly, Acb)]
    @testset "Constructors" begin
        @test TPoly() == TPoly(T(0)) == TPoly(T[0]) == zero(TPoly) == zero(TPoly())
        @test TPoly(T(1)) == TPoly(T[1]) == one(TPoly) == one(TPoly())
        @test Arblib.isx(TPoly(T[0, 1]))
        @test TPoly(T[1, 2, 0]) == TPoly(T[1, 2])
    end

    @testset "Interface" begin
        @test eltype(TPoly()) == T

        for (P, l) in [(zero(TPoly), 0), (one(TPoly), 1), (TPoly(T[0, 0, 1]), 3)]
            @test length(P) == Arblib.degree(P) + 1 == l
        end

        P = TPoly(T[i for i = 0:10])
        @test all(P[i] == i for i = 0:10)
        @test P[11] == 0
        @test P[12] == 0

        P[3] = T(7)
        @test P[3] == 7

        @test_throws BoundsError P[-1]
    end
end
