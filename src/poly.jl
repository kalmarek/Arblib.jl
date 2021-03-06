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

for (TPoly, TSeries) in [(:ArbPoly, :ArbSeries), (:AcbPoly, :AcbSeries)]
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

    @eval $TPoly(p::Union{$TPoly,$TSeries}; prec::Integer = precision(p)) =
        set!($TPoly(prec = prec), p)
end
function AcbPoly(p::Union{ArbPoly,ArbSeries}; prec = precision(p))
    res = fit_length!(AcbPoly(prec = prec), length(p))
    @inbounds for i = 0:degree(p)
        res[i] = p[i]
    end
    return res
end

for (TSeries, TPoly) in [(:ArbSeries, :ArbPoly), (:AcbSeries, :AcbPoly)]
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

    @eval $TSeries(p::Union{$TPoly,$TSeries}; prec::Integer = precision(p)) =
        set!($TSeries(degree = degree(p), prec = prec), p)
end
function AcbSeries(p::Union{ArbPoly,ArbSeries}; degree = degree(p), prec = precision(p))
    res = AcbSeries(degree = degree, prec = prec)
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

# TODO: Avoid conversion of Ref-types.
# TODO: Avoid the extra allocation required for addition and
# subtraction to extract the first coefficient.
for (T, Tel) in [(Union{ArbPoly,ArbSeries}, Real), (Union{AcbPoly,AcbSeries}, Number)]
    @eval function Base.:+(p::$T, c::$Tel)
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

    @eval Base.:/(p::$T, c::$Tel) = div!(zero(p), p, convert(eltype(p), c))
end

# Promotion to complex
for (T, complexT) in [(ArbPoly, AcbPoly), (ArbSeries, AcbSeries)]
    @eval function Base.:+(p::$T, c::Union{AcbOrRef,Complex})
        res = $complexT(p)
        res[0] += c
        return res
    end

    @eval function Base.:-(p::$T, c::Union{AcbOrRef,Complex})
        res = $complexT(p)
        res[0] -= c
        return res
    end
    @eval function Base.:-(c::Union{AcbOrRef,Complex}, p::$T)
        res = $complexT(p)
        neg!(res, res)
        res[0] += c
        return res
    end

    @eval function Base.:*(p::$T, c::Union{AcbOrRef,Complex})
        res = $complexT(p)
        return mul!(res, res, convert(Acb, c))
    end

    @eval function Base.:/(p::$T, c::Union{AcbOrRef,Complex})
        res = $complexT(p)
        return div!(res, res, convert(Acb, c))
    end
end

Base.:+(c::Number, p::Union{Poly,Series}) = p + c
Base.:*(c::Number, p::Union{Poly,Series}) = p * c

function Base.:/(c::Real, p::ArbSeries)
    res = inv(p)
    return mul!(res, res, convert(Arb, c))
end
function Base.:/(c::Union{AcbOrRef,Complex}, p::ArbSeries)
    res = AcbSeries(inv(p))
    return mul!(res, res, convert(Acb, c))
end
function Base.:/(c::Number, p::AcbSeries)
    res = inv(p)
    return mul!(res, res, convert(Acb, c))
end

##
## Composition
##

taylor_shift(p::Union{Poly,Series}, c) = taylor_shift!(zero(p), p, convert(eltype(p), c))

compose(p::T, q::T) where {T<:Poly} = compose!(T(prec = _precision((p, q))), p, q)
function compose(p::T, q::T) where {T<:Series}
    iszero(q[0]) ||
        throw(ArgumentError("constant term of q must be zero, got q[0] = $(q[0])"))
    deg = _degree(p, q)
    res = T(degree = deg, prec = _precision((p, q)))
    return compose_series!(res, p, q, deg + 1)
end

function revert(p::Series)
    degree(p) >= 1 || throw(ArgumentError("p must have degree at least 1"))
    iszero(p[0]) ||
        throw(ArgumentError("constant term of p must be zero, got p[0] = $(p[0])"))
    !iszero(p[1]) ||
        throw(ArgumentError("linear term of p must be non-zero, got p[0] = $(p[0])"))
    return revert_series!(zero(p), p, degree(p) + 1)
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

Base.:^(p::ArbSeries, e::Real) = pow_arb_series!(zero(p), p, convert(Arb, e), length(p))
function Base.:^(p::ArbSeries, e::Number)
    res = AcbSeries(p)
    return pow_acb_series!(res, res, convert(Acb, e), length(p))
end

Base.:^(p::AcbSeries, e::Number) = pow_acb_series!(zero(p), p, convert(Acb, e), length(p))

# Disambiguation
Base.:^(p::ArbSeries, e::Integer) = pow_arb_series!(zero(p), p, convert(Arb, e), length(p))
Base.:^(p::AcbSeries, e::Integer) = pow_acb_series!(zero(p), p, convert(Acb, e), length(p))

##
## Series methods
##

for f in [:sqrt, :log, :log1p, :exp, :sin, :cos, :tan, :atan, :sinh, :cosh]
    @eval Base.$f(p::Series) = $(Symbol(f, :_series!))(zero(p), p, length(p))
end

Base.asin(p::ArbSeries) = asin_series!(zero(p), p, length(p))
Base.acos(p::ArbSeries) = acos_series!(zero(p), p, length(p))

rsqrt(p::Series) = rsqrt_series!(zero(p), p, length(p))

Base.sinpi(p::Series) = sin_pi_series!(zero(p), p, length(p))
Base.cospi(p::Series) = cos_pi_series!(zero(p), p, length(p))
cotpi(p::Series) = cot_pi_series!(zero(p), p, length(p))
# Julias definition of sinc is equivalent to Arbs definition of sincpi
Base.sinc(p::ArbSeries) = sinc_pi_series!(zero(p), p, length(p))

function Base.sincos(p::Series)
    s, c = zero(p), zero(p)
    sin_cos_series!(s, c, p, length(p))
    return (s, c)
end
function sincospi(p::Series)
    s, c = zero(p), zero(p)
    sin_cos_pi_series!(s, c, p, length(p))
    return (s, c)
end
function sinhcosh(p::Series)
    s, c = zero(p), zero(p)
    sinh_cosh_series!(s, c, p, length(p))
    return (s, c)
end
