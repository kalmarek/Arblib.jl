## ArbMatrix AbstractMatrix interface
Base.size(A::arb_mat_struct) = (A.r, A.c)
Base.size(A::ArbMatrix) = size(A.arb_mat)

function Base.getindex(A::arb_mat_struct, i::Integer, j::Integer)
    return ccall(
        @libarb(arb_mat_entry_ptr),
        Ptr{arb_struct},
        (Ref{arb_mat_struct}, Clong, Clong),
        A,
        i - 1,
        j - 1,
    )
end
Base.@propagate_inbounds function Base.getindex(A::ArbMatrix, i::Integer, j::Integer)
    @boundscheck checkbounds(A, i, j)
    return ArbRef(A.arb_mat[i, j], precision(A), cstruct(A))
end

Base.setindex!(A::arb_mat_struct, x, i::Integer, j::Integer) = (set!(A[i, j], x); x)
Base.@propagate_inbounds function Base.setindex!(A::ArbMatrix, x, i::Integer, j::Integer)
    @boundscheck checkbounds(A, i, j)
    A.arb_mat[i, j] = x
    return x
end

## AcbMatrix AbstractMatrix interface
Base.size(A::acb_mat_struct) = (A.r, A.c)
Base.size(A::AcbMatrix) = size(A.acb_mat)

function Base.getindex(A::acb_mat_struct, i::Integer, j::Integer)
    return ccall(
        @libarb(acb_mat_entry_ptr),
        Ptr{acb_struct},
        (Ref{acb_mat_struct}, Clong, Clong),
        A,
        i - 1,
        j - 1,
    )
end
Base.@propagate_inbounds function Base.getindex(A::AcbMatrix, i::Integer, j::Integer)
    @boundscheck checkbounds(A, i, j)
    return AcbRef(A.acb_mat[i, j], precision(A), cstruct(A))
end

Base.setindex!(A::acb_mat_struct, x, i::Integer, j::Integer) = (set!(A[i, j], x); x)
Base.@propagate_inbounds function Base.setindex!(A::AcbMatrix, x, i::Integer, j::Integer)
    @boundscheck checkbounds(A, i, j)
    A.acb_mat[i, j] = x
    return x
end

## Common methods

# linear indexing
Base.@propagate_inbounds function Base.getindex(A::Union{ArbMatrix,AcbMatrix}, k::Integer)
    @boundscheck (1 ≤ k ≤ length(A) || throw(BoundsError(A, k)))
    j, i = divrem(k - 1, size(A, 1))
    A[i+1, j+1]
end
Base.@propagate_inbounds function Base.setindex!(
    A::Union{ArbMatrix,AcbMatrix},
    x,
    k::Integer,
)
    @boundscheck (1 ≤ k ≤ length(A) || throw(BoundsError(A, k)))
    j, i = divrem(k - 1, size(A, 1))
    A[i+1, j+1] = x
    x
end

# General constructor
for T in [:ArbMatrix, :AcbMatrix]
    @eval function $T(A::AbstractMatrix, prec::Integer = _precision(first(A)))
        B = $T(size(A)...; prec = prec)
        # ensure to handle all kind of indices
        ax1, ax2 = axes(A)
        for (i, i′) in enumerate(ax1), (j, j′) in enumerate(ax2)
            B[i, j] = A[i′, j′]
        end
        return B
    end

    @eval function $T(v::AbstractVector, prec::Integer = _precision(first(v)))
        A = $T(length(v), 1; prec = prec)
        for (i, vᵢ) in enumerate(v)
            A[i, 1] = vᵢ
        end
        return A
    end
end

Base.copy(A::T) where {T<:Union{ArbMatrix,AcbMatrix}} =
    copy!(T(size(A)...; prec = precision(A)), A)
function Base.copy!(A::T, B::T) where {T<:Union{ArbMatrix,AcbMatrix}}
    @boundscheck size(A) == size(B) || throw(DimensionMismatch())
    set!(A, B)
    A
end
function Base.copyto!(A::T, B::T) where {T<:Union{ArbMatrix,AcbMatrix}}
    @boundscheck size(A) == size(B) || throw(DimensionMismatch())
    set!(A, B)
    A
end

## Common methods

# Basic arithmetic
for (jf, af) in [(:+, :add!), (:-, :sub!)]
    @eval function Base.$jf(A::T, B::T) where {T<:Union{ArbMatrix,AcbMatrix}}
        @boundscheck (
            size(A) == size(B) ||
            throw(DimensionMismatch("Matrix sizes are not compatible."))
        )
        C = T(size(A, 1), size(B, 2); prec = max(precision(A), precision(B)))
        $af(C, A, B)
        C
    end
end

function Base.:(-)(A::T) where {T<:Union{ArbMatrix,AcbMatrix}}
    C = T(size(A)...; prec = precision(A))
    neg!(C, A)
    C
end

function LinearAlgebra.mul!(C::T, A::T, B::T) where {T<:Union{ArbMatrix,AcbMatrix}}
    @boundscheck (
        (size(C) == (size(A, 1), size(B, 2)) && size(A, 2) == size(B, 1)) ||
        throw(DimensionMismatch("Matrix sizes are not compatible."))
    )
    Arblib.mul!(C, A, B)
    C
end

function Base.:(*)(A::T, B::T) where {T<:Union{ArbMatrix,AcbMatrix}}
    C = T(size(A, 1), size(B, 2); prec = max(precision(A), precision(B)))
    LinearAlgebra.mul!(C, A, B)
end

# lu factorization
function LinearAlgebra.lu!(A::T) where {T<:Union{ArbMatrix,AcbMatrix}}
    ipiv = zeros(Int, size(A, 2))
    retcode = lu!(ipiv, A, A)
    LinearAlgebra.LU(A, ipiv, retcode > 0 ? 0 : 1)
end
function LinearAlgebra.lu(A::T) where {T<:Union{ArbMatrix,AcbMatrix}}
    lu = T(size(A)...; prec = precision(A))
    ipiv = zeros(Int, size(A, 2))
    retcode = lu!(ipiv, lu, A)
    LinearAlgebra.LU(lu, ipiv, retcode > 0 ? 0 : 1)
end

# ldiv! and \
function LinearAlgebra.ldiv!(Y::T, A::T, B::T) where {T<:Union{ArbMatrix,AcbMatrix}}
    @boundscheck (
        (size(Y) == size(B) && size(A, 1) == size(A, 2) && size(A, 1) == size(B, 1)) ||
        throw(DimensionMismatch("Matrix sizes are not compatible."))
    )
    LinearAlgebra.ldiv!(Y, LinearAlgebra.lu(A), B)
end

function LinearAlgebra.ldiv!(A::T, B::T) where {T<:Union{ArbMatrix,AcbMatrix}}
    @boundscheck (
        (size(A, 1) == size(A, 2)) ||
        throw(DimensionMismatch("Expected a square matrix as the left hand side."))
    )
    LinearAlgebra.ldiv!(B, LinearAlgebra.lu(A), B)
end

function LinearAlgebra.ldiv!(
    Y::T,
    A::LinearAlgebra.LU{<:Any,T},
    B::T,
) where {T<:Union{ArbMatrix,AcbMatrix}}
    @boundscheck (
        (size(Y) == size(B) && size(A, 1) == size(A, 2) && size(A, 1) == size(B, 1)) ||
        throw(DimensionMismatch("Matrix sizes are not compatible."))
    )
    Arblib.solve_lu_precomp!(Y, A.ipiv, A.factors, B)
    Y
end
LinearAlgebra.ldiv!(
    A::LinearAlgebra.LU{<:Any,T},
    B::T,
) where {T<:Union{ArbMatrix,AcbMatrix}} = LinearAlgebra.ldiv!(B, A, B)

function Base.:(\)(A::T, B::T) where {T<:Union{ArbMatrix,AcbMatrix}}
    Y = T(size(A, 2), size(B, 2); prec = max(precision(A), precision(B)))
    LinearAlgebra.ldiv!(Y, A, B)
end
function Base.:(\)(A::LinearAlgebra.LU{<:Any,T}, B::T) where {T<:Union{ArbMatrix,AcbMatrix}}
    Y = T(size(A, 2), size(B, 2); prec = max(precision(A.factors), precision(B)))
    LinearAlgebra.ldiv!(Y, A, B)
end

# inverse
function LinearAlgebra.inv(A::T) where {T<:Union{ArbMatrix,AcbMatrix}}
    B = T(size(A)...; prec = precision(A))
    Arblib.inv!(B, A)
    B
end
