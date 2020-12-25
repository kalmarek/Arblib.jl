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
    end

    @testset "Arf" begin
        @test sign(Arf(2)) == Arf(1)
        @test sign(Arf(-2)) == Arf(-1)
        @test sign(Arf(0)) == Arf(0)
        @test min(Arf(1), Arf(2)) == Arf(1)
        @test max(Arf(1), Arf(2)) == Arf(2)
        @test minmax(Arf(1), Arf(2)) == minmax(Arf(2), Arf(1)) == (Arf(1), Arf(2))

        @test abs(Arf(-2)) == abs(Arf(2)) == Arf(2)
        @test -Arf(2) == Arf(-2)

        @test Arf(1) + Arf(2) ==
              Arf(1) + 2 ==
              2 + Arf(1) ==
              Arf(1) + UInt(2) ==
              UInt(2) + Arf(1) ==
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
              Arf(3)

        @test sqrt(Arf(4)) == Arf(2)
        @test Arblib.rsqrt(Arf(4)) == Arf(1 // 2)
        @test Arblib.root(Arf(8), 3) == Arf(2)
    end

    @testset "$T" for T in [Arb, Acb]
        @test T(3) + 1 == 4
        @test T(3) + 1 isa T
        @test T(2) + T(3) == 5
        @test T(2) + T(3) isa T
        @test T(3) - 1 == 2
        @test T(3) - 1 isa T
        @test T(2) - T(3) == -1
        @test T(2) - T(3) isa T
        @test T(3) * 1 == 3
        @test T(3) * 1 isa T
        @test Bool(Arblib.contains(T(3) / 1, T(3)))
        @test T(3) / 1 isa T
        @test Bool(Arblib.contains(T(3) / T(1), T(3)))
        @test T(3) / T(1) isa T
    end

    @testset "Acb - specific" begin
        @test real(Acb(1, 2)) isa Arb
        @test real(Acb(1, 2)) == Arb(1)
        @test imag(Acb(1, 2)) isa Arb
        @test imag(Acb(1, 2)) == Arb(2)

        @test conj(Acb(1, 2)) == Acb(1, -2)

        @test abs(Acb(3, 4)) isa Arb
        @test abs(Acb(3, 4)) == Arb(5)
    end
end
