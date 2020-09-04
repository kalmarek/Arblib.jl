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

    @testset "real/imag" begin
        x, y = Arb(rand()), Arb(rand())
        z = Acb(x, y)

        @test Arblib.realref(z) isa ArbRef
        @test Arblib.realref(z) == x
        @test real(z) == x
        @test Arblib.imagref(z) isa ArbRef
        @test Arblib.imagref(z) == y
        @test imag(z) == y
    end

    @testset "midref" begin
        x = Arb(0.25)
        @test Arblib.midref(x) isa ArfRef
        @test startswith(sprint(show, x), "0.250")
        @test Float64(Arblib.midref(x)) isa Float64
        @test Float64(Arblib.midref(x)) == 0.25
        @test Float64(x) == 0.25
        @test sprint(show, x) == sprint(show, x[])
    end

    @testset "radref" begin
        x = Arb(0.25)
        m = Arblib.radref(x)
        @test m isa MagRef
        m[] = 1.0
        @test Float64(m) ≥ 1.0
        @test sprint(show, m) == sprint(show, m[])
    end

    @testset "convert to Float64/ComplexF64" begin
        x = Arb(0.25)
        @test Float64(x) isa Float64
        @test Float64(x) == 0.25
        z = Acb(2.0 + 0.125im)
        @test ComplexF64(z) isa ComplexF64
        @test ComplexF64(z) == 2.0 + 0.125im
    end
end
