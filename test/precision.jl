@testset "precision" begin
    precdefault = 256
    prec = 64

    types = (
        Arf,
        Acf,
        Arb,
        Acb,
        ArbPoly,
        ArbSeries,
        AcbPoly,
        AcbSeries,
        ArbVector,
        ArbRefVector,
        AcbVector,
        AcbRefVector,
        ArbMatrix,
        ArbRefMatrix,
        AcbMatrix,
        AcbRefMatrix,
    )

    @testset "precision: $T" for T in types
        if T <: AbstractVector
            x = T(1)
            y = T(1; prec)
        elseif T <: AbstractMatrix
            x = T(1, 1)
            y = T(1, 1; prec)
        else
            x = T()
            y = T(; prec)
        end

        @test precision(x) == precdefault
        @test precision(y) == prec

        @test precision(Arblib.cstruct(x)) == precdefault
        @test precision(Arblib.cstruct(y)) == precdefault

        @test precision(T) == precdefault
        @test precision(Arblib.cstructtype(T)) == precdefault
        @test precision(Ptr{Arblib.cstructtype(T)}) == precdefault

        if T <: Union{ArbPoly,ArbSeries,AcbPoly,AcbSeries}
            @test precision(x[0]) == precdefault
            @test precision(y[0]) == prec
        elseif T <: AbstractVector
            @test precision(x[1, 1]) == precdefault
            @test precision(y[1, 1]) == prec
        elseif T <: AbstractMatrix
            @test precision(x[1, 1]) == precdefault
            @test precision(y[1, 1]) == prec
        end

        if VERSION >= v"1.8.0"
            @test precision(x, base = 4) == precdefault ÷ 2
            @test precision(y, base = 4) == prec ÷ 2

            @test precision(Arblib.cstruct(x), base = 4) == precdefault ÷ 2
            @test precision(Arblib.cstruct(y), base = 4) == precdefault ÷ 2

            @test precision(T, base = 4) == precdefault ÷ 2
            @test precision(Arblib.cstructtype(T), base = 4) == precdefault ÷ 2
            @test precision(Ptr{Arblib.cstructtype(T)}, base = 4) == precdefault ÷ 2
        end

        x2 = setprecision(x, prec)
        @test precision(x2) == prec
        @test isequal(x, x2)

        # Check aliasing
        if T <: Union{Arf,Arb,Acb}
            x2[] = 2
            @test !isequal(x, x2)
        elseif T <: Union{ArbPoly,ArbSeries,AcbPoly,AcbSeries}
            x2[0] = 2
            @test !isequal(x, x2)
        elseif T <: AbstractVector
            x2[1] = 2
            @test !isequal(x, x2)
        elseif T <: AbstractMatrix
            x2[1, 1] = 2
            @test !isequal(x, x2)
        end

        if VERSION >= v"1.8.0"
            x3 = setprecision(x, prec ÷ 2, base = 4)
            @test precision(x3) == prec
            @test isequal(x3, x)
        end
    end

    @testset "setprecision do" begin
        x = Arb("0.1")
        @test precision(x) == 256
        @test string(x) ==
              "[0.1000000000000000000000000000000000000000000000000000000000000000000000000000 +/- 1.95e-78]"

        setprecision(Arb, 64) do
            @test precision(x) == 256
            y = Arb("0.1")
            @test precision(y) == 64
            @test string(y) == "[0.100000000000000000 +/- 1.22e-20]"
        end
    end

    @testset "_precision" begin
        let _precision = Arblib._precision
            # One argument
            @test _precision(Arf(prec = 64)) == 64
            @test _precision(Acf(prec = 64)) == 64
            @test _precision(Arb(prec = 64)) == 64
            @test _precision(Acb(prec = 64)) == 64
            @test _precision(BigFloat(precision = 64)) == 64
            @test _precision(Arf(prec = 64) + im * Arf(prec = 80)) == 80
            @test _precision(Arb(prec = 80) + im * Arb(prec = 64)) == 80
            @test _precision(Complex(BigFloat(precision = 64), BigFloat(precision = 80))) ==
                  80

            @test _precision(1) == precision(Arb)
            @test _precision(1.0) == precision(Arb)
            @test _precision(1 // 1) == precision(Arb)
            @test _precision(1 + im) == precision(Arb)
            @test _precision(1.0 + im) == precision(Arb)
            @test _precision(1 // 1 + im) == precision(Arb)

            # Two arguments
            @test _precision(Arf(prec = 64), Arb(prec = 80)) == 80
            @test _precision(Arf(prec = 80), Arb(prec = 64)) == 80
            @test _precision(BigFloat(precision = 80), Acb(prec = 64)) == 80
            @test _precision(BigFloat(precision = 64), Acb(prec = 80)) == 80
            @test _precision(im * Arb(prec = 80), Acb(prec = 64)) == 80
            @test _precision(im * Arb(prec = 64), Acb(prec = 80)) == 80
            @test _precision(
                Complex(BigFloat(precision = 64), BigFloat(precision = 64)),
                Arf(prec = 80),
            ) == 80
            @test _precision(
                Arf(prec = 80),
                Complex(BigFloat(precision = 64), BigFloat(precision = 64)),
            ) == 80

            @test _precision(Arf(prec = 64), 1) == 64
            @test _precision(1, Arf(prec = 64)) == 64
            @test _precision(BigFloat(precision = 64), 1) == 64
            @test _precision(1, BigFloat(precision = 64)) == 64
            @test _precision(im * Arf(prec = 64), 1) == 64
            @test _precision(1, im * Arf(prec = 64)) == 64

            @test _precision(1.0, 2) == precision(Arb)
        end
    end
end
