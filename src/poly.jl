# Interface
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

# Constructors
function ArbPoly(coeff::Arb; prec::Integer = precision(coeff))
    poly = ArbPoly(prec = prec)
    poly[0] = coeff
    return poly
end

function ArbPoly(coeffs::AbstractVector{Arb}; prec::Integer = precision(first(coeffs)))
    poly = ArbPoly(prec = prec)
    @inbounds for i = 1:length(coeffs)
        poly[i-1] = coeffs[i]
    end
    return poly
end

function ArbSeries(coeff::Arb, N::Integer; prec::Integer = precision(coeff))
    series = ArbSeries(N, prec = prec)
    series[0] = coeff
    return series
end

function ArbSeries(coeffs::AbstractVector{Arb}; prec::Integer = precision(first(coeffs)))
    series = ArbSeries(length(coeffs), prec = prec)
    @inbounds for i = 1:length(coeffs)
        series[i-1] = coeffs[i]
    end
    return series
end

Base.zero(poly::ArbPoly) = ArbPoly(prec = precision(poly))
Base.one(poly::ArbPoly) =
    ArbPoly([Arb(1, prec = precision(series))], prec = precision(poly))
Base.zero(series::ArbSeries) = ArbSeries(degree(series), prec = precision(series))
Base.one(series::ArbSeries) =
    ArbSeries([Arb(1, prec = precision(series))]degree(series), prec = precision(series))
