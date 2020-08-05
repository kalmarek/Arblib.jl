function AcbMatrix(A::AbstractMatrix{Acb}; prec::Integer = precision(first(A)))
    M = AcbMatrix(size(A)...; prec = prec)
    for j in 1:size(A, 2), i in 1:size(A,1)
        M[i,j] = A[i,j]
    end
    M
end

Base.size(M::AcbMatrix) = (M.acb_mat.r, M.acb_mat.c)
Base.precision(M::AcbMatrix) = M.prec

function Base.getindex(M::acb_mat_struct, i::Integer, j::Integer)
    ccall(
        @libarb(acb_mat_entry_ptr),
        Ptr{acb_struct},
        (Ref{acb_mat_struct}, Clong, Clong),
        M,
        i - 1,
        j - 1,
    )
end
Base.@propagate_inbounds function Base.getindex(
    M::AcbMatrix,
    i::Integer,
    j::Integer;
    shallow::Bool = false,
)
    @boundscheck checkbounds(M, i, j)
    Acb(unsafe_load(M.acb_mat[i, j]); prec = M.prec, shallow = shallow)
end

function Base.setindex!(
    M::acb_mat_struct,
    x::Union{Acb,acb_struct,Ref{acb_struct}},
    i::Integer,
    j::Integer,
)
    ccall(
        @libarb(acb_set),
        Cvoid,
        (Ptr{acb_struct}, Ref{acb_struct}),
        M[i, j],
        x,
    )
    x
end
Base.@propagate_inbounds function Base.setindex!(
    M::AcbMatrix,
    x::Union{Acb,acb_struct,Ref{acb_struct}},
    i::Integer,
    j::Integer,
)
    @boundscheck checkbounds(M, i, j)
    setindex!(M.acb_mat, x, i, j)
    x
end
