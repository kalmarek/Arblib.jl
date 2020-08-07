function ArbMatrix(A::AbstractMatrix{Arb}; prec::Integer = precision(first(A)))
    M = ArbMatrix(size(A)...; prec = prec)
    @inbounds for j = 1:size(A, 2), i = 1:size(A, 1)
        M[i, j] = A[i, j]
    end
    M
end

Base.size(A::ArbMatrix) = (A.arb_mat.r, A.arb_mat.c)

function Base.getindex(A::arb_mat_struct, i::Integer, j::Integer)
    ccall(
        @libarb(arb_mat_entry_ptr),
        Ptr{arb_struct},
        (Ref{arb_mat_struct}, Clong, Clong),
        A,
        i - 1,
        j - 1,
    )
end
Base.@propagate_inbounds function Base.getindex(
    A::ArbMatrix,
    i::Integer,
    j::Integer;
    shallow::Bool = false,
)
    @boundscheck checkbounds(A, i, j)
    Arb(unsafe_load(A.arb_mat[i, j]); prec = precision(A), shallow = shallow)
end

function Base.setindex!(
    A::arb_mat_struct,
    x::Union{Arb,arb_struct,Ref{arb_struct}},
    i::Integer,
    j::Integer,
)
    ccall(@libarb(arb_set), Cvoid, (Ptr{arb_struct}, Ref{arb_struct}), A[i, j], x)
    x
end
Base.@propagate_inbounds function Base.setindex!(
    A::ArbMatrix,
    x::Union{Arb,arb_struct,Ref{arb_struct}},
    i::Integer,
    j::Integer,
)
    @boundscheck checkbounds(A, i, j)
    setindex!(A.arb_mat, x, i, j)
    x
end
