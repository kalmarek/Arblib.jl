for (T, funcpairs) in (
    (
        MagOrRef,
        (
            (:(Base.isfinite), :is_finite),
            (:(Base.isinf), :is_inf),
            (:isspecial, :is_special),
            (:(Base.iszero), :is_zero),
        ),
    ),
    (
        ArfOrRef,
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
        ArbOrRef,
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
        AcbOrRef,
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
    (ArbVectorOrRef, ((:(Base.isfinite), :is_finite), (:(Base.iszero), :is_zero))),
    (
        AcbVectorOrRef,
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
        ArbMatrixOrRef,
        (
            (:isexact, :is_exact),
            (:(Base.isfinite), :is_finite),
            (:(Base.isone), :is_one),
            (:(Base.iszero), :is_zero),
        ),
    ),
    (
        AcbMatrixOrRef,
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

for ArbT in (ArfOrRef, ArbOrRef, AcbOrRef)
    @eval begin
        Base.isequal(y::$ArbT, x::$ArbT) = !iszero(equal(x, y))
        # Comparison of non-floating point values should use ==
        Base.:(==)(y::Integer, x::$ArbT) = !iszero(equal(x, y))
        Base.:(==)(x::$ArbT, y::Integer) = !iszero(equal(x, y))
    end
end
Base.:(==)(x::MagOrRef, y::MagOrRef) = !iszero(equal(x, y))
Base.isless(x::MagOrRef, y::MagOrRef) = cmp(x, y) < 0
Base.:(<)(x::MagOrRef, y::MagOrRef) = cmp(x, y) < 0
Base.:(<=)(x::MagOrRef, y::MagOrRef) = cmp(x, y) <= 0

for jltype in (ArfOrRef, Integer, Unsigned, Base.GMP.CdoubleMax)
    @eval begin
        Base.isless(x::ArfOrRef, y::$jltype) = (isnan(y) && !isnan(x)) || cmp(x, y) < 0
        Base.:(<)(x::ArfOrRef, y::$jltype) = !isnan(x) && !isnan(y) && cmp(x, y) < 0
        Base.:(<=)(x::ArfOrRef, y::$jltype) = (x < y) || isequal(x, y)
    end
end

for (ArbT, args) in (
    (ArfOrRef, ((:(==), :equal),)),
    (
        ArbOrRef,
        ((:(==), :eq), (:(!=), :ne), (:(<), :lt), (:(<=), :le), (:(>), :gt), (:(>=), :ge)),
    ),
    (AcbOrRef, ((:(==), :eq), (:(!=), :ne))),
    (ArbMatrixOrRef, ((:(==), :eq), (:(!=), :ne))),
    (AcbMatrixOrRef, ((:(==), :eq), (:(!=), :ne))),
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
Base.:<(x::ArbOrRef, y::Rational) = x < convert(Arb, y)
Base.:<(x::Rational, y::ArbOrRef) = convert(Arb, x) < y
Base.:<=(x::ArbOrRef, y::Rational) = x <= convert(Arb, y)
Base.:<=(x::Rational, y::ArbOrRef) = convert(Arb, x) <= y
Base.cmp(x::ArbOrRef, y::Rational) = Base.cmp(x, convert(Arb, y))
Base.cmp(x::Rational, y::ArbOrRef) = Base.cmp(convert(Arb, x), y)

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

# For structs we only have to define == since isequals defaults to
# this for non-number types. Note that in this case we always compare
# them using Arblib.equal.
Base.:(==)(x::T, y::T) where {T<:ArbStructTypes} = equal(x, y)

function Base.:(==)(x::T, y::T) where {T<:Union{arb_vec_struct,acb_vec_struct}}
    x.n == y.n || return false
    for i = 1:x.n
        equal(x[i], y[i]) || return false
    end
    return true
end
