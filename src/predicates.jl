for (T, funcpairs) in (
    (Mag, (
        (:isfinite, :_is_finite),
        (:isinf, :_is_inf),
        (:isspecial, :_is_special),
        (:iszero, :_is_zero),)),
    (Arf, (
        (:isfinite, :_is_finite),
        (:isinf, :_is_inf),
        (:isinteger, :_is_int),
        (:isnan, :_is_nan),
        (:isneginf, :_is_neg_inf),
        (:isnormal, :_is_normal),
        (:isone, :_is_one),
        (:isposinf, :_is_pos_inf),
        (:isspecial, :_is_special),
        (:iszero, :_is_zero),
        )),
    (Arb, (
        (:isexact, :_is_exact),
        (:isfinite, :_is_finite),
        (:isinteger, :_is_int),
        (:isnegative, :_is_negative),
        (:isnonnegative, :_is_nonnegative),
        (:isnonpositive, :_is_nonpositive),
        (:isnonzero, :_is_nonzero),
        (:isone, :_is_one),
        (:ispositive, :_is_positive),
        (:iszero, :_is_zero),
    )),
    (Acb, (
        (:isexact, :_is_exact),
        (:isfinite, :_is_finite),
        (:isinteger, :_is_int),
        (:isone, :_is_one),
        (:isreal, :_is_real),
        (:iszero, :_is_zero),
    ))
    )
    for (jlf, arbsuffix) in funcpairs
        arbf = Symbol(cprefix(T), arbsuffix)
        @eval begin
            function $jlf(x::$T)
                return !iszero(ccall(@libarb($arbf), Cint, (Ref{$T},), x))
            end
        end
    end
end
