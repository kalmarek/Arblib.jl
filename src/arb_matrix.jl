function ArbMatrix(v::AbstractVector{Arb}; prec::Integer = precision(first(v)))
    M = ArbMatrix(length(v), 1; prec = prec)
    @inbounds for (i, vᵢ) in enumerate(v)
        M[i, 1] = vᵢ
    end
    return M
end

function ArbMatrix(A::AbstractMatrix{Arb}; prec::Integer = precision(first(A)))
    M = ArbMatrix(size(A)...; prec = prec)
    @inbounds for j = 1:size(A, 2), i = 1:size(A, 1)
        M[i, j] = A[i, j]
    end
    return M
end

Base.size(A::ArbMatrix) = size(A.arb_mat)
Base.size(A::arb_mat_struct) = (A.r, A.c)

Base.copy(A::ArbMatrix) = copy!(ArbMatrix(size(A)...; prec = precision(A)), A)
Base.copy!(A::ArbMatrix, B::ArbMatrix) = (set!(A, B); A)
Base.copyto!(A::ArbMatrix, B::ArbMatrix) = (set!(A, B); A)

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

function Base.setindex!(
    A::arb_mat_struct,
    x::Union{Arb,arb_struct,Ref{arb_struct}},
    i::Integer,
    j::Integer,
)
    set!(A[i, j], x)
    return x
end
Base.@propagate_inbounds function Base.setindex!(
    A::ArbMatrix,
    x::Union{Arb,arb_struct,Ref{arb_struct}},
    i::Integer,
    j::Integer,
)
    @boundscheck checkbounds(A, i, j)
    A.arb_mat[i, j] = x
    return x
end
