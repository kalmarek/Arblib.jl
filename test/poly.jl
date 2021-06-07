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

        q = TPoly(prec = 512)
        q[0] = π
        @test Arblib.rel_accuracy_bits(q[0]) > 500

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

    @testset "Arithmetic" begin
        p = TPoly([1, 2, 3])
        q = TPoly([2, 3, 4])

        @test p + q == TPoly([3, 5, 7])
        @test p - q == TPoly([-1, -1, -1])
        @test p * q == TPoly([2, 7, 16, 17, 12])

        @test -p == TPoly([-1, -2, -3])

        @test divrem(p, TPoly([0, 1])) == (TPoly([2, 3]), TPoly([1]))

        @test precision(setprecision(p, 80) + setprecision(q, 90)) == 90
        @test precision(setprecision(p, 80) - setprecision(q, 90)) == 90
        @test precision(setprecision(p, 80) * setprecision(q, 90)) == 90
        @test precision(-setprecision(p, 80)) == 80
        @test precision.(divrem(setprecision(p, 80), TPoly([0, 1], prec = 90))) == (90, 90)

        if TPoly == AcbPoly
            q = ArbPoly([2, 3, 4])
            @test p + q == q + p == TPoly([3, 5, 7])
            @test p - q == TPoly([-1, -1, -1])
            @test q - p == TPoly([1, 1, 1])
            @test p * q == q * p == TPoly([2, 7, 16, 17, 12])
        end
    end

    @testset "Scalar arithmetic" begin
        p = TPoly([1, 2, 3])

        @test p + T(2) ==
              T(2) + p ==
              p + 2 ==
              2 + p ==
              p + 2.0 ==
              2.0 + p ==
              TPoly([3, 2, 3])
        @test p - T(2) == p - 2 == p - 2.0 == TPoly([-1, 2, 3])
        @test T(2) - p == 2 - p == 2.0 - p == TPoly([1, -2, -3])
        @test p * T(2) ==
              T(2) * p ==
              p * 2 ==
              2 * p ==
              p * 2.0 ==
              2.0 * p ==
              TPoly([2, 4, 6])
        @test p / T(2) == p / 2 == p / 2.0 == TPoly([0.5, 1, 1.5])

        # TODO: Take precision of polynomial into account when
        # converting? So that these tests would pass.
        #let p = setprecision(p, 512)
        #    @test Arblib.rel_accuracy_bits((p + π)[0]) > 500
        #    @test Arblib.rel_accuracy_bits((π + p)[0]) > 500
        #    @test Arblib.rel_accuracy_bits((p - π)[0]) > 500
        #    @test Arblib.rel_accuracy_bits((π - p)[0]) > 500
        #    @test Arblib.rel_accuracy_bits((p * π)[0]) > 500
        #    @test Arblib.rel_accuracy_bits((π * p)[0]) > 500
        #    @test Arblib.rel_accuracy_bits((p / π)[0]) > 500
        #end

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
        end

        if TPoly == AcbPoly
            @test p + Arb(2) == Arb(2) + p == TPoly([3, 2, 3])
            @test p - Arb(2) == TPoly([-1, 2, 3])
            @test Arb(2) - p == TPoly([1, -2, -3])
            @test p * Arb(2) == Arb(2) * p == TPoly([2, 4, 6])
            @test p / Arb(2) == TPoly([0.5, 1, 1.5])
        end
    end

    @testset "Evaluation" begin
        p = TPoly([1, 2, 3])

        @test p(Arb(2)) == p(2) == p(2.0) == 17
        @test p(Acb(1, 2)) == p(1 + 2im) == p(1.0 + 2.0im) == -6 + 16im

        @test Arblib.evaluate2(p, Arb(2)) == Arblib.evaluate2(p, 2) == (17, 14)
        @test Arblib.evaluate2(p, Acb(1, 2)) ==
              Arblib.evaluate2(p, 1 + 2im) ==
              (-6 + 16im, 8 + 12im)

        @test precision(p(T())) == precision(p(T(prec = 2precision(p)))) == precision(p)
        @test precision(TPoly(prec = 80)(T())) == 80
    end

    @testset "Differentiation and integration" begin
        p = TPoly([1, 2, 3])

        @test Arblib.derivative(p) == TPoly([2, 6])
        @test Arblib.integral(p) == TPoly([0, 1, 1, 1])

        @test precision(Arblib.derivative(p)) == precision(p)
        @test precision(Arblib.integral(p)) == precision(p)
        @test precision(Arblib.derivative(TPoly(prec = 80))) == 80
        @test precision(Arblib.integral(TPoly(prec = 80))) == 80
    end

    @testset "Power methods" begin
        p = TPoly([1, 2, 3])

        @test p^2 == p^Int(2) == p^UInt(2) == TPoly([1, 4, 10, 12, 9])

        @test precision(TPoly([1, 2, 3], prec = 80)^Int(2)) == 80

        @test_throws InexactError p^Int(-1)
    end
end
