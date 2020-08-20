@testset "precision" begin
    precdefault = 256
    prec = 64

    @testset "precision" begin
        for T in (Arf, Arb, Acb)
            @test precision(T()) == precdefault
            @test precision(T(prec = prec)) == prec

            @test precision(Arblib.cstruct(T())) == precdefault
            @test precision(Arblib.cstruct(T(prec = prec))) == precdefault

            @test precision(T) == precdefault
            @test precision(Arblib.cstructtype(T)) == precdefault
            @test precision(Ptr{Arblib.cstructtype(T)}) == precdefault
        end
    end

    @testset "setprecision" begin
        for T in (Arf, Arb, Acb)
            x = T()
            @test precision(x) == precdefault

            y = setprecision(x, prec)
            @test precision(y) == prec
            Arblib.set!(y, 2)
            @test !isequal(x, y)
        end
    end

    @testset "setprecision 2" begin
        x = Arb("0.1")
        @test precision(x) == 256
        @test precision(Arb) == 256
        @test string(x) ==
              "[0.1000000000000000000000000000000000000000000000000000000000000000000000000000 +/- 1.95e-78]"

        setprecision(Arb, 64)
        @test precision(x) == 256
        @test precision(Arb) == 64
        y = Arb("0.1")
        @test precision(y) == 64
        @test string(y) == "[0.100000000000000000 +/- 1.22e-20]"

        setprecision(Arb, 256)
    end

end
