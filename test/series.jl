@testset "Series: $TSeries" for (TSeries, T) in [(ArbSeries, Arb), (AcbSeries, Acb)]
    @testset "Length and degree" begin
        for (p, l) in [
            (zero(TSeries), 1),
            (one(TSeries), 1),
            (TSeries(T[0, 1, 0]), 3),
            (TSeries(T[0, 1], degree = 4), 5),
        ]
            @test firstindex(p) == 0
            @test size(p) == ()
            @test size(p, 1) == 1
            @test length(p) == Arblib.degree(p) + 1 == lastindex(p) + 1 == l
        end
    end

    @testset "Get and set coefficients" begin
        @test eltype(TSeries()) == T

        p = TSeries(T[i for i = 0:10])

        @test firstindex(p) == 0
        @test lastindex(p) == 10
        @test lastindex(TSeries(degree = 5)) == 5

        @test Arblib.coeffs(p) == p[:] == 0:10

        @test all(p[i] == i for i = 0:10)

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
        @test_throws BoundsError p[11]
    end

    @testset "Constructors" begin
        @test TSeries() == TSeries(T[0]) == zero(TSeries) == zero(TSeries())
        @test TSeries(degree = 3) ==
              TSeries(T(0), degree = 3) ==
              TSeries(T[0], degree = 3) ==
              zero(TSeries(degree = 3))
        @test TSeries(T[1]) == one(TSeries) == one(TSeries())
        @test Arblib.isx(TSeries(T[0, 1]))
        @test TSeries(T[1, 2, 0]) != TSeries(T[1, 2])
        @test TSeries([5.0]) == TSeries([5]) == TSeries(T[5])

        @test precision(TSeries(degree = 1, prec = 64)) == 64
        @test precision(TSeries(0, degree = 1, prec = 64)) == 64
        @test precision(TSeries([0], prec = 64)) == 64
        @test precision(zero(TSeries(degree = 1, prec = 64))) == 64
        @test precision(one(TSeries(degree = 1, prec = 64))) == 64

        if TSeries == AcbSeries
            @test TSeries(ArbSeries([1, 2])) == TSeries([1, 2])
            @test Arblib.degree(TSeries(ArbSeries(degree = 4))) == 4
            @test precision(TSeries(ArbSeries(prec = 64))) == 64
        end
    end
end
