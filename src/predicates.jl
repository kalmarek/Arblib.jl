for (T, funcpairs) in (
    (
        MagLike,
        (
            (:(Base.isfinite), :is_finite),
            (:(Base.isinf), :is_inf),
            (:isspecial, :is_special),
            (:(Base.iszero), :is_zero),
        ),
    ),
    (
        ArfLike,
        (
            (:(Base.isfinite), :is_finite),
            (:(Base.isinf), :is_inf),
            (:(Base.isinteger), :is_int),
            (:(Base.isnan), :is_nan),
            (:isneginf, :is_neg_inf),
            (:isnormal, :is_normal),
            (:(Base.isone), :is_one),
            (:isposinf, :is_pos_inf),
            (:isspecial, :is_special),
            (:(Base.iszero), :is_zero),
        ),
    ),
    (
        ArbLike,
        (
            (:isexact, :is_exact),
            (:(Base.isfinite), :is_finite),
            (:(Base.isinteger), :is_int),
            (:isnegative, :is_negative),
            (:isnonnegative, :is_nonnegative),
            (:isnonpositive, :is_nonpositive),
            (:isnonzero, :is_nonzero),
            (:(Base.isone), :is_one),
            (:ispositive, :is_positive),
            (:(Base.iszero), :is_zero),
        ),
    ),
    (
        AcbLike,
        (
            (:isexact, :is_exact),
            (:(Base.isfinite), :is_finite),
            (:(Base.isinteger), :is_int),
            (:(Base.isone), :is_one),
            (:(Base.isreal), :is_real),
            (:(Base.iszero), :is_zero),
            (:containszero, :contains_zero),
            (:containsint, :contains_int),
        ),
    ),
    (ArbVectorLike, ((:(Base.isfinite), :is_finite), (:(Base.iszero), :is_zero))),
    (
        AcbVectorLike,
        (
            (:(Base.isfinite), :is_finite),
            (:(Base.isreal), :is_real),
            (:(Base.iszero), :is_zero),
        ),
    ),
    (ArbPoly, ((:(Base.isone), :is_one), (:(isx), :is_x), (:(Base.iszero), :is_zero))),
    (ArbSeries, ((:(Base.isone), :is_one), (:(isx), :is_x), (:(Base.iszero), :is_zero))),
    (
        AcbPoly,
        (
            (:(Base.isone), :is_one),
            (:(isx), :is_x),
            (:(Base.iszero), :is_zero),
            (:(Base.isreal), :is_real),
        ),
    ),
    (
        AcbSeries,
        (
            (:(Base.isone), :is_one),
            (:(isx), :is_x),
            (:(Base.iszero), :is_zero),
            (:(Base.isreal), :is_real),
        ),
    ),
    (
        ArbMatrixLike,
        (
            (:isexact, :is_exact),
            (:(Base.isfinite), :is_finite),
            (:(Base.isone), :is_one),
            (:(Base.iszero), :is_zero),
        ),
    ),
    (
        AcbMatrixLike,
        (
            (:isexact, :is_exact),
            (:(Base.isfinite), :is_finite),
            (:(Base.isone), :is_one),
            (:(Base.isreal), :is_real),
            (:(Base.iszero), :is_zero),
        ),
    ),
)
    for (jlf, arbf) in funcpairs
        @eval $jlf(x::$T) = !iszero($arbf(x))
    end
end

Base.isnan(x::ArbOrRef) = isnan(midref(x))
Base.isnan(x::AcbOrRef) = isnan(midref(realref(x))) || isnan(midref(imagref(x)))

function Base.isnan(p::Union{ArbPoly,ArbSeries,AcbPoly,AcbSeries})
    # degree(cstruct(p)) instead of degree(p) avoids iterating over
    # coefficients known to be zero for series.
    @inbounds for i = 0:degree(cstruct(p))
        isnan(Arblib.ref(p, i)) && return true
    end
    return false
end
function Base.isfinite(p::Union{ArbPoly,ArbSeries,AcbPoly,AcbSeries})
    # degree(cstruct(p)) instead of degree(p) avoids iterating over
    # coefficients known to be zero for series.
    @inbounds for i = 0:degree(cstruct(p))
        isfinite(Arblib.ref(p, i)) || return false
    end
    return true
end

for ArbT in (ArfLike, ArbLike, AcbLike)
    @eval begin
        Base.isequal(y::$ArbT, x::$ArbT) = !iszero(equal(x, y))
        # Comparison of non-floating point values should use ==
        Base.:(==)(y::Integer, x::$ArbT) = !iszero(equal(x, y))
        Base.:(==)(x::$ArbT, y::Integer) = !iszero(equal(x, y))
    end
end
Base.:(==)(x::MagLike, y::MagLike) = !iszero(equal(x, y))
Base.isless(x::MagLike, y::MagLike) = cmp(x, y) < 0
Base.:(<)(x::MagLike, y::MagLike) = cmp(x, y) < 0
Base.:(<=)(x::MagLike, y::MagLike) = cmp(x, y) <= 0

for jltype in (ArfLike, Integer, Unsigned, Base.GMP.CdoubleMax)
    @eval begin
        Base.isless(x::ArfLike, y::$jltype) = (isnan(y) && !isnan(x)) || cmp(x, y) < 0
        Base.:(<)(x::ArfLike, y::$jltype) = !isnan(x) && !isnan(y) && cmp(x, y) < 0
        Base.:(<=)(x::ArfLike, y::$jltype) = (x < y) || isequal(x, y)
    end
end

for (ArbT, args) in (
    (ArfLike, ((:(==), :equal),)),
    (
        ArbLike,
        ((:(==), :eq), (:(!=), :ne), (:(<), :lt), (:(<=), :le), (:(>), :gt), (:(>=), :ge)),
    ),
    (AcbLike, ((:(==), :eq), (:(!=), :ne))),
    (ArbMatrixLike, ((:(==), :eq), (:(!=), :ne))),
    (AcbMatrixLike, ((:(==), :eq), (:(!=), :ne))),
)
    for (jlf, arbf) in args
        @eval begin
            Base.$jlf(x::$ArbT, y::$ArbT) = !iszero($arbf(x, y))
        end
    end
end

# Julia Base defines special methods for comparison between Rational
# and AbstractFloat which do not work well for Arb. We redefine these
# methods to just convert the rational number to Arb.
Base.:<(x::Arb, y::Rational) = x < convert(Arb, y)
Base.:<(x::Rational, y::Arb) = convert(Arb, x) < y
Base.:<=(x::Arb, y::Rational) = x <= convert(Arb, y)
Base.:<=(x::Rational, y::Arb) = convert(Arb, x) <= y
Base.cmp(x::Arb, y::Rational) = Base.cmp(x, convert(Arb, y))
Base.cmp(x::Rational, y::Arb) = Base.cmp(convert(Arb, x), y)

Base.isequal(x::T, y::T) where {T<:Union{ArbPoly,AcbPoly}} = !iszero(equal(x, y))
Base.isequal(x::T, y::T) where {T<:Union{ArbSeries,AcbSeries}} =
    degree(x) == degree(y) && !iszero(equal(x, y))

function Base.:(==)(x::T, y::T) where {T<:Union{ArbPoly,ArbSeries,AcbPoly,AcbSeries}}
    degree(x) == degree(y) || return false
    for i = 0:degree(x)
        x[i] == y[i] || return false
    end
    return true
end

function Base.:(!=)(x::T, y::T) where {T<:Union{ArbPoly,AcbPoly}}
    return iszero(overlaps(x, y))
end

function Base.:(!=)(x::T, y::T) where {T<:Union{ArbSeries,AcbSeries}}
    return (degree(x) != degree(y)) || iszero(overlaps(x, y))
end
