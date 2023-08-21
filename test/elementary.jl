@testset "Elementary" begin
    @testset "Mag" begin
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
    end

    @testset "Arf" begin
        @test sqrt(Arf(4)) == 2
        @test Arblib.rsqrt(Arf(4)) == 1 // 2
        @test Arblib.root(Arf(8), 3) == 2
    end

    @testset "$T" for T in [Arb, Acb]
        @test Arblib.root(T(8), 3) == T(2)

        for f in [
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
            @test f(T(0.5)) ≈ f(0.5)
        end
        @test acosh(T(2)) ≈ acosh(2)

        @test Arblib.rsqrt(T(1 // 4)) == 2

        @test sinpi(T(1)) == 0
        @test cospi(T(1)) == -1
        @test Arblib.tanpi(T(1)) == 0
        @test Arblib.cotpi(T(0.5)) == 0
        @test Arblib.cscpi(T(0.5)) == 1
        @test sinc(T(0.5)) ≈ sinc(0.5)

        @test isequal(sincos(T(1)), (sin(T(1)), cos(T(1))))
        @test isequal(sincospi(T(1)), (sinpi(T(1)), cospi(T(1))))
        @test isequal(Arblib.sinhcosh(T(1)), (sinh(T(1)), cosh(T(1))))
    end

    @testset "Arb - specific" begin
        @test hypot(Arb(3), Arb(4)) == 5

        @test Arblib.sqrtpos(Arb(4)) == 2
        @test Arblib.sqrtpos(Arb(-4)) == 0
        @test Arblib.sqrt1pm1(Arb(3)) == 1

        @test atan(Arb(2), Arb(3)) ≈ atan(2, 3)
    end
end
