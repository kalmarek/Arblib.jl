for (jf, af) in [(:+, :add!), (:-, :sub!), (:*, :mul!)]
    @eval function $(Expr(:., :Base, QuoteNode(jf)))(
        A::T,
        B::T,
    ) where {T<:Union{ArbMatrix,AcbMatrix}}
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

function LinearAlgebra.inv(A::AcbMatrix)
    B = AcbMatrix(size(A)...; prec = precision(A))
    Arblib.inv!(B, A)
    B
end

LinearAlgebra.ldiv!(Y::AcbMatrix, A::AcbMatrix, B::AcbMatrix) =
    LinearAlgebra.ldiv!(Y, LinearAlgebra.lu(A), B)
LinearAlgebra.ldiv!(A::AcbMatrix, B::AcbMatrix) =
    LinearAlgebra.ldiv!(B, LinearAlgebra.lu(A), B)
function LinearAlgebra.ldiv!(Y::AcbMatrix, A::LinearAlgebra.LU{AcbRef,AcbMatrix}, B::AcbMatrix)
    Arblib.solve_lu_precomp!(Y, A.ipiv, A.factors, B)
    Y
end
LinearAlgebra.ldiv!(A::LinearAlgebra.LU{AcbRef,AcbMatrix}, B::AcbMatrix) =
    LinearAlgebra.ldiv!(B, A, B)

function Base.:(\)(A::AcbMatrix, B::AcbMatrix)
    Y = AcbMatrix(size(A, 2), size(B, 2); prec = max(precision(A), precision(B)))
    LinearAlgebra.ldiv!(Y, A, B)
end
function Base.:(\)(A::LinearAlgebra.LU{AcbRef,AcbMatrix}, B::AcbMatrix)
    Y = AcbMatrix(size(A, 2), size(B, 2); prec = max(precision(A.factors), precision(B)))
    LinearAlgebra.ldiv!(Y, A, B)
end
