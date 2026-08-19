@testset "fft" begin
    AcbFFTPlan = Arblib.AcbFFTPlan

    @testset "AcbFFTPlan" begin
        @test Arblib.fft_plan_size(AcbFFTPlan(1)) == 1
        @test Arblib.fft_plan_size(AcbFFTPlan(8)) == 8
        @test Arblib.fft_plan_size(AcbFFTPlan(64)) == 64

        @test precision(AcbFFTPlan(1)) == precision(Arb)
        @test precision(AcbFFTPlan(1, prec = 80)) == 80
        @test precision(AcbFFTPlan(1, prec = 80), base = 4) == 40

        @test_throws Arblib.GRDomainError AcbFFTPlan(0)
        @test_throws Arblib.GRDomainError AcbFFTPlan(-1)

        let plan = AcbFFTPlan(8, prec = 80), plan_copy = deepcopy(plan)
            # The copy owns its own Flint data
            @test plan_copy.plan !== plan.plan
            @test Arblib.fft_plan_size(plan_copy) == 8
            @test precision(plan_copy) == 80

            v = AcbVector(1:8, prec = 80)
            @test isequal(Arblib.fft(v, plan_copy), Arblib.fft(v, plan))
        end
    end

    # Test good path
    n = 128
    v = AcbVector(1:n)

    plan = AcbFFTPlan(n)

    w1 = Arblib.fft(v)
    w2 = Arblib.fft(v, plan)
    w3 = Arblib.fft!(similar(v), v)
    w4 = Arblib.fft!(similar(v), v, plan)
    w5, w6 = copy(v), copy(v)
    Arblib.fft!(w5, w5)
    Arblib.fft!(w6, w6, plan)

    @test allequal((w1, w2, w3, w4, w5, w6))

    v1 = Arblib.ifft(w1)
    v2 = Arblib.ifft(w2, plan)
    v3 = Arblib.ifft!(similar(w3), w3)
    v4 = Arblib.ifft!(similar(w4), w4, plan)
    v5, v6 = copy(w5), copy(w6)
    Arblib.ifft!(v5, v5)
    Arblib.ifft!(v6, v6, plan)

    @test allequal((v1, v2, v3, v4, v5, v6))
    @test Arblib.overlaps(v, v1)

    # Check the normalization. The forward transform is unnormalized
    # and the inverse transform has a factor 1 / m. For a constant
    # input this gives
    # fft([c, c, ..., c]) == [m * c, 0, ..., 0] and
    # ifft([c, c, ..., c]) == [c, 0, ..., 0].
    let m = 8, c = 3
        u = AcbVector(fill(c, m))

        w = Arblib.fft(u)
        @test Arblib.contains(w[1], Acb(m * c))
        @test all(i -> Arblib.contains_zero(w[i]), 2:m)

        z = Arblib.ifft(u)
        @test Arblib.contains(z[1], Acb(c))
        @test all(i -> Arblib.contains_zero(z[i]), 2:m)
    end

    # Special cases
    @test isempty(Arblib.fft(AcbVector(0)))
    @test isempty(Arblib.fft!(AcbVector(0), AcbVector(0)))
    @test isempty(Arblib.ifft(AcbVector(0)))
    @test isempty(Arblib.ifft!(AcbVector(0), AcbVector(0)))

    @test precision(Arblib.fft(AcbVector(8, prec = 80))) == 80
    @test precision(Arblib.ifft(AcbVector(8, prec = 80))) == 80
    # It uses the precision from the vector, rather than the plan
    @test precision(Arblib.fft(AcbVector(8, prec = 80), AcbFFTPlan(8, prec = 90))) == 80
    @test precision(Arblib.ifft(AcbVector(8, prec = 80), AcbFFTPlan(8, prec = 90))) == 80

    # Test errors
    @test_throws DimensionMismatch Arblib.fft!(AcbVector(1), AcbVector(2))
    @test_throws DimensionMismatch Arblib.fft!(AcbVector(1), AcbVector(1), AcbFFTPlan(2))
    @test_throws DimensionMismatch Arblib.fft!(AcbVector(1), AcbVector(2), AcbFFTPlan(2))
    @test_throws DimensionMismatch Arblib.fft!(AcbVector(2), AcbVector(1), AcbFFTPlan(2))
    @test_throws DimensionMismatch Arblib.fft!(AcbVector(1), AcbVector(2), AcbFFTPlan(3))

    @test_throws DimensionMismatch Arblib.ifft!(AcbVector(1), AcbVector(2))
    @test_throws DimensionMismatch Arblib.ifft!(AcbVector(1), AcbVector(1), AcbFFTPlan(2))
    @test_throws DimensionMismatch Arblib.ifft!(AcbVector(1), AcbVector(2), AcbFFTPlan(2))
    @test_throws DimensionMismatch Arblib.ifft!(AcbVector(2), AcbVector(1), AcbFFTPlan(2))
    @test_throws DimensionMismatch Arblib.ifft!(AcbVector(1), AcbVector(2), AcbFFTPlan(3))
end
