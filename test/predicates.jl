@testset "predicates" begin
    Mag = Arblib.Mag

    @testset "predicates" begin
        for (T, fs) in (
            (Mag, (isfinite, isinf, Arblib.isspecial, iszero)),
            (
                Arf,
                (
                    isfinite,
                    isinf,
                    isinteger,
                    isnan,
                    Arblib.isneginf,
                    Arblib.isnormal,
                    isone,
                    Arblib.isposinf,
                    Arblib.isspecial,
                    iszero,
                ),
            ),
            (Acf, (iszero, isone, isfinite, isinf, isnan, isinteger, isreal)),
            (
                Arb,
                (
                    Arblib.isexact,
                    isfinite,
                    isinteger,
                    Arblib.isnegative,
                    Arblib.isnonnegative,
                    Arblib.isnonpositive,
                    Arblib.isnonzero,
                    isone,
                    Arblib.ispositive,
                    iszero,
                ),
            ),
            (Acb, (Arblib.isexact, isfinite, isinteger, isone, isreal, iszero)),
            (ArbPoly, (isone, Arblib.isx, iszero)),
            (ArbSeries, (isone, Arblib.isx, iszero)),
        )
            for f in fs
                @test f(zero(T)) isa Bool
            end
        end

        for (T, fs) in (
            (
                ArbMatrix,
                (
                    Arblib.isexact,
                    isfinite,
                    iszero,
                    LinearAlgebra.istriu,
                    LinearAlgebra.istril,
                    LinearAlgebra.isdiag,
                ),
            ),
            (
                AcbMatrix,
                (
                    Arblib.isexact,
                    isfinite,
                    isreal,
                    iszero,
                    LinearAlgebra.istriu,
                    LinearAlgebra.istril,
                    LinearAlgebra.isdiag,
                ),
            ),
        )
            for f in fs
                @test f(T(2, 2))
            end
        end

        @test isnan(Arb(NaN))
        @test !isnan(zero(Arb))
        @test !isnan(one(Arb))
        @test !isnan(Arb(Inf))

        @test isnan(Acb(NaN))
        @test isnan(Acb(0, NaN))
        @test !isnan(zero(Acb))
        @test !isnan(one(Acb))
        @test !isnan(Acb(Inf))

        for T in [ArbPoly, ArbSeries, AcbPoly, AcbSeries]
            @test isnan(T(NaN))
            @test isnan(T([NaN, 0]))
            @test isnan(T([0, NaN]))
            @test !isnan(T(1))
            @test !isnan(T([0, 1]))

            @test isfinite(T(1))
            @test isfinite(T([0, 1]))
            @test !isfinite(T(NaN))
            @test !isfinite(T([NaN, 0]))
            @test !isfinite(T([0, NaN]))
            @test !isfinite(T(Inf))
            @test !isfinite(T([Inf, 0]))
            @test !isfinite(T([0, Inf]))
        end
    end

    @testset "isequal" begin
        @test isequal(Mag(0.0), Mag(0.0))
        @test !isequal(Mag(0.0), Mag(1.0))

        @test isequal(Arf(0), Arf(0))
        @test !isequal(Arf(0), Arf(1))
        @test isequal(Arf(NaN), Arf(NaN))
        @test isequal(Arf(0), 0)
        @test isequal(0, Arf(0))

        @test isequal(Acf(0), Acf(0))
        @test !isequal(Acf(0), Acf(1))
        @test isequal(Acf(NaN), Acf(NaN))
        @test isequal(Acf(0), 0)
        @test isequal(0, Acf(0))

        @test isequal(Arb(0), Arb(0))
        @test !isequal(Arb(0), Arb(1))
        @test isequal(Arb(NaN), Arb(NaN))
        @test isequal(Arb(0), 0)
        @test isequal(0, Arb(0))

        @test isequal(Acb(0), Acb(0))
        @test !isequal(Acb(0), Acb(1))
        @test isequal(Acb(NaN), Acb(NaN))
        @test isequal(Acb(0), 0)
        @test isequal(0, Acb(0))
    end

    @testset "comparison" begin
        x, y, z = Mag(0), Mag(1), Mag(Inf)
        @test isless(x, y)
        @test isless(y, z)
        @test x < y
        @test !(y < x)
        @test x <= x

        x, y, z = Arf(0.0), Arf(1.0), Arf(NaN)
        @test isless(x, y)
        @test isless(x, z)
        @test !isless(z, x)
        @test x < y
        @test !(x < z)
        @test !(z < x)
        @test !(x <= z)
        @test !(z <= x)
        @test x < 1
        @test x <= 1
        @test x < UInt(1)
        @test x <= UInt(1)
        @test x < 1.0
        @test x <= 1.0
        @test y <= 1
        @test y <= UInt(1)
        @test y <= 1.0

        x, y = Acf(0), Acf(1)
        @test x == x
        @test x == 0
        @test 0 == x
        @test y == 1
        @test 1 == y
        @test x != y

        x, y = Arb(0), Arb(1)
        @test x == x
        @test x == 0
        @test 0 == x
        @test y == 1
        @test 1 == y
        @test x != y
        @test x < y
        @test x <= y
        @test y > x
        @test y >= x

        # Comparison with rationals
        @test -1 // 2 < x < 1 // 2
        @test -1 // 2 <= x <= 1 // 2
        @test cmp(x, 1 // 2) == -1
        @test cmp(-1 // 2, x) == -1
        @test 1 // 2 > x > -1 // 2
        @test 1 // 2 >= x >= -1 // 2
        @test cmp(1 // 2, x) == 1
        @test cmp(x, -1 // 2) == 1

        @test !(-1 // 2 > x)
        @test !(-1 // 2 >= x)
        @test cmp(-1 // 2, x) == -1

        x, y = Acb(0), Acb(1)
        @test x == x
        @test x == 0
        @test 0 == x
        @test y == 1
        @test 1 == y
        @test x != y

        P1 = ArbPoly(Arb[1, 2])
        P2 = ArbPoly(Arb[1, 2, 0])
        P3 = ArbPoly(Arb.([1, "2 +/- 1"]))
        P4 = ArbPoly(Arb[1, 4])
        @test P1 == P2
        @test !(P1 != P2)
        @test !(P1 == P3)
        @test !(P1 != P3)
        @test !(P1 == P4)
        @test P1 != P4
        @test !(P3 == P4)
        @test P3 != P4
        @test isequal(P3, P3)
    end

    @testset "isequal for structs" begin
        let cstruct = Arblib.cstruct
            @test isequal(cstruct(Mag(1)), cstruct(Mag(1)))
            @test isequal(cstruct(Arf(1)), cstruct(Arf(1)))
            @test isequal(cstruct(Acf(1)), cstruct(Acf(1)))
            @test isequal(cstruct(Arb(1)), cstruct(Arb(1)))
            @test isequal(cstruct(Acb(1)), cstruct(Acb(1)))

            @test isequal(cstruct(ArbVector([1, 2])), cstruct(ArbVector([1, 2])))
            @test isequal(cstruct(AcbVector([1, 2])), cstruct(AcbVector([1, 2])))

            @test isequal(cstruct(ArbPoly([1, 2])), cstruct(ArbPoly([1, 2])))
            @test isequal(cstruct(AcbPoly([1, 2])), cstruct(AcbPoly([1, 2])))

            @test isequal(cstruct(ArbMatrix([1, 2])), cstruct(ArbMatrix([1, 2])))
            @test isequal(cstruct(AcbMatrix([1, 2])), cstruct(AcbMatrix([1, 2])))

            # It should behave like Arblib.equal and not Arblib.eq
            @test isequal(cstruct(Arb(π)), cstruct(Arb(π)))
            @test isequal(cstruct(Acb(π)), cstruct(Acb(π)))
            @test isequal(cstruct(ArbMatrix([π])), cstruct(ArbMatrix([π])))
            @test isequal(cstruct(AcbMatrix([π])), cstruct(AcbMatrix([π])))

            # Different types should not be equal even if they are
            # numerically the same
            @test !isequal(cstruct(Mag(1)), cstruct(Arf(1)))
            @test !isequal(cstruct(Arf(1)), cstruct(Acf(1)))
            @test !isequal(cstruct(Arb(1)), cstruct(Acb(1)))
            @test !isequal(cstruct(ArbVector([1])), cstruct(AcbVector([1])))
            @test !isequal(cstruct(ArbMatrix([1])), cstruct(AcbMatrix([1])))
        end
    end
end
