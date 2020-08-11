function AcbMatrix(A::AbstractMatrix{Acb}; prec::Integer = precision(first(A)))
    M = AcbMatrix(size(A)...; prec = prec)
    @inbounds for j = 1:size(A, 2), i = 1:size(A, 1)
        M[i, j] = A[i, j]
    end
    return M
end

Base.size(A::AcbMatrix) = size(A.acb_mat)
Base.size(A::acb_mat_struct) = (A.r, A.c)

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
Base.@propagate_inbounds function Base.getindex(
    A::AcbMatrix,
    i::Integer,
    j::Integer;
    shallow::Bool = false,
)
    @boundscheck checkbounds(A, i, j)
    return Acb(unsafe_load(A.acb_mat[i, j]); prec = precision(A), shallow = shallow)
end

function Base.setindex!(
    A::acb_mat_struct,
    x::Union{Acb,acb_struct,Ref{acb_struct}},
    i::Integer,
    j::Integer,
)
    set!(A[i, j], x)
    return x
end
Base.@propagate_inbounds function Base.setindex!(
    A::AcbMatrix,
    x::Union{Acb,acb_struct,Ref{acb_struct}},
    i::Integer,
    j::Integer,
)
    @boundscheck checkbounds(A, i, j)
    A.acb_mat[i, j] = x
    return x
end
