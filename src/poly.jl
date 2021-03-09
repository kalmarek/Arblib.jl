# Interface
Base.length(poly::Union{arb_poly_struct,ArbPoly}) =
    ccall(@libarb(arb_poly_length), Int, (Ref{arb_poly_struct},), poly)
Base.length(poly::Union{acb_poly_struct,AcbPoly}) =
    ccall(@libarb(acb_poly_length), Int, (Ref{acb_poly_struct},), poly)
Base.length(series::Union{ArbSeries,AcbSeries}) = series.degree + 1

# We have to define these separately so that it overrides the default
# correctly
degree(series::ArbSeries) = series.degree
degree(series::AcbSeries) = series.degree

Base.eltype(::Type{<:Union{ArbPoly,ArbSeries}}) = Arb
Base.eltype(::Type{<:Union{AcbPoly,AcbSeries}}) = Acb

Base.checkbounds(::Type{Bool}, poly::Union{ArbPoly,AcbPoly}, i::Integer) = i >= 0
Base.checkbounds(::Type{Bool}, series::Union{ArbSeries,AcbSeries}, i::Integer) =
    0 <= i <= degree(series)
Base.checkbounds(poly::Union{ArbPoly,ArbSeries,AcbPoly,AcbSeries}, i::Integer) =
    checkbounds(Bool, poly, i) || throw(BoundsError(poly, i))

Base.@propagate_inbounds function Base.getindex(
    poly::T,
    i::Integer,
) where {T<:Union{ArbPoly,ArbSeries,AcbPoly,AcbSeries}}
    @boundscheck checkbounds(poly, i)
    res = eltype(T)(prec = precision(poly))
    get_coeff!(res, poly, i)
    return res
end

Base.@propagate_inbounds function Base.setindex!(
    poly::Union{ArbPoly,ArbSeries},
    x::ArbLike,
    i::Integer,
)
    @boundscheck checkbounds(poly, i)
    set_coeff!(poly, i, x)
    return x
end

Base.@propagate_inbounds function Base.setindex!(
    poly::Union{AcbPoly,AcbSeries},
    x::AcbLike,
    i::Integer,
)
    @boundscheck checkbounds(poly, i)
    set_coeff!(poly, i, x)
    return x
end

Base.@propagate_inbounds function Base.setindex!(
    poly::Union{ArbPoly,ArbSeries,AcbPoly,AcbSeries},
    x,
    i::Integer,
)
    @boundscheck checkbounds(poly, i)
    set_coeff!(poly, i, convert(eltype(poly), x))
    return x
end

# Constructors
for TPoly in [:ArbPoly, :AcbPoly]
    @eval function $TPoly(poly::cstructtype($TPoly); prec::Integer = DEFAULT_PRECISION[])
        res = $TPoly(prec = prec)
        set!(res, poly)
        return res
    end

    @eval function $TPoly(coeff; prec::Integer = _precision(coeff))
        poly = $TPoly(prec = prec)
        poly[0] = coeff
        return poly
    end

    @eval function $TPoly(coeffs::AbstractVector; prec::Integer = _precision(first(coeffs)))
        poly = $TPoly(prec = prec)
        @inbounds for i = 1:length(coeffs)
            poly[i-1] = coeffs[i]
        end
        return poly
    end
end
function AcbPoly(poly::ArbPoly; prec = precision(poly))
    res = AcbPoly(prec = prec)
    @inbounds for i = 0:Arblib.degree(poly)
        res[i] = poly[i]
    end
    return res
end

for TSeries in [:ArbSeries, :AcbSeries]
    @eval function $TSeries(
        poly::cstructtype($TSeries);
        degree::Integer = degree(poly),
        prec::Integer = DEFAULT_PRECISION[],
    )
        res = $TSeries(degree = degree, prec = prec)
        set!(res, poly)
        return res
    end

    @eval function $TSeries(coeff; degree::Integer = 0, prec::Integer = _precision(coeff))
        series = $TSeries(degree = degree, prec = prec)
        series[0] = coeff
        return series
    end

    @eval function $TSeries(
        coeffs::AbstractVector;
        degree::Integer = length(coeffs) - 1,
        prec::Integer = _precision(first(coeffs)),
    )
        series = $TSeries(degree = degree, prec = prec)
        @inbounds for i = 1:length(coeffs)
            series[i-1] = coeffs[i]
        end
        return series
    end
end
function AcbSeries(series::ArbSeries; degree = degree(series), prec = precision(series))
    res = AcbSeries(degree = degree, prec = prec)
    @inbounds for i = 0:Arblib.degree(series)
        res[i] = series[i]
    end
    return res
end

Base.zero(poly::T) where {T<:Union{ArbPoly,AcbPoly}} = T(prec = precision(poly))
Base.one(poly::T) where {T<:Union{ArbPoly,AcbPoly}} = one!(T(prec = precision(poly)))

Base.zero(series::T) where {T<:Union{ArbSeries,AcbSeries}} =
    T(degree = degree(series), prec = precision(series))
Base.one(series::T) where {T<:Union{ArbSeries,AcbSeries}} =
    one!(T(degree = degree(series), prec = precision(series)))

Base.zero(::Type{T}) where {T<:Union{ArbPoly,AcbPoly}} = T()
Base.one(::Type{T}) where {T<:Union{ArbPoly,AcbPoly}} = one!(T())

Base.zero(::Type{T}) where {T<:Union{ArbSeries,AcbSeries}} = T()
Base.one(::Type{T}) where {T<:Union{ArbSeries,AcbSeries}} = one!(T())
