# @inline clear!(arb_vs::arb_vec_struct) = clear!(arb_vs.entries, arb_vs.n)
function clear!(v::arb_vec_struct)
    ccall(@libarb(_arb_vec_clear), Cvoid, (Ptr{arb_struct}, Clong), v.entries, v.n)
end
Base.size(v::arb_vec_struct) = (v.n,)
Base.getindex(v::arb_vec_struct, i::Integer) = v.entries + (i - 1) * sizeof(arb_struct)
function Base.setindex!(v::arb_vec_struct, x, i::Integer)
    set!(v[i], x)
    return x
end

Base.size(v::ArbVector) = size(v.arb_vec)
Base.cconvert(::Type{Ptr{arb_struct}}, v::ArbVector) = v.arb_vec
Base.unsafe_convert(::Type{Ptr{arb_struct}}, v::arb_vec_struct) = v.entries

function ArbVector(v::AbstractVector, prec::Integer = _precision(first(v)))
    V = ArbVector(length(v); prec = prec)
    @inbounds for (i, vᵢ) in enumerate(v)
        V[i] = vᵢ
    end
    return V
end

Base.@propagate_inbounds function Base.getindex(v::ArbVector, i::Integer)
    @boundscheck checkbounds(v, i)
    return ArbRef(v.arb_vec[i], precision(v), cstruct(v))
end

Base.@propagate_inbounds function Base.setindex!(v::ArbVector, x, i::Integer)
    @boundscheck checkbounds(v, i)
    v.arb_vec[i] = x
    return x
end
