@testset "Arithmethic" begin
    @testset "Mag" begin
        @test Mag(4) <= Mag(1) + Mag(3) <= Mag(5)
        @test Mag(2) <= Mag(3) - Mag(1) <= Mag(3)
        @test Mag(0) <= Mag(3) - Mag(5) <= Mag(1)
        @test Mag(6) <= Mag(2) * Mag(3) <= Mag(7)
        @test Mag(3) <= Mag(6) / Mag(2) <= Mag(4)

        @test Mag(4) <= Mag(1) + 3 == 1 + Mag(3) <= Mag(5)
        @test Mag(6) <= Mag(2) * 3 == 3 * Mag(2) <= Mag(7)
        @test Mag(2) <= Mag(4) / 2 <= Mag(3)

        @test Mag(1 / 4) <= inv(Mag(4)) <= Mag(1 / 3)
        @test Mag(8) <= Mag(2)^3 <= Mag(9)
        @test Mag(2) <= sqrt(Mag(4)) <= Mag(3)
        @test Mag(1 / 2) <= Arblib.rsqrt(Mag(4)) <= Mag(1)
        @test Mag(5) <= hypot(Mag(3), Mag(4)) <= Mag(6)
        @test Mag(2) <= Arblib.root(Mag(8), 3) <= Mag(3)
        @test Mag(log(8)) <= log(Mag(8)) <= Mag(log(9))
        @test log(Mag(2)) <= Arblib.neglog(inv(Mag(2.0))) <= log(Mag(3))
        @test log(Mag(2)) <= log1p(Mag(1)) <= log(Mag(3))
        @test Mag(exp(2)) <= exp(Mag(2)) <= Mag(exp(3))
        @test Mag(exp(-2)) <= Arblib.expinv(Mag(2)) <= Mag(exp(-1))
        @test Mag(expm1(2)) <= expm1(Mag(2)) <= Mag(expm1(3))
        @test Mag(atan(2)) <= atan(Mag(2)) <= Mag(atan(3))
        @test Mag(cosh(2)) <= cosh(Mag(2)) <= Mag(cosh(3))
        @test Mag(sinh(2)) <= sinh(Mag(2)) <= Mag(sinh(3))

        @test min(Mag(1), Mag(2)) == Mag(1)
        @test max(Mag(1), Mag(2)) == Mag(2)
        @test minmax(Mag(1), Mag(2)) == minmax(Mag(2), Mag(1)) == (Mag(1), Mag(2))
        @test minimum(Mag[10:20; 0:9]) == Mag(0)
        @test maximum(Mag[10:20; 0:9]) == Mag(20)
        @test extrema(Mag[10:20; 0:9]) == (Mag(0), Mag(20))
    end

    @testset "Arf" begin
        @test sign(Arf(2)) == Arf(1)
        @test sign(Arf(-2)) == Arf(-1)
        @test sign(Arf(0)) == Arf(0)

        @test abs(Arf(-2)) == abs(Arf(2)) == Arf(2)
        @test -Arf(2) == Arf(-2)

        @test Arf(1) + Arf(2) ==
              Arf(1) + 2 ==
              2 + Arf(1) ==
              Arf(1) + UInt(2) ==
              UInt(2) + Arf(1) ==
              Arf(1) + UInt8(2) ==
              Arf(1) + UInt8(2) ==
              UInt8(2) + Arf(1) ==
              Arf(3)
        @test Arf(1) - Arf(2) == Arf(1) - 2 == Arf(1) - UInt(2) == Arf(-1)
        @test Arf(2) * Arf(3) ==
              Arf(2) * 3 ==
              3 * Arf(2) ==
              Arf(2) * UInt(3) ==
              UInt(3) * Arf(2) ==
              Arf(6)
        @test Arf(6) / Arf(2) ==
              Arf(6) / 2 ==
              6 / Arf(2) ==
              Arf(6) / UInt(2) ==
              UInt(6) / Arf(2) ==
              Arf(6) / UInt8(2) ==
              UInt8(6) / Arf(2) ==
              Arf(3)

        @test sqrt(Arf(4)) == Arf(2)
        @test Arblib.rsqrt(Arf(4)) == Arf(1 // 2)
        @test Arblib.root(Arf(8), 3) == Arf(2)

        @test min(Arf(1), Arf(2)) == Arf(1)
        @test max(Arf(1), Arf(2)) == Arf(2)
        @test minmax(Arf(1), Arf(2)) == minmax(Arf(2), Arf(1)) == (Arf(1), Arf(2))
        @test minimum(Arf[10:20; 0:9]) == Arf(0)
        @test maximum(Arf[10:20; 0:9]) == Arf(20)
        @test extrema(Arf[10:20; 0:9]) == (Arf(0), Arf(20))
    end

    @testset "$T" for T in [Arb, Acb]
        @test T(1) + T(2) ==
              T(1) + 2 ==
              2 + T(1) ==
              T(1) + UInt(2) ==
              UInt(2) + T(1) ==
              T(1) + UInt8(2) ==
              UInt8(2) + T(1) ==
              T(3)
        @test T(1) - T(2) == T(1) - 2 == T(1) - UInt(2) == T(-1)
        @test T(2) * T(3) ==
              T(2) * 3 ==
              3 * T(2) ==
              T(2) * UInt(3) ==
              UInt(3) * T(2) ==
              T(6)
        @test T(6) / T(2) == T(6) / 2 == T(6) / UInt(2) == T(3)

        @test Base.literal_pow(^, T(2), Val(-2)) ==
              T(2)^-2 ==
              Arblib.sqr(inv(T(2))) ==
              T(1 // 4)
        @test Base.literal_pow(^, T(2), Val(0)) == T(2)^0 == one(T)
        @test Base.literal_pow(^, T(2), Val(1)) == T(2)^1 == T(2)
        @test Base.literal_pow(^, T(2), Val(2)) == T(2)^2 == Arblib.sqr(T(2)) == T(4)

        @test Arblib.root(T(8), 3) == T(2)

        for f in [
            inv,
            sqrt,
            log,
            log1p,
            exp,
            expm1,
            sin,
            cos,
            tan,
            cot,
            sec,
            csc,
            atan,
            asin,
            acos,
            sinh,
            cosh,
            tanh,
            coth,
            sech,
            csch,
            atanh,
            asinh,
        ]
            # TODO: Replace with ≈
            @test abs(f(T(0.5)) - f(0.5)) <= 1e-15
        end
        # TODO: Replace with ≈
        @test abs(acosh(T(2)) - acosh(2)) <= 1e-15

        @test Arblib.rsqrt(T(1 // 4)) == T(2)
        @test Arblib.sqr(T(3)) == T(9)

        @test sinpi(T(1)) == T(0)
        @test cospi(T(1)) == T(-1)
        @test Arblib.tanpi(T(1)) == T(0)
        # TODO: Replace with ≈
        @test abs(Arblib.cotpi(T(0.5))) <= 1e-15
        @test abs(Arblib.cscpi(T(0.5)) - 1) <= 1e-15
        @test abs(sinc(T(0.5)) - sinc(0.5)) <= 1e-15

        @test isequal(sincos(T(1)), (sin(T(1)), cos(T(1))))
        if VERSION >= v"1.6"
            @test isequal(sincospi(T(1)), (sinpi(T(1)), cospi(T(1))))
        else
            @test isequal(Arblib.sincospi(T(1)), (sinpi(T(1)), cospi(T(1))))
        end
        @test isequal(Arblib.sinhcosh(T(1)), (sinh(T(1)), cosh(T(1))))
    end

    @testset "Arb - specific" begin
        @test Arb(1) + Arf(2) == Arf(2) + Arb(1) == Arb(3)
        @test Arb(1) - Arf(2) == Arb(-1)
        @test Arb(2) * Arf(3) == Arf(3) * Arb(2) == Arb(6)
        @test Arb(6) / Arf(2) == UInt(6) / Arb(2) == UInt8(6) / Arb(2) == Arb(3)

        @test Arb(2)^Arb(3) ==
              Arb(2)^3 ==
              Arb(2)^Int8(3) ==
              Arb(2)^UInt(3) ==
              Arb(2)^UInt8(3) ==
              (Arb(2)^-3)^-1 ==
              Arb(8)
        @test hypot(Arb(3), Arb(4)) == Arb(5)

        @test Arblib.sqrtpos(Arb(4)) == Arb(2)
        @test Arblib.sqrtpos(Arb(-4)) == Arb(0)
        @test Arblib.sqrt1pm1(Arb(3)) == Arb(1)

        # TODO: Replace with ≈
        @test abs(atan(Arb(2), Arb(3)) - atan(2, 3)) <= 1e-15

        @test min(Arb(1), Arb(2)) == Arb(1)
        @test max(Arb(1), Arb(2)) == Arb(2)
        @test minmax(Arb(1), Arb(2)) == minmax(Arb(2), Arb(1)) == (Arb(1), Arb(2))
        @test Arblib.contains(min(Arb((0, 2)), Arb((-1, 3))), -1)
        @test Arblib.contains(min(Arb((0, 2)), Arb((-1, 3))), 2)
        @test !Arblib.contains(min(Arb((0, 2)), Arb((-1, 3))), 3)
        @test Arblib.contains(max(Arb((0, 2)), Arb((-1, 3))), 0)
        @test Arblib.contains(max(Arb((0, 2)), Arb((-1, 3))), 3)
        @test !Arblib.contains(max(Arb((0, 2)), Arb((-1, 3))), -1)
        @test all(Arblib.contains.(minmax(Arb((0, 2)), Arb((-1, 3))), (-1, 0)))
        @test all(Arblib.contains.(minmax(Arb((0, 2)), Arb((-1, 3))), (2, 3)))
        @test all(.!Arblib.contains.(minmax(Arb((0, 2)), Arb((-1, 3))), (3, -1)))
        @test minimum(Arb[10:20; 0:9]) == Arb(0)
        @test maximum(Arb[10:20; 0:9]) == Arb(20)
        @test extrema(Arb[10:20; 0:9]) == (Arb(0), Arb(20))
        A = [Arb((i, i + 1)) for i = 0:10]
        @test Arblib.contains(minimum(A), Arb((0, 1)))
        @test Arblib.contains(minimum(reverse(A)), Arb((0, 1)))
        @test Arblib.contains(maximum(A), Arb((10, 11)))
        @test Arblib.contains(maximum(reverse(A)), Arb((10, 11)))
        @test all(Arblib.contains.(extrema(A), (Arb((0, 1)), Arb((10, 11)))))
        # These fails with the default implementation
        @test Arblib.contains(
            minimum([Arb((-i, -i + 1)) for i = 0:1000]),
            Arb((-1000, -999)),
        )
        @test Arblib.contains(maximum([Arb((i, i + 1)) for i = 0:1000]), Arb((1000, 1001)))
    end

    @testset "Acb - specific" begin
        @test Acb(1) + Arb(2) == Arb(2) + Acb(1) == Acb(3)
        @test Acb(1) - Arb(2) == Acb(-1)
        @test Acb(2) * Arb(3) == Arb(3) * Acb(2) == Acb(6)
        @test Acb(6) / Arb(2) == Acb(3)

        @test Acb(2)^Acb(3) ==
              Acb(2)^Arb(3) ==
              Acb(2)^3 ==
              Acb(2)^Int8(3) ==
              Acb(2)^UInt(3) ==
              Acb(2)^UInt8(3) ==
              (Acb(2)^-3)^-1 ==
              Acb(8)

        @test Acb(2, 3) * Complex{Bool}(0, 0) ==
              Complex{Bool}(0, 0) * Acb(2, 3) ==
              Acb(2, 3) * (0 + 0im)
        @test Acb(2, 3) * Complex{Bool}(0, 1) ==
              Complex{Bool}(0, 1) * Acb(2, 3) ==
              Acb(2, 3) * (0 + 1im)
        @test Acb(2, 3) * Complex{Bool}(1, 0) ==
              Complex{Bool}(1, 0) * Acb(2, 3) ==
              Acb(2, 3) * (1 + 0im)
        @test Acb(2, 3) * Complex{Bool}(1, 1) ==
              Complex{Bool}(1, 1) * Acb(2, 3) ==
              Acb(2, 3) * (1 + 1im)

        @test real(Acb(1, 2)) isa Arb
        @test real(Acb(1, 2)) == Arb(1)
        @test imag(Acb(1, 2)) isa Arb
        @test imag(Acb(1, 2)) == Arb(2)

        @test conj(Acb(1, 2)) == Acb(1, -2)

        @test abs(Acb(3, 4)) isa Arb
        @test abs(Acb(3, 4)) == Arb(5)
    end
end
