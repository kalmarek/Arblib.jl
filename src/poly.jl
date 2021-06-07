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

_degree(p::Series, q::Series) = min(degree(p), degree(q))

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
    set_coeff!(p, i, eltype(p)(x, prec = precision(p)))
    return x
end

# TODO: Add a ref method for getting references to the coefficients.
# The main issue with this is how to handle access to indices outside
# the length, in particular for series.
#function ref(p::Union{ArbPoly,ArbSeries}, i::Integer)
#    0 <= i <= length(cstruct(p)) || throw(BoundsError(p, i))
#    ptr = cstruct(p).coeffs + i * sizeof(arb_struct)
#    return ArbRef(ptr, precision(p), cstruct(p))
#end

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
        p = fit_length!($TPoly(prec = prec), length(coeffs))
        @inbounds for i = 1:length(coeffs)
            p[i-1] = coeffs[i]
        end
        return p
    end
end
function AcbPoly(p::ArbPoly; prec = precision(p))
    res = fit_length!(AcbPoly(prec = prec), length(p))
    @inbounds for i = 0:degree(p)
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
        p = fit_length!($TSeries(degree = degree, prec = prec), degree + 1)
        @inbounds for i = 1:min(length(coeffs), degree + 1)
            p[i-1] = coeffs[i]
        end
        return p
    end
end
function AcbSeries(p::ArbSeries; degree = degree(p), prec = precision(p))
    res = fit_length!(AcbSeries(degree = degree, prec = prec), degree + 1)
    @inbounds for i = 0:min(Arblib.degree(p), degree)
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

fromroots(::Type{ArbPoly}, roots::ArbVector; prec::Integer = DEFAULT_PRECISION[]) =
    product_roots!(ArbPoly(prec = prec), roots)
fromroots(::Type{ArbPoly}, roots::AbstractVector; prec::Integer = DEFAULT_PRECISION[]) =
    fromroots(ArbPoly, ArbVector(roots, prec = prec), prec = prec)

fromroots(
    ::Type{ArbPoly},
    real_roots::ArbVector,
    complex_roots::AcbVector;
    prec::Integer = DEFAULT_PRECISION[],
) = product_roots_complex!(
    ArbPoly(prec = prec),
    real_roots,
    length(real_roots),
    complex_roots,
    length(complex_roots),
)
fromroots(
    ::Type{ArbPoly},
    real_roots::AbstractVector,
    complex_roots::AbstractVector;
    prec::Integer = DEFAULT_PRECISION[],
) = fromroots(
    ArbPoly,
    ArbVector(real_roots, prec = prec),
    AcbVector(complex_roots, prec = prec),
    prec = prec,
)

fromroots(::Type{AcbPoly}, roots::AcbVector; prec::Integer = DEFAULT_PRECISION[]) =
    product_roots!(AcbPoly(prec = prec), roots)
fromroots(::Type{AcbPoly}, roots::AbstractVector; prec::Integer = DEFAULT_PRECISION[]) =
    fromroots(AcbPoly, AcbVector(roots, prec = prec), prec = prec)

Base.copy(p::Union{Poly,Series}) = set!(zero(p), p)

##
## Arithmetic
##

Base.:-(p::Union{Poly,Series}) = neg!(zero(p), p)

Base.:+(p::T, q::T) where {T<:Poly} = add!(T(prec = _precision((p, q))), p, q)
Base.:-(p::T, q::T) where {T<:Poly} = sub!(T(prec = _precision((p, q))), p, q)
Base.:*(p::T, q::T) where {T<:Poly} = mul!(T(prec = _precision((p, q))), p, q)

function Base.:+(p::AcbPoly, q::ArbPoly)
    res = AcbPoly(q, prec = _precision((p, q)))
    return add!(res, p, res)
end
Base.:+(p::ArbPoly, q::AcbPoly) = q + p

function Base.:-(p::AcbPoly, q::ArbPoly)
    res = AcbPoly(q, prec = _precision((p, q)))
    return sub!(res, p, res)
end
function Base.:-(p::ArbPoly, q::AcbPoly)
    res = AcbPoly(p, prec = _precision((p, q)))
    return sub!(res, res, q)
end

function Base.:*(p::AcbPoly, q::ArbPoly)
    res = AcbPoly(q, prec = _precision((p, q)))
    return mul!(res, p, res)
end
Base.:*(p::ArbPoly, q::AcbPoly) = q * p

# We can't define these as `(p::T, q::T) where {T <: Series}` due to
# method ambiguity issues.
for T in [ArbSeries, AcbSeries]
    @eval function Base.:+(p::$T, q::$T)
        deg = _degree(p, q)
        return add_series!($T(degree = deg, prec = _precision((p, q))), p, q, deg + 1)
    end
    @eval function Base.:-(p::$T, q::$T)
        deg = _degree(p, q)
        return sub_series!($T(degree = deg, prec = _precision((p, q))), p, q, deg + 1)
    end
    @eval function Base.:*(p::$T, q::$T)
        deg = _degree(p, q)
        return mullow!($T(degree = deg, prec = _precision((p, q))), p, q, deg + 1)
    end
    @eval function Base.:/(p::$T, q::$T)
        deg = _degree(p, q)
        return div_series!($T(degree = deg, prec = _precision((p, q))), p, q, deg + 1)
    end
end

function Base.:+(p::AcbSeries, q::ArbSeries)
    deg = _degree(p, q)
    res = AcbSeries(q, degree = deg, prec = _precision((p, q)))
    return add_series!(res, p, res, deg + 1)
end
Base.:+(p::ArbSeries, q::AcbSeries) = q + p

function Base.:-(p::AcbSeries, q::ArbSeries)
    deg = _degree(p, q)
    res = AcbSeries(q, degree = deg, prec = _precision((p, q)))
    return sub_series!(res, p, res, deg + 1)
end
function Base.:-(p::ArbSeries, q::AcbSeries)
    deg = _degree(p, q)
    res = AcbSeries(p, degree = deg, prec = _precision((p, q)))
    return sub_series!(res, res, q, deg + 1)
end

function Base.:*(p::AcbSeries, q::ArbSeries)
    deg = _degree(p, q)
    res = AcbSeries(q, degree = deg, prec = _precision((p, q)))
    return mullow!(res, p, res, deg + 1)
end
Base.:*(p::ArbSeries, q::AcbSeries) = q * p

function Base.:/(p::AcbSeries, q::ArbSeries)
    deg = _degree(p, q)
    res = AcbSeries(q, degree = deg, prec = _precision((p, q)))
    return div_series!(res, p, res, deg + 1)
end
function Base.:/(p::ArbSeries, q::AcbSeries)
    deg = _degree(p, q)
    res = AcbSeries(p, degree = deg, prec = _precision((p, q)))
    return div_series!(res, res, q, deg + 1)
end

Base.inv(p::Series) = inv_series!(zero(p), p, degree(p) + 1)

# TODO: Implement separate ÷ and rem as well? They are only
# implemented for vectors in Arb so we would have to call those
# functions manually.
function Base.divrem(p::T, q::T) where {T<:Poly}
    quotient = T(prec = _precision((p, q)))
    remainder = T(prec = _precision((p, q)))
    divrem!(quotient, remainder, p, q)
    return quotient, remainder
end

##
## Scalar arithmetic
##

# TODO: Promotion from ArbPoly to AcbPoly when needed?
# TODO: Avoid conversion of Ref-types.
# TODO: Avoid the extra allocation required for addition and
# subtraction to extract the first coefficient.
# TODO: How do we want to handle precision? Prioritize polynomial?
# TODO: Take precision of polynomial into account when converting?
for (T, Tel) in [(Union{ArbPoly,ArbSeries}, Real), (Union{AcbPoly,AcbSeries}, Number)]
    @eval function Base.:+(p::$T, c::$Tel)
        res = copy(p)
        res[0] += c
        return res
    end
    @eval function Base.:+(c::$Tel, p::$T)
        res = copy(p)
        res[0] += c
        return res
    end

    @eval function Base.:-(p::$T, c::$Tel)
        res = copy(p)
        res[0] -= c
        return res
    end
    @eval function Base.:-(c::$Tel, p::$T)
        res = -p
        res[0] += c
        return res
    end

    @eval Base.:*(p::$T, c::$Tel) = mul!(zero(p), p, convert(eltype(p), c))
    @eval Base.:*(c::$Tel, p::$T) = mul!(zero(p), p, convert(eltype(p), c))

    @eval Base.:/(p::$T, c::$Tel) = div!(zero(p), p, convert(eltype(p), c))
end

function Base.:/(c::Real, p::ArbSeries)
    res = inv(p)
    return mul!(res, res, convert(Arb, c))
end
function Base.:/(c::Number, p::AcbSeries)
    res = inv(p)
    return mul!(res, res, convert(Acb, c))
end
##
## Evaluation
##

(p::Union{ArbPoly,ArbSeries})(x::ArbOrRef) = evaluate!(Arb(prec = precision(p)), p, x)

(p::Union{ArbPoly,ArbSeries})(x::Real) =
    evaluate!(Arb(prec = precision(p)), p, convert(Arb, x))

(p::Union{Poly,Series})(x::AcbOrRef) = evaluate!(Acb(prec = precision(p)), p, x)

(p::Union{Poly,Series})(x) = evaluate!(Acb(prec = precision(p)), p, convert(Acb, x))

function evaluate2(p::Union{ArbPoly,ArbSeries}, x::ArbOrRef)
    res1, res2 = Arb(prec = precision(p)), Arb(prec = precision(p))
    evaluate2!(res1, res2, p, x)
    return (res1, res2)
end

function evaluate2(p::Union{ArbPoly,ArbSeries}, x::Real)
    res1, res2 = Arb(prec = precision(p)), Arb(prec = precision(p))
    evaluate2!(res1, res2, p, convert(Arb, x))
    return (res1, res2)
end

function evaluate2(p::Union{Poly,Series}, x::AcbOrRef)
    res1, res2 = Acb(prec = precision(p)), Acb(prec = precision(p))
    evaluate2!(res1, res2, p, x)
    return (res1, res2)
end

evaluate2(p::Union{Poly,Series}, x::T) where {T} = evaluate2(p, convert(Acb, x))

##
## Differentiation and integration
##

derivative(p::Poly) = derivative!(zero(p), p)
derivative(p::T) where {T<:Series} =
    derivative!(T(degree = degree(p) - 1, prec = precision(p)), p)

integral(p::Poly) = integral!(zero(p), p)
integral(p::T) where {T<:Series} =
    integral!(T(degree = degree(p) + 1, prec = precision(p)), p)

##
## Power methods
##

Base.:^(p::Poly, e::Integer) = pow!(zero(p), p, convert(UInt, e))

function Base.:^(p::ArbSeries, q::ArbSeries)
    deg = _degree(p, q)
    return pow_series!(ArbSeries(degree = deg, prec = _precision((p, q))), p, q, deg + 1)
end
function Base.:^(p::AcbSeries, q::AcbSeries)
    deg = _degree(p, q)
    return pow_series!(AcbSeries(degree = deg, prec = _precision((p, q))), p, q, deg + 1)
end

# TODO: ArbSeries to a complex power
Base.:^(p::ArbSeries, e::Real) = pow_arb_series!(zero(p), p, convert(Arb, e), length(p))
function Base.:^(p::ArbSeries, e::Number)
    res = AcbSeries(p)
    return pow_acb_series!(res, res, convert(Acb, e), length(p))
end

Base.:^(p::AcbSeries, e::Number) = pow_acb_series!(zero(p), p, convert(Acb, e), length(p))

# Disambiguation
Base.:^(p::ArbSeries, e::Integer) = pow_arb_series!(zero(p), p, convert(Arb, e), length(p))
Base.:^(p::AcbSeries, e::Integer) = pow_acb_series!(zero(p), p, convert(Acb, e), length(p))
