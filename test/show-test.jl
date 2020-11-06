@testset "show" begin
    Mag = Arblib.Mag
    @testset "string" begin
        @test Arblib._string(Mag()) isa String
        @test !isempty(Arblib._string(Mag(2.3)))
        @test Arblib.string_nice(Arb()) isa String
        @test Arblib.string_nice(Acb()) isa String
    end

    @testset "dump" begin
        x = Mag(1.1)
        for x in (Mag(1.1), Arf(1.1), Arb(1.1))
            y = zero(x)
            str = Arblib.dump_string(x)
            Arblib.load_string!(y, str)
            @test isequal(x, y)
        end
    end

    @testset "show" begin
        prec = 32

        P = ArbPoly(Arb[1, 2, 0, π], prec = prec)
        @test "$P" == "1.00000000 + 2.00000000⋅x + [3.14159265 +/- 3.59e-9]⋅x^3"
        P = AcbPoly([Acb[1, 2, 0, π]; Acb(1, 1)], prec = prec)
        @test "$P" ==
              "1.00000000 + 2.00000000⋅x + [3.14159265 +/- 3.59e-9]⋅x^3 + (1.00000000 + 1.00000000im)⋅x^4"
        P = ArbSeries(Arb[1, 2, 0, π], 4, prec = prec)
        @test "$P" == "1.00000000 + 2.00000000⋅x + [3.14159265 +/- 3.59e-9]⋅x^3 + 𝒪(x^5)"
        P = AcbSeries([Acb[1, 2, 0, π]; Acb(1, 1)], 5, prec = prec)
        @test "$P" ==
              "1.00000000 + 2.00000000⋅x + [3.14159265 +/- 3.59e-9]⋅x^3 + (1.00000000 + 1.00000000im)⋅x^4 + 𝒪(x^6)"

        @test "$(ArbPoly())" == "$(AcbPoly())" == "0"
        @test "$(ArbSeries())" == "$(AcbSeries())" == "𝒪(x)"
    end
end
