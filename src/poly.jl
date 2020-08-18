Base.length(poly::Union{arb_poly_struct,ArbPoly}) =
    ccall(@libarb(arb_poly_length), Int, (Ref{arb_poly_struct},), poly)
Base.length(series::ArbSeries) = series.degree + 1

degree(series::ArbSeries) = series.degree

Base.checkbounds(::Type{Bool}, poly::ArbPoly, i::Integer) = i >= 0
Base.checkbounds(::Type{Bool}, series::ArbSeries, i::Integer) = 0 <= i <= degree(series)
Base.checkbounds(poly::Union{ArbPoly,ArbSeries}, i::Integer) =
    checkbounds(Bool, poly, i) || throw(BoundsError(poly, i))

Base.@propagate_inbounds function Base.getindex(poly::Union{ArbPoly,ArbSeries}, i::Integer)
    @boundscheck checkbounds(poly, i)
    res = Arb()
    get_coeff!(res, poly, i)
    return res
end

Base.@propagate_inbounds function Base.setindex!(
    poly::Union{ArbPoly,ArbSeries},
    x::Arb,
    i::Integer,
)
    @boundscheck checkbounds(poly, i)
    set_coeff!(poly, i, x)
    return x
end
