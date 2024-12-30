@testset "types" begin
    @testset "Mag" begin
        @test Mag() isa Mag
        @test Mag(Arblib.cstruct(Mag())) isa Mag
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
        x = ArbPoly()
        y = copy(x)
        x[0] = 10
        @test x == ArbPoly(10)
        @test y == ArbPoly(0)
    end

    @testset "ArbSeries" begin
        @test ArbSeries() isa ArbSeries
        @test precision(ArbSeries(prec = 80)) == 80
        @test ArbSeries(degree = 3).degree == 3
        x = ArbSeries(degree = 2)
        y = copy(x)
        x[0] = 10
        @test x == ArbSeries(10, degree = 2)
        @test y == ArbSeries(0, degree = 2)
    end

    @testset "AcbPoly" begin
        @test AcbPoly() isa AcbPoly
        @test precision(AcbPoly(prec = 80)) == 80
        x = AcbPoly()
        y = copy(x)
        x[0] = 10
        @test x == AcbPoly(10)
        @test y == AcbPoly(0)
    end

    @testset "AcbSeries" begin
        @test AcbSeries() isa AcbSeries
        @test precision(AcbSeries(prec = 80)) == 80
        @test AcbSeries(degree = 3).degree == 3
        x = AcbSeries(degree = 2)
        y = copy(x)
        x[0] = 10
        @test x == AcbSeries(10, degree = 2)
        @test y == AcbSeries(0, degree = 2)
    end
end
