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
        Arb,
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
        Acb,
        (
            (:isexact, :is_exact),
            (:(Base.isfinite), :is_finite),
            (:(Base.isinteger), :is_int),
            (:(Base.isone), :is_one),
            (:(Base.isreal), :is_real),
            (:(Base.iszero), :is_zero),
        ),
    ),
    (
        ArbMatrix,
        (
            (:isexact, :is_exact),
            (:(Base.isfinite), :is_finite),
            (:(Base.isone), :is_one),
            (:(Base.isreal), :is_real),
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

for ArbT in (Mag, Arf, Arb, Acb)
    @eval begin
        Base.isequal(y::$ArbT, x::$ArbT) = !iszero(equal(x, y))
    end

    ArbT == Mag && continue

    @eval begin
        Base.isequal(y::Integer, x::$ArbT) = !iszero(equal(x, y))
        Base.isequal(x::$ArbT, y::Integer) = !iszero(equal(x, y))
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
        Arb,
        ((:(==), :eq), (:(!=), :ne), (:(<), :lt), (:(<=), :le), (:(>), :gt), (:(>=), :ge)),
    ),
    (Acb, ((:(==), :eq), (:(!=), :ne))),
    (ArbMatrix, ((:(==), :eq), (:(!=), :ne))),
    (AcbMatrix, ((:(==), :eq), (:(!=), :ne))),
)
    for (jlf, arbf) in args
        @eval begin
            Base.$jlf(x::$ArbT, y::$ArbT) = !iszero($arbf(x, y))
        end
    end
end
