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
    res = eltype(T)()
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

Base.@propagate_inbounds function Base.setindex!(
    poly::Union{AcbPoly,AcbSeries},
    x::Acb,
    i::Integer,
)
    @boundscheck checkbounds(poly, i)
    set_coeff!(poly, i, x)
    return x
end

# Constructors
for (TPoly, T) in [(:ArbPoly, :Arb), (:AcbPoly, :Acb)]
    @eval function $TPoly(coeff::$T; prec::Integer = precision(coeff))
        poly = $TPoly(prec = prec)
        poly[0] = coeff
        return poly
    end

    @eval function $TPoly(
        coeffs::AbstractVector{$T};
        prec::Integer = precision(first(coeffs)),
    )
        poly = $TPoly(prec = prec)
        @inbounds for i = 1:length(coeffs)
            poly[i-1] = coeffs[i]
        end
        return poly
    end
end

for (TSeries, T) in [(:ArbSeries, :Arb), (:AcbSeries, :Acb)]
    @eval $TSeries(; prec::Integer = DEFAULT_PRECISION[]) = $TSeries(0)

    @eval function $TSeries(coeff::$T, degree::Integer; prec::Integer = precision(coeff))
        series = $TSeries(degree, prec = prec)
        series[0] = coeff
        return series
    end

    @eval function $TSeries(
        coeffs::AbstractVector{$T};
        prec::Integer = precision(first(coeffs)),
    )
        series = $TSeries(length(coeffs) - 1, prec = prec)
        @inbounds for i = 1:length(coeffs)
            series[i-1] = coeffs[i]
        end
        return series
    end
end

Base.zero(poly::T) where {T<:Union{ArbPoly,AcbPoly}} = T(prec = precision(poly))
function Base.one(poly::T) where {T<:Union{ArbPoly,AcbPoly}}
    res = T(prec = precision(poly))
    one!(res)
    return res
end
Base.zero(series::T) where {T<:Union{ArbSeries,AcbSeries}} =
    T(degree(series), prec = precision(series))
function Base.one(series::T) where {T<:Union{ArbSeries,AcbSeries}}
    res = T(degree(series), prec = precision(series))
    one!(res)
    return res
end

Base.zero(::Type{T}) where {T<:Union{ArbPoly,AcbPoly}} = T()
function Base.one(::Type{T}) where {T<:Union{ArbPoly,AcbPoly}}
    res = T()
    one!(res)
    return res
end
Base.zero(::Type{T}) where {T<:Union{ArbSeries,AcbSeries}} = T(0)
function Base.one(::Type{T}) where {T<:Union{ArbSeries,AcbSeries}}
    res = T(0)
    one!(res)
    return res
end
