@testset "Arithmethic" begin
    @testset "basic arithmetic: $T" for T in [Arb, Acb]
        @test T(3) + 1 == 4
        @test T(3) + 1 isa T
        @test T(2) + T(3) == 5
        @test T(2) + T(3) isa T
        @test T(3) - 1 == 2
        @test T(3) - 1 isa T
        @test T(2) - T(3) == -1
        @test T(2) - T(3) isa T
        @test T(3) * 1 == 3
        @test T(3) * 1 isa T
        @test Bool(Arblib.contains(T(3) / 1, T(3)))
        @test T(3) / 1 isa T
        @test Bool(Arblib.contains(T(3) / T(1), T(3)))
        @test T(3) / T(1) isa T
    end

    @testset "promote: $T" for (T, TMat) in [(Arb, ArbMatrix), (Acb, AcbMatrix)]
        A = TMat(3, 3)
        # promotion of TRef to T
        a = A[1, 1]
        promote(a, 1) isa Tuple{T,T}
        promote(a, T(1)) isa Tuple{T,T}
        @test a + 3 == 3
        @test a + 3 isa T
    end

    @testset "midref" begin
        x = Arb(0.25)
        Arblib.midref(x) isa ArfRef
        @test startswith(sprint(show, x), "0.250")
        Arblib.get(Arblib.midref(x)) isa Float64
        Arblib.get(Arblib.midref(x)) == 0.25
    end
end
