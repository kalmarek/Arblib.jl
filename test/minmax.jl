@testset "MinMax" begin
    @testset "$T" for T in (Mag, Arf, Mag)
        @test min(T(1), T(2)) == T(1)
        @test max(T(1), T(2)) == T(2)
        @test minmax(T(1), T(2)) == minmax(T(2), T(1)) == (T(1), T(2))
    end

    @testset "Arb - specific" begin
        @test Arblib.contains(min(Arb((0, 2)), Arb((-1, 3))), -1)
        @test Arblib.contains(min(Arb((0, 2)), Arb((-1, 3))), 2)
        @test !Arblib.contains(min(Arb((0, 2)), Arb((-1, 3))), 3)
        @test Arblib.contains(max(Arb((0, 2)), Arb((-1, 3))), 0)
        @test Arblib.contains(max(Arb((0, 2)), Arb((-1, 3))), 3)
        @test !Arblib.contains(max(Arb((0, 2)), Arb((-1, 3))), -1)
        @test all(Arblib.contains.(minmax(Arb((0, 2)), Arb((-1, 3))), (-1, 0)))
        @test all(Arblib.contains.(minmax(Arb((0, 2)), Arb((-1, 3))), (2, 3)))
        @test all(.!Arblib.contains.(minmax(Arb((0, 2)), Arb((-1, 3))), (3, -1)))
    end

    @testset "minimum/maximum/extrema" begin
        # See https://github.com/JuliaLang/julia/issues/45932 for
        # discussions about the issues with the Base implementation

        # Currently there is no special implementation of extrema, the
        # default implementation works well. But to help find future
        # issues we test it here as well.

        @testset "$T" for T in (Mag, Arf, Mag)
            A = T[10:20; 0:9]
            @test minimum(A) == T(0)
            @test maximum(A) == T(20)
            @test extrema(A) == (T(0), T(20))
        end

        A = [Arb((i, i + 1)) for i = 0:20]
        @test Arblib.contains(minimum(A), Arb((0, 1)))
        @test Arblib.contains(minimum(reverse(A)), Arb((0, 1)))
        @test Arblib.contains(maximum(A), Arb((20, 21)))
        @test Arblib.contains(maximum(reverse(A)), Arb((20, 21)))
        @test all(Arblib.contains.(extrema(A), (Arb((0, 1)), Arb((20, 21)))))
        @test all(Arblib.contains.(extrema(reverse(A)), (Arb((0, 1)), Arb((20, 21)))))

        # Fails in Julia version < 1.8 with default implementation due
        # to short circuiting in Base.mapreduce_impl
        A = [setball(Arb, 2, 1); zeros(Arb, 257)]
        @test iszero(minimum(A))
        @test iszero(maximum(-A))
        @test iszero(extrema(A)[1])
        @test iszero(extrema(-A)[2])
        # Before 1.8.0 these test failed with no way to fix them
        @test iszero(minimum(identity, A))
        @test iszero(maximum(identity, -A))
        # These work
        @test iszero(extrema(identity, A)[1])
        @test iszero(extrema(identity, -A)[2])

        # Fails with default implementation due to Base._fast
        A = [Arb(0); [setball(Arb, 0, i) for i in reverse(0:257)]]
        @test Arblib.contains(minimum(A), -257)
        @test Arblib.contains(maximum(A), 257)
        @test Arblib.contains(extrema(A)[1], -257)
        @test Arblib.contains(extrema(A)[2], 257)
        @test Arblib.contains(minimum(identity, A), -257)
        @test Arblib.contains(maximum(identity, A), 257)
        @test Arblib.contains(extrema(identity, A)[1], -257)
        @test Arblib.contains(extrema(identity, A)[2], 257)
        # In a previous version of Arblib, Base._fast was not correctly
        # overloaded for ArbRef.
        A = [
            Arblib.realref(Acb(0))
            [Arblib.realref(Acb(setball(Arb, 0, i))) for i in reverse(0:257)]
        ]
        @test Arblib.contains(minimum(A), -257)
        @test Arblib.contains(maximum(A), 257)
        @test Arblib.contains(extrema(A)[1], -257)
        @test Arblib.contains(extrema(A)[2], 257)
        @test Arblib.contains(minimum(identity, A), -257)
        @test Arblib.contains(maximum(identity, A), 257)
        @test Arblib.contains(extrema(identity, A)[1], -257)
        @test Arblib.contains(extrema(identity, A)[2], 257)
        # In a previous version of Arblib, Base._fast was not correctly
        # handling mixture of Arb and AbstractFloat
        @test minimum(AbstractFloat[Arb(0); fill(1.0, 257)]) == 0
        @test maximum(AbstractFloat[Arb(0); fill(1.0, 257)]) == 1
        @test extrema(AbstractFloat[Arb(0); fill(1.0, 257)]) == (0, 1)

        # Fails with default implementation due to both short circuit
        # and Base._fast
        A = [setball(Arb, 0, i) for i = 0:1000]
        @test Arblib.contains(minimum(A), -1000)
        @test Arblib.contains(maximum(A), 1000)
        @test Arblib.contains(extrema(A)[1], -1000)
        @test Arblib.contains(extrema(A)[2], 1000)
        # Before 1.8.0 these test failed with no way to fix them
        @test Arblib.contains(minimum(identity, A), -1000)
        @test Arblib.contains(maximum(identity, A), 1000)
        @test Arblib.contains(extrema(identity, A)[1], -1000)
        @test Arblib.contains(extrema(identity, A)[2], 1000)

        @test !Base.isbadzero(min, zero(Mag))
        @test !Base.isbadzero(min, zero(Arf))
        @test !Base.isbadzero(min, zero(Arb))
        @test !Base.isbadzero(min, Arblib.radref(zero(Arb)))
        @test !Base.isbadzero(min, Arblib.midref(zero(Arb)))
        @test !Base.isbadzero(min, Arblib.realref(zero(Acb)))

        @test !Base.isbadzero(max, zero(Mag))
        @test !Base.isbadzero(max, zero(Arf))
        @test !Base.isbadzero(max, zero(Arb))
        @test !Base.isbadzero(max, Arblib.radref(zero(Arb)))
        @test !Base.isbadzero(max, Arblib.midref(zero(Arb)))
        @test !Base.isbadzero(max, Arblib.realref(zero(Acb)))

        @test !Base.isgoodzero(min, zero(Mag))
        @test !Base.isgoodzero(min, zero(Arf))
        @test !Base.isgoodzero(min, zero(Arb))
        @test !Base.isgoodzero(min, Arblib.radref(zero(Arb)))
        @test !Base.isgoodzero(min, Arblib.midref(zero(Arb)))
        @test !Base.isgoodzero(min, Arblib.realref(zero(Acb)))

        @test !Base.isgoodzero(max, zero(Mag))
        @test !Base.isgoodzero(max, zero(Arf))
        @test !Base.isgoodzero(max, zero(Arb))
        @test !Base.isgoodzero(max, Arblib.radref(zero(Arb)))
        @test !Base.isgoodzero(max, Arblib.midref(zero(Arb)))
        @test !Base.isgoodzero(max, Arblib.realref(zero(Acb)))
    end
end
