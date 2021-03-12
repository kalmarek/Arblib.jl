const Poly = Union{ArbPoly,AcbPoly}
const Series = Union{ArbSeries,AcbSeries}

##
## Length and degree
##
Base.length(p::Union{arb_poly_struct,ArbPoly}) =
    ccall(@libarb(arb_poly_length), Int, (Ref{arb_poly_struct},), p)
Base.length(p::Union{acb_poly_struct,AcbPoly}) =
    ccall(@libarb(acb_poly_length), Int, (Ref{acb_poly_struct},), p)
Base.length(p::Series) = p.degree + 1

# Only define size for Poly. Series inherits the size from being
# Numbers
Base.size(p::Poly) = (length(p),)
Base.size(p::Poly, d::Integer) = d < 1 ? throw(BoundsError()) : d == 1 ? length(p) : 1

# We have to define these separately so that it overrides the default
# correctly
degree(p::ArbSeries) = p.degree
degree(p::AcbSeries) = p.degree

##
## Get and set coefficients
##

Base.eltype(::Type{<:Union{ArbPoly,ArbSeries}}) = Arb
Base.eltype(::Type{<:Union{AcbPoly,AcbSeries}}) = Acb

coeffs(p::Union{Poly,Series}) = [@inbounds p[i] for i = 0:degree(p)]

Base.firstindex(::Union{Poly,Series}) = 0
Base.lastindex(p::Union{Poly,Series}) = degree(p)

Base.checkbounds(::Type{Bool}, ::Poly, i::Integer) = i >= 0
Base.checkbounds(::Type{Bool}, p::Series, i::Integer) = 0 <= i <= degree(p)
Base.checkbounds(p::Union{Poly,Series}, i::Integer) =
    checkbounds(Bool, p, i) || throw(BoundsError(p, i))

Base.@propagate_inbounds function Base.getindex(
    p::T,
    i::Integer,
) where {T<:Union{Poly,Series}}
    @boundscheck checkbounds(p, i)
    return get_coeff!(eltype(T)(prec = precision(p)), p, i)
end

Base.getindex(p::Union{Poly,Series}, ::Colon) = coeffs(p)
Base.getindex(p::Union{Poly,Series}, I::AbstractRange{<:Integer}) = [p[i] for i in I]

Base.@propagate_inbounds function Base.setindex!(
    p::Union{ArbPoly,ArbSeries},
    x::ArbLike,
    i::Integer,
)
    @boundscheck checkbounds(p, i)
    set_coeff!(p, i, x)
    return x
end

Base.@propagate_inbounds function Base.setindex!(
    p::Union{AcbPoly,AcbSeries},
    x::AcbLike,
    i::Integer,
)
    @boundscheck checkbounds(p, i)
    set_coeff!(p, i, x)
    return x
end

Base.@propagate_inbounds function Base.setindex!(p::Union{Poly,Series}, x, i::Integer)
    @boundscheck checkbounds(p, i)
    set_coeff!(p, i, convert(eltype(p), x))
    return x
end

##
## Constructors
##

for TPoly in [:ArbPoly, :AcbPoly]
    @eval $TPoly(p::cstructtype($TPoly); prec::Integer = DEFAULT_PRECISION[]) =
        set!($TPoly(prec = prec), p)

    @eval function $TPoly(coeff; prec::Integer = _precision(coeff))
        p = $TPoly(prec = prec)
        p[0] = coeff
        return p
    end

    @eval function $TPoly(coeffs::AbstractVector; prec::Integer = _precision(first(coeffs)))
        p = $TPoly(prec = prec)
        @inbounds for i = 1:length(coeffs)
            p[i-1] = coeffs[i]
        end
        return p
    end
end
function AcbPoly(p::ArbPoly; prec = precision(p))
    res = AcbPoly(prec = prec)
    @inbounds for i = 0:Arblib.degree(p)
        res[i] = p[i]
    end
    return res
end

for TSeries in [:ArbSeries, :AcbSeries]
    @eval $TSeries(
        p::cstructtype($TSeries);
        degree::Integer = degree(p),
        prec::Integer = DEFAULT_PRECISION[],
    ) = set!($TSeries(degree = degree, prec = prec), p)

    @eval function $TSeries(coeff; degree::Integer = 0, prec::Integer = _precision(coeff))
        p = $TSeries(degree = degree, prec = prec)
        p[0] = coeff
        return p
    end

    @eval function $TSeries(
        coeffs::AbstractVector;
        degree::Integer = length(coeffs) - 1,
        prec::Integer = _precision(first(coeffs)),
    )
        p = $TSeries(degree = degree, prec = prec)
        @inbounds for i = 1:length(coeffs)
            p[i-1] = coeffs[i]
        end
        return p
    end
end
function AcbSeries(p::ArbSeries; degree = degree(p), prec = precision(p))
    res = AcbSeries(degree = degree, prec = prec)
    @inbounds for i = 0:Arblib.degree(p)
        res[i] = p[i]
    end
    return res
end

Base.zero(p::T) where {T<:Poly} = T(prec = precision(p))
Base.one(p::Poly) = one!(zero(p))

Base.zero(p::T) where {T<:Series} = T(degree = degree(p), prec = precision(p))
Base.one(p::Series) = one!(zero(p))

Base.zero(::Type{T}) where {T<:Union{Poly,Series}} = T()
Base.one(::Type{T}) where {T<:Union{Poly,Series}} = one!(zero(T))
