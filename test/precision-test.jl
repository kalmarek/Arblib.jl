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

            y = setprecision(x, prec, shallow = false)
            z = setprecision(x, prec, shallow = true)
            @test precision(y) == prec
            @test precision(z) == prec

            # Test that y is a normal copy and z a shallow copy
            Arblib.set!(y, 2)
            @test !isequal(x, y)
            Arblib.set!(z, 2)
            @test isequal(x, z)
        end
    end
end
