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

        q = TSeries(prec = 512)
        q[0] = π
        @test Arblib.rel_accuracy_bits(q[0]) > 500

        @test_throws BoundsError p[-1]
        @test_throws BoundsError p[11]

        p = TSeries(T[i for i = 0:10])
        @test all(Arblib.ref(p, i) == p[i] for i = 0:10)

        Arblib.set!(Arblib.ref(p, 0), 5)
        @test p[0] == 5

        @test_throws BoundsError Arblib.ref(p, -1)
        @test_throws BoundsError Arblib.ref(p, 11)
    end

    @testset "Constructors" begin
        @test TSeries() ==
              TSeries([]) ==
              TSeries(T(0)) ==
              TSeries((0,)) ==
              TSeries(T[0]) ==
              zero(TSeries) ==
              zero(TSeries())
        @test TSeries(degree = 3) ==
              TSeries(T(0), degree = 3) ==
              TSeries((0,), degree = 3) ==
              TSeries(T[0], degree = 3) ==
              zero(TSeries(degree = 3))
        @test TSeries(T(1)) ==
              TSeries((1,)) ==
              TSeries(T[1]) ==
              one(TSeries) ==
              one(TSeries())
        @test Arblib.isx(TSeries((0, 1)))
        @test Arblib.isx(TSeries(T[0, 1]))
        @test TSeries((1, 2, 0)) ==
              TSeries(T[1, 2, 0]) !=
              TSeries((1, 2)) ==
              TSeries(T[1, 2])
        @test TSeries([5.0]) ==
              TSeries([5]) ==
              TSeries((5.0,)) ==
              TSeries(T[5]) ==
              TSeries(T(5))
        @test TSeries(TSeries((1, 2))) ==
              TSeries(ArbPoly((1, 2))) ==
              TSeries(TSeries((1, 2, 3)), degree = 1) ==
              TSeries(ArbPoly((1, 2, 3)), degree = 1) ==
              TSeries((1, 2))

        # A previous bug always set both coefficients
        @test Arblib.cstruct(TSeries((2, 1), degree = 0)).length == 1

        @test precision(TSeries(degree = 1, prec = 64)) == 64
        @test precision(TSeries(0, degree = 1, prec = 64)) == 64
        @test precision(TSeries((T(0),), prec = 64)) == 64
        @test precision(TSeries([0], prec = 64)) == 64
        @test precision(zero(TSeries(degree = 1, prec = 64))) == 64
        @test precision(one(TSeries(degree = 1, prec = 64))) == 64
        @test precision(TSeries(TSeries((1, 2), prec = 64))) == 64
        @test precision(TSeries(ArbPoly((1, 2), prec = 64))) == 64

        if TSeries == AcbSeries
            @test TSeries(AcbPoly((1, 2))) == TSeries(ArbSeries((1, 2))) == TSeries((1, 2))
            @test Arblib.degree(TSeries(ArbSeries(degree = 4))) == 4
            @test precision(TSeries(AcbPoly(prec = 64))) == 64
            @test precision(TSeries(ArbSeries(prec = 64))) == 64
        end
    end

    @testset "Arithmetic" begin
        p = TSeries([1, 2, 3])
        q = TSeries([2, 3, 4])

        @test p + q == TSeries([3, 5, 7])
        @test p - q == TSeries([-1, -1, -1])
        @test p * q == TSeries([2, 7, 16])
        @test q / p == TSeries([2, -1, 0])

        @test -p == TSeries([-1, -2, -3])

        @test inv(p) == TSeries([1, -2, 1])

        let p = setprecision(p, 80), q = setprecision(q, 90)
            @test precision(p + q) == 90
            @test precision(p - q) == 90
            @test precision(p * q) == 90
            @test precision(p / q) == 90
            @test precision(-p) == 80
            @test precision(inv(p)) == 80
        end

        if TSeries == AcbSeries
            q = ArbSeries([2, 3, 4])
            @test p + q == q + p == TSeries([3, 5, 7])
            @test p - q == TSeries([-1, -1, -1])
            @test q - p == TSeries([1, 1, 1])
            @test p * q == q * p == TSeries([2, 7, 16])
            @test p / ArbSeries(1, degree = 2) == p
            @test q / AcbSeries(1, degree = 2) == AcbSeries(q)
        end
    end

    @testset "Scalar arithmetic" begin
        p = TSeries([1, 2, 3])

        @test p + T(2) ==
              T(2) + p ==
              p + 2 ==
              2 + p ==
              p + 2.0 ==
              2.0 + p ==
              TSeries([3, 2, 3])
        @test p - T(2) == p - 2 == p - 2.0 == TSeries([-1, 2, 3])
        @test T(2) - p == 2 - p == 2.0 - p == TSeries([1, -2, -3])
        @test p * T(2) ==
              T(2) * p ==
              p * 2 ==
              2 * p ==
              p * 2.0 ==
              2.0 * p ==
              TSeries([2, 4, 6])
        @test p / T(2) == p / 2 == p / 2.0 == TSeries([0.5, 1, 1.5])
        @test T(2) / p == 2 / p == 2.0 / p == TSeries([2, -4, 2])

        # Test with zero polynomial
        @test zero(TSeries) + 1 == TSeries(1)
        @test zero(TSeries) - 1 == TSeries(-1)
        @test 1 - zero(TSeries) == TSeries(1)
        @test 1 * zero(TSeries) == TSeries()
        @test zero(TSeries) / 1 == TSeries()

        # Test that the normalisation works
        @test iszero(TSeries(-1) + 1)
        @test iszero(TSeries(1) - 1)
        @test iszero(1 - TSeries(1))

        let p = setprecision(p, 80)
            @test precision(p + T(2)) ==
                  precision(T(2) + p) ==
                  precision(2 + p) ==
                  precision(p + 2) ==
                  80
            @test precision(p - T(2)) == precision(p - 2) == 80
            @test precision(T(2) - p) == precision(2 - p) == 80
            @test precision(p * T(2)) ==
                  precision(T(2) * p) ==
                  precision(2 * p) ==
                  precision(p * 2) ==
                  80
            @test precision(p / T(2)) == precision(p / 2) == 80
            @test precision(T(2) / p) == precision(2 / p) == 80
        end

        if TSeries == ArbSeries
            @test p + im == p + Acb(im) == AcbSeries([1 + im, 2, 3])
            @test p - im == p - Acb(im) == AcbSeries([1 - im, 2, 3])
            @test im - p == Acb(im) - p == AcbSeries([im - 1, -2, -3])
            @test p * im == p * Acb(im) == AcbSeries([im, 2im, 3im])
            @test p / im == p / Acb(im) == AcbSeries([-im, -2im, -3im])
            @test im / p == Acb(im) / p == AcbSeries([im, -2im, im])

            let p = setprecision(p, 80)
                @test precision(p + im) == 80
                @test precision(p - im) == 80
                @test precision(im - p) == 80
                @test precision(p * im) == 80
                @test precision(p / im) == 80
            end
        end

        if TSeries == AcbSeries
            @test p + Arb(2) == Arb(2) + p == TSeries([3, 2, 3])
            @test p - Arb(2) == TSeries([-1, 2, 3])
            @test Arb(2) - p == TSeries([1, -2, -3])
            @test p * Arb(2) == Arb(2) * p == TSeries([2, 4, 6])
            @test p / Arb(2) == TSeries([0.5, 1, 1.5])
            @test Arb(2) / p == TSeries([2, -4, 2])
        end
    end

    @testset "Composition" begin
        p = TSeries([1, 2])
        q = TSeries([0, 3])

        @test Arblib.taylor_shift(p, T(2)) == Arblib.taylor_shift(p, 2) == TSeries([5, 2])
        @test Arblib.compose(p, q) == TSeries([1, 6])
        @test Arblib.revert(TSeries([0, 2])) == TSeries([0, 0.5])

        @test precision(Arblib.taylor_shift(setprecision(p, 80), T(2))) == 80
        @test precision(Arblib.compose(setprecision(p, 80), setprecision(q, 90))) == 90
        @test precision(Arblib.revert(TSeries([0, 2], prec = 80))) == 80

        @test_throws ArgumentError Arblib.compose(p, TSeries([1, 1]))
        @test_throws ArgumentError Arblib.revert(TSeries([0]))
        @test_throws ArgumentError Arblib.revert(TSeries([1, 1]))
        @test_throws ArgumentError Arblib.revert(TSeries([0, 0, 1]))
    end

    @testset "Evaluation" begin
        p = TSeries([1, 2, 3])

        @test p(Arb(2)) == p(2) == p(2.0) == 17
        @test p(Acb(1, 2)) == p(1 + 2im) == p(1.0 + 2.0im) == -6 + 16im

        @test Arblib.evaluate2(p, Arb(2)) == Arblib.evaluate2(p, 2) == (17, 14)
        @test Arblib.evaluate2(p, Acb(1, 2)) ==
              Arblib.evaluate2(p, 1 + 2im) ==
              (-6 + 16im, 8 + 12im)

        @test precision(p(T())) == precision(p(T(prec = 2precision(p)))) == precision(p)
        @test precision(TSeries(prec = 80)(T())) == 80
    end

    @testset "Differentiation and integration" begin
        p = TSeries([1, 2, 3])

        @test Arblib.derivative(p) == Arblib.derivative(p, 1) == TSeries([2, 6])
        @test Arblib.integral(p) == Arblib.integral(p, 1) == TSeries([0, 1, 1, 1])

        @test Arblib.derivative(p, 0) == Arblib.integral(p, 0) == p

        @test Arblib.derivative(p, 2) == TSeries([6])
        @test Arblib.integral(TSeries([2, 6, 12]), 2) == TSeries([0, 0, 1, 1, 1])

        @test precision(Arblib.derivative(p)) ==
              precision(Arblib.derivative(p, 0)) ==
              precision(Arblib.derivative(p, 2)) ==
              precision(p)
        @test precision(Arblib.integral(p)) ==
              precision(Arblib.integral(p, 0)) ==
              precision(Arblib.integral(p, 2)) ==
              precision(p)
        @test precision(Arblib.derivative(TSeries(p, prec = 80))) ==
              precision(Arblib.derivative(TSeries(p, prec = 80), 0)) ==
              precision(Arblib.derivative(TSeries(p, prec = 80), 2)) ==
              80
        @test precision(Arblib.integral(TSeries(p, prec = 80))) ==
              precision(Arblib.integral(TSeries(p, prec = 80), 0)) ==
              precision(Arblib.integral(TSeries(p, prec = 80), 2)) ==
              80

        @test_throws ArgumentError Arblib.derivative(TSeries(degree = 0), 1)
        @test_throws ArgumentError Arblib.derivative(TSeries(degree = 1), 2)
    end

    @testset "Power methods" begin
        p = TSeries([1, 2, 3])
        q = TSeries([2, 3, 0])

        @test p^q == TSeries([1, 4, 16])

        @test p^T(2) ==
              p^Int(2) ==
              p^UInt(2) ==
              p^(2 // 1) ==
              p^2.0 ==
              p^2 ==
              TSeries([1, 4, 10])
        @test p^T(-1) == p^Int(-1) == p^(-1 // 1) == p^-1.0 == p^-1 == TSeries([1, -2, 1])

        @test p^(2 + 2im) == AcbSeries([1, 4 + 4im, 2 + 18im])

        @test 2^TSeries([1, 0]) == TSeries([2, 0])
        @test (2 + im)^TSeries([1, 0]) == AcbSeries([2 + im, 0])

        @test precision(setprecision(p, 80)^setprecision(q, 90)) == 90
        @test precision(setprecision(p, 80)^T(2)) == 80
    end

    @testset "Series methods" begin
        x = T(0.8)
        p = TSeries([x, 1])

        for f in [
            sqrt,
            log,
            log1p,
            exp,
            sin,
            cos,
            tan,
            atan,
            sinh,
            cosh,
            sinpi,
            cospi,
            Arblib.cotpi,
            Arblib.rsqrt,
        ]
            res = f(p)
            @test res[0] ≈ f(x)
            @test !iszero(res[1])
            iszero(res[1]) && @show f
        end

        @test all(isequal.(sincos(p), (sin(p), cos(p))))
        @test all(Arblib.coeffs(Arblib.sincospi(p)[1]) .≈ Arblib.coeffs(sinpi(p)))
        @test all(Arblib.coeffs(Arblib.sincospi(p)[2]) .≈ Arblib.coeffs(cospi(p)))
        @test all(isequal.(Arblib.sinhcosh(p), (sinh(p), cosh(p))))

        if TSeries == ArbSeries
            for f in [asin, acos, sinc]
                res = f(p)
                @test res[0] ≈ f(x)
                @test !iszero(res[1])
            end
        end
    end
end
