@testset "interval" begin
    @testset "radius" begin
        x = Arb(2)
        y = Arb(2)
        Arblib.set!(Arblib.radref(y), one(Mag))

        @test radius(x) == radius(Mag, x) == radius(Arf, x) == radius(Arb, x) == 0
        @test radius(y) == radius(Mag, y) == radius(Arf, y) == radius(Arb, y) == 1

        @test radius(x) isa Mag
        @test radius(Mag, x) isa Mag
        @test radius(Arf, x) isa Arf
        @test radius(Arb, x) isa Arb
        @test radius(Float64, x) isa Float64

        @test precision(radius(Arf, Arb(prec = 80))) == 80
        @test precision(radius(Arb, Arb(prec = 80))) == 80
    end

    @testset "midpoint" begin
        x = zero(Arb)
        y = one(Arb)

        @test midpoint(x) == midpoint(Arf, x) == midpoint(Arb, x) == 0
        @test midpoint(y) == midpoint(Arf, y) == midpoint(Arb, y) == 1
        @test midpoint(x) isa Arf
        @test midpoint(Arf, x) isa Arf
        @test midpoint(Arb, x) isa Arb

        @test precision(midpoint(Arb(prec = 80))) == 80
        @test precision(midpoint(Arf, Arb(prec = 80))) == 80
        @test precision(midpoint(Arb, Arb(prec = 80))) == 80

        x = zero(Acb)
        y = Acb(1, 1)

        @test midpoint(x) == midpoint(Arf, x) == midpoint(Arb, x) == midpoint(Acb, x) == 0
        @test midpoint(y) ==
              midpoint(Arf, y) ==
              midpoint(Arb, y) ==
              midpoint(Acb, y) ==
              1 + im
        @test midpoint(x) isa Complex{Arf}
        @test midpoint(Arf, x) isa Complex{Arf}
        @test midpoint(Arb, x) isa Complex{Arb}
        @test midpoint(Acb, x) isa Acb

        @test precision(real(midpoint(Acb(prec = 80)))) == 80
        @test precision(imag(midpoint(Acb(prec = 80)))) == 80
        @test precision(real(midpoint(Arf, Acb(prec = 80)))) == 80
        @test precision(imag(midpoint(Arf, Acb(prec = 80)))) == 80
        @test precision(real(midpoint(Arb, Acb(prec = 80)))) == 80
        @test precision(imag(midpoint(Arb, Acb(prec = 80)))) == 80
        @test precision(midpoint(Acb, Acb(prec = 80))) == 80
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

        @test getball(x) == getball(Arf, x) == getball(Arb, x) == (one(Arf), zero(Mag))
        @test getball(y) == getball(Arf, y) == getball(Arb, y) == (one(Arf), one(Mag))

        @test getball(x) isa Tuple{Arf,Mag}
        @test getball(Arf, x) isa Tuple{Arf,Arf}
        @test getball(Arb, x) isa Tuple{Arb,Arb}

        @test precision(getball(Arb(prec = 80))[1]) == 80
        @test precision.(getball(Arf, Arb(prec = 80))) == (80, 80)
        @test precision.(getball(Arb, Arb(prec = 80))) == (80, 80)
    end

    @testset "union" begin
        xs = [Arb(i) for i in vcat(1:10, 10:-1:1)]
        xsc = Acb.(xs)

        @test Arblib.contains(Arblib.union(zero(Arb), one(Arb)), Arb(0.5))
        @test Arblib.contains(Arblib.union(zero(Acb), Acb(1, 1)), Acb(0.5, 0.5))
        @test all(i -> Arblib.contains(Arblib.union(xs...), i), 1:10)
        @test all(i -> Arblib.contains(Arblib.union(xsc...), i), Acb.(1:10))

        @test precision(Arblib.union(Arb(prec = 80), Arb(prec = 90))) == 90
        @test precision(Arblib.union(Acb(prec = 80), Acb(prec = 90))) == 90
        @test precision(Arblib.union([Arb(prec = p) for p = 70:10:100]...)) == 100
        @test precision(Arblib.union([Acb(prec = p) for p = 70:10:100]...)) == 100

        # Alternative (very inefficient) implementation of
        # Arblib.union
        union_alt(p, q) =
            let m = max(Arblib.degree(p), Arblib.degree(q))
                typeof(p)(Arblib.union.([p[i] for i = 0:m], [q[i] for i = 0:m]))
            end
        union_alt(p, q, ps...) = foldr(union_alt, [p, q, ps...])

        # Same degrees

        for T in [ArbPoly, AcbPoly, ArbSeries, AcbSeries]
            ps = [T([i, 10i]) for i in vcat(1:5, 5:-1:1)]
            @test isequal(Arblib.union(ps[1], ps[2]), union_alt(ps[1], ps[2]))
            @test isequal(Arblib.union(ps...), union_alt(ps...))
        end

        # Different degrees

        for T in [ArbPoly, AcbPoly]
            p, q = T([1, 2, 3]), T([2, 3])
            @test isequal(Arblib.union(p, q), union_alt(p, q))
            @test isequal(Arblib.union(q, p), union_alt(p, q))

            ps = [T(i:2i) for i in vcat(1:5, 5:-1:1)]
            @test isequal(Arblib.union(ps...), union_alt(ps...))
        end

        for T in [ArbSeries, AcbSeries]
            p1, p2 = T(degree = 1), T(degree = 2)
            @test_throws ArgumentError Arblib.union(p1, p2)
            @test_throws ArgumentError Arblib.union(p2, p1)
            @test_throws ArgumentError Arblib.union(p1, p2, p2)
            @test_throws ArgumentError Arblib.union(p2, p1, p2)
            @test_throws ArgumentError Arblib.union(p2, p2, p1)
        end
    end

    @testset "intersection" begin
        xs = [Arb((0, i)) for i in vcat(1:10, 10:-1:1)]

        @test Arblib.contains(Arblib.intersection(Arb((0, 2)), Arb((1, 3))), Arb((1, 2)))
        @test Arblib.contains(Arblib.intersection(xs...), Arb((0, 1)))
        @test !Arblib.contains(Arblib.intersection(xs...), Arb(2))

        @test precision(Arblib.intersection(Arb(prec = 80), Arb(prec = 90))) == 90
        @test precision(Arblib.intersection([Arb(prec = p) for p = 70:10:100]...)) == 100

        @test_throws ArgumentError Arblib.intersection(Arb(1), Arb(2))
        @test_throws ArgumentError Arblib.intersection([xs; Arb(2)]...)

        # Alternative (very inefficient) implementation of
        # Arblib.intersection
        intersection_alt(p, q) =
            let m = max(Arblib.degree(p), Arblib.degree(q))
                typeof(p)(Arblib.intersection.([p[i] for i = 0:m], [q[i] for i = 0:m]))
            end
        intersection_alt(p, q, ps...) = foldr(intersection_alt, [p, q, ps...])

        # Same degrees

        for T in [ArbPoly, ArbSeries]
            ps = [T([Arb((-i, i)), Arb((-10i, 10i))]) for i in vcat(1:5, 5:-1:1)]
            @test isequal(Arblib.intersection(ps[1], ps[2]), intersection_alt(ps[1], ps[2]))
            @test isequal(Arblib.intersection(ps...), intersection_alt(ps...))

            p, q = T([1, 2]), T([1, 3])
            @test_throws ArgumentError Arblib.intersection(p, q)
        end

        # Different degrees

        let T = ArbPoly
            p, q = T([1, 2, Arb((-1, 1))]), T([1, 2])
            @test isequal(Arblib.intersection(p, q), intersection_alt(p, q))
            @test isequal(Arblib.intersection(q, p), intersection_alt(p, q))

            p, q = T([1, 2, NaN]), T([1, 2])
            @test isequal(Arblib.intersection(p, q), intersection_alt(p, q))
            @test isequal(Arblib.intersection(q, p), intersection_alt(p, q))

            ps = [T([Arb((-j, j)) for j = 1:i]) for i in vcat(1:5, 5:-1:1)]
            @test isequal(Arblib.intersection(ps...), intersection_alt(ps...))
        end

        let T = ArbSeries
            p1, p2 = T(degree = 1), T(degree = 2)
            @test_throws ArgumentError Arblib.intersection(p1, p2)
            @test_throws ArgumentError Arblib.intersection(p2, p1)
            @test_throws ArgumentError Arblib.intersection(p1, p2, p2)
            @test_throws ArgumentError Arblib.intersection(p2, p1, p2)
            @test_throws ArgumentError Arblib.intersection(p2, p2, p1)
        end
    end

    @testset "add_error" begin
        x = Arblib.setball(Arb, 0, 1)

        @test radius(Arblib.add_error(x, Mag(1))) == Mag(2)
        @test radius(Arblib.add_error(x, Arf(2))) == Mag(1) + Mag(Arf(2))
        @test radius(Arblib.add_error(x, Arb(3))) == Mag(1) + Mag(Arf(3))

        y = Arblib.add_error(x, Mag(1))
        Arblib.zero!(y)
        @test !isequal(x, y)

        x = Acb(Arblib.setball(Arb, 0, 1), Arblib.setball(Arb, 2, 3))

        y = Arblib.add_error(x, Mag(1))
        @test radius(real(y)) == Mag(2)
        @test radius(imag(y)) == Mag(1) + Mag(3)
        y = Arblib.add_error(x, Arf(2))
        @test radius(real(y)) == Mag(1) + Mag(Arf(2))
        @test radius(imag(y)) == Mag(3) + Mag(Arf(2))
        y = Arblib.add_error(x, Arb(3))
        @test radius(real(y)) == Mag(1) + Mag(Arf(3))
        @test radius(imag(y)) == Mag(3) + Mag(Arf(3))

        @test precision(Arblib.add_error(Arb(prec = 80), Arb(prec = 90))) == 80
        @test precision(Arblib.add_error(Acb(prec = 80), Arb(prec = 90))) == 80

        @test all(isone, radius.(Arblib.add_error(ArbMatrix(2, 2), Mag(1))))
        @test all(isone, radius.(real.(Arblib.add_error(AcbMatrix(2, 2), Mag(1)))))
        @test all(isone, radius.(imag.(Arblib.add_error(AcbMatrix(2, 2), Mag(1)))))
    end
end
