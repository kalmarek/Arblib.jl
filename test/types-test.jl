@testset "types" begin
    @testset "Mag" begin
        @test Mag() isa Mag
        @test Mag(Mag()) isa Mag
        @test Mag(Arf()) isa Mag
        x = Mag()
        y = copy(x)
        Arblib.set!(x, 1)
        @test x == Mag(1)
        @test y == Mag(0)
    end

    @testset "Arf" begin
        @test Arf() isa Arf
        @test precision(Arf(prec = 80)) == 80
        @test Arf(UInt64(1)) isa Arf
        @test precision(Arf(UInt64(1), prec = 80)) == 80
        @test Arf(1) isa Arf
        @test precision(Arf(1, prec = 80)) == 80
        x = Arf()
        y = copy(x)
        Arblib.set!(x, 1)
        @test x == Arf(1)
        @test y == Arf(0)
    end

    @testset "Arb" begin
        @test Arb() isa Arb
        @test precision(Arb(prec = 80)) == 80
        x = Arb()
        y = copy(x)
        Arblib.set!(x, 1)
        @test x == Arb(1)
        @test y == Arb(0)
    end

    @testset "Acb" begin
        @test Acb() isa Acb
        @test precision(Acb(prec = 80)) == 80
        x = Acb()
        y = copy(x)
        Arblib.set!(x, 1)
        @test x == Acb(1)
        @test y == Acb(0)
    end

    @testset "ArbPoly" begin
        @test ArbPoly() isa ArbPoly
        @test precision(ArbPoly(prec = 80)) == 80
    end

    @testset "ArbSeries" begin
        @test ArbSeries(3) isa ArbSeries
        @test precision(ArbSeries(3, prec = 80)) == 80
        @test ArbSeries(3).degree == 3
    end

    @testset "AcbPoly" begin
        @test AcbPoly() isa AcbPoly
        @test precision(AcbPoly(prec = 80)) == 80
    end

    @testset "AcbSeries" begin
        @test AcbSeries(3) isa AcbSeries
        @test precision(AcbSeries(3, prec = 80)) == 80
        @test AcbSeries(3).degree == 3
    end
end
