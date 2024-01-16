@testset "Conversion" begin
    ArbRoundNearest = Arblib.RoundNearest
    ArbRoundDown = Arblib.RoundDown
    ArbRoundUp = Arblib.RoundUp

    @testset "Floats" begin
        @testset "$T" for T in (Float16, Float32, Float64)
            # Mag
            @test T(Mag(2)) isa T
            @test π < T(Mag(π)) == T(Mag(π), RoundUp) == T(Mag(π), ArbRoundUp) < 3.15

            @test_throws ArgumentError T(Mag(1), RoundDown)
            @test_throws ArgumentError T(Mag(1), ArbRoundDown)
            @test_throws ArgumentError T(Mag(1), RoundNearest)
            @test_throws ArgumentError T(Mag(1), ArbRoundNearest)

            # Arf
            @test T(Arf(2)) isa T
            @test T(Arf(2)) == 2

            @test T(1 + Arf(eps(T)) / 3) == T(1)
            @test T(1 + Arf(eps(T)) / 3, RoundNearest) == T(1)
            @test T(1 + Arf(eps(T)) / 3, ArbRoundNearest) == T(1)
            @test T(1 + 2Arf(eps(T)) / 3, RoundNearest) == nextfloat(T(1))
            @test T(1 + 2Arf(eps(T)) / 3, ArbRoundNearest) == nextfloat(T(1))
            @test T(1 + Arf(eps(T)) / 3, RoundDown) == T(1)
            @test T(1 + Arf(eps(T)) / 3, ArbRoundDown) == T(1)
            @test T(1 + Arf(eps(T)) / 3, RoundUp) == nextfloat(T(1))
            @test T(1 + Arf(eps(T)) / 3, ArbRoundUp) == nextfloat(T(1))

            # Arb
            @test T(Arb(2)) isa T
            @test T(Arb(2)) == 2

            @test T(1 + Arb(eps(T)) / 3) == T(1)
            @test T(1 + Arb(eps(T)) / 3, RoundNearest) == T(1)
            @test T(1 + Arb(eps(T)) / 3, ArbRoundNearest) == T(1)
            @test T(1 + 2Arb(eps(T)) / 3, RoundNearest) == nextfloat(T(1))
            @test T(1 + 2Arb(eps(T)) / 3, ArbRoundNearest) == nextfloat(T(1))
            @test T(1 + Arb(eps(T)) / 3, RoundDown) == T(1)
            @test T(1 + Arb(eps(T)) / 3, ArbRoundDown) == T(1)
            @test T(1 + Arb(eps(T)) / 3, RoundUp) == nextfloat(T(1))
            @test T(1 + Arb(eps(T)) / 3, ArbRoundUp) == nextfloat(T(1))

            @test T(setball(Arb, 1 + Arf(eps(T)) / 3, Mag(1))) == T(1)
            @test T(setball(Arb, 1 + Arf(eps(T)) / 3, Mag(1)), RoundNearest) == T(1)
            @test T(setball(Arb, 1 + Arf(eps(T)) / 3, Mag(1)), ArbRoundNearest) == T(1)
            @test T(setball(Arb, 1 + 2Arf(eps(T)) / 3, Mag(1)), RoundNearest) ==
                  nextfloat(T(1))
            @test T(setball(Arb, 1 + 2Arf(eps(T)) / 3, Mag(1)), ArbRoundNearest) ==
                  nextfloat(T(1))
            @test T(setball(Arb, 1 + Arf(eps(T)) / 3, Mag(1)), RoundDown) == T(1)
            @test T(setball(Arb, 1 + Arf(eps(T)) / 3, Mag(1)), ArbRoundDown) == T(1)
            @test T(setball(Arb, 1 + Arf(eps(T)) / 3, Mag(1)), RoundUp) == nextfloat(T(1))
            @test T(setball(Arb, 1 + Arf(eps(T)) / 3, Mag(1)), ArbRoundUp) ==
                  nextfloat(T(1))
        end

        @testset "BigFloat" begin
            @test BigFloat(Arf(2)) isa BigFloat
            @test BigFloat(Arf(2)) == 2

            @test precision(BigFloat(Arf(2), precision = 80)) == 80
            @test precision(BigFloat(Arb(2), precision = 80)) == 80

            let precision = 80,
                ϵ = setprecision(eps(Arf(1, prec = precision)), 256),
                M = Base.MPFR

                @test BigFloat(1 + ϵ / 3; precision) == 1
                @test BigFloat(1 + ϵ / 3, RoundNearest; precision) == 1
                @test BigFloat(1 + ϵ / 3, ArbRoundNearest; precision) == 1
                @test BigFloat(1 + ϵ / 3, M.MPFRRoundNearest; precision) == 1
                @test BigFloat(1 + 2ϵ / 3, RoundNearest; precision) ==
                      nextfloat(BigFloat(1; precision))
                @test BigFloat(1 + 2ϵ / 3, ArbRoundNearest; precision) ==
                      nextfloat(BigFloat(1; precision))
                @test BigFloat(1 + 2ϵ / 3, M.MPFRRoundNearest; precision) ==
                      nextfloat(BigFloat(1; precision))
                @test BigFloat(1 + ϵ / 3, RoundDown; precision) == 1
                @test BigFloat(1 + ϵ / 3, ArbRoundDown; precision) == 1
                @test BigFloat(1 + ϵ / 3, M.MPFRRoundDown; precision) == 1
                @test BigFloat(1 + ϵ / 3, RoundUp; precision) ==
                      nextfloat(BigFloat(1; precision))
                @test BigFloat(1 + ϵ / 3, ArbRoundUp; precision) ==
                      nextfloat(BigFloat(1; precision))
                @test BigFloat(1 + ϵ / 3, M.MPFRRoundUp; precision) ==
                      nextfloat(BigFloat(1; precision))
            end

            let precision = 80,
                ϵ = setprecision(eps(Arb(1, prec = precision)), 256),
                M = Base.MPFR

                @test BigFloat(1 + ϵ / 3; precision) == 1
                @test BigFloat(1 + ϵ / 3, RoundNearest; precision) == 1
                @test BigFloat(1 + ϵ / 3, ArbRoundNearest; precision) == 1
                @test BigFloat(1 + ϵ / 3, M.MPFRRoundNearest; precision) == 1
                @test BigFloat(1 + 2ϵ / 3, RoundNearest; precision) ==
                      nextfloat(BigFloat(1; precision))
                @test BigFloat(1 + 2ϵ / 3, ArbRoundNearest; precision) ==
                      nextfloat(BigFloat(1; precision))
                @test BigFloat(1 + 2ϵ / 3, M.MPFRRoundNearest; precision) ==
                      nextfloat(BigFloat(1; precision))
                @test BigFloat(1 + ϵ / 3, RoundDown; precision) == 1
                @test BigFloat(1 + ϵ / 3, ArbRoundDown; precision) == 1
                @test BigFloat(1 + ϵ / 3, M.MPFRRoundDown; precision) == 1
                @test BigFloat(1 + ϵ / 3, RoundUp; precision) ==
                      nextfloat(BigFloat(1; precision))
                @test BigFloat(1 + ϵ / 3, ArbRoundUp; precision) ==
                      nextfloat(BigFloat(1; precision))
                @test BigFloat(1 + ϵ / 3, M.MPFRRoundUp; precision) ==
                      nextfloat(BigFloat(1; precision))
            end

            let precision = 80,
                ϵ = setprecision(eps(Arf(1, prec = precision)), 256),
                M = Base.MPFR

                @test BigFloat(setball(Arb, 1 + ϵ / 3, Mag(1)); precision) == 1
                @test BigFloat(setball(Arb, 1 + ϵ / 3, Mag(1)), RoundNearest; precision) ==
                      1
                @test BigFloat(
                    setball(Arb, 1 + ϵ / 3, Mag(1)),
                    ArbRoundNearest;
                    precision,
                ) == 1
                @test BigFloat(
                    setball(Arb, 1 + ϵ / 3, Mag(1)),
                    M.MPFRRoundNearest;
                    precision,
                ) == 1
                @test BigFloat(setball(Arb, 1 + 2ϵ / 3, Mag(1)), RoundNearest; precision) ==
                      nextfloat(BigFloat(1; precision))
                @test BigFloat(
                    setball(Arb, 1 + 2ϵ / 3, Mag(1)),
                    ArbRoundNearest;
                    precision,
                ) == nextfloat(BigFloat(1; precision))
                @test BigFloat(
                    setball(Arb, 1 + 2ϵ / 3, Mag(1)),
                    M.MPFRRoundNearest;
                    precision,
                ) == nextfloat(BigFloat(1; precision))
                @test BigFloat(setball(Arb, 1 + ϵ / 3, Mag(1)), RoundDown; precision) == 1
                @test BigFloat(setball(Arb, 1 + ϵ / 3, Mag(1)), ArbRoundDown; precision) ==
                      1
                @test BigFloat(
                    setball(Arb, 1 + ϵ / 3, Mag(1)),
                    M.MPFRRoundDown;
                    precision,
                ) == 1
                @test BigFloat(setball(Arb, 1 + ϵ / 3, Mag(1)), RoundUp; precision) ==
                      nextfloat(BigFloat(1; precision))
                @test BigFloat(setball(Arb, 1 + ϵ / 3, Mag(1)), ArbRoundUp; precision) ==
                      nextfloat(BigFloat(1; precision))
                @test BigFloat(setball(Arb, 1 + ϵ / 3, Mag(1)), M.MPFRRoundUp; precision) ==
                      nextfloat(BigFloat(1; precision))
            end
        end
    end

    @testset "Integers" begin
        @test Int(Arf(2.0)) isa Int
        @test Int(Arf(2.0)) == 2
        @test_throws InexactError Int(Arf(2.5))

        @test Arblib.get_si(Arf(0.5)) == 0
        @test Arblib.get_si(Arf(0.5); rnd = Arblib.ArbRoundFromZero) == 1
    end

    @testset "Complex" begin
        @test Complex{Float32}(Acb(2 + 3im)) isa Complex{Float32}
        @test Complex{Float64}(Acb(2 + 3im)) isa Complex{Float64}
        @test Complex{Arb}(Acb(2 + 3im)) isa Complex{Arb}
        @test Complex(Acb(2 + 3im)) isa Complex{Arb}

        @test Complex{Float32}(Acb(2 + 3im)) == 2.0 + 3.0im
        @test Complex{Float64}(Acb(2 + 3im)) == 2.0 + 3.0im
        @test Complex{Arb}(Acb(2 + 3im)) == 2.0 + 3.0im
        @test Complex(Acb(2 + 3im)) == 2.0 + 3.0im
    end
end
