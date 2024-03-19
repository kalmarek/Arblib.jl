@testset "show" begin
    @testset "string" begin
        @test Arblib._string(Mag()) == "(0)"
        @test Arblib._string(Mag(1)) == "(536870912 * 2^-29)"

        @test string(Mag()) == "0"
        @test string(Mag(1)) == "1.0"
        @test string(Mag(1), digits = 3, remove_trailing_zeros = false) == "1.00"
        @test string(Mag(1), digits = 12, remove_trailing_zeros = false) == "1.00000000000"
        @test string(Mag(10^15)) == "1.0e+15"
        @test string(Mag(10^15), remove_trailing_zeros = false) == "1.00000000e+15"
        @test string(Mag(π) * 10^10) == "3.14159267e+10"

        @test string(Arf()) == "0"
        @test string(Arf(1)) == "1.0"
        @test string(Arf(1), digits = 3, remove_trailing_zeros = false) == "1.00"
        @test string(Arf(1), digits = 12, remove_trailing_zeros = false) == "1.00000000000"
        @test string(Arf(1) / 3) ==
              "0.33333333333333333333333333333333333333333333333333333333333333333333333333333"
        @test string(Arf(1) / 3, digits = 12) == "0.333333333333"
        @test string(Arf(10)^100) == "1.0e+100"
        @test string(Arf(10)^100, remove_trailing_zeros = false) ==
              "1.0000000000000000000000000000000000000000000000000000000000000000000000000000e+100"
        @test string(Arf(1 // 3) * Arf(10)^81) ==
              "3.3333333333333333333333333333333333333333333333333333333333333333333333333334e+80"

        @test string(Arb()) == "0"
        @test string(Arb(1)) == "1.0"
        @test string(Arb(1, prec = 64), remove_trailing_zeros = false) ==
              "1.000000000000000000"
        @test string(Arb(1), digits = 2, remove_trailing_zeros = false) == "1.0"
        @test string(Arb(1), digits = 12, remove_trailing_zeros = false) == "1.00000000000"
        @test string(Arb(10)^100) == "1.0e+100"
        @test string(Arb(10)^100, remove_trailing_zeros = false) ==
              "1.0000000000000000000000000000000000000000000000000000000000000000000000000000e+100"
        @test string(Arb(π)) ==
              "[3.1415926535897932384626433832795028841971693993751058209749445923078164062862 +/- 1.93e-77]"
        @test string(Arb(π, prec = 64)) == "[3.141592653589793239 +/- 5.96e-19]"
        @test string(Arb(π), digits = 2) == "[3.1 +/- 0.0416]"
        @test string(Arb(π), digits = 12) == "[3.14159265359 +/- 2.07e-13]"
        @test string(Arb(Arb(π, prec = 64), prec = 256)) ==
              "[3.141592653589793239 +/- 5.96e-19]"
        @test string(Arb(Arb(π, prec = 64), prec = 256), more = true) ==
              "[3.1415926535897932385128089594061862044327426701784133911132812500000000000000 +/- 1.09e-19]"
        @test string(Arb(π), no_radius = true) ==
              "3.1415926535897932384626433832795028841971693993751058209749445923078164062862"
        @test string(Arb(π), condense = 5) == "[3.14159{...66 digits...}62862 +/- 1.93e-77]"
        @test string(Arb(π), unicode = true) ==
              "[3.1415926535897932384626433832795028841971693993751058209749445923078164062862 ± 1.93e-77]"
        @test string(Arb(π), condense = 5, unicode = true) ==
              "[3.14159{…66 digits…}62862 ± 1.93e-77]"

        @test string(Acb()) == "0"
        @test string(Acb(1)) == "1.0"
        @test string(Acb(0, 1)) == "0 + 1.0im"
        @test string(Acb(1, 1)) == "1.0 + 1.0im"
        @test string(Acb(1, 1), remove_trailing_zeros = false) ==
              "1.0000000000000000000000000000000000000000000000000000000000000000000000000000 + 1.0000000000000000000000000000000000000000000000000000000000000000000000000000im"
        @test string(Acb(π, ℯ)) ==
              "[3.1415926535897932384626433832795028841971693993751058209749445923078164062862 +/- 1.93e-77] + [2.7182818284590452353602874713526624977572470936999595749669676277240766303535 +/- 5.46e-77]im"
        @test string(Acb(π, ℯ, prec = 64)) ==
              "[3.141592653589793239 +/- 5.96e-19] + [2.718281828459045235 +/- 4.29e-19]im"
        @test string(Acb(π, ℯ), digits = 2) == "[3.1 +/- 0.0416] + [2.7 +/- 0.0183]im"
        @test string(Acb(π, ℯ), digits = 12) ==
              "[3.14159265359 +/- 2.07e-13] + [2.71828182846 +/- 9.55e-13]im"
        @test string(Acb(Acb(π, ℯ, prec = 64), prec = 256)) ==
              "[3.141592653589793239 +/- 5.96e-19] + [2.718281828459045235 +/- 4.29e-19]im"
        @test string(Acb(Acb(π, ℯ, prec = 64), prec = 256), more = true) ==
              "[3.1415926535897932385128089594061862044327426701784133911132812500000000000000 +/- 1.09e-19] + [2.7182818284590452352113276734968394521274603903293609619140625000000000000000 +/- 2.17e-19]im"
        @test string(Acb(π, ℯ), no_radius = true) ==
              "3.1415926535897932384626433832795028841971693993751058209749445923078164062862 + 2.7182818284590452353602874713526624977572470936999595749669676277240766303535im"
        @test string(Acb(π, ℯ), condense = 5) ==
              "[3.14159{...66 digits...}62862 +/- 1.93e-77] + [2.71828{...66 digits...}03535 +/- 5.46e-77]im"
        @test string(Acb(π, ℯ), unicode = true) ==
              "[3.1415926535897932384626433832795028841971693993751058209749445923078164062862 ± 1.93e-77] + [2.7182818284590452353602874713526624977572470936999595749669676277240766303535 ± 5.46e-77]im"
        @test string(Acb(π, ℯ), condense = 5, unicode = true) ==
              "[3.14159{…66 digits…}62862 ± 1.93e-77] + [2.71828{…66 digits…}03535 ± 5.46e-77]im"
    end

    @testset "dump" begin
        for x in (Mag(π), Arf(1 // 3), Arb(π))
            str = Arblib.dump_string(x)
            y = Arblib.load_string!(zero(x), str)
            z = Arblib.load_string(typeof(x), str)
            @test isequal(x, y)
            @test isequal(x, z)
        end
    end

    @testset "show" begin
        @test repr(Mag(1), context = IOContext(stdout, :compact => true)) == "1.0"
        @test repr(Arf(1), context = IOContext(stdout, :compact => true)) == "1.0"
        @test repr(Arb(π), context = IOContext(stdout, :compact => true)) ==
              "[3.14{…72 digits…}62 ± 1.93e-77]"
        @test repr(Acb(π, ℯ), context = IOContext(stdout, :compact => true)) ==
              "[3.14{…72 digits…}62 ± 1.93e-77] + [2.71{…72 digits…}35 ± 5.46e-77]im"

        prec = 32

        P = ArbPoly(Arb[1, 2, 0, π]; prec)
        @test "$P" == "1.0 + 2.0⋅x + [3.14159265 +/- 3.59e-9]⋅x^3"
        P = AcbPoly([Acb[1, 2, 0, π]; Acb(1, 1)]; prec)
        @test "$P" == "1.0 + 2.0⋅x + [3.14159265 +/- 3.59e-9]⋅x^3 + (1.0 + 1.0im)⋅x^4"
        P = ArbSeries(Arb[1, 2, 0, π], degree = 4; prec)
        @test "$P" == "1.0 + 2.0⋅x + [3.14159265 +/- 3.59e-9]⋅x^3 + 𝒪(x^5)"
        P = AcbSeries([Acb[1, 2, 0, π]; Acb(1, 1)], degree = 5; prec)
        @test "$P" ==
              "1.0 + 2.0⋅x + [3.14159265 +/- 3.59e-9]⋅x^3 + (1.0 + 1.0im)⋅x^4 + 𝒪(x^6)"

        @test "$(ArbPoly())" == "$(AcbPoly())" == "0"
        @test "$(ArbSeries())" == "$(AcbSeries())" == "𝒪(x)"
    end
end
