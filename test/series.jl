@testset "Series: $TSeries" for (TSeries, T) in [(ArbSeries, Arb), (AcbSeries, Acb)]
    @testset "Constructors" begin
        @test TSeries() == TSeries(T[0]) == zero(TSeries) == zero(TSeries())
        @test TSeries(3) == TSeries(T(0), 3) == TSeries(T[0], 3) == zero(TSeries(3))
        @test TSeries(T[1]) == one(TSeries) == one(TSeries())
        @test Arblib.isx(TSeries(T[0, 1]))
        @test TSeries(T[1, 2, 0]) != TSeries(T[1, 2])
        @test TSeries([5.0]) == TSeries([5]) == TSeries(T[5])

        @test precision(TSeries(1, prec = 64)) == 64
        @test precision(TSeries(0, 1, prec = 64)) == 64
        @test precision(TSeries([0], prec = 64)) == 64
        @test precision(zero(TSeries(1, prec = 64))) == 64
        @test precision(one(TSeries(1, prec = 64))) == 64
    end

    @testset "Interface" begin
        for (P, l) in [
            (zero(TSeries), 1),
            (one(TSeries), 1),
            (TSeries(T[0, 1, 0]), 3),
            (TSeries(T[0, 1], 4), 5),
        ]
            @test length(P) == Arblib.degree(P) + 1 == l
        end

        P = TSeries(T[i for i = 0:10])
        @test all(P[i] == i for i = 0:10)

        P[3] = T(7)
        @test P[3] == 7
        P[4] = 8
        @test P[4] == 8
        P[5] = π
        @test isequal(P[5], T(π))
        if T == Arb
            P[6] = ArbRefVector(T[9])[1]
        else
            P[6] = AcbRefVector(T[9])[1]
        end
        @test P[6] == 9

        @test_throws BoundsError P[-1]
        @test_throws BoundsError P[11]
    end
end
