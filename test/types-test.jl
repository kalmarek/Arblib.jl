@testset "types" begin
    Mag = Arblib.Mag

    @testset "Mag" begin
        @test typeof(Mag()) == Mag
        @test typeof(Mag(Mag())) == Mag
        @test typeof(Mag(Arf())) == Mag
    end

    @testset "Arf" begin
        @test typeof(Arf()) == Arf
        @test precision(Arf(prec = 64)) == 64
        @test typeof(Arf(UInt64(1))) == Arf
        @test precision(Arf(UInt64(1), prec = 64)) == 64
        @test typeof(Arf(1)) == Arf
        @test precision(Arf(1, prec = 64)) == 64
    end

    @testset "Arb" begin
        @test typeof(Arb()) == Arb
        @test precision(Arb(prec = 64)) == 64
    end

    @testset "Acb" begin
        @test typeof(Acb()) == Acb
        @test precision(Acb(prec = 64)) == 64
    end
end
