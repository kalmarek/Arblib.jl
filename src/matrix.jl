## ArbMatrix AbstractMatrix interface
Base.size(A::arb_mat_struct) = (A.r, A.c)
Base.size(A::Union{ArbMatrix,ArbRefMatrix}) = size(A.arb_mat)

function Base.getindex(A::arb_mat_struct, i::Integer, j::Integer)
    return ccall(
        @libarb(arb_mat_entry_ptr),
        Ptr{arb_struct},
        (Ref{arb_mat_struct}, Int, Int),
        A,
        i - 1,
        j - 1,
    )
end
Base.@propagate_inbounds function Base.getindex(A::ArbMatrix, i::Integer, j::Integer)
    @boundscheck checkbounds(A, i, j)
    x = Arb(prec = precision(A))
    x[] = A.arb_mat[i, j]
    x
end
Base.@propagate_inbounds function Base.getindex(A::ArbRefMatrix, i::Integer, j::Integer)
    @boundscheck checkbounds(A, i, j)
    return ArbRef(A.arb_mat[i, j], precision(A), cstruct(A))
end

"""
    ref(A::ArbMatrix, i, j)

Similar to `A[i,j]` but instead of an `Arb` returns an `ArbRef` which still shares the
memory with the `(i,j)`-th entry of `A`.
"""
Base.@propagate_inbounds function ref(
    A::Union{ArbMatrix,ArbRefMatrix},
    i::Integer,
    j::Integer,
)
    @boundscheck checkbounds(A, i, j)
    return ArbRef(A.arb_mat[i, j], precision(A), cstruct(A))
end

Base.setindex!(A::arb_mat_struct, x, i::Integer, j::Integer) = (set!(A[i, j], x); x)
Base.@propagate_inbounds function Base.setindex!(
    A::Union{ArbMatrix,ArbRefMatrix},
    x,
    i::Integer,
    j::Integer,
)
    @boundscheck checkbounds(A, i, j)
    ref(A, i, j)[] = x
    return x
end

## AcbMatrix AbstractMatrix interface
Base.size(A::acb_mat_struct) = (A.r, A.c)
Base.size(A::Union{AcbMatrix,AcbRefMatrix}) = size(A.acb_mat)

function Base.getindex(A::acb_mat_struct, i::Integer, j::Integer)
    return ccall(
        @libarb(acb_mat_entry_ptr),
        Ptr{acb_struct},
        (Ref{acb_mat_struct}, Int, Int),
        A,
        i - 1,
        j - 1,
    )
end
Base.@propagate_inbounds function Base.getindex(A::AcbMatrix, i::Integer, j::Integer)
    @boundscheck checkbounds(A, i, j)
    x = Acb(prec = precision(A))
    x[] = A.acb_mat[i, j]
    x
end
Base.@propagate_inbounds function Base.getindex(A::AcbRefMatrix, i::Integer, j::Integer)
    @boundscheck checkbounds(A, i, j)
    return AcbRef(A.acb_mat[i, j], precision(A), cstruct(A))
end

"""
    ref(A::AcbMatrix, i, j)

Similar to `A[i,j]` but instead of an `Acb` returns an `AcbRef` which still shares the
memory with the `(i,j)`-th entry of `A`.
"""
Base.@propagate_inbounds function ref(
    A::Union{AcbMatrix,AcbRefMatrix},
    i::Integer,
    j::Integer,
)
    @boundscheck checkbounds(A, i, j)
    return AcbRef(A.acb_mat[i, j], precision(A), cstruct(A))
end

Base.setindex!(A::acb_mat_struct, x, i::Integer, j::Integer) = (set!(A[i, j], x); x)
Base.@propagate_inbounds function Base.setindex!(
    A::Union{AcbMatrix,AcbRefMatrix},
    x,
    i::Integer,
    j::Integer,
)
    @boundscheck checkbounds(A, i, j)
    ref(A, i, j)[] = x
    return x
end

## Common methods

# General constructor
for T in [:ArbMatrix, :ArbRefMatrix, :AcbMatrix, :AcbRefMatrix]
    @eval function $T(A::AbstractMatrix; prec::Integer = _precision(first(A)))
        B = $T(size(A)...; prec = prec)
        # ensure to handle all kind of indices
        ax1, ax2 = axes(A)
        for (i, i′) in enumerate(ax1), (j, j′) in enumerate(ax2)
            B[i, j] = A[i′, j′]
        end
        return B
    end

    @eval function $T(v::AbstractVector; prec::Integer = _precision(first(v)))
        A = $T(length(v), 1; prec = prec)
        for (i, vᵢ) in enumerate(v)
            A[i, 1] = vᵢ
        end
        return A
    end
end

const Matrices = Union{ArbMatrix,ArbRefMatrix,AcbMatrix,AcbRefMatrix}

Base.copy(A::T) where {T<:Matrices} = copy!(T(size(A)...; prec = precision(A)), A)
function Base.copy!(A::T, B::T) where {T<:Matrices}
    @boundscheck size(A) == size(B) || throw(DimensionMismatch())
    set!(A, B)
    A
end
function Base.copyto!(A::T, B::T) where {T<:Matrices}
    @boundscheck size(A) == size(B) || throw(DimensionMismatch())
    set!(A, B)
    A
end

# Basic arithmetic
for (jf, af) in [(:+, :add!), (:-, :sub!)]
    @eval function Base.$jf(A::T, B::T) where {T<:Matrices}
        @boundscheck (
            size(A) == size(B) ||
            throw(DimensionMismatch("Matrix sizes are not compatible."))
        )
        C = T(size(A, 1), size(B, 2); prec = max(precision(A), precision(B)))
        $af(C, A, B)
        C
    end
end

Base.:(-)(A::Matrices) = neg!(similar(A), A)

function LinearAlgebra.mul!(C::T, A::T, B::T) where {T<:Matrices}
    @boundscheck (
        (size(C) == (size(A, 1), size(B, 2)) && size(A, 2) == size(B, 1)) ||
        throw(DimensionMismatch("Matrix sizes are not compatible."))
    )
    Arblib.mul!(C, A, B)
    C
end

function Base.:(*)(A::T, B::T) where {T<:Matrices}
    C = T(size(A, 1), size(B, 2); prec = max(precision(A), precision(B)))
    LinearAlgebra.mul!(C, A, B)
end

# scalar multiplication
function Base.:(*)(c::ArbLike, A::T) where {T <: Matrices}
    C = similar(A)
    Arblib.mul!(C,A,c)
end
function Base.:(*)(c::AcbLike, A::AcbMatrixLike)
    C = similar(A)
    Arblib.mul!(C,A,c)
end
function Base.:(*)(c::AcbLike, A::ArbMatrixLike)
    C = AcbMatrix(A)
    Arblib.mul!(C,C,c)
end
Base.:(*)(A::T, c::AcbLike) where {T <: Matrices} = c*A
Base.:(*)(A::T, c::ArbLike) where {T <: Matrices} = c*A

# scalar division
function Base.:(\)(c::ArbLike, A::T) where {T <: Matrices}
    C = similar(A)
    Arblib.div!(C,A,c)
end
function Base.:(\)(c::AcbLike, A::AcbMatrixLike)
    C = similar(A)
    Arblib.div!(C,A,c)
end
function Base.:(\)(c::AcbLike, A::ArbMatrixLike)
    C = AcbMatrix(A)
    Arblib.div!(C,C,c)
end
Base.:(/)(A::T, c::AcbLike) where {T <: Matrices} = c\A
Base.:(/)(A::T, c::ArbLike) where {T <: Matrices} = c\A

# lu factorization
function LinearAlgebra.lu!(A::T) where {T<:Matrices}
    ipiv = zeros(Int, size(A, 2))
    retcode = lu!(ipiv, A, A; prec = precision(A))
    LinearAlgebra.LU(A, ipiv, retcode > 0 ? 0 : 1)
end
function LinearAlgebra.lu(A::Matrices)
    lu = similar(A)
    ipiv = zeros(Int, size(A, 2))
    retcode = lu!(ipiv, lu, A; prec = precision(lu))
    LinearAlgebra.LU(lu, ipiv, retcode > 0 ? 0 : 1)
end

# ldiv! and \
function LinearAlgebra.ldiv!(Y::T, A::T, B::T) where {T<:Matrices}
    @boundscheck (
        (size(Y) == size(B) && size(A, 1) == size(A, 2) && size(A, 1) == size(B, 1)) ||
        throw(DimensionMismatch("Matrix sizes are not compatible."))
    )
    LinearAlgebra.ldiv!(Y, LinearAlgebra.lu(A), B)
end

function LinearAlgebra.ldiv!(A::T, B::T) where {T<:Matrices}
    @boundscheck (
        (size(A, 1) == size(A, 2)) ||
        throw(DimensionMismatch("Expected a square matrix as the left hand side."))
    )
    LinearAlgebra.ldiv!(B, LinearAlgebra.lu(A), B)
end

function LinearAlgebra.ldiv!(Y::T, A::LinearAlgebra.LU{<:Any,T}, B::T) where {T<:Matrices}
    @boundscheck (
        (size(Y) == size(B) && size(A, 1) == size(A, 2) && size(A, 1) == size(B, 1)) ||
        throw(DimensionMismatch("Matrix sizes are not compatible."))
    )
    Arblib.solve_lu_precomp!(Y, A.ipiv, A.factors, B)
    Y
end
LinearAlgebra.ldiv!(A::LinearAlgebra.LU{<:Any,T}, B::T) where {T<:Matrices} =
    LinearAlgebra.ldiv!(B, A, B)

function Base.:(\)(A::T, B::T) where {T<:Matrices}
    Y = T(size(A, 2), size(B, 2); prec = max(precision(A), precision(B)))
    LinearAlgebra.ldiv!(Y, A, B)
end
function Base.:(\)(A::LinearAlgebra.LU{<:Any,T}, B::T) where {T<:Matrices}
    Y = T(size(A, 2), size(B, 2); prec = max(precision(A.factors), precision(B)))
    LinearAlgebra.ldiv!(Y, A, B)
end

# inverse
LinearAlgebra.inv(A::Matrices) = (B = similar(A); inv!(B, A); B)
