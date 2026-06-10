@testset "Matrices" begin
    @testset "Matrix: $TMat" for (TMat, T, TRef) in [
        (ArbMatrix, Arb, Arb),
        (AcbMatrix, Acb, Acb),
        (ArbRefMatrix, Arb, ArbRef),
        (AcbRefMatrix, Acb, AcbRef),
    ]
        @testset "Basic" begin
            @test isempty(TMat([]))
            @test isempty(TMat([]))

            M = TMat(4, 4, prec = 128)
            @test size(M) == (4, 4)
            @test precision(M) == 128

            x = T(1.5)
            M[2, 2] = x
            @test M[2, 2] == x
            @test M[2, 2] isa TRef
            @test precision(M[2, 2]) == 128

            Arblib.add!(M, M, M)
            M2 = TMat(4, 4, prec = 128)
            M2[2, 2] = T(3)
            @test M == M2

            A = TMat([T(i + j) for i = 1:4, j = 1:4])
            @test A[4, 4] == T(8)
            A = TMat([i + j for i = 1:4, j = 1:4]; prec = 96)
            @test A[4, 4] == T(8)
            @test precision(A) == precision(T(8; prec = 96)) == 96

            @test ref(A, 3, 3) isa Union{ArbRef,AcbRef}
        end

        @testset "add and sub" begin
            AInt = [1 2; 3 4]
            BInt = [5 6; 7 8]
            A = TMat(AInt; prec = 96)
            B = TMat(BInt; prec = 96)
            @test A - B == AInt - BInt
            @test precision(A - B) == 96
            @test (A - B) isa TMat
            @test -B == -BInt
            @test -B isa TMat
            @test -B + A == A - B
            @test precision(-B + A) == 96
        end

        @testset "scalar arithmetic" begin
            AInt = [2 4; 6 8]
            A = TMat(AInt; prec = 96)
            cInt = 2
            c = T(cInt; prec = 96)
            @test c * A isa TMat
            @test c * A == cInt * AInt
            @test A * c isa TMat
            @test A * c == AInt * cInt

            @test c \ A isa TMat
            @test c \ A == cInt \ AInt
            @test A / c isa TMat
            @test A / c == AInt / cInt
            if TRef <: Real
                @test Acb(c) * A isa AcbMatrix
                @test Acb(c) * A == c * A
                @test A * Acb(c) isa AcbMatrix
                @test A * Acb(c) == A * c

                @test Acb(c) \ A isa AcbMatrix
                @test Acb(c) \ A == c \ A
                @test A / Acb(c) isa AcbMatrix
                @test A / Acb(c) == A / c
            end
        end

        @testset "LinearAlgebra" begin
            @testset "mul" begin
                A = TMat(sin.(Arb.(reshape(1:6, 3, 2))))
                B = TMat(cos.(Arb.(reshape(1:8, 2, 4))))
                @test Arblib.overlaps(A * B, TMat(collect(A) * collect(B)))
                @test isequal(A * B, LinearAlgebra.mul!(TMat(3, 4), A, B))
                @test isequal(A * B, Arblib.mul!(TMat(3, 4), A, B))

                @test precision(TMat(1, 1, prec = 80) * TMat(1, 1, prec = 96)) == 96

                @test_throws DimensionMismatch("matrix sizes are not compatible.") TMat(
                    2,
                    2,
                ) * TMat(
                    3,
                    3,
                )
                @test_throws DimensionMismatch("matrix sizes are not compatible.") TMat(
                    2,
                    3,
                ) * TMat(
                    2,
                    3,
                )
            end

            @testset "norm" begin
                A = TMat(sin.(Arb.(reshape(1:6, 3, 2))))

                # TODO: We use norm(real(collect(A))) since
                # norm(collect(A)) doesn't work for Acb as it doesn't
                # implement float(::Acb). This might be something we
                # want to look at implementing at some point.
                @test Arblib.overlaps(norm(A), norm(real(collect(A))))
                @test Arblib.overlaps(norm(A, 2), norm(real(collect(A)), 2))
                @test Arblib.overlaps(norm(A, Arb(2)), norm(real(collect(A)), Arb(2)))
                @test Arblib.overlaps(norm(A, -Inf), norm(real(collect(A)), -Inf))
                @test Arblib.overlaps(norm(A, Inf), norm(real(collect(A)), Inf))
                @test Arblib.overlaps(norm(A, 1), norm(real(collect(A)), 1))
                @test Arblib.overlaps(norm(A, 0), norm(real(collect(A)), 0))
                @test Arblib.overlaps(norm(A, -1), norm(real(collect(A)), -1))
                @test Arblib.overlaps(norm(A, Arb(-1)), norm(real(collect(A)), -1))

                @test iszero(norm(TMat(0, 0)))

                @test precision(norm(TMat(A, prec = 80))) == 80
                @test precision(norm(TMat(A, prec = 80), 2)) == 80
                @test precision(norm(TMat(A, prec = 80), Inf)) == 80
                @test precision(norm(TMat(A, prec = 80), -Inf)) == 80
                @test precision(norm(TMat(A, prec = 80), 1)) == 80
                @test precision(norm(TMat(0, 0, prec = 80))) == 80
            end

            @testset "lu" begin
                A = TMat([
                    1 1 1 1;
                    1 3 1 1;
                    1 1 4 1;
                    1 1 1 5
                ]) # A matrix with exact lu decomposition
                B1 = TMat(1:4)
                B2 = TMat(reshape(1:8, 4, 2))

                F = lu(A)

                @test isequal(F, lu(A, RowMaximum()))
                F_int = lu(Int.(A))
                @test isequal(F.L, F_int.L)
                @test isequal(F.U, F_int.U)
                @test isequal(F.p, F_int.p)

                @test isequal(A \ B1, F \ B1)
                @test isequal(A \ B2, F \ B2)
                @test isequal(A \ B1, LinearAlgebra.ldiv!(F, B1))
                @test isequal(A \ B2, LinearAlgebra.ldiv!(F, B2))
                @test isequal(A \ B1, LinearAlgebra.ldiv!(similar(B1), F, B1))
                @test isequal(A \ B2, LinearAlgebra.ldiv!(similar(B2), F, B2))

                # List of all permutations of 4 elements
                permutations_4 = [
                    [1, 2, 3, 4],
                    [1, 2, 4, 3],
                    [1, 3, 2, 4],
                    [1, 3, 4, 2],
                    [1, 4, 2, 3],
                    [1, 4, 3, 2],
                    [2, 1, 3, 4],
                    [2, 1, 4, 3],
                    [2, 3, 1, 4],
                    [2, 3, 4, 1],
                    [2, 4, 1, 3],
                    [2, 4, 3, 1],
                    [3, 1, 2, 4],
                    [3, 1, 4, 2],
                    [3, 2, 1, 4],
                    [3, 2, 4, 1],
                    [3, 4, 1, 2],
                    [3, 4, 2, 1],
                    [4, 1, 2, 3],
                    [4, 1, 3, 2],
                    [4, 2, 1, 3],
                    [4, 2, 3, 1],
                    [4, 3, 1, 2],
                    [4, 3, 2, 1],
                ]

                # For each permutation, construct a matrix such that
                # when LU factorized it has the given permutation.
                matrices = map(permutations_4) do perm
                    C = TMat(4, 4)
                    for (col_idx, row_idx) in enumerate(perm)
                        # Use descending powers of 2 (8, 4, 2, 1) to force pivot choices
                        C[row_idx, col_idx] = 2^(4 - col_idx + 1)
                    end
                    return C
                end

                for A in matrices
                    F = lu(A)
                    F_int = lu(Int.(A))

                    @test isequal(F.L, F_int.L)
                    @test isequal(F.U, F_int.U)
                    @test isequal(F.p, F_int.p)
                end

                @test precision(lu(TMat(A, prec = 80)) \ TMat(B1, prec = 96)) == 96
                @test precision(
                    LinearAlgebra.ldiv!(lu(TMat(A, prec = 96)), TMat(B1, prec = 80)),
                ) == 80
                @test precision(
                    LinearAlgebra.ldiv!(
                        TMat(B1, prec = 96),
                        lu(TMat(A, prec = 80)),
                        TMat(B1, prec = 80),
                    ),
                ) == 96

                @test_throws DimensionMismatch(
                    "matrix is not square: dimensions are (2, 3)",
                ) lu(TMat(2, 3))

                @test_throws SingularException(0) lu(TMat(2, 2))
                @test_throws SingularException(0) lu(TMat(ones(2, 2)))

                @test !issuccess(lu(TMat(2, 2), check = false))
                @test !issuccess(lu(TMat(2, 2), check = false, allowsingular = true))
            end

            @testset "ldiv" begin
                A = TMat([
                    2 1 1 1;
                    1 3 1 1;
                    1 1 4 1;
                    1 1 1 5
                ]) # Some random invertible matrix
                B1 = TMat(1:4)
                B2 = TMat(reshape(1:8, 4, 2))

                @test Arblib.overlaps(A * (A \ B1), B1)
                @test Arblib.overlaps(A * (A \ B2), B2)

                @test isequal(A \ B1, LinearAlgebra.ldiv!(A, B1))
                @test isequal(A \ B2, LinearAlgebra.ldiv!(A, B2))

                @test isequal(A \ B1, LinearAlgebra.ldiv!(similar(B1), A, B1))
                @test isequal(A \ B2, LinearAlgebra.ldiv!(similar(B2), A, B2))

                @test precision(TMat(A, prec = 80) \ TMat(B1, prec = 96)) == 96
                @test precision(
                    LinearAlgebra.ldiv!(TMat(A, prec = 96), TMat(B1, prec = 80)),
                ) == 80
                @test precision(
                    LinearAlgebra.ldiv!(
                        TMat(B1, prec = 96),
                        TMat(A, prec = 80),
                        TMat(B1, prec = 80),
                    ),
                ) == 96

                @test all(!isfinite, TMat(Diagonal([1, 2, 3, 0])) \ B1)
                @test all(!isfinite, TMat(Diagonal([1, 2, 3, 0])) \ B2)

                @test_throws DimensionMismatch(
                    "matrix is not square: dimensions are (2, 3)",
                ) TMat(2, 3) \ TMat(3, 1)
                @test_throws DimensionMismatch(
                    "matrix is not square: dimensions are (2, 3)",
                ) LinearAlgebra.ldiv!(TMat(2, 3), TMat(3, 1))
                @test_throws DimensionMismatch(
                    "matrix is not square: dimensions are (2, 3)",
                ) LinearAlgebra.ldiv!(TMat(3, 1), TMat(2, 3), TMat(3, 1))

                @test_throws DimensionMismatch("matrix sizes are not compatible") TMat(
                    2,
                    2,
                ) \ TMat(3, 1)
                @test_throws DimensionMismatch("matrix sizes are not compatible") LinearAlgebra.ldiv!(
                    TMat(2, 2),
                    TMat(3, 1),
                )
                @test_throws DimensionMismatch("matrix sizes are not compatible") LinearAlgebra.ldiv!(
                    TMat(3, 1),
                    TMat(2, 2),
                    TMat(3, 1),
                )
                @test_throws DimensionMismatch("output not same size as input") LinearAlgebra.ldiv!(
                    TMat(3, 1),
                    TMat(2, 2),
                    TMat(2, 1),
                )
            end

            @testset "inv" begin
                A = TMat([
                    1 1 1 1;
                    1 2 1 1;
                    1 1 3 1;
                    1 1 1 4
                ]) # Some random invertible matrix
                @test Arblib.overlaps(inv(A) * A, TMat(I(4)))

                @test all(!isfinite, inv(TMat(Diagonal([1, 2, 3, 0]))))

                @test_throws DimensionMismatch(
                    "matrix is not square: dimensions are (2, 3)",
                ) inv(TMat(2, 3))
            end

            @testset "det" begin
                A = TMat([
                    1 1 1 1;
                    1 2 1 1;
                    1 1 3 1;
                    1 1 1 4
                ]) # Some random invertible matrix

                @test det(A) == det(Int.(A))

                B = TMat(sin.(A))
                @test Arblib.contains(det(B) * det(inv(B)), T(1))
            end
        end

        @testset "indexing" begin
            A = TMat(3, 1)
            A[3, 1][] = 4
            @test A[3] == A[3, 1]
            B = TMat(reshape(1:15, 3, 5))
            @test B[1:15] == 1:15
            C = TMat(reshape(1:15, 5, 3))
            @test C[1:15] == 1:15
        end

        @testset "similar:" begin
            A = TMat(3, 5; prec = 96)

            a = similar(A)
            @test a isa TMat
            @test precision(a) == precision(A)

            a = similar(A, TRef, (2, 3))
            @test a isa TMat
            @test precision(a) == precision(A)

            for (ElT, VT, MT) in (
                (Arb, ArbVector, ArbMatrix),
                (Acb, AcbVector, AcbMatrix),
                (ArbRef, ArbRefVector, ArbRefMatrix),
                (AcbRef, AcbRefVector, AcbRefMatrix),
            )
                a = similar(A, ElT, 3)
                @test a isa VT
                @test precision(a) == precision(A)

                a = similar(A, ElT, (3, 2))
                @test a isa MT
                @test precision(a) == precision(A)
            end
        end

        @testset "set Rational" begin
            A = TMat(2, 2)
            A[1, 1] = 5 // 8
            @test !iszero(A[1, 1])
        end

        @testset "copy" begin
            A = TMat([1 2; 3 4])
            B = copy(A)
            @test A == B
            B[1] = 2
            @test A[1, 1] == 1
            @test B[1, 1] == 2

            B = similar(A)
            copy!(B, A)
            @test A == B
            B[1] = 2
            @test A[1] == 1
            @test B[1] == 2

            @test_throws DimensionMismatch copy!(TMat(1, 2), A)
            @test_throws DimensionMismatch copy!(TMat(3, 2), A)
            @test_throws DimensionMismatch copy!(TMat(2, 1), A)
            @test_throws DimensionMismatch copy!(TMat(3, 3), A)
        end
    end

    @testset "RefMatrix: $T" for (T, TRef) in
                                 [(ArbMatrix, ArbRefMatrix), (AcbMatrix, AcbRefMatrix)]
        A = T(2, 3; prec = 96)
        A[1, 2] = 3

        # shallow = false
        B = TRef(A)
        @test B isa TRef
        @test precision(B) == 96
        B[1, 2] = 4
        @test A[1, 2] == 3
        @test B[1, 2] == 4

        # shallow = true
        B = TRef(A, shallow = true)
        @test B isa TRef
        @test precision(B) == 96
        B[1, 2] = 4
        @test A[1, 2] == 4
        @test B[1, 2] == 4
    end
end
