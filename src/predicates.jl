for (T, funcpairs) in (
    (Mag, (
        (:isfinite, :is_finite),
        (:isinf, :is_inf),
        (:isspecial, :is_special),
        (:iszero, :is_zero),)),
    (Arf, (
        (:isfinite, :is_finite),
        (:isinf, :is_inf),
        (:isinteger, :is_int),
        (:isnan, :is_nan),
        (:isneginf, :is_neg_inf),
        (:isnormal, :is_normal),
        (:isone, :is_one),
        (:isposinf, :is_pos_inf),
        (:isspecial, :is_special),
        (:iszero, :is_zero),
        )),
    (Arb, (
        (:isexact, :is_exact),
        (:isfinite, :is_finite),
        (:isinteger, :is_int),
        (:isnegative, :is_negative),
        (:isnonnegative, :is_nonnegative),
        (:isnonpositive, :is_nonpositive),
        (:isnonzero, :is_nonzero),
        (:isone, :is_one),
        (:ispositive, :is_positive),
        (:iszero, :is_zero),
    )),
    (Acb, (
        (:isexact, :is_exact),
        (:isfinite, :is_finite),
        (:isinteger, :is_int),
        (:isone, :is_one),
        (:isreal, :is_real),
        (:iszero, :is_zero),
    ))
    )
    for (jlf, arbf) in funcpairs
        @eval $jlf(x::$T) = !iszero($arbf(x))
    end
end

for ArbT in (Arf, Arb, Acb, Mag)
    @eval begin
        Base.isequal(y::$ArbT, x::$ArbT) = !iszero(is_equal(x,y))
    end

    ArbT == Mag && continue

    @eval begin
        Base.isequal(y::Int, x::$ArbT) = !iszero(is_equal(x,y))
    end
end

Base.:(==)(x::Arf, y::Arf) = isequal(x, y)
Base.:(==)(x::Arf, y::Int) = isequal(x, y)
Base.:(==)(y::Int, x::Arf) = isequal(x, y)

for jltype in (Arf, Integer, Unsigned, Base.GMP.CdoubleMax)
    @eval begin
        Base.isless(x::Arf, y::$jltype) = cmp(x, y) < 0
        Base.:(<)(x::Arf, y::$jltype) = isless(x, y)
        Base.:(<=)(x::Arf, y::$jltype) = isequal(x,y) | isless(x,y)
    end
end

for (ArbT, args) in (
    (Arb, (
        (:(==), :eq), (:(!=), :ne),
        (:(<),  :lt), (:(<=), :le),
        (:(>),  :gt), (:(>=), :ge),
        )),
    (Acb, (
        (:(==), :eq), (:(!=), :ne),
        )),
    )
    for (jlf, arbf) in args
        @eval begin
            Base.$jlf(x::$ArbT, y::$ArbT) = !iszero($arbf(x,y))
        end
    end
end
