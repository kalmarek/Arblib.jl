@testset "MinMax" begin
    @testset "Mag" begin
        @test min(Mag(1), Mag(2)) == Mag(1)
        @test max(Mag(1), Mag(2)) == Mag(2)
        @test minmax(Mag(1), Mag(2)) == minmax(Mag(2), Mag(1)) == (Mag(1), Mag(2))
    end

    @testset "Arf" begin
        @test min(Arf(1), Arf(2)) == Arf(1)
        @test max(Arf(1), Arf(2)) == Arf(2)
        @test minmax(Arf(1), Arf(2)) == minmax(Arf(2), Arf(1)) == (Arf(1), Arf(2))
    end

    @testset "Arb" begin
        @test min(Arb(1), Arb(2)) == Arb(1)
        @test max(Arb(1), Arb(2)) == Arb(2)
        @test minmax(Arb(1), Arb(2)) == minmax(Arb(2), Arb(1)) == (Arb(1), Arb(2))
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

        A = Arb[10:20; 0:9]
        @test minimum(A) == 0
        @test maximum(A) == 20
        @test extrema(A) == (0, 20)

        A = [Arb((i, i + 1)) for i = 0:20]
        @test contains(minimum(A), Arb((0, 1)))
        @test contains(minimum(reverse(A)), Arb((0, 1)))
        @test contains(maximum(A), Arb((20, 21)))
        @test contains(maximum(reverse(A)), Arb((20, 21)))
        @test all(contains.(extrema(A), (Arb((0, 1)), Arb((20, 21)))))
        @test all(contains.(extrema(reverse(A)), (Arb((0, 1)), Arb((20, 21)))))

        # Fails in Julia version < 1.8 with default implementation due
        # to short circuiting in Base.mapreduce_impl
        A = [setball(Arb, 2, 1); zeros(Arb, 257)]
        @test iszero(minimum(A))
        @test iszero(maximum(-A))
        @test iszero(extrema(A)[1])
        @test iszero(extrema(-A)[2])
        # Before 1.8.0 these still fails and there is no real way to
        # overload them
        if VERSION < v"1.8.0-rc3"
            @test_broken iszero(minimum(identity, A))
            @test_broken iszero(maximum(identity, -A))
        else
            @test iszero(minimum(identity, A))
            @test iszero(maximum(identity, -A))
        end
        # These work
        @test iszero(extrema(identity, A)[1])
        @test iszero(extrema(identity, -A)[2])

        # Fails with default implementation due to Base._fast
        #A = [Arb(0); [setball(Arb, 0, i) for i in reverse(0:257)]]
        A = [setball(Arb, 0, i) for i = 0:257]
        @test contains(minimum(A), -257)
        @test contains(maximum(A), 257)
        @test contains(extrema(A)[1], -257)
        @test contains(extrema(A)[2], 257)
        @test contains(minimum(identity, A), -257)
        @test contains(maximum(identity, A), 257)
        @test contains(extrema(identity, A)[1], -257)
        @test contains(extrema(identity, A)[2], 257)

        # Fails with default implementation due to both short circuit
        # and Base._fast
        A = [setball(Arb, 0, i) for i = 0:1000]
        @test contains(minimum(A), -1000)
        @test contains(maximum(A), 1000)
        @test contains(extrema(A)[1], -1000)
        @test contains(extrema(A)[2], 1000)
        if VERSION < v"1.8.0-rc3"
            @test_broken contains(minimum(identity, A), -1000)
            @test_broken contains(maximum(identity, A), 1000)
        else
            @test contains(minimum(identity, A), -1000)
            @test contains(maximum(identity, A), 1000)
        end
        @test contains(extrema(identity, A)[1], -1000)
        @test contains(extrema(identity, A)[2], 1000)

        @test !Base.isbadzero(min, zero(Mag))
        @test !Base.isbadzero(min, zero(Arf))
        @test !Base.isbadzero(min, zero(Arb))

        @test !Base.isbadzero(max, zero(Mag))
        @test !Base.isbadzero(max, zero(Arf))
        @test !Base.isbadzero(max, zero(Arb))

        @test !Base.isgoodzero(min, zero(Mag))
        @test !Base.isgoodzero(min, zero(Arf))
        @test !Base.isgoodzero(min, zero(Arb))

        @test !Base.isgoodzero(max, zero(Mag))
        @test !Base.isgoodzero(max, zero(Arf))
        @test !Base.isgoodzero(max, zero(Arb))
    end
end
