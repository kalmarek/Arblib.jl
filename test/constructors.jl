@testset "constructors" begin
    @testset "Mag" begin
        # Results for doubles are only upper bounds, even for integers
        # they are quite crude
        @test Mag() == Mag(UInt64(0)) == Mag(0) == zero(Mag) == zero(Mag()) == Mag(0.0)
        @test Mag(UInt64(1)) == Mag(1) == one(Mag) == one(Mag()) <= Mag(1.0)
        @test π < Float64(Mag(π)) < 3.15
        @test Mag(3, 4) == Mag(3 * 2^4)

        # Test init_set! constructor
        @test Mag(Ptr{Arblib.mag_struct}(pointer_from_objref(Mag().mag))) == Mag()

        # Check for ambiguities
        @test Mag(1 + 0im) == Mag(1)
        @test_throws InexactError Mag(1 + im)
    end

    @testset "Arf" begin
        for T in [UInt, Int, Float64, Mag, Arf, BigFloat]
            @test Arf(zero(T)) == zero(Arf)
            @test Arf(one(T)) == one(Arf)
            @test precision(Arf(zero(T), prec = 80)) == 80
        end

        @test Arf(0) == zero(Arf)
        @test precision(Arf(zero(Arf), prec = 80)) == 80

        @test precision(Arf(Arf(prec = 80))) == 80
        @test precision(Arf(BigFloat(0, precision = 80))) == 80

        @test precision(zero(Arf(prec = 80))) == 80
        @test precision(one(Arf(prec = 80))) == 80

        # Check for ambiguities
        @test Arf(1 + 0im) == 1
        @test_throws InexactError Arf(1 + im)
    end

    @testset "Acf" begin
        for T in [UInt, Int, Float64, Mag, Arf, BigFloat]
            @test Acf(zero(T)) == zero(Acf)
            @test Acf(one(T)) == one(Acf)
            @test precision(Acf(zero(T), prec = 80)) == 80

            @test imag(Acf(zero(T), one(T))) == one(Arb)
            @test precision(Acf(zero(T), zero(T), prec = 80)) == 80

            @test imag(Acf(Complex(zero(T), one(T)))) == one(Arb)
            @test precision(Acf(Complex(zero(T), zero(T)), prec = 80)) == 80
        end

        @test Acf(0) == zero(Acf)
        @test Acb(1) == one(Acf)

        @test imag(Acf(zero(Arf), one(Arf))) == one(Arf)
        @test precision(Acf(zero(Arf), zero(Arf), prec = 80)) == 80

        @test precision(Acf(Arf(prec = 80))) == 80
        @test precision(Acf(Acf(prec = 80))) == 80
        @test precision(Acf(BigFloat(0, precision = 80))) == 80

        @test precision(Acf(Arf(prec = 80), Arf(prec = 100))) == 100
        @test precision(Acf(BigFloat(0, precision = 80), BigFloat(0, precision = 100))) ==
              100

        @test precision(Acf(Complex(Arf(prec = 80), Arf(prec = 100)))) == 100
        @test precision(
            Acf(Complex(BigFloat(0, precision = 80), BigFloat(0, precision = 100))),
        ) == 100

        @test precision(zero(Acf(prec = 80))) == 80
        @test precision(one(Acf(prec = 80))) == 80
    end

    @testset "Arb" begin
        for T in [UInt, Int, Float64, Arf, Arb, BigInt, BigFloat, Rational{Int}]
            @test Arb(zero(T)) == zero(Arb)
            @test Arb(one(T)) == one(Arb)
            @test precision(Arb(zero(T), prec = 80)) == 80
        end

        @test Arb((0, 0)) == zero(Arb)
        @test Arb((one(Arf), one(Arf))) == one(Arb)
        @test isequal(Arb((Arf(1), Arf(2))), Arb((1, 2)))

        @test Arb(0) == Arb("0.0") == zero(Arb)
        @test Arb(1) == Arb("1.0") == one(Arb)
        @test precision(Arb(zero(Arb), prec = 80)) == precision(Arb("0.0", prec = 80)) == 80

        @test precision(Arb(Arf(prec = 80))) == 80
        @test precision(Arb(Arb(prec = 80))) == 80
        @test precision(Arb(BigFloat(0, precision = 80))) == 80

        @test precision(zero(Arb(prec = 80))) == 80
        @test precision(one(Arb(prec = 80))) == 80

        @test Arb(3) < Arb(π) < Arb(4)
        @test Arb(2) < Arb(ℯ) < Arb(3)
        @test Arb(0) < Arb(MathConstants.γ) < Arb(1)
        @test Arb(0) < Arb(MathConstants.catalan) < Arb(1)
        @test Arblib.overlaps(Arb(BigFloat(MathConstants.φ)), Arb(MathConstants.φ))
        @test precision(Arb(π, prec = 80)) == 80
        @test precision(Arb(ℯ, prec = 80)) == 80
        @test precision(Arb(MathConstants.γ, prec = 80)) == 80
        @test precision(Arb(MathConstants.catalan, prec = 80)) == 80
        @test precision(Arb(MathConstants.φ, prec = 80)) == 80

        @test Arb(Acb(1)) == 1
        @test precision(Arb(Acb(1, prec = 80))) == 80
        @test_throws InexactError Arb(Acb(1, 1))

        # setball
        @test isone(Arblib.setball(Arb, Arf(1), Mag(0)))
        @test isone(Arblib.setball(Arb, 1, 0))
        @test isone(Arblib.setball(Arb, 1.0, 0.0))
        @test isone(Arblib.setball(Arb, big(1.0), 0))
        @test isone(Arblib.setball(Arb, 1 // 1, 0))

        @test getinterval(Arblib.setball(Arb, 2, 1)) == (1, 3)
        @test Arblib.contains(Arblib.setball(Arb, 0.5, 0.5), 0)
        @test Arblib.contains(Arblib.setball(Arb, 0.5, 0.5), 1)

        @test precision(Arblib.setball(Arb, Arf(prec = 80), 0)) == 80
        @test precision(Arblib.setball(Arb, Arf(prec = 90), 0, prec = 80)) == 80

        # Check for ambiguities
        @test Arb(1 + 0im) == 1
        @test_throws InexactError Arb(1 + im)
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

        @test Acb(0) == Acb("0.0") == zero(Acb)
        @test Acb(1) == Acb("1.0") == one(Acb)
        @test precision(Acb("0.0", prec = 80)) == 80

        @test imag(Acb(zero(Arb), one(Arb))) == imag(Acb("0.0", "1.0")) == one(Arb)
        @test precision(Acb(zero(Arb), zero(Arb), prec = 80)) ==
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
        @test precision(
            Acb(Complex(BigFloat(0, precision = 80), BigFloat(0, precision = 100))),
        ) == 100

        @test precision(zero(Acb(prec = 80))) == 80
        @test precision(one(Acb(prec = 80))) == 80

        @test isequal(real(Acb(π)), Arb(π))
        @test isequal(real(Acb(ℯ)), Arb(ℯ))
        @test isequal(real(Acb(MathConstants.γ)), Arb(MathConstants.γ))
        @test precision(Acb(π, prec = 80)) == 80
        @test precision(Acb(ℯ, prec = 80)) == 80
        @test precision(Acb(MathConstants.γ, prec = 80)) == 80

        @test isequal(Acb(π, -1), Acb(Arb(π), Arb(-1)))
        @test isequal(Acb(BigFloat(1.3), ℯ), Acb(Arb(1.3), Arb(ℯ)))

        @test isequal(Acb((1, 2)), Acb(Arb((1, 2))))
        @test isequal(Acb((1, 2), (3, 4)), Acb(Arb((1, 2)), Arb((3, 4))))
    end

    @testset "zeros/ones" begin
        for T in [Mag, Arf, Acf, Arb, Acb]
            @test zeros(T, 2) == zeros(one(T), 2) == [zero(T), zero(T)]
            @test ones(T, 2) == ones(zero(T), 2) == [one(T), one(T)]
        end

        v = zeros(Arb, 2)
        @test length(v) == 2
        @test v[1] == v[2] == zero(Arb)
        Arblib.set!(v[2], 1)
        @test v[1] == zero(Arb) && v[2] == one(Arb)

        v = ones(Arb, 2)
        @test length(v) == 2
        @test v[1] == v[2] == one(Arb)
        Arblib.set!(v[2], 0)
        @test v[1] == one(Arb) && v[2] == zero(Arb)
    end
end
