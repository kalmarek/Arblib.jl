@testset "eigen" begin
    # Gives an invertible matrix A + B * im used for testing
    A = [
        0.68 0.72 0.07
        0.01 0.92 0.53
        0.07 0.40 0.20
    ]
    B = [
        0.89 0.30 0.85
        0.75 0.88 0.30
        0.23 0.57 0.51
    ]

    @testset "eigenvalues/eigenvectors: $MatT" for MatT in (AcbMatrix, AcbRefMatrix)
        M = MatT(A + B * im, prec = 64)

        VecT = typeof(similar(M, 3))

        @testset "approx_eig_qr" begin
            λs_a_r, revs_a = Arblib.approx_eig_qr(M, side = :right)
            @test λs_a_r isa VecT
            @test revs_a isa MatT

            ε = Mag(1e-10)

            λs_a_l, revs_a = Arblib.approx_eig_qr(M, tol = ε, side = :left)
            @test λs_a_l isa VecT
            @test revs_a isa MatT

            @test all(abs.(λs_a_r - λs_a_l) .< ε)

            λs_r = similar(M, size(M, 1))
            Arblib.approx_eig_qr!(λs_r, M)
            @test isequal(λs_r, λs_a_r)

            λs_l = similar(M, size(M, 1))
            Arblib.approx_eig_qr!(λs_l, M, tol = ε)
            @test isequal(λs_l, λs_a_l)
        end

        @testset "eig_simple" begin
            λs1, _ = Arblib.eig_simple_vdhoeven_mourrain(M, side = :right)
            λs2, _ = Arblib.eig_simple_vdhoeven_mourrain(M, side = :left)

            @test Arblib.overlaps(λs1, λs2)

            λs1, _ = Arblib.eig_simple_rump(M, side = :right)
            λs2, _ = Arblib.eig_simple_rump(M, side = :left)
            @test Arblib.overlaps(λs1, λs2)

            λs1, _ = Arblib.eig_simple(M, side = :right)
            λs2, _ = Arblib.eig_simple(M, side = :left)
            @test Arblib.overlaps(λs1, λs2)

            λs = similar(M, size(M, 1))
            Arblib.eig_simple_vdhoeven_mourrain!(λs, M)
            @test Arblib.overlaps(λs, λs1)

            λs = similar(M, size(M, 1))
            Arblib.eig_simple_rump!(λs, M)
            @test Arblib.overlaps(λs, λs1)

            λs = similar(M, size(M, 1))
            Arblib.eig_simple!(λs, M)
            @test Arblib.overlaps(λs, λs1)
        end

        @testset "enclosures - simple" begin
            ε = Mag()
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

            @test Arblib.eig_global_enclosure(M, λ_approx, R_approx) <= tol

            λs = similar(M, size(M, 1))
            Arblib.eig_simple!(λs, M, λ_approx, R_approx)

            @test all(
                any(Arblib.overlaps(add_error(Acb(λa), ε), λ) for λ in λs) for
                λa in λ_approx
            )
        end

        # Take N to be a matrix with an eigenvalue of multiplicity 2,
        # specifically the eigenvalues [0.3, 2, 2]. Used to test the
        # multiple eigenvalue code.
        evs = Acb[0.3, 2, 2]
        N = M * MatT(Diagonal(evs), prec = precision(M)) * inv(M)

        @testset "enclosures - multiple" begin
            @test_throws Arblib.EigenvalueComputationError Arblib.eig_simple(N)
            @test_throws "Failed to separate eigenvalues" Arblib.eig_simple(N)

            λ_approx, R_approx = Arblib.approx_eig_qr(N)
            v = sortperm(λ_approx, by = abs)

            λ = Acb(prec = precision(N))
            R1 = similar(N, (3, 1))
            R2 = similar(N, (3, 2))
            J2 = similar(N, (2, 2))

            # Simple eigenvalue
            Arblib.eig_enclosure_rump!(λ, R1, N, λ_approx[v[1]], R_approx[:, v[1:1]])
            @test isfinite(λ)
            @test Arblib.contains(λ, evs[1])

            # Double eigenvalue with one dimensional basis
            Arblib.eig_enclosure_rump!(λ, R1, N, λ_approx[v[2]], R_approx[:, v[2:2]])
            @test !isfinite(λ)

            # Double eigenvalue with two dimensional basis
            Arblib.eig_enclosure_rump!(λ, R2, N, λ_approx[v[2]], R_approx[:, v[2:3]])
            @test isfinite(λ)
            @test Arblib.contains(λ, evs[2])
            @test Arblib.overlaps(N * R2, R2 * λ)

            Arblib.eig_enclosure_rump!(λ, J2, R2, N, λ_approx[v[2]], R_approx[:, v[2:3]])
            @test Arblib.contains(λ, evs[2])
            @test Arblib.overlaps(N * R2, R2 * J2)
        end

        @testset "eig_multiple" begin
            λ_approx, R_approx = Arblib.approx_eig_qr(N)

            λs1 = Arblib.eig_multiple_rump(N)
            λs2 = Arblib.eig_multiple_rump(N, λ_approx, R_approx)
            λs3 = similar(N, 3)
            Arblib.eig_multiple_rump!(λs3, N)
            @test λs1 isa VecT
            @test λs2 isa VecT
            @test λs3 isa VecT
            @test allequal((λs1, λs2, λs3))
            @test Arblib.contains(sort(λs1, by = abs), AcbVector(evs))


            λs1 = Arblib.eig_multiple(N)
            λs2 = Arblib.eig_multiple(N, λ_approx, R_approx)
            λs3 = similar(N, 3)
            Arblib.eig_multiple!(λs3, N)
            @test λs1 isa VecT
            @test λs2 isa VecT
            @test λs3 isa VecT
            @test allequal((λs1, λs2, λs3))
            @test Arblib.contains(sort(λs1, by = abs), AcbVector(evs))

            @test Arblib.contains(sort(LinearAlgebra.eigvals(N), by = abs), AcbVector(evs))

        end
    end

    @testset "eigenvalues/eigenvectors: acb_mat_struct" begin
        # We only run very limited tests for this type to see that the
        # functions run. We don't actually check the return values,
        # just that the functions run.
        M = AcbMatrix(A + B * im, prec = 64).acb_mat
        eigvals_approx = AcbVector(3).acb_vec
        eigvecs_approx = AcbMatrix(3, 3).acb_mat
        eigvals = AcbVector(3).acb_vec
        eigvecs = AcbMatrix(3, 3).acb_mat

        @test Arblib.approx_eig_qr!(eigvals_approx, eigvecs_approx, M, side = :left) isa
              Arblib.acb_vec_struct
        @test Arblib.approx_eig_qr!(eigvals_approx, eigvecs_approx, M, side = :right) isa
              Arblib.acb_vec_struct
        @test Arblib.approx_eig_qr!(eigvals_approx, M) isa Arblib.acb_vec_struct

        @testset "$f" for f in (
            Arblib.eig_simple!,
            Arblib.eig_simple_rump!,
            Arblib.eig_simple_vdhoeven_mourrain!,
        )
            @test f(eigvals, eigvecs, M, eigvals_approx, eigvecs_approx, side = :right) isa
                  Arblib.acb_vec_struct
            @test f(eigvals, eigvecs, M, eigvals_approx, eigvecs_approx, side = :left) isa
                  Arblib.acb_vec_struct
            @test f(eigvals, M, eigvals_approx, eigvecs_approx) isa Arblib.acb_vec_struct
        end

        @test Arblib.eig_global_enclosure!(
            Mag().mag,
            M,
            eigvals_approx,
            eigvecs_approx,
            prec = 64,
        ) isa Arblib.mag_struct

        @test Arblib.eig_enclosure_rump!(
            Acb().acb,
            AcbMatrix(3, 1).acb_mat,
            M,
            eigvals[1],
            AcbMatrix(eigvecs_approx)[:, 1:1].acb_mat,
        ) isa Arblib.acb_struct
        @test Arblib.eig_enclosure_rump!(
            Acb().acb,
            AcbMatrix(2, 2).acb_mat,
            AcbMatrix(3, 2).acb_mat,
            M,
            eigvals[1],
            AcbMatrix(eigvecs_approx)[:, 1:2].acb_mat,
        ) isa Arblib.acb_struct
    end
end
