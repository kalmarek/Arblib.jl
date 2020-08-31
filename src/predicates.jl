for (T, funcpairs) in (
    (
        Mag,
        (
            (:(Base.isfinite), :is_finite),
            (:(Base.isinf), :is_inf),
            (:isspecial, :is_special),
            (:(Base.iszero), :is_zero),
        ),
    ),
    (
        Arf,
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
        Union{Arb,ArbRef},
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
        Union{Acb,AcbRef},
        (
            (:isexact, :is_exact),
            (:(Base.isfinite), :is_finite),
            (:(Base.isinteger), :is_int),
            (:(Base.isone), :is_one),
            (:(Base.isreal), :is_real),
            (:(Base.iszero), :is_zero),
        ),
    ),
    (ArbVector, ((:(Base.isfinite), :is_finite), (:(Base.iszero), :is_zero))),
    (
        AcbVector,
        (
            (:(Base.isfinite), :is_finite),
            (:(Base.isreal), :is_real),
            (:(Base.iszero), :is_zero),
        ),
    ),
    (ArbPoly, ((:(Base.isone), :is_one), (:(isx), :is_x), (:(Base.iszero), :is_zero))),
    (ArbSeries, ((:(Base.isone), :is_one), (:(isx), :is_x), (:(Base.iszero), :is_zero))),
    (
        ArbMatrix,
        (
            (:isexact, :is_exact),
            (:(Base.isfinite), :is_finite),
            (:(Base.isone), :is_one),
            (:(Base.iszero), :is_zero),
        ),
    ),
    (
        AcbMatrix,
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

#Base.isless(x::Mag, y::Mag) = cmp(x, y) < 0
#Base.:(==)(x::Mag, y::Mag) = !iszero(is_equal(x, y))
#
#Base.isless(x::Arf, y::Arf) = (isnan(y) && !isnan(x)) || cmp(x, y) < 0
#Base.:(==)(x::Arf, y::Arf) = !isnan(x) && !iszero(equal(x, y))
#Base.:(<)(x::Arf, y::Arf) = !isnan(x) && !isnan(y) && cmp(x, y) < 0
#Base.:(<=)(x::Arf, y::Arf) = !isnan(x) && !isnan(y) && cmp(x, y) <= 0
#Base.isequal(x::Arf, y::Arf) = !iszero(is_equal(x, y))

for ArbT in (Mag, Arf, Union{Arb,ArbRef}, Union{Acb,AcbRef}, ArbPoly, ArbSeries)
    @eval begin
        Base.isequal(y::$ArbT, x::$ArbT) = !iszero(equal(x, y))
    end

    (ArbT == Mag || ArbT == ArbPoly || ArbT == ArbSeries) && continue

    # Comparison of non-floating point values should use ==
    @eval begin
        Base.:(==)(y::Integer, x::$ArbT) = !iszero(equal(x, y))
        Base.:(==)(x::$ArbT, y::Integer) = !iszero(equal(x, y))
    end
end

Base.isless(x::Mag, y::Mag) = cmp(x, y) < 0
Base.:(<)(x::Mag, y::Mag) = cmp(x, y) < 0
Base.:(<=)(x::Mag, y::Mag) = cmp(x, y) <= 0

for jltype in (Arf, Integer, Unsigned, Base.GMP.CdoubleMax)
    @eval begin
        Base.isless(x::Arf, y::$jltype) = (isnan(y) && !isnan(x)) || cmp(x, y) < 0
        Base.:(<)(x::Arf, y::$jltype) = !isnan(x) && !isnan(y) && cmp(x, y) < 0
        Base.:(<=)(x::Arf, y::$jltype) = (x < y) || isequal(x, y)
    end
end

for (ArbT, args) in (
    (
        Union{Arb,ArbRef},
        ((:(==), :eq), (:(!=), :ne), (:(<), :lt), (:(<=), :le), (:(>), :gt), (:(>=), :ge)),
    ),
    (Union{Acb,AcbRef}, ((:(==), :eq), (:(!=), :ne))),
    (ArbMatrix, ((:(==), :eq), (:(!=), :ne))),
    (AcbMatrix, ((:(==), :eq), (:(!=), :ne))),
)
    for (jlf, arbf) in args
        @eval begin
            Base.$jlf(x::$ArbT, y::$ArbT) = !iszero($arbf(x, y))
        end
    end
end

function Base.:(==)(x::T, y::T) where {T<:Union{ArbPoly,ArbSeries}}
    degree(x) == degree(y) || return false
    for i = 0:degree(x)
        x[i] == y[i] || return false
    end
    return true
end

function Base.:(!=)(x::T, y::T) where {T<:Union{ArbPoly,ArbSeries}}
    return iszero(overlaps(x, y))
end
