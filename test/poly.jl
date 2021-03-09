@testset "Poly: $TPoly" for (TPoly, T) in [(ArbPoly, Arb), (AcbPoly, Acb)]
    @testset "Length and degree" begin
        for (p, l) in [(zero(TPoly), 0), (one(TPoly), 1), (TPoly(T[0, 0, 1, 0]), 3)]
            @test length(p) == Arblib.degree(p) + 1 == l
        end
    end

    @testset "Get and set coefficients" begin
        @test eltype(TPoly()) == T

        p = TPoly(T[i for i = 0:10])
        @test all(p[i] == i for i = 0:10)
        @test p[11] == 0
        @test p[12] == 0

        p[3] = T(7)
        @test p[3] == 7
        p[4] = 8
        @test p[4] == 8
        p[5] = π
        @test isequal(p[5], T(π))
        if T == Arb
            p[6] = ArbRefVector(T[9])[1]
        else
            p[6] = AcbRefVector(T[9])[1]
        end
        @test p[6] == 9

        @test_throws BoundsError p[-1]
    end

    @testset "Constructors" begin
        @test TPoly() == TPoly(T(0)) == TPoly(T[0]) == zero(TPoly) == zero(TPoly())
        @test TPoly(T(1)) == TPoly(T[1]) == one(TPoly) == one(TPoly())
        @test Arblib.isx(TPoly(T[0, 1]))
        @test TPoly(T[1, 2, 0]) == TPoly(T[1, 2])
        @test TPoly(5) == TPoly(5.0) == TPoly([5.0]) == TPoly(T(5))

        @test precision(TPoly(prec = 64)) == 64
        @test precision(TPoly(T(0), prec = 64)) == 64
        @test precision(TPoly(T[0], prec = 64)) == 64
        @test precision(zero(TPoly(prec = 64))) == 64
        @test precision(one(TPoly(prec = 64))) == 64

        if TPoly == AcbPoly
            @test TPoly(ArbPoly([1, 2])) == TPoly([1, 2])
            @test precision(TPoly(ArbPoly(prec = 64))) == 64
        end
    end
end
