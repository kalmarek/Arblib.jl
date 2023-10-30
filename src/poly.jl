const Poly = Union{ArbPoly,AcbPoly}
const Series = Union{ArbSeries,AcbSeries}

##
## Length and degree
##
Base.length(p::Union{arb_poly_struct,ArbPoly}) =
    ccall(@libflint(arb_poly_length), Int, (Ref{arb_poly_struct},), p)
Base.length(p::Union{acb_poly_struct,AcbPoly}) =
    ccall(@libflint(acb_poly_length), Int, (Ref{acb_poly_struct},), p)
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
    x::Union{ArbOrRef,_BitSigned},
    i::Integer,
)
    @boundscheck checkbounds(p, i)
    set_coeff!(p, i, x)
    return x
end

Base.@propagate_inbounds function Base.setindex!(
    p::Union{AcbPoly,AcbSeries},
    x::AcbOrRef,
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

"""
    ref(p::Union{ArbPoly,ArbSeries,AcbPoly,AcbSeries}, i)

Similar to `p[i]` but instead of an `Arb` or `Acb` returns an `ArbRef`
or `AcbRef` which still shares the memory with the `i`-th entry of
`p[i]`.

It only allows accessing coefficients that are allocated. For
`ArbPoly` and `AcbPoly` this is typically the degree of the
polynomial, but can be higher if for example `Arblib.fit_length!` is
used. For `ArbSeries` and `AcbSeries` all coefficients up to the
degree of the series are guaranteed to be allocated, even if the
underlying polynomial has a lower degree.

!!! Note: If you use this to change the coefficient in a way so that
    the degree of the polynomial might change you need to normalise
    the polynomial afterwards to make sure that Arb recognises the
    possibly new degree of the polynomial. If the new degree is the
    same or lower this can be done using `Arblib.normalise!(p)`. If
    the new degree is higher you need to manually set the length with
    `Arblib.set_length!(p, len)`, where `len` is one higher than the
    new degree.
"""
Base.@propagate_inbounds function ref(p::Union{ArbPoly,ArbSeries}, i::Integer)
    @boundscheck 0 <= i < cstruct(p).alloc || throw(BoundsError(p, i))
    ptr = cstruct(p).coeffs + i * sizeof(arb_struct)
    return ArbRef(ptr, precision(p), cstruct(p))
end

Base.@propagate_inbounds function ref(p::Union{AcbPoly,AcbSeries}, i::Integer)
    @boundscheck 0 <= i < cstruct(p).alloc || throw(BoundsError(p, i))
    ptr = cstruct(p).coeffs + i * sizeof(acb_struct)
    return AcbRef(ptr, precision(p), cstruct(p))
end

##
## Constructors
##

for (TPoly, TSeries) in [(:ArbPoly, :ArbSeries), (:AcbPoly, :AcbSeries)]
    @eval $TPoly(p::cstructtype($TPoly); prec::Integer = DEFAULT_PRECISION[]) =
        set!($TPoly(; prec), p)

    @eval function $TPoly(coeff; prec::Integer = _precision(coeff))
        p = $TPoly(; prec)
        @inbounds p[0] = coeff
        return p
    end

    @eval function $TPoly(
        coeffs::Union{Tuple,AbstractVector};
        prec::Integer = _precision(coeffs),
    )
        p = fit_length!($TPoly(; prec), length(coeffs))
        @inbounds for (i, c) in enumerate(coeffs)
            p[i-1] = c
        end
        return p
    end

    # Add a specialised constructors for the common case of a tuple
    # with two elements. This would for example be used when
    # constructing a polynomial with a constant plus x, e.g
    # ArbPoly((x, 1))
    @eval function $TPoly(coeffs::Tuple{Any,Any}; prec::Integer = _precision(coeffs))
        p = fit_length!($TPoly(; prec), length(coeffs))
        @inbounds p[0] = coeffs[1]
        @inbounds p[1] = coeffs[2]
        return p
    end

    @eval $TPoly(p::Union{$TPoly,$TSeries}; prec::Integer = precision(p)) =
        set!($TPoly(; prec), p)
end
function AcbPoly(p::Union{ArbPoly,ArbSeries}; prec = precision(p))
    res = fit_length!(AcbPoly(; prec), length(p))
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
    ) = set!($TSeries(; degree, prec), p)

    @eval function $TSeries(coeff; degree::Integer = 0, prec::Integer = _precision(coeff))
        p = $TSeries(; degree, prec)
        @inbounds p[0] = coeff
        return p
    end

    @eval function $TSeries(
        coeffs::Union{Tuple,AbstractVector};
        degree::Integer = max(length(coeffs) - 1, 0),
        prec::Integer = _precision(coeffs),
    )
        p = $TSeries(; degree, prec)
        @inbounds for (i, c) in enumerate(coeffs)
            p[i-1] = c
            i == degree + 1 && break
        end
        return p
    end

    # Add a specialised constructors for the common case of a tuple
    # with two elements. This would for example be used when
    # constructing a series with a constant plus x, e.g ArbSeries((x,
    # 1))
    @eval function $TSeries(
        coeffs::Tuple{Any,Any};
        degree::Integer = length(coeffs) - 1,
        prec::Integer = _precision(coeffs),
    )
        p = $TSeries(; degree, prec)
        @inbounds p[0] = coeffs[1]
        if degree >= 1
            @inbounds p[1] = coeffs[2]
        end
        return p
    end

    @eval $TSeries(
        p::Union{$TPoly,$TSeries};
        degree::Integer = degree(p),
        prec::Integer = precision(p),
    ) = set_trunc!($TSeries(; degree, prec), p, degree + 1)
end
function AcbSeries(p::Union{ArbPoly,ArbSeries}; degree = degree(p), prec = precision(p))
    res = AcbSeries(; degree, prec)
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
    product_roots!(ArbPoly(; prec), roots)
fromroots(::Type{ArbPoly}, roots::AbstractVector; prec::Integer = DEFAULT_PRECISION[]) =
    fromroots(ArbPoly, ArbVector(roots; prec); prec)

fromroots(
    ::Type{ArbPoly},
    real_roots::ArbVector,
    complex_roots::AcbVector;
    prec::Integer = DEFAULT_PRECISION[],
) = product_roots_complex!(
    ArbPoly(; prec),
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
) = fromroots(ArbPoly, ArbVector(real_roots; prec), AcbVector(complex_roots; prec); prec)

fromroots(::Type{AcbPoly}, roots::AcbVector; prec::Integer = DEFAULT_PRECISION[]) =
    product_roots!(AcbPoly(; prec), roots)
fromroots(::Type{AcbPoly}, roots::AbstractVector; prec::Integer = DEFAULT_PRECISION[]) =
    fromroots(AcbPoly, AcbVector(roots; prec); prec)

Base.copy(p::Union{Poly,Series}) = set!(zero(p), p)

##
## Arithmetic
##

Base.:-(p::Union{Poly,Series}) = neg!(zero(p), p)

Base.:+(p::T, q::T) where {T<:Poly} = add!(T(prec = _precision(p, q)), p, q)
Base.:-(p::T, q::T) where {T<:Poly} = sub!(T(prec = _precision(p, q)), p, q)
Base.:*(p::T, q::T) where {T<:Poly} = mul!(T(prec = _precision(p, q)), p, q)

function Base.:+(p::AcbPoly, q::ArbPoly)
    res = AcbPoly(q, prec = _precision(p, q))
    return add!(res, p, res)
end
Base.:+(p::ArbPoly, q::AcbPoly) = q + p

function Base.:-(p::AcbPoly, q::ArbPoly)
    res = AcbPoly(q, prec = _precision(p, q))
    return sub!(res, p, res)
end
function Base.:-(p::ArbPoly, q::AcbPoly)
    res = AcbPoly(p, prec = _precision(p, q))
    return sub!(res, res, q)
end

function Base.:*(p::AcbPoly, q::ArbPoly)
    res = AcbPoly(q, prec = _precision(p, q))
    return mul!(res, p, res)
end
Base.:*(p::ArbPoly, q::AcbPoly) = q * p

# We can't define these as `(p::T, q::T) where {T <: Series}` due to
# method ambiguity issues.
for T in [ArbSeries, AcbSeries]
    @eval function Base.:+(p::$T, q::$T)
        deg = _degree(p, q)
        return add_series!($T(degree = deg, prec = _precision(p, q)), p, q, deg + 1)
    end
    @eval function Base.:-(p::$T, q::$T)
        deg = _degree(p, q)
        return sub_series!($T(degree = deg, prec = _precision(p, q)), p, q, deg + 1)
    end
    @eval function Base.:*(p::$T, q::$T)
        deg = _degree(p, q)
        return mullow!($T(degree = deg, prec = _precision(p, q)), p, q, deg + 1)
    end
    @eval function Base.:/(p::$T, q::$T)
        deg = _degree(p, q)
        return div_series!($T(degree = deg, prec = _precision(p, q)), p, q, deg + 1)
    end
end

function Base.:+(p::AcbSeries, q::ArbSeries)
    deg = _degree(p, q)
    res = AcbSeries(q, degree = deg, prec = _precision(p, q))
    return add_series!(res, p, res, deg + 1)
end
Base.:+(p::ArbSeries, q::AcbSeries) = q + p

function Base.:-(p::AcbSeries, q::ArbSeries)
    deg = _degree(p, q)
    res = AcbSeries(q, degree = deg, prec = _precision(p, q))
    return sub_series!(res, p, res, deg + 1)
end
function Base.:-(p::ArbSeries, q::AcbSeries)
    deg = _degree(p, q)
    res = AcbSeries(p, degree = deg, prec = _precision(p, q))
    return sub_series!(res, res, q, deg + 1)
end

function Base.:*(p::AcbSeries, q::ArbSeries)
    deg = _degree(p, q)
    res = AcbSeries(q, degree = deg, prec = _precision(p, q))
    return mullow!(res, p, res, deg + 1)
end
Base.:*(p::ArbSeries, q::AcbSeries) = q * p

function Base.:/(p::AcbSeries, q::ArbSeries)
    deg = _degree(p, q)
    res = AcbSeries(q, degree = deg, prec = _precision(p, q))
    return div_series!(res, p, res, deg + 1)
end
function Base.:/(p::ArbSeries, q::AcbSeries)
    deg = _degree(p, q)
    res = AcbSeries(p, degree = deg, prec = _precision(p, q))
    return div_series!(res, res, q, deg + 1)
end

Base.inv(p::Series) = inv_series!(zero(p), p, degree(p) + 1)

# TODO: Implement separate ÷ and rem as well? They are only
# implemented for vectors in Arb so we would have to call those
# functions manually.
function Base.divrem(p::T, q::T) where {T<:Poly}
    quotient = T(prec = _precision(p, q))
    remainder = T(prec = _precision(p, q))
    divrem!(quotient, remainder, p, q)
    return quotient, remainder
end

##
## Scalar arithmetic
##

for (T, Tel, Tel_inplace) in [
    (Union{ArbPoly,ArbSeries}, Real, Union{ArbOrRef,ArfOrRef,Unsigned,Integer}),
    (Union{AcbPoly,AcbSeries}, Number, Union{AcbOrRef,ArbOrRef,Unsigned,Integer}),
]
    # Since we use inplace methods we need to manually normalise the
    # polynomials after the operation. This is to make sure that it
    # correctly recognizes the possibly new degree of the polynomial.
    # For example for iszero(ArbPoly(1) - 1) to work.

    @eval function Base.:+(p::$T, c::$Tel_inplace)
        res = copy(p)
        # Handle p being the zero polynomial
        iszero(p) && return set_coeff!(res, 0, c)
        res0 = ref(res, 0)
        add!(res0, res0, c)
        return normalise!(res)
    end
    @eval Base.:+(p::$T, c::$Tel) = p + convert(eltype(p), c)

    @eval function Base.:-(p::$T, c::$Tel_inplace)
        res = copy(p)
        # Handle p being the zero polynomial
        if iszero(p)
            set_coeff!(res, 0, c)
            res0 = ref(res, 0)
            neg!(res0, res0)
            return res
        end
        res0 = ref(res, 0)
        sub!(res0, res0, c)
        return normalise!(res)
    end
    @eval Base.:-(p::$T, c::$Tel) = p - convert(eltype(p), c)
    @eval function Base.:-(c::$Tel_inplace, p::$T)
        res = -p
        # Handle p being the zero polynomial
        iszero(p) && return set_coeff!(res, 0, c)
        res0 = ref(res, 0)
        add!(res0, res0, c)
        return normalise!(res)
    end
    @eval Base.:-(c::$Tel, p::$T) = convert(eltype(p), c) - p

    @eval Base.:*(p::$T, c::$Tel) = mul!(zero(p), p, convert(eltype(p), c))

    @eval Base.:/(p::$T, c::$Tel) = div!(zero(p), p, convert(eltype(p), c))
end

# Avoid conversion in these cases
@eval Base.:*(p::Union{ArbPoly,ArbSeries}, c::ArbOrRef) = mul!(zero(p), p, c)
@eval Base.:*(p::Union{AcbPoly,AcbSeries}, c::AcbOrRef) = mul!(zero(p), p, c)

@eval Base.:/(p::Union{ArbPoly,ArbSeries}, c::ArbOrRef) = div!(zero(p), p, c)
@eval Base.:/(p::Union{AcbPoly,AcbSeries}, c::AcbOrRef) = div!(zero(p), p, c)

# Promotion to complex
for (T, complexT) in [(ArbPoly, AcbPoly), (ArbSeries, AcbSeries)]
    @eval function Base.:+(p::$T, c::AcbOrRef)
        res = $complexT(p)
        res0 = ref(res, 0)
        add!(res0, res0, c)
        return res
    end

    @eval function Base.:-(p::$T, c::AcbOrRef)
        res = $complexT(p)
        res0 = ref(res, 0)
        sub!(res0, res0, c)
        return res
    end
    @eval function Base.:-(c::AcbOrRef, p::$T)
        res = $complexT(p)
        neg!(res, res)
        res0 = ref(res, 0)
        add!(res0, res0, c)
        return res
    end

    @eval function Base.:*(p::$T, c::AcbOrRef)
        res = $complexT(p)
        return mul!(res, res, c)
    end

    @eval function Base.:/(p::$T, c::AcbOrRef)
        res = $complexT(p)
        return div!(res, res, c)
    end
end
Base.:+(p::Union{ArbPoly,ArbSeries}, c::Complex) = p + convert(Acb, c)
Base.:-(p::Union{ArbPoly,ArbSeries}, c::Complex) = p - convert(Acb, c)
Base.:-(c::Complex, p::Union{ArbPoly,ArbSeries}) = convert(Acb, c) - p
Base.:*(p::Union{ArbPoly,ArbSeries}, c::Complex) = p * convert(Acb, c)
Base.:/(p::Union{ArbPoly,ArbSeries}, c::Complex) = p / convert(Acb, c)

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

compose(p::T, q::T) where {T<:Poly} = compose!(T(prec = _precision(p, q)), p, q)
function compose(p::T, q::T) where {T<:Series}
    iszero(ref(q, 0)) ||
        throw(ArgumentError("constant term of q must be zero, got q[0] = $(q[0])"))
    deg = _degree(p, q)
    res = T(degree = deg, prec = _precision(p, q))
    return compose_series!(res, p, q, deg + 1)
end

function revert(p::Series)
    degree(p) >= 1 || throw(ArgumentError("p must have degree at least 1"))
    iszero(ref(p, 0)) ||
        throw(ArgumentError("constant term of p must be zero, got p[0] = $(p[0])"))
    !iszero(ref(p, 1)) ||
        throw(ArgumentError("linear term of p must be non-zero, got p[0] = $(p[0])"))
    return revert_series!(zero(p), p, degree(p) + 1)
end

##
## Evaluation
##

(p::Union{ArbPoly,ArbSeries})(x::ArbOrRef) = evaluate!(Arb(prec = precision(p)), p, x)

function (p::Union{ArbPoly,ArbSeries})(x::Real)
    x = Arb(x, prec = precision(p))
    evaluate!(x, p, x)
end

(p::Union{Poly,Series})(x::AcbOrRef) = evaluate!(Acb(prec = precision(p)), p, x)

function (p::Union{Poly,Series})(x)
    x = Acb(x, prec = precision(p))
    evaluate!(x, p, x)
end

function evaluate2(p::Union{ArbPoly,ArbSeries}, x::ArbOrRef)
    res1, res2 = Arb(prec = precision(p)), Arb(prec = precision(p))
    evaluate2!(res1, res2, p, x)
    return (res1, res2)
end

function evaluate2(p::Union{ArbPoly,ArbSeries}, x::Real)
    # Use res1 for converting x
    res1, res2 = Arb(x, prec = precision(p)), Arb(prec = precision(p))
    evaluate2!(res1, res2, p, res1)
    return (res1, res2)
end

function evaluate2(p::Union{Poly,Series}, x::AcbOrRef)
    res1, res2 = Acb(prec = precision(p)), Acb(prec = precision(p))
    evaluate2!(res1, res2, p, x)
    return (res1, res2)
end

function evaluate2(p::Union{Poly,Series}, x)
    # Use res1 for converting x
    res1, res2 = Acb(x, prec = precision(p)), Acb(prec = precision(p))
    evaluate2!(res1, res2, p, res1)
    return (res1, res2)
end

##
## Differentiation and integration
##

derivative(p::Poly) = derivative!(zero(p), p)
derivative(p::T) where {T<:Series} =
    derivative!(T(degree = degree(p) - 1, prec = precision(p)), p)

derivative(p::Poly, n::Integer) = nth_derivative!(zero(p), p, convert(UInt, n))

function derivative(p::T, n::Integer) where {T<:Series}
    n <= Arblib.degree(p) ||
        throw(ArgumentError("n must be less than or equal to the degree of p"))

    return nth_derivative!(
        T(degree = degree(p) - n, prec = precision(p)),
        p,
        convert(UInt, n),
    )
end

integral(p::Poly) = integral!(zero(p), p)
integral(p::T) where {T<:Series} =
    integral!(T(degree = degree(p) + 1, prec = precision(p)), p)

function integral(p::T, n::Integer) where {T<:Union{Poly,Series}}
    n == 0 && return copy(p)
    n >= 0 || throw(ArgumentError("n must be non-negative"))

    if T <: Poly
        res = zero(p)
    elseif T <: Series
        res = T(degree = degree(p) + n, prec = precision(p))
    end
    integral!(res, p)
    for _ = 2:n
        integral!(res, res)
    end
    return res
end

##
## Power methods
##

Base.:^(p::Poly, e::Integer) = pow!(zero(p), p, convert(UInt, e))

function Base.:^(p::ArbSeries, q::ArbSeries)
    deg = _degree(p, q)
    return pow_series!(ArbSeries(degree = deg, prec = _precision(p, q)), p, q, deg + 1)
end
function Base.:^(p::AcbSeries, q::AcbSeries)
    deg = _degree(p, q)
    return pow_series!(AcbSeries(degree = deg, prec = _precision(p, q)), p, q, deg + 1)
end

Base.:^(p::ArbSeries, e::Real) = pow_arb_series!(zero(p), p, convert(Arb, e), length(p))
function Base.:^(p::ArbSeries, e::Number)
    res = AcbSeries(p)
    return pow_acb_series!(res, res, convert(Acb, e), length(p))
end
function Base.:^(x::Real, p::ArbSeries)
    res = ArbSeries(x, degree = degree(p), prec = precision(p))
    return pow_series!(res, res, p, length(p))
end
function Base.:^(x::Number, p::ArbSeries)
    res = AcbSeries(x, degree = degree(p), prec = precision(p))
    return pow_series!(res, res, AcbSeries(p), length(p))
end

Base.:^(p::AcbSeries, e::Number) = pow_acb_series!(zero(p), p, convert(Acb, e), length(p))
function Base.:^(x::Number, p::AcbSeries)
    res = AcbSeries(x, degree = degree(p), prec = precision(p))
    return pow_series!(res, res, p, length(p))
end

# Disambiguation
Base.:^(p::ArbSeries, e::Integer) = pow_arb_series!(zero(p), p, convert(Arb, e), length(p))
Base.:^(p::AcbSeries, e::Integer) = pow_acb_series!(zero(p), p, convert(Acb, e), length(p))
Base.:^(p::ArbSeries, e::Rational) = pow_arb_series!(zero(p), p, convert(Arb, e), length(p))
Base.:^(p::AcbSeries, e::Rational) = pow_acb_series!(zero(p), p, convert(Acb, e), length(p))

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
