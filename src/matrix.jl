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

# lu factorization
function LinearAlgebra.lu!(A::Matrices)
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
    Y = T(size(A, 2), size(B, 2); prec = _precision(A, B))
    LinearAlgebra.ldiv!(Y, A, B)
end
function Base.:(\)(A::LinearAlgebra.LU{<:Any,T}, B::T) where {T<:Matrices}
    Y = T(size(A, 2), size(B, 2); prec = _precision(A.factors, B))
    LinearAlgebra.ldiv!(Y, A, B)
end

# inv
function Base.inv(A::Matrices)
    LinearAlgebra.checksquare(A)

    B = similar(A)
    flag = inv!(B, A)

    iszero(flag) && throw(LinearAlgebra.SingularException(0))

    return B
end

# det
LinearAlgebra.det(A::ArbMatrixOrRef) = det!(Arb(prec = precision(A)), A)
LinearAlgebra.det(A::AcbMatrixOrRef) = det!(Acb(prec = precision(A)), A)
