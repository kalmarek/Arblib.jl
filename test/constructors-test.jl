@testset "constructors" begin
    @testset "Mag" begin
        # Results for doubles are only upper bounds, even for integers
        # they are quite crude
        @test Mag(UInt64(0)) == zero(Mag) == zero(Mag()) == Mag(0.0)
        @test Mag(UInt64(1)) == one(Mag) == one(Mag()) <= Mag(1.0)
        @test π < Float64(Mag(π)) < 3.15
    end

    @testset "Arf" begin
        for T in [UInt, Int, Float64, Mag, Arf, BigFloat]
            @test Arf(zero(T)) == zero(Arf)
            @test Arf(one(T)) == one(Arf)
            @test precision(Arf(zero(T), prec = 80)) == 80
        end

        @test Arf(zero(Arf).arf) == zero(Arf)
        @test precision(Arf(zero(Arf).arf, prec = 80)) == 80

        @test precision(Arf(Arf(prec = 80))) == 80
        @test precision(Arf(BigFloat(0, precision = 80))) == 80

        @test precision(zero(Arf(prec = 80))) == 80
        @test precision(one(Arf(prec = 80))) == 80

        # TODO: Move these to other file
        @test Float64(Arf(2.0)) isa Float64
        @test Float64(Arf(2.0)) == 2.0
        @test convert(Float64, Arf(2.0)) isa Float64
        @test convert(Float64, Arf(2.0)) == 2.0
        @test Int(Arf(2.0)) isa Int
        @test Int(Arf(2.0)) == 2
        @test convert(Int, Arf(2.0)) isa Int
        @test convert(Int, Arf(2.0)) == 2
        @test Int(Arf(2.0)) == 2
        @test Int(Arf(0.5)) == 0
        @test Int(Arf(0.5); rnd = Arblib.ArbRoundFromZero) == 1
    end

    @testset "Arb" begin
        for T in [UInt, Int, Float64, Arf, Arb, BigFloat, Rational{Int}]
            @test Arb(zero(T)) == zero(Arb)
            @test Arb(one(T)) == one(Arb)
            @test precision(Arb(zero(T), prec = 80)) == 80
        end

        @test Arb(zero(Arb).arb) == Arb("0.0") == zero(Arb)
        @test Arb(one(Arb).arb) == Arb("1.0") == one(Arb)
        @test precision(Arb(zero(Arb).arb, prec = 80)) ==
              precision(Arb("0.0", prec = 80)) ==
              80

        @test precision(Arb(Arf(prec = 80))) == 80
        @test precision(Arb(Arb(prec = 80))) == 80
        @test precision(Arb(BigFloat(0, precision = 80))) == 80

        @test precision(zero(Arb(prec = 80))) == 80
        @test precision(one(Arb(prec = 80))) == 80

        @test Arb(3) < Arb(π) < Arb(4)
        @test Arb(2) < Arb(ℯ) < Arb(3)
        @test Arb(0) < Arb(MathConstants.γ) < Arb(1)
        @test precision(Arb(π, prec = 80)) == 80
        @test precision(Arb(ℯ, prec = 80)) == 80
        @test precision(Arb(MathConstants.γ, prec = 80)) == 80
    end

    @testset "Acb" begin
        for T in [UInt, Int, Float64, Arf, Arb, BigFloat, Rational{Int}]
            @test Acb(zero(T)) == zero(Acb)
            @test Acb(one(T)) == one(Acb)
            @test precision(Acb(zero(T), prec = 80)) == 80

            @test imag(Acb(zero(T), one(T))) == one(Arb)
            @test precision(Acb(zero(T), zero(T), prec = 80)) == 80

            @test imag(Acb(Complex(zero(T), one(T)))) == one(Arb)
            @test precision(Acb(Complex(zero(T), zero(T)), prec = 80)) == 80
        end

        @test Acb(zero(Acb).acb) == Acb("0.0") == zero(Acb)
        @test Acb(one(Acb).acb) == Acb("1.0") == one(Acb)
        @test precision(Acb(zero(Acb).acb, prec = 80)) ==
              precision(Acb("0.0", prec = 80)) ==
              80

        @test imag(Acb(zero(Arb).arb, one(Arb).arb)) == imag(Acb("0.0", "1.0")) == one(Arb)
        @test precision(Acb(zero(Arb).arb, zero(Arb).arb, prec = 80)) ==
              precision(Acb("0.0", "0.0", prec = 80)) ==
              80

        @test precision(Acb(Arf(prec = 80))) == 80
        @test precision(Acb(Arb(prec = 80))) == 80
        @test precision(Acb(Acb(prec = 80))) == 80
        @test precision(Acb(BigFloat(0, precision = 80))) == 80

        @test precision(Acb(Arf(prec = 80), Arf(prec = 100))) == 100
        @test precision(Acb(Arb(prec = 80), Arb(prec = 100))) == 100
        @test precision(Acb(BigFloat(0, precision = 80), BigFloat(0, precision = 100))) ==
              100

        @test precision(Acb(Complex(Arf(prec = 80), Arf(prec = 100)))) == 100
        @test precision(Acb(Complex(Arb(prec = 80), Arb(prec = 100)))) == 100
        @test precision(Acb(Complex(
            BigFloat(0, precision = 80),
            BigFloat(0, precision = 100),
        ))) == 100

        @test precision(zero(Arb(prec = 80))) == 80
        @test precision(one(Arb(prec = 80))) == 80

        @test isequal(real(Acb(π)), Arb(π))
        @test isequal(real(Acb(ℯ)), Arb(ℯ))
        @test isequal(real(Acb(MathConstants.γ)), Arb(MathConstants.γ))
        @test precision(Acb(π, prec = 80)) == 80
        @test precision(Acb(ℯ, prec = 80)) == 80
        @test precision(Acb(MathConstants.γ, prec = 80)) == 80

        @test isequal(Acb(π, -1), Acb(Arb(π), Arb(-1)))
        @test isequal(Acb(BigFloat(1.3), ℯ), Acb(Arb(1.3), Arb(ℯ)))
    end
end
