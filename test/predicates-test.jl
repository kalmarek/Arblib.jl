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
        )
            for f in fs
                @test f(T()) isa Bool
            end
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
        x, y, z = Mag(0.0), Mag(1.0), Mag(Inf)
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
        @test x < UInt64(1)
        @test x <= UInt64(1)
        @test x < 1
        @test x <= UInt64(1)
        @test x < 1.1
        @test x <= UInt64(1)

        x, y = Arb(0), Arb(1)
        @test x == x
        @test x != y
        @test x < y
        @test x <= y
        @test y > x
        @test y >= x

        x, y = Acb(0), Acb(1)
        @test x == x
        @test x != y
    end

end
