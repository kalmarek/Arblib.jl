@testset "constructors" begin
    @testset "Mag" begin
        @test typeof(Mag(UInt64(1))) == Mag
        @test typeof(Mag(1.0)) == Mag
        @test typeof(zero(Mag)) == Mag
        @test typeof(one(Mag)) == Mag
        @test typeof(zero(Mag())) == Mag
        @test typeof(one(Mag())) == Mag
        @test typeof(Mag(π)) == Mag
        @test typeof(Mag(Mag().mag)) == Mag
        @test typeof(Mag(Mag().mag)) == Mag
        @test Float64(Mag(2.0)) isa Float64
        # Mag doesn't guarantee exact conversions, just upper bounds
        @test Float64(Mag(2.0)) ≥ 2.0
    end

    @testset "Arf" begin
        @test typeof(Arf(UInt64(1))) == Arf
        @test typeof(Arf(1)) == Arf
        @test typeof(Arf(1.0)) == Arf
        @test typeof(Arf(BigFloat(1))) == Arf
        @test typeof(Arf(Mag())) == Arf
        @test typeof(Arf(Arf())) == Arf
        @test typeof(zero(Arf)) == Arf
        @test typeof(one(Arf)) == Arf

        @test precision(Arf(UInt64(1), prec = 64)) == 64
        @test precision(Arf(1, prec = 64)) == 64
        @test precision(Arf(1.0, prec = 64)) == 64
        @test precision(Arf(BigFloat(1, precision = 64))) == 64
        @test precision(Arf(Mag(), prec = 64)) == 64
        @test precision(Arf(Arf(prec = 64))) == 64
        @test precision(zero(Arf(prec = 64))) == 64
        @test precision(one(Arf(prec = 64))) == 64

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
        @test typeof(Arb(UInt64(1))) == Arb
        @test typeof(Arb(1)) == Arb
        @test typeof(Arb(1.0)) == Arb
        @test typeof(Arb(Arf())) == Arb
        @test typeof(Arb(Arb())) == Arb
        @test typeof(Arb("1.1")) == Arb
        @test typeof(zero(Arb)) == Arb
        @test typeof(one(Arb)) == Arb
        @test typeof(Arb(π)) == Arb
        @test typeof(Arb(ℯ)) == Arb
        @test typeof(Arb(MathConstants.γ)) == Arb

        @test precision(Arb(UInt64(1), prec = 64)) == 64
        @test precision(Arb(1, prec = 64)) == 64
        @test precision(Arb(1.0, prec = 64)) == 64
        @test precision(Arb(Arf(prec = 64))) == 64
        @test precision(Arb(Arb(prec = 64))) == 64
        @test precision(Arb("1.1", prec = 64)) == 64
        @test precision(zero(Arb(prec = 64))) == 64
        @test precision(one(Arb(prec = 64))) == 64
        @test precision(Arb(π, prec = 64)) == 64
        @test typeof(Arb(ℯ, prec = 64)) == Arb
        @test typeof(Arb(MathConstants.γ, prec = 64)) == Arb
    end

    @testset "Acb" begin
        @test typeof(Acb(UInt64(1))) == Acb
        @test typeof(Acb(1)) == Acb
        @test typeof(Acb(1.0)) == Acb
        @test typeof(Acb(Arb())) == Acb
        @test typeof(Acb(Acb())) == Acb
        @test typeof(Acb(1, 1)) == Acb
        @test typeof(Acb(1.0, 1.0)) == Acb
        @test typeof(Acb(Arb(), Arb())) == Acb
        @test typeof(Acb(complex(1, 1))) == Acb
        @test typeof(Acb(complex(1.0, 1.0))) == Acb
        @test typeof(Acb(complex(Arb(), Arb()))) == Acb
        @test typeof(zero(Acb)) == Acb
        @test typeof(one(Acb)) == Acb
        @test typeof(Acb(π)) == Acb

        @test precision(Acb(UInt64(1), prec = 64)) == 64
        @test precision(Acb(1, prec = 64)) == 64
        @test precision(Acb(1.0, prec = 64)) == 64
        @test precision(Acb(Arb(prec = 64))) == 64
        @test precision(Acb(Acb(prec = 64))) == 64
        @test precision(Acb(1, 1, prec = 64)) == 64
        @test precision(Acb(1.0, 1.0, prec = 64)) == 64
        @test precision(Acb(Arb(), Arb(), prec = 64)) == 64
        @test precision(zero(Acb(prec = 64))) == 64
        @test precision(one(Acb(prec = 64))) == 64
        @test precision(Acb(π, prec = 64)) == 64

        x = Acb()
        x[] = (1.0 + 2.0im)
        @test x == Acb(1, 2)
    end

    @testset "MagRef/ArfRef" begin
        x = Arb(2.0)
        m = Arblib.radref(x)
        @test m isa MagRef
        @test m[] isa Mag
        @test m == m[]

        d = Arblib.midref(x)
        @test d isa ArfRef
        @test d[] isa Arf
        @test d == d[]
    end

    @testset "Set Rational" begin
        z = Arb(prec=64)
        z[] = 1//2
        @test z == 0.5

        z = Acb(prec=64)
        z[] = 1//2
        @test z == 0.5

        z = Acb(prec=64)
        z[] = 1//2 + 3//4  * im
        @test z == 0.5 + 0.75im
    end
end
