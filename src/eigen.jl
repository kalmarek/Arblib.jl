# eigenvalue/eigenvector computations

struct EigenvalueComputationError <: Exception end

Base.showerror(io::IO, ::EigenvalueComputationError) = print(io, "Failed to separate eigenvalues.\nYou may try to increase precision, apply a similarity transform, or call `eig_multiple` if clusters of eigenvalues are expected.")

function approx_eig_qr!(
    eigvals::AcbVector,
    eigvecs::AcbMatrix,
    A::AcbMatrix;
    tol = Mag(),
    maxiter = 0,
    prec = precision(A),
    side = :right,
)
    @boundscheck size(eigvals, 1) == size(A, 1) && size(eigvecs) == size(A) ||
                 throw(DimensionMismatch("eigvals, eigvecs and A sizes are not compatible."))
    @assert side in (:left, :right) ||
            throw(ArgumentError("In approx_eig_qr!: `side` kwarg must be eithe :left or :right"))

    if iszero(tol)
        if side == :right
            approx_eig_qr!(eigvals, C_NULL, eigvecs, A, C_NULL, maxiter, prec = prec)
        else # side == :left
            approx_eig_qr!(eigvals, eigvecs, C_NULL, A, C_NULL, maxiter, prec = prec)
        end
    else
        mag_tol = convert(Mag, tol)
        if side == :right
            approx_eig_qr!(eigvals, C_NULL, eigvecs, A, mag_tol, maxiter, prec = prec)
        else # side == :left
            approx_eig_qr!(eigvals, eigvecs, C_NULL, A, mag_tol, maxiter, prec = prec)
        end
    end
    return eigvals
end

function approx_eig_qr!(
    eigvals::AcbVector,
    A::AcbMatrix;
    tol = Mag(),
    maxiter = 0,
    prec = precision(A),
)
    @boundscheck size(eigvals, 1) == size(A, 1) ||
                 throw(DimensionMismatch("eigvals, eigvecs and A sizes are not compatible."))
    if iszero(tol)
        approx_eig_qr!(eigvals, C_NULL, C_NULL, A, C_NULL, maxiter, prec = prec)
    else
        mag_tol = convert(Mag, tol)
        approx_eig_qr!(eigvals, C_NULL, C_NULL, A, mag_tol, maxiter, prec = prec)
    end
    return eigvals
end

function approx_eig_qr(
    A::AcbMatrix;
    tol = Mag(),
    maxiter = 0,
    prec = precision(A),
    side = :right,
)
    λ_approx = similar(A, size(A, 1))
    eigvecs_approx = similar(A)
    approx_eig_qr!(
        λ_approx,
        eigvecs_approx,
        A,
        tol = tol,
        maxiter = maxiter,
        prec = prec,
        side = side,
    )
    return λ_approx, eigvecs_approx
end

for jlf in (:eig_simple_rump!, :eig_simple_vdhoeven_mourrain!, :eig_simple!)
    jlf_allocating = Symbol(string(jlf)[1:end-1])
    @eval begin
        function $jlf(
            eigvals::AcbVector,
            eigvecs::AcbMatrix,
            A::AcbMatrix,
            eigvals_approx::AcbVector,
            R_eigvecs_approx::AcbMatrix;
            prec = precision(A),
            side = :right,
        )
            @assert side in (:left, :right) ||
                    throw(ArgumentError("In approx_eig_qr!: `side` kwarg must be either :left or :right"))

            @boundscheck size(eigvals, 1) == size(eigvals_approx, 1) == size(A, 1) ||
                         throw(DimensionMismatch("Eigenvalues sizes are not compatible with matrix A"))
            @boundscheck size(eigvecs) == size(R_eigvecs_approx) == size(A) ||
                         throw(DimensionMismatch("Eigenvectors sizes are not compatible with matrix A"))

            val = if side == :left
                $jlf(eigvals, eigvecs, C_NULL, A, eigvals_approx, R_eigvecs_approx, prec = prec)
            else
                $jlf(eigvals, C_NULL, eigvecs, A, eigvals_approx, R_eigvecs_approx, prec = prec)
            end
            isone(val) || throw(EigenvalueComputationError())
            return eigvals, eigvecs
        end

        function $jlf(
            eigvals::AcbVector,
            A::AcbMatrix,
            eigvals_approx::AcbVector,
            R_eigvecs_approx::AcbMatrix;
            prec = precision(A),
        )
            val = $jlf(
                eigvals,
                C_NULL,
                C_NULL,
                A,
                eigvals_approx,
                R_eigvecs_approx,
                prec = prec,
            )
            isone(val) || throw(EigenvalueComputationError())
            return eigvals
        end

        function $jlf(
            eigvals::AcbVector,
            eigvecs::AcbMatrix,
            A::AcbMatrix;
            prec = precision(A),
            side = :right,
        )
            eigvals_approx, R_eigvecs_approx = approx_eig_qr(A)
            return $jlf(
                eigvals,
                eigvecs,
                A,
                eigvals_approx,
                R_eigvecs_approx,
                prec = prec,
                side = side,
            )
        end

        function $jlf(eigvals::AcbVector, A::AcbMatrix; prec = precision(A))
            λ_approx, R_approx = approx_eig_qr(A)
            return $jlf(eigvals, A, λ_approx, R_approx, prec = prec)
        end

        function $jlf_allocating(A::AcbMatrix; prec = precision(A), side = :right)
            eigvals = similar(A, size(A, 1))
            eigvecs = similar(A)
            $jlf(eigvals, eigvecs, A, prec = prec, side = side)
            return eigvals, eigvecs
        end
    end
end

function eig_global_enclosure!(eps::Mag, A::AcbMatrix; prec = precision(A))
    λ_approx, R_approx = approx_eig_qr(A)
    return eig_global_enclosure!(eps, A, λ_approx, R_approx, prec = prec)
end

function eig_enclosure_rump!(
    λ::Acb,
    eigvecs::AcbMatrix,
    A::AcbMatrix,
    λ_approx::Acb,
    R_eigvecs_approx::AcbMatrix;
    prec = precision(A),
)
    @boundscheck size(eigvecs) == size(R_eigvecs_approx) && size(eigvecs, 1) == size(A, 1) ||
        throw(DimensionMismatch("Eigenvalues sizes are not compatible"))

    return eig_enclosure_rump!(
        λ,
        C_NULL,
        eigvecs,
        A,
        λ_approx,
        R_eigvecs_approx,
        prec = prec,
    )
end

for f in (:eig_multiple_rump, :eig_multiple)
    f_inplace = Symbol(f, "!")
    @eval begin
        function $f_inplace(eigvals::AcbVector, A::AcbMatrix; prec = precision(A))
            λ_approx, R_approx = approx_eig_qr(A)
            return $f_inplace(eigvals, A, λ_approx, R_approx, prec = prec)
        end

        function $f(A::AcbMatrix; prec = precision(A))
            λ = similar(A, size(A, 1))
            $f_inplace(λ, A, prec = prec)
            return λ
        end
    end
end

LinearAlgebra.eigvals(A::AcbMatrix) = eig_multiple(A)
