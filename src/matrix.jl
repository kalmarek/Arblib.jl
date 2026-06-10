# arb_mat_struct and acb_mat_struct methods
Base.size(A::Union{arb_mat_struct,acb_mat_struct}) = (A.r, A.c)

function Base.getindex(A::arb_mat_struct, i::Integer, j::Integer)
    return ccall(
        @libflint(arb_mat_entry_ptr),
        Ptr{arb_struct},
        (Ref{arb_mat_struct}, Int, Int),
        A,
        i - 1,
        j - 1,
    )
end

function Base.getindex(A::acb_mat_struct, i::Integer, j::Integer)
    return ccall(
        @libflint(acb_mat_entry_ptr),
        Ptr{acb_struct},
        (Ref{acb_mat_struct}, Int, Int),
        A,
        i - 1,
        j - 1,
    )
end

Base.setindex!(A::Union{arb_mat_struct,acb_mat_struct}, x, i::Integer, j::Integer) =
    (set!(A[i, j], x); x)

# AbstractMatrix interface

const Matrices = Union{ArbMatrixOrRef,AcbMatrixOrRef}

Base.size(A::Matrices) = size(cstruct(A))

"""
    ref(A::Union{ArbMatrixOrRef,AcbMatrixOrRef}, i, j)

Similar to `A[i,j]` but instead of an `Arb` or `Acb` returns an
`ArbRef` or `AcbRef` which still shares the memory with the `(i,j)`-th
entry of `A`.
"""
Base.@propagate_inbounds function ref(A::ArbMatrixOrRef, i::Integer, j::Integer)
    @boundscheck checkbounds(A, i, j)
    return ArbRef(cstruct(A)[i, j], precision(A), cstruct(A))
end
Base.@propagate_inbounds function ref(A::AcbMatrixOrRef, i::Integer, j::Integer)
    @boundscheck checkbounds(A, i, j)
    return AcbRef(cstruct(A)[i, j], precision(A), cstruct(A))
end

Base.@propagate_inbounds function Base.getindex(
    A::Union{ArbMatrix,AcbMatrix},
    i::Integer,
    j::Integer,
)
    @boundscheck checkbounds(A, i, j)
    return set!(eltype(A)(prec = precision(A)), cstruct(A)[i, j])
end
Base.@propagate_inbounds Base.getindex(
    A::Union{ArbRefMatrix,AcbRefMatrix},
    i::Integer,
    j::Integer,
) = ref(A, i, j)

Base.@propagate_inbounds function Base.setindex!(A::Matrices, x, i::Integer, j::Integer)
    ref(A, i, j)[] = x
    return x
end

# General constructors

for (T, TOrRef) in [
    (:ArbMatrix, :ArbMatrixOrRef),
    (:ArbRefMatrix, :ArbMatrixOrRef),
    (:AcbMatrix, :AcbMatrixOrRef),
    (:AcbRefMatrix, :AcbMatrixOrRef),
]
    @eval $T(r::Integer, c::Integer; prec::Integer = _current_precision()) =
        $T(cstructtype($T)(r, c), shallow = true; prec)

    @eval $T(v::$TOrRef; shallow::Bool = false, prec::Integer = precision(v)) =
        $T(cstruct(v); shallow, prec)


    @eval function $T(A::AbstractMatrix; prec::Integer = _precision(A))
        B = $T(size(A)...; prec)
        # ensure to handle all kind of indices
        ax1, ax2 = axes(A)
        for (i, i′) in enumerate(ax1), (j, j′) in enumerate(ax2)
            B[i, j] = A[i′, j′]
        end
        return B
    end

    @eval function $T(v::AbstractVector; prec::Integer = _precision(v))
        A = $T(length(v), 1; prec)
        for (i, vᵢ) in enumerate(v)
            A[i, 1] = vᵢ
        end
        return A
    end
end

Base.copy(A::Matrices) = copy!(similar(A), A)
function Base.copy!(A::T, B::T) where {T<:Matrices}
    size(A) == size(B) || throw(DimensionMismatch())
    return set!(A, B)
end

# add and sub

for (jf, af) in [(:+, :add!), (:-, :sub!)]
    @eval function Base.$jf(A::T, B::T) where {T<:Matrices}
        @boundscheck (
            size(A) == size(B) ||
            throw(DimensionMismatch("matrix sizes are not compatible."))
        )
        C = T(size(A, 1), size(B, 2); prec = _precision(A, B))
        return $af(C, A, B)
    end
end

Base.:(-)(A::Matrices) = neg!(similar(A), A)

# mul

function LinearAlgebra.mul!(C::T, A::T, B::T) where {T<:Matrices}
    @boundscheck (
        (size(C) == (size(A, 1), size(B, 2)) && size(A, 2) == size(B, 1)) ||
        throw(DimensionMismatch("matrix sizes are not compatible."))
    )
    return Arblib.mul!(C, A, B)
end

function Base.:(*)(A::T, B::T) where {T<:Matrices}
    C = T(size(A, 1), size(B, 2); prec = _precision(A, B))
    return LinearAlgebra.mul!(C, A, B)
end

# scalar multiplication
Base.:(*)(c::ArbOrRef, A::T) where {T<:Matrices} = Arblib.mul!(similar(A), A, c)
Base.:(*)(c::AcbOrRef, A::AcbMatrixOrRef) = Arblib.mul!(similar(A), A, c)
function Base.:(*)(c::AcbOrRef, A::ArbMatrixOrRef)
    C = AcbMatrix(A)
    return Arblib.mul!(C, C, c)
end
Base.:(*)(A::Matrices, c::Union{ArbOrRef,AcbOrRef}) = c * A

# scalar division
Base.:(\)(c::ArbOrRef, A::T) where {T<:Matrices} = Arblib.div!(similar(A), A, c)
Base.:(\)(c::AcbOrRef, A::AcbMatrixOrRef) = Arblib.div!(similar(A), A, c)
function Base.:(\)(c::AcbOrRef, A::ArbMatrixOrRef)
    C = AcbMatrix(A)
    return Arblib.div!(C, C, c)
end
Base.:(/)(A::Matrices, c::Union{ArbOrRef,AcbOrRef}) = c \ A

# norm
function LinearAlgebra.norm(A::Matrices, p::Real = 2)
    if isempty(A)
        return Arb(prec = precision(A))
    elseif p == 2
        return frobenius_norm!(Arb(prec = precision(A)), A)
    elseif p == Inf
        # Return maximum absolute value
        res = Arb(prec = precision(A))
        abs_a = zero(res)
        for ij in CartesianIndices(A)
            abs!(abs_a, ref(A, Tuple(ij)...))
            max!(res, res, abs_a)
        end

        return res
    elseif p == -Inf
        # Return minimum absolute value
        # A is always non-empty here, so Inf is neutral
        res = Arb(Inf, prec = precision(A))
        abs_a = zero(res)
        for ij in CartesianIndices(A)
            abs!(abs_a, ref(A, Tuple(ij)...))
            min!(res, res, abs_a)
        end

        return res
    else
        p = p isa ArbOrRef ? p : Arb(p, prec = precision(A))

        res = Arb(0, prec = precision(A))
        pow!(res, res, p)
        abs_a_pow_p = zero(res)
        for ij in CartesianIndices(A)
            abs!(abs_a_pow_p, ref(A, Tuple(ij)...))
            pow!(abs_a_pow_p, abs_a_pow_p, p)
            add!(res, res, abs_a_pow_p)
        end

        inv_p = inv!(abs_a_pow_p, p) # Reuse abs_a_pow_p
        return pow!(res, res, inv_p)
    end
end

# lu factorization

# Helper function to convert a final permutation vector `p` into a
# sequence of swaps `ipiv` compatible with LinearAlgebra.LU. It is the
# inverse of LinearAlgebra.ipiv2perm
function _perm2ipiv!(p::Vector{Int})
    ipiv = similar(p)

    # q is the inverse permutation (maps position -> value)
    # We simulate sorting q back to identity
    q = invperm(p)

    @inbounds for i in eachindex(p)
        # We want to place value i at index i in q

        k = p[i] # Current position k of value i in q
        l = q[i]

        # Record the pivot
        ipiv[i] = k

        # Perform the swap in q
        # q[i] = i # q[i] is never accessed again, so we can skip swapping it
        q[k] = l

        # Update the lookup table for the value that was moved
        p[l] = k
        # p[i] = i # p[i] is never accessed again, so we can skip swapping it
    end

    return ipiv
end

function LinearAlgebra.lu!(
    A::Matrices,
    pivot::LinearAlgebra.RowMaximum;
    check::Bool = true,
    allowsingular::Bool = false,
)
    LinearAlgebra.checksquare(A) # Flint only supports square LU decomposition

    perm = zeros(Int, size(A, 2))

    flag = lu!(perm, A, A, prec = precision(A))

    check && iszero(flag) && throw(LinearAlgebra.SingularException(0))

    # Convert from 0-based indexing to 1-based indexing
    perm .+= 1

    ipiv = _perm2ipiv!(perm)

    # Negative info indicates a failure, 0 indicates success
    info = iszero(flag) ? -1 : 0

    return LinearAlgebra.LU(A, ipiv, info)
end

# Default implementation of lu uses _lucopy(A, lutype(T)) to convert
# the input to the right type. Due to how e.g. Arb and ArbRef interact
# this converts ArbRefMatrix to ArbMatrix, which we don't want.
# Instead we simply directly call lu!, which is what LinearAlgebra
# does in the end.
# The most convenient would be to overload it like
#lu(A::Matrices, args...; kwargs...) where {T} = _lu(copy(A), args...; kwargs...)
# This however leads to ambiguities due to the deprecated versions
#lu(A::AbstractMatrix, ::Val{true}; check::Bool = true)
#lu(A::AbstractMatrix, ::Val{false}; check::Bool = true)
# And also with other definitions on Julia version 1.10 and older. We
# therefore selectively overload only some cases.
LinearAlgebra.lu(A::Matrices; kwargs...) = LinearAlgebra.lu!(copy(A); kwargs...)
LinearAlgebra.lu(A::Matrices, pivot::LinearAlgebra.RowMaximum; kwargs...) =
    LinearAlgebra.lu!(copy(A), pivot; kwargs...)

# ldiv! and \

function LinearAlgebra.ldiv!(Y::T, A::T, B::T) where {T<:Matrices}
    LinearAlgebra.checksquare(A)

    @boundscheck (
        size(Y) == size(B) || throw(DimensionMismatch("output not same size as input"))
    )
    @boundscheck (
        size(A, 1) == size(B, 1) ||
        throw(DimensionMismatch("matrix sizes are not compatible"))
    )

    # Directly call arb_mat_solve (or acb_mat_solve), which
    # automatically selects between arb_mat_solve_lu and
    # arb_mat_solve_precond depending on the size of the input and the
    # precision.
    flag = solve!(Y, A, B)

    # The Base version of this throws a
    # LinearAlgebra.SingularException in case the inversion fails. We
    # instead opt to return a matrix filled with indeterminate values.
    # The motivation for this is that failure to invert matrices is
    # fairly common when working with wide balls and the overhead of
    # catching an exception adds a lot of extra work.
    if iszero(flag)
        for i in axes(Y, 1)
            for j in axes(Y, 2)
                @inbounds indeterminate!(ref(Y, i, j))
            end
        end
    end

    return Y
end

LinearAlgebra.ldiv!(A::T, B::T) where {T<:Matrices} = LinearAlgebra.ldiv!(B, A, B)
Base.:(\)(A::T, B::T) where {T<:Matrices} =
    LinearAlgebra.ldiv!(T(size(B)...; prec = _precision(A, B)), A, B)

# TODO: How to handle the Any?
function LinearAlgebra.ldiv!(Y::T, A::LinearAlgebra.LU{<:Any,T}, B::T) where {T<:Matrices}
    LinearAlgebra.checksquare(A)
    @boundscheck (
        size(Y) == size(B) || throw(DimensionMismatch("output not same size as input"))
    )
    @boundscheck (
        size(A, 1) == size(B, 1) ||
        throw(DimensionMismatch("matrix sizes are not compatible"))
    )

    # The documentation of LinearAlgebra.lu specifies that it is the
    # users responsibility to check issuccess(A). We therefore don't
    # check it here, it will just return garbage in case it wasn't
    # successful.

    # Convert from 1-based indexing to 0-based indexing
    # IMPROVE: It seems like A.p always generates a new copy of p. We
    # could hence mutate it to save one allocation.
    perm = A.p .- 1

    return solve_lu_precomp!(Y, perm, A.factors, B)
end

LinearAlgebra.ldiv!(A::LinearAlgebra.LU{<:Any,T}, B::T) where {T<:Matrices} =
    LinearAlgebra.ldiv!(B, A, B)
Base.:(\)(A::LinearAlgebra.LU{<:Any,T}, B::T) where {T<:Matrices} =
    LinearAlgebra.ldiv!(T(size(B)...; prec = _precision(A.factors, B)), A, B)

# inv
function Base.inv(A::Matrices)
    LinearAlgebra.checksquare(A)

    B = similar(A)
    flag = inv!(B, A)

    # The Base version of this throws a
    # LinearAlgebra.SingularException in case the inversion fails. We
    # instead opt to return a matrix filled with indeterminate values.
    # The motivation for this is that failure to invert matrices is
    # fairly common when working with wide balls and the overhead of
    # catching an exception adds a lot of extra work.
    if iszero(flag)
        for i in axes(B, 1)
            for j in axes(B, 2)
                @inbounds indeterminate!(ref(B, i, j))
            end
        end
    end

    return B
end

# det
LinearAlgebra.det(A::ArbMatrixOrRef) = det!(Arb(prec = precision(A)), A)
LinearAlgebra.det(A::AcbMatrixOrRef) = det!(Acb(prec = precision(A)), A)
