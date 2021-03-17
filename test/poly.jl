@testset "Poly: $TPoly" for (TPoly, T) in [(ArbPoly, Arb), (AcbPoly, Acb)]
    @testset "Length and degree" begin
        for (p, l) in [(zero(TPoly), 0), (one(TPoly), 1), (TPoly(T[0, 0, 1, 0]), 3)]
            @test firstindex(p) == 0
            @test size(p) == (l,)
            @test length(p) == size(p, 1) == Arblib.degree(p) + 1 == lastindex(p) + 1 == l
        end
    end

    @testset "Get and set coefficients" begin
        @test eltype(TPoly()) == T

        p = TPoly(T[i for i = 0:10])

        @test firstindex(p) == 0
        @test lastindex(p) == 10

        @test Arblib.coeffs(p) == p[:] == 0:10

        @test all(p[i] == i for i = 0:10)
        @test p[0:2] == 0:2

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

        if TPoly == ArbPoly
            @test Arblib.fromroots(TPoly, []) == one(TPoly)
            @test Arblib.fromroots(TPoly, [1, -1]) == TPoly([-1, 0, 1])
            @test Arblib.fromroots(TPoly, [], []) == one(TPoly)
            @test Arblib.fromroots(TPoly, [0], [im]) == TPoly([0, 1, 0, 1])
            @test Arblib.fromroots(TPoly, [], [im]) == TPoly([1, 0, 1])
            @test Arblib.fromroots(TPoly, [1, -1], []) == TPoly([-1, 0, 1])
        else
            @test Arblib.fromroots(TPoly, []) == one(TPoly)
            @test Arblib.fromroots(TPoly, [0, im]) == TPoly([0, -im, 1])
            @test Arblib.fromroots(TPoly, [0, im, -im]) == TPoly([0, 1, 0, 1])
        end
    end
    end
end
