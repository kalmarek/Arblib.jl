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

function LinearAlgebra.inv(A::T) where {T<:Union{ArbMatrix,AcbMatrix}}
    B = T(size(A)...; prec = precision(A))
    Arblib.inv!(B, A)
    B
end

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
