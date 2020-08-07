@inline clear!(acb_vs::acb_vec_struct) = clear!(acb_vs.entries, acb_vs.n)
size(acb_v::acb_vec_struct) = (acb_v.n,)
Base.getindex(v::acb_vec_struct, i::Integer) = v.entries + (i - 1) * sizeof(acb_struct)
function Base.setindex!(v::acb_vec_struct, x, i::Integer)
    set!(v[i], x)
    return x
end

Base.size(v::AcbVector) = size(v.acb_vec)
Base.precision(v::AcbVector) = v.prec
Base.cconvert(::Type{Ptr{acb_struct}}, v::AcbVector) = v.acb_vec
Base.unsafe_convert(::Type{Ptr{acb_struct}}, v::acb_vec_struct) = v.entries

function AcbVector(v::AbstractVector{Acb}, prec::Integer = precision(first(v)))
    V = AcbVector(length(v); prec = prec)
    @inbounds for i in eachindex(V)
        V[i] = v[i]
    end
    return V
end

Base.@propagate_inbounds function Base.getindex(
    v::AcbVector,
    i::Integer;
    shallow::Bool = false,
)
    @boundscheck checkbounds(v, i)
    return Acb(unsafe_load(v.acb_vec[i]); prec = precision(v), shallow = shallow)
end

Base.@propagate_inbounds function Base.setindex!(v::AcbVector, x, i::Integer)
    @boundscheck checkbounds(v, i)
    v.acb_vec[i] = x
    return x
end
