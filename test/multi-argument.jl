@testset "Multi-argument" begin
    @testset "Mag + and *" begin
        @test Mag(6) <= +(Mag.((1, 2, 3))...) <= Mag(7)
        @test Mag(10) <= +(Mag.((1, 2, 3, 4))...) <= Mag(11)
        @test Mag(15) <= +(Mag.((1, 2, 3, 4, 5))...) <= Mag(16)

        @test Mag(6) <= *(Mag.((1, 2, 3))...) <= Mag(7)
        @test Mag(24) <= *(Mag.((1, 2, 3, 4))...) <= Mag(25)
        @test Mag(120) <= *(Mag.((1, 2, 3, 4, 5))...) <= Mag(121)
    end

    @testset "$T + and *" for T in [Arf, Arb, Acb]
        @test +(T.((1, 2, 3))...) == 6
        @test +(T.((1, 2, 3, 4))...) == 10
        @test +(T.((1, 2, 3, 4, 5))...) == 15

        @test *(T.((1, 2, 3))...) == 6
        @test *(T.((1, 2, 3, 4))...) == 24
        @test *(T.((1, 2, 3, 4, 5))...) == 120
    end

    @testset "$T + and *" for T in [ArbPoly, AcbPoly, ArbSeries, AcbSeries]
        @test +(T.((1:3, 2:4, 3:5))...) == T(6:3:12)
        @test +(T.((1:3, 2:4, 3:5, 4:6))...) == T(10:4:18)
        @test +(T.((1:3, 2:4, 3:5, 4:6, 5:7))...) == T(15:5:25)

        @test *(T.((1:3, 2:4, 3:5))...) == (T(1:3) * T(2:4)) * T(3:5)
        @test *(T.((1:3, 2:4, 3:5, 4:6))...) == ((T(1:3) * T(2:4)) * T(3:5)) * T(4:6)
        @test *(T.((1:3, 2:4, 3:5, 4:6, 5:7))...) ==
              (((T(1:3) * T(2:4)) * T(3:5)) * T(4:6)) * T(5:7)
    end

    @testset "$T min and max" for T in [Mag, Arf, Arb]
        @test min(T.((1, 2, 2))...) == T(1)
        @test min(T.((1, 1, 2))...) == T(1)
        @test min(T.((2, 2, 1))...) == T(1)
        @test min(T.((1, 2, 2, 2))...) == T(1)
        @test min(T.((1, 1, 2, 2))...) == T(1)
        @test min(T.((2, 2, 1, 2))...) == T(1)
        @test min(T.((2, 2, 2, 1))...) == T(1)
        @test min(T.((1, 2, 2, 2, 2))...) == T(1)
        @test min(T.((1, 1, 2, 2, 2))...) == T(1)
        @test min(T.((2, 2, 1, 2, 2))...) == T(1)
        @test min(T.((2, 2, 2, 1, 2))...) == T(1)
        @test min(T.((2, 2, 2, 2, 1))...) == T(1)

        @test max(T.((2, 1, 1))...) == T(2)
        @test max(T.((2, 2, 1))...) == T(2)
        @test max(T.((1, 1, 2))...) == T(2)
        @test max(T.((2, 1, 1, 1))...) == T(2)
        @test max(T.((2, 2, 1, 1))...) == T(2)
        @test max(T.((1, 1, 2, 1))...) == T(2)
        @test max(T.((1, 1, 1, 2))...) == T(2)
        @test max(T.((2, 1, 1, 1, 1))...) == T(2)
        @test max(T.((2, 2, 1, 1, 1))...) == T(2)
        @test max(T.((1, 1, 2, 1, 1))...) == T(2)
        @test max(T.((1, 1, 1, 2, 1))...) == T(2)
        @test max(T.((1, 1, 1, 1, 2))...) == T(2)
    end
end
