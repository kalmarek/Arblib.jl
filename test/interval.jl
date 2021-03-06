@testset "interval" begin
    @testset "radius" begin
        x = Arb(2)
        y = Arb(2)
        Arblib.set!(Arblib.radref(y), one(Mag))

        @test radius(x) == radius(Mag, x) == radius(Arf, x) == radius(Arb, x) == zero(Mag)
        @test radius(y) == radius(Mag, y) == radius(Arf, y) == radius(Arb, y) == one(Mag)

        @test radius(x) isa Mag
        @test radius(Mag, x) isa Mag
        @test radius(Arf, x) isa Arf
        @test radius(Arb, x) isa Arb

        @test precision(radius(Arf, Arb(prec = 80))) == 80
        @test precision(radius(Arb, Arb(prec = 80))) == 80
    end

    @testset "midpoint" begin
        x = zero(Arb)
        y = one(Arb)

        @test midpoint(x) == midpoint(Arf, x) == midpoint(Arb, x) == zero(Arf)
        @test midpoint(y) == midpoint(Arf, y) == midpoint(Arb, y) == one(Arf)
        @test midpoint(x) isa Arf
        @test midpoint(Arf, x) isa Arf
        @test midpoint(Arb, x) isa Arb

        @test precision(midpoint(Arb(prec = 80))) == 80
        @test precision(midpoint(Arf, Arb(prec = 80))) == 80
        @test precision(midpoint(Arb, Arb(prec = 80))) == 80
    end

    @testset "lbound/ubound" begin
        x = Arb(2)
        y = Arb(0)
        Arblib.set!(Arblib.radref(y), 1)

        @test lbound(x) == lbound(Arf, x) == lbound(Arb, x) == Arf(2)
        @test lbound(y) == lbound(Arf, y) == lbound(Arb, y) == Arf(-1)
        @test ubound(x) == ubound(Arf, x) == ubound(Arb, x) == Arf(2)
        @test ubound(y) == ubound(Arf, y) == ubound(Arb, y) == Arf(1)

        @test typeof(lbound(x)) == typeof(ubound(x)) == Arf
        @test typeof(lbound(Arf, x)) == typeof(ubound(Arf, x)) == Arf
        @test typeof(lbound(Arb, x)) == typeof(ubound(Arb, x)) == Arb

        @test precision(lbound(Arb(prec = 80))) == 80
        @test precision(lbound(Arf, Arb(prec = 80))) == 80
        @test precision(lbound(Arb, Arb(prec = 80))) == 80
        @test precision(ubound(Arb(prec = 80))) == 80
        @test precision(ubound(Arf, Arb(prec = 80))) == 80
        @test precision(ubound(Arb, Arb(prec = 80))) == 80
    end

    @testset "abs_lbound/abs_ubound" begin
        x = Arb(-2)
        y = Arb(1)
        Arblib.set!(Arblib.radref(x), 1)
        Arblib.set!(Arblib.radref(y), 2)
        xc = Acb(0, x)
        yc = Acb(0, y)

        @test abs_lbound(x) ==
              abs_lbound(Arf, x) ==
              abs_lbound(Arb, x) ==
              abs_lbound(xc) ==
              abs_lbound(Arf, xc) ==
              abs_lbound(Arb, xc) ==
              Arf(1)
        @test abs_lbound(y) ==
              abs_lbound(Arf, y) ==
              abs_lbound(Arb, y) ==
              abs_lbound(yc) ==
              abs_lbound(Arf, yc) ==
              abs_lbound(Arb, yc) ==
              Arf(0)
        @test abs_ubound(x) ==
              abs_ubound(Arf, x) ==
              abs_ubound(Arb, x) ==
              abs_ubound(xc) ==
              abs_ubound(Arf, xc) ==
              abs_ubound(Arb, xc) ==
              Arf(3)
        @test abs_ubound(y) ==
              abs_ubound(Arf, y) ==
              abs_ubound(Arb, y) ==
              abs_ubound(yc) ==
              abs_ubound(Arf, yc) ==
              abs_ubound(Arb, yc) ==
              Arf(3)

        @test typeof(abs_lbound(x)) ==
              typeof(abs_ubound(x)) ==
              typeof(abs_lbound(xc)) ==
              typeof(abs_ubound(xc)) ==
              Arf
        @test typeof(abs_lbound(Arf, x)) ==
              typeof(abs_ubound(Arf, x)) ==
              typeof(abs_lbound(Arf, xc)) ==
              typeof(abs_ubound(Arf, xc)) ==
              Arf
        @test typeof(abs_lbound(Arb, x)) ==
              typeof(abs_ubound(Arb, x)) ==
              typeof(abs_lbound(Arb, xc)) ==
              typeof(abs_ubound(Arb, xc)) ==
              Arb

        @test precision(abs_lbound(Arb(prec = 80))) ==
              precision(abs_lbound(Acb(prec = 80))) ==
              80
        @test precision(abs_lbound(Arf, Arb(prec = 80))) ==
              precision(abs_lbound(Arf, Acb(prec = 80))) ==
              80
        @test precision(abs_lbound(Arb, Arb(prec = 80))) ==
              precision(abs_lbound(Arb, Acb(prec = 80))) ==
              80
        @test precision(abs_ubound(Arb(prec = 80))) ==
              precision(abs_ubound(Acb(prec = 80))) ==
              80
        @test precision(abs_ubound(Arf, Arb(prec = 80))) ==
              precision(abs_ubound(Arf, Acb(prec = 80))) ==
              80
        @test precision(abs_ubound(Arb, Arb(prec = 80))) ==
              precision(abs_ubound(Arb, Acb(prec = 80))) ==
              80
    end

    @testset "getinterval" begin
        x = one(Arb)
        y = one(Arb)
        Arblib.set!(Arblib.radref(y), 1)

        @test getinterval(x) ==
              getinterval(Arf, x) ==
              getinterval(BigFloat, x) ==
              getinterval(Arb, x) ==
              (one(Arf), one(Arf))
        @test getinterval(y) ==
              getinterval(Arf, y) ==
              getinterval(BigFloat, y) ==
              getinterval(Arb, y) ==
              (Arf(0), Arf(2))

        @test getinterval(x) isa NTuple{2,Arf}
        @test getinterval(Arf, x) isa NTuple{2,Arf}
        @test getinterval(BigFloat, x) isa NTuple{2,BigFloat}
        @test getinterval(Arb, x) isa NTuple{2,Arb}

        @test precision.(getinterval(Arb(prec = 80))) == (80, 80)
        @test precision.(getinterval(Arf, Arb(prec = 80))) == (80, 80)
        @test precision.(getinterval(BigFloat, Arb(prec = 80))) == (80, 80)
        @test precision.(getinterval(Arb, Arb(prec = 80))) == (80, 80)
    end

    @testset "getball" begin
        x = one(Arb)
        y = one(Arb)
        Arblib.set!(Arblib.radref(y), 1)

        @test getball(x) == getball(Arb, x) == (one(Arf), zero(Mag))
        @test getball(y) == getball(Arb, y) == (one(Arf), one(Mag))

        @test getball(x) isa Tuple{Arf,Mag}
        @test getball(Arb, x) isa Tuple{Arb,Arb}

        @test precision(getball(Arb(prec = 80))[1]) == 80
        @test precision.(getball(Arb, Arb(prec = 80))) == (80, 80)
    end

    @testset "union" begin
        xs = [Arb(i) for i in vcat(1:10, 10:-1:1)]
        xsc = Acb.(xs)

        @test Arblib.contains(union(zero(Arb), one(Arb)), Arb(0.5))
        @test Arblib.contains(union(zero(Acb), Acb(1, 1)), Acb(0.5, 0.5))
        @test all(i -> Arblib.contains(union(xs...), i), 1:10)
        @test all(i -> Arblib.contains(union(xsc...), i), Acb.(1:10))

        @test precision(union(Arb(prec = 80), Arb(prec = 90))) == 90
        @test precision(union(Acb(prec = 80), Acb(prec = 90))) == 90
        @test precision(union([Arb(prec = p) for p = 70:10:100]...)) == 100
        @test precision(union([Acb(prec = p) for p = 70:10:100]...)) == 100
    end

    @testset "intersect" begin
        xs = [Arb((0, i)) for i in vcat(1:10, 10:-1:1)]

        @test Arblib.contains(intersect(Arb((0, 2)), Arb((1, 3))), Arb((1, 2)))
        @test Arblib.contains(intersect(xs...), Arb((0, 1)))
        @test !Arblib.contains(intersect(xs...), Arb(2))

        @test precision(intersect(Arb(prec = 80), Arb(prec = 90))) == 90
        @test precision(intersect([Arb(prec = p) for p = 70:10:100]...)) == 100

        @test_throws ArgumentError intersect(Arb(1), Arb(2))
        @test_throws ArgumentError intersect([xs; Arb(2)]...)
    end
end
