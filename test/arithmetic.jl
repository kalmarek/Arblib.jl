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

    @testset "basic arithmetic: $T" for T in [Arb, Acb]
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

    @testset "promote: $T" for (T, TMat) in [(Arb, ArbMatrix), (Acb, AcbMatrix)]
        A = TMat(3, 3)
        # promotion of TRef to T
        a = A[1, 1]
        promote(a, 1) isa Tuple{T,T}
        promote(a, T(1)) isa Tuple{T,T}
        @test a + 3 == 3
        @test a + 3 isa T
    end

    @testset "real/imag" begin
        x, y = Arb(rand()), Arb(rand())
        z = Acb(x, y)

        @test Arblib.realref(z) isa ArbRef
        @test Arblib.realref(z) == x
        @test real(z) == x
        @test Arblib.imagref(z) isa ArbRef
        @test Arblib.imagref(z) == y
        @test imag(z) == y
    end

    @testset "midref" begin
        x = Arb(0.25)
        @test Arblib.midref(x) isa ArfRef
        @test startswith(sprint(show, x), "0.250")
        @test Float64(Arblib.midref(x)) isa Float64
        @test Float64(Arblib.midref(x)) == 0.25
        @test Float64(x) == 0.25
        @test sprint(show, x) == sprint(show, x[])
    end

    @testset "radref" begin
        x = Arb(0.25)
        m = Arblib.radref(x)
        @test m isa MagRef
        m[] = 1.0
        @test Float64(m) ≥ 1.0
        @test sprint(show, m) == sprint(show, m[])
    end

    @testset "convert to Float64/ComplexF64" begin
        x = Arb(0.25)
        @test Float64(x) isa Float64
        @test Float64(x) == 0.25
        z = Acb(2.0 + 0.125im)
        @test ComplexF64(z) isa ComplexF64
        @test ComplexF64(z) == 2.0 + 0.125im
    end
end
