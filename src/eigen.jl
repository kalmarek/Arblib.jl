# eigenvalue/eigenvector computations

struct EigenvalueComputationError <: Exception end

Base.showerror(io::IO, ::EigenvalueComputationError) = print(
    io,
    "Failed to separate eigenvalues.\n",
    "You may try to increase precision, apply a similarity transform, or call `eig_multiple` if clusters of eigenvalues are expected.",
)

function approx_eig_qr!(
    eigvals::AcbVectorLike,
    eigvecs::AcbMatrixLike,
    A::AcbMatrixLike;
    tol = Mag(),
    maxiter = 0,
    prec = _precision(A),
    side = :right,
)
    @boundscheck size(eigvals, 1) == size(A, 1) && size(eigvecs) == size(A) || throw(
        DimensionMismatch("eigvals, eigvecs and A sizes are not compatible."),
    )
    @assert side in (:left, :right) || throw(
        ArgumentError("In approx_eig_qr!: `side` kwarg must be eithe :left or :right"),
    )

    if iszero(tol)
        if side == :right
            approx_eig_qr!(eigvals, C_NULL, eigvecs, A, C_NULL, maxiter; prec)
        else # side == :left
            approx_eig_qr!(eigvals, eigvecs, C_NULL, A, C_NULL, maxiter; prec)
        end
    else
        mag_tol = convert(Mag, tol)
        if side == :right
            approx_eig_qr!(eigvals, C_NULL, eigvecs, A, mag_tol, maxiter; prec)
        else # side == :left
            approx_eig_qr!(eigvals, eigvecs, C_NULL, A, mag_tol, maxiter; prec)
        end
    end
    return eigvals
end

function approx_eig_qr!(
    eigvals::AcbVectorLike,
    A::AcbMatrixLike;
    tol = Mag(),
    maxiter = 0,
    prec = _precision(A),
)
    @boundscheck size(eigvals, 1) == size(A, 1) || throw(
        DimensionMismatch("eigvals, eigvecs and A sizes are not compatible."),
    )
    if iszero(tol)
        approx_eig_qr!(eigvals, C_NULL, C_NULL, A, C_NULL, maxiter; prec)
    else
        mag_tol = convert(Mag, tol)
        approx_eig_qr!(eigvals, C_NULL, C_NULL, A, mag_tol, maxiter; prec)
    end
    return eigvals
end

function approx_eig_qr(
    A::Union{AcbMatrix,AcbRefMatrix};
    tol = Mag(),
    maxiter = 0,
    prec = precision(A),
    side = :right,
)
    λ_approx = similar(A, size(A, 1))
    eigvecs_approx = similar(A)
    approx_eig_qr!(λ_approx, eigvecs_approx, A; tol, maxiter, prec, side)
    return λ_approx, eigvecs_approx
end

for jlf in (:eig_simple_rump!, :eig_simple_vdhoeven_mourrain!, :eig_simple!)
    jlf_allocating = Symbol(string(jlf)[1:(end-1)])
    @eval begin
        function $jlf(
            eigvals::AcbVectorLike,
            eigvecs::AcbMatrixLike,
            A::AcbMatrixLike,
            eigvals_approx::AcbVectorLike,
            R_eigvecs_approx::AcbMatrixLike;
            prec = _precision(A),
            side = :right,
        )
            @assert side in (:left, :right) || throw(
                ArgumentError(
                    "In approx_eig_qr!: `side` kwarg must be either :left or :right",
                ),
            )

            @boundscheck size(eigvals, 1) == size(eigvals_approx, 1) == size(A, 1) || throw(
                DimensionMismatch("Eigenvalues sizes are not compatible with matrix A"),
            )
            @boundscheck size(eigvecs) == size(R_eigvecs_approx) == size(A) || throw(
                DimensionMismatch("Eigenvectors sizes are not compatible with matrix A"),
            )

            val = if side == :left
                $jlf(eigvals, eigvecs, C_NULL, A, eigvals_approx, R_eigvecs_approx; prec)
            else
                $jlf(eigvals, C_NULL, eigvecs, A, eigvals_approx, R_eigvecs_approx; prec)
            end
            isone(val) || throw(EigenvalueComputationError())
            return eigvals, eigvecs
        end

        function $jlf(
            eigvals::AcbVectorLike,
            A::AcbMatrixLike,
            eigvals_approx::AcbVectorLike,
            R_eigvecs_approx::AcbMatrixLike;
            prec = _precision(A),
        )
            @boundscheck size(eigvals_approx, 1) == size(A, 1) || throw(
                DimensionMismatch("Eigenvalues sizes are not compatible with matrix A"),
            )
            @boundscheck size(R_eigvecs_approx) == size(A) || throw(
                DimensionMismatch("Eigenvectors sizes are not compatible with matrix A"),
            )

            val = $jlf(eigvals, C_NULL, C_NULL, A, eigvals_approx, R_eigvecs_approx; prec)
            isone(val) || throw(EigenvalueComputationError())
            return eigvals
        end

        function $jlf(
            eigvals::AcbVectorLike,
            eigvecs::AcbMatrixLike,
            A::Union{AcbMatrix,AcbRefMatrix};
            prec = precision(A),
            side = :right,
        )
            eigvals_approx, R_eigvecs_approx = approx_eig_qr(A, prec = prec)
            return $jlf(eigvals, eigvecs, A, eigvals_approx, R_eigvecs_approx; prec, side)
        end

        function $jlf(
            eigvals::AcbVectorLike,
            A::Union{AcbMatrix,AcbRefMatrix};
            prec = precision(A),
        )
            λ_approx, R_approx = approx_eig_qr(A, prec = prec)
            return $jlf(eigvals, A, λ_approx, R_approx; prec)
        end

        function $jlf_allocating(
            A::Union{AcbMatrix,AcbRefMatrix};
            prec = precision(A),
            side = :right,
        )
            eigvals = similar(A, size(A, 1))
            eigvecs = similar(A)
            $jlf(eigvals, eigvecs, A; prec, side)
            return eigvals, eigvecs
        end
    end
end

function eig_global_enclosure(
    A::Union{AcbMatrix,AcbRefMatrix},
    eigvals_approx::AcbVectorLike,
    R_eigvecs_approx::AcbMatrixLike;
    prec = precision(A),
)
    return eig_global_enclosure!(Mag(), A, eigvals_approx, R_eigvecs_approx, prec)
end

function eig_enclosure_rump!(
    λ::AcbLike,
    eigvecs::Union{AcbMatrix,AcbRefMatrix},
    A::Union{AcbMatrix,AcbRefMatrix},
    λ_approx::AcbLike,
    R_eigvecs_approx::Union{AcbMatrix,AcbRefMatrix};
    prec = precision(A),
)
    @boundscheck size(eigvecs) == size(R_eigvecs_approx) &&
                 size(eigvecs, 1) == size(A, 1) ||
                 throw(DimensionMismatch("Eigenvalues sizes are not compatible"))

    return eig_enclosure_rump!(λ, C_NULL, eigvecs, A, λ_approx, R_eigvecs_approx; prec)
end

for f in (:eig_multiple_rump, :eig_multiple)
    f_inplace = Symbol(f, "!")
    @eval begin
        function $f_inplace(
            eigvals::Union{AcbVector,AcbRefVector},
            A::Union{AcbMatrix,AcbRefMatrix};
            prec = precision(A),
        )
            λ_approx, R_approx = approx_eig_qr(A; prec)
            return $f_inplace(eigvals, A, λ_approx, R_approx; prec)
        end

        function $f(
            A::Union{AcbMatrix,AcbRefMatrix},
            eigvals_approx::AcbVectorLike,
            R_eigvecs_approx::AcbMatrixLike;
            prec = precision(A),
        )
            λ = similar(A, size(A, 1))
            $f_inplace(λ, A, eigvals_approx, R_eigvecs_approx; prec)
            return λ
        end

        function $f(A::Union{AcbMatrix,AcbRefMatrix}; prec = precision(A))
            λ = similar(A, size(A, 1))
            $f_inplace(λ, A; prec)
            return λ
        end

    end
end

LinearAlgebra.eigvals(A::Union{AcbMatrix,AcbRefMatrix}) = eig_multiple(A)
