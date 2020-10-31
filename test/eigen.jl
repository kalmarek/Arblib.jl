@testset "eigenvalues/eigenvectors: $MatT" for MatT in (AcbMatrix, AcbRefMatrix)
    A = [
        0.6873474041954415 0.7282180564881044 0.07360652513458521
        0.000835810121029068 0.9256166870757694 0.5363310989411239
        0.07387174694790022 0.4050436025621329 0.20226010388885896
    ]
    B = [
        0.8982563031334123 0.3029712969740874 0.8585014523679579
        0.7583002736998279 0.8854763478184455 0.3031103325817668
        0.2319572749472405 0.5769840251057949 0.5119507333628952
    ]
    M = MatT(A + B * im, prec = 64)
    # M = MatT(rand(3, 3) + im * rand(3, 3), prec = 64)

    VecT = typeof(similar(M, 3))

    @testset "approx_eig_qr" begin
        λs_a_r, revs_a = Arblib.approx_eig_qr(M, side = :right)
        @test λs_a_r isa VecT
        @test revs_a isa MatT

        ε = 1e-10

        λs_a_l, revs_a = Arblib.approx_eig_qr(M, tol = Arblib.Mag(ε), side = :left)
        @test λs_a_l isa VecT
        @test revs_a isa MatT

        @test all(abs.(λs_a_r - λs_a_l) .< ε)

        λs_r = similar(M, size(M, 1))
        Arblib.approx_eig_qr!(λs_r, M)
        @test Arblib.is_zero(λs_r - λs_a_r, length(λs_r))
    end

    @testset "eig_simple" begin
        λs1, _ = Arblib.eig_simple_vdhoeven_mourrain(M, side = :right)
        λs2, _ = Arblib.eig_simple_vdhoeven_mourrain(M, side = :left)

        @test all(Arblib.containszero, λs1 - λs2)

        # λs1, _ = Arblib.eig_simple_rump(M, side = :right)
        # segfaults in acb_mat_solve at /workspace/srcdir/arb-2.18.1/acb_mat/solve.c:17
        # Issue #321 in Arblib (fixed by #330)
        # λs2, _ = Arblib.eig_simple_rump(M, side=:left)
        # @test all(Arblib.containszero, λs1 - λs2)

        λs1, _ = Arblib.eig_simple(M, side = :right)
        λs2, _ = Arblib.eig_simple(M, side = :left)
        @test all(Arblib.containszero, λs1 - λs2)

        λs = similar(M, size(M, 1))
        Arblib.eig_simple_vdhoeven_mourrain!(λs, M)
        @test all(Arblib.containszero, λs - λs1)

        λs = similar(M, size(M, 1))
        Arblib.eig_simple_rump!(λs, M)
        @test all(Arblib.containszero, λs - λs1)

        λs = similar(M, size(M, 1))
        Arblib.eig_simple!(λs, M)
        @test all(Arblib.containszero, λs - λs1)
    end

    N = similar(M)
    evs = [Arb(2.0), Arb(2.0), Arb(rand())]
    N[1, 1], N[2, 2], N[3, 3] = evs

    N = M * N * M^-1

    @testset "enclosures" begin
        ε = Arblib.Mag()
        tol = 1e-12
        λ_approx, R_approx = Arblib.approx_eig_qr(M, tol = tol)

        @test Arblib.eig_global_enclosure!(
            ε,
            M,
            λ_approx,
            R_approx;
            prec = precision(M),
        ) isa Arblib.Mag

        @test ε <= tol

        λs = similar(M, size(M, 1))
        Arblib.eig_simple!(λs, M, λ_approx, R_approx)

        for λa in λ_approx
            a_real = let x = real(λa)
                m = Arblib.midref(x)
                r = Arblib.radref(x)
                Arblib.set_interval!(x, m - (r + ε), m + (r + ε))
            end

            a_imag = let x = imag(λa)
                m = Arblib.midref(x)
                r = Arblib.radref(x)
                Arblib.set_interval!(x, m - (r + ε), m + (r + ε))
            end

            a = Acb(a_real, a_imag)
            @test any(Arblib.containszero(a - λ) for λ in λs)
        end


        @test_throws Arblib.EigenvalueComputationError Arblib.eig_simple(N)

        λ_approx, R_approx = Arblib.approx_eig_qr(N)
        v = sortperm(λ_approx, by = abs, rev = true)

        λ = Acb(prec = precision(N))
        R = similar(N, (3, 1))
        Arblib.eig_enclosure_rump!(λ, R, N, λ_approx[v[1]], R_approx[:, v[1:1]])
        @test !isfinite(λ)

        λ = Acb(prec = precision(N))
        R = similar(N, (3, 1))
        Arblib.eig_enclosure_rump!(λ, R, N, λ_approx[v[3]], R_approx[:, v[3:3]])
        @test isfinite(λ)
        @test Arblib.contains_zero(λ - evs[3])

        λ = Acb(prec = precision(N))
        R = similar(N, (3, 2))
        Arblib.eig_enclosure_rump!(λ, R, N, λ_approx[v[1]], R_approx[:, v[1:2]])
        @test isfinite(λ)
        @test Arblib.contains_zero(λ - 2)
        @test all(Arblib.contains_zero.(N * R - R * λ))

        λ = Acb(prec = precision(N))
        R = similar(N, (3, 2))
        J = similar(N, (2, 2))

        Arblib.eig_enclosure_rump!(λ, J, R, N, λ_approx[v[2]], R_approx[:, v[1:2]])
        @test Arblib.contains_zero(λ - 2)
        @test all(Arblib.contains_zero.(N * R - R * J))
    end

    @testset "eig_multiple" begin
        λs = similar(N, 3)
        @test Arblib.eig_multiple_rump(N) isa VecT
        Arblib.eig_multiple_rump!(λs, N)

        v = sortperm(λs, by = abs, rev = true)
        @test all(Arblib.contains_zero.(λs[v] - evs))

        @test Arblib.eig_multiple(N) isa VecT
        Arblib.eig_multiple!(λs, N)

        v = sortperm(λs, by = abs, rev = true)
        @test all(Arblib.contains_zero.(λs[v] - evs))
    end
end
