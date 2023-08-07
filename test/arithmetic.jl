@testset "Arithmethic" begin
    @testset "Mag" begin
        # +, -, *, /
        @test Mag(4) <= Mag(1) + Mag(3) <= Mag(5)
        @test Mag(2) <= Mag(3) - Mag(1) <= Mag(3)
        @test Mag(0) <= Mag(3) - Mag(5) <= Mag(1)
        @test Mag(6) <= Mag(2) * Mag(3) <= Mag(7)
        @test Mag(3) <= Mag(6) / Mag(2) <= Mag(4)

        @test Mag(4) <= Mag(1) + 3 == 1 + Mag(3) <= Mag(5)
        @test Mag(6) <= Mag(2) * 3 == 3 * Mag(2) <= Mag(7)
        @test Mag(2) <= Mag(4) / 2 <= Mag(3)

        @test Mag(1 / 4) <= inv(Mag(4)) <= Mag(1 / 3)

        @test Mag(6) <= +(Mag.((1, 2, 3))...) <= Mag(7)
        @test Mag(10) <= +(Mag.((1, 2, 3, 4))...) <= Mag(11)
        @test Mag(15) <= +(Mag.((1, 2, 3, 4, 5))...) <= Mag(16)
        @test Mag(6) <= *(Mag.((1, 2, 3))...) <= Mag(7)
        @test Mag(24) <= *(Mag.((1, 2, 3, 4))...) <= Mag(25)
        @test Mag(120) <= *(Mag.((1, 2, 3, 4, 5))...) <= Mag(121)

        # signbit, sign and abs
        @test !signbit(Mag(0))
        @test !signbit(Mag(2))

        @test iszero(sign(Mag(0)))
        @test isone(sign(Mag(1)))
        @test isone(sign(Mag(Inf)))

        @test abs(Mag(5)) == Mag(5)

        # ^
        @test Mag(8) <= Mag(2)^3 <= Mag(9)
    end

    @testset "Arf" begin
        # +, -, *, /
        @test -Arf(2) == -2

        @test Arf(1) + Arf(2) ==
              Arf(1) + 2 ==
              2 + Arf(1) ==
              Arf(1) + UInt(2) ==
              UInt(2) + Arf(1) ==
              Arf(1) + UInt8(2) ==
              Arf(1) + UInt8(2) ==
              UInt8(2) + Arf(1) ==
              3
        @test Arf(1) - Arf(2) == Arf(1) - 2 == Arf(1) - UInt(2) == -1
        @test Arf(2) * Arf(3) ==
              Arf(2) * 3 ==
              3 * Arf(2) ==
              Arf(2) * UInt(3) ==
              UInt(3) * Arf(2) ==
              6
        @test Arf(6) / Arf(2) ==
              Arf(6) / 2 ==
              6 / Arf(2) ==
              Arf(6) / UInt(2) ==
              UInt(6) / Arf(2) ==
              Arf(6) / UInt8(2) ==
              UInt8(6) / Arf(2) ==
              3

        @test +(Arf.((1, 2, 3))...) == 6
        @test +(Arf.((1, 2, 3, 4))...) == 10
        @test +(Arf.((1, 2, 3, 4, 5))...) == 15
        @test *(Arf.((1, 2, 3))...) == 6
        @test *(Arf.((1, 2, 3, 4))...) == 24
        @test *(Arf.((1, 2, 3, 4, 5))...) == 120

        # fma and muladd
        @test fma(Arf(2), Arf(3), Arf(4)) == muladd(Arf(2), Arf(3), Arf(4)) == 10

        # signbit, sign and abs
        @test signbit(Arf(-2))
        @test !signbit(Arf(0))
        @test !signbit(Arf(2))
        @test !signbit(Arf(NaN))

        @test sign(Arf(-2)) == -1
        @test sign(Arf(0)) == 0
        @test sign(Arf(2)) == 1
        @test sign(Arf(NaN)) == NaN

        @test abs(Arf(-2)) == abs(Arf(2)) == 2
    end

    @testset "$T" for T in [Arb, Acb]
        @test T(1) + T(2) ==
              T(1) + 2 ==
              2 + T(1) ==
              T(1) + UInt(2) ==
              UInt(2) + T(1) ==
              T(1) + UInt8(2) ==
              UInt8(2) + T(1) ==
              3
        @test T(1) - T(2) == T(1) - 2 == T(1) - UInt(2) == T(-1)
        @test T(2) * T(3) == T(2) * 3 == 3 * T(2) == T(2) * UInt(3) == UInt(3) * T(2) == 6
        @test T(6) / T(2) == T(6) / 2 == T(6) / UInt(2) == 3

        @test +(T.((1, 2, 3))...) == 6
        @test +(T.((1, 2, 3, 4))...) == 10
        @test +(T.((1, 2, 3, 4, 5))...) == 15
        @test *(T.((1, 2, 3))...) == 6
        @test *(T.((1, 2, 3, 4))...) == 24
        @test *(T.((1, 2, 3, 4, 5))...) == 120

        # ^
        @test Base.literal_pow(^, T(2), Val(-2)) ==
              T(2)^-2 ==
              Arblib.sqr(inv(T(2))) ==
              1 // 4
        @test Base.literal_pow(^, T(2), Val(-1)) == T(2)^-1 == inv(T(2)) == 1 // 2
        @test Base.literal_pow(^, T(2), Val(0)) == T(2)^0 == 1
        @test Base.literal_pow(^, T(2), Val(1)) == T(2)^1 == 2
        @test Base.literal_pow(^, T(2), Val(2)) == T(2)^2 == Arblib.sqr(T(2)) == 4
    end

    @testset "Arb - specific" begin
        @test Arb(1) + Arf(2) == Arf(2) + Arb(1) == 3
        @test Arb(1) - Arf(2) == Arb(-1)
        @test Arb(2) * Arf(3) == Arf(3) * Arb(2) == 6
        @test Arb(6) / Arf(2) == UInt(6) / Arb(2) == UInt8(6) / Arb(2) == 3

        # fma and muladd
        @test fma(Arb(2), Arb(3), Arb(4)) ==
              fma(Arb(2), 3, Arb(4)) ==
              fma(2, Arb(3), Arb(4)) ==
              muladd(Arb(2), Arb(3), Arb(4)) ==
              muladd(Arb(2), 3, Arb(4)) ==
              muladd(2, Arb(3), Arb(4)) ==
              10

        # signbit, sign and abs
        @test signbit(Arb(-2))
        @test !signbit(Arb(0))
        @test !signbit(Arb(2))
        @test !signbit(Arb((-1, 0)))
        @test !signbit(Arb(NaN))

        @test sign(Arb(-2)) == -1
        @test sign(Arb(0)) == 0
        @test sign(Arb(2)) == 1
        @test isequal(sign(Arb((-3, 1))), Arblib.zero_pm_one!(Arb()))
        @test isequal(sign(Arb(NaN)), Arblib.zero_pm_one!(Arb()))

        @test abs(Arb(-2)) == abs(Arb(2)) == 2

        # ^
        @test Arb(2)^Arb(3) ==
              Arb(2)^3 ==
              Arb(2)^Int8(3) ==
              Arb(2)^UInt(3) ==
              Arb(2)^UInt8(3) ==
              (Arb(2)^-3)^-1 ==
              8
    end

    @testset "Acb - specific" begin
        @test Acb(1) + Arb(2) == Arb(2) + Acb(1) == 3
        @test Acb(1) - Arb(2) == -1
        @test Acb(2) * Arb(3) == Arb(3) * Acb(2) == 6
        @test Acb(6) / Arb(2) == 3

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

        # abs
        @test abs(Acb(3, 4)) isa Arb
        @test abs(Acb(3, 4)) == 5

        # ^
        @test Acb(2)^Acb(3) ==
              Acb(2)^Arb(3) ==
              Acb(2)^3 ==
              Acb(2)^Int8(3) ==
              Acb(2)^UInt(3) ==
              Acb(2)^UInt8(3) ==
              (Acb(2)^-3)^-1 ==
              8

        @test Base.literal_pow(^, Acb(2), Val(-3)) ==
              Acb(2)^-3 ==
              Arblib.cube(inv(Acb(2))) ==
              1 // 8
        @test Base.literal_pow(^, Acb(2), Val(3)) == Acb(2)^3 == Arblib.cube(Acb(2)) == 8

        # real, imag, conj
        @test real(Acb(1, 2)) isa Arb
        @test real(Acb(1, 2)) == 1
        @test imag(Acb(1, 2)) isa Arb
        @test imag(Acb(1, 2)) == 2

        @test conj(Acb(1, 2)) == Acb(1, -2)
    end
end
