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

        @test inv(T(2)) == 1 // 2
        @test Arblib.sqr(T(2)) == 4
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
