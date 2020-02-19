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

for ArbT in (Arf, Arb, Acb, Mag)
    arbf = Symbol(cprefix(ArbT), :_equal)
    @eval begin
        function Base.isequal(x::$ArbT, y::$ArbT)
            res = ccall(@libarb($arbf), Cint, (Ref{$ArbT}, Ref{$ArbT}), x, y)
            return !iszero(res)
        end
    end

    ArbT == Mag && continue

    arbf = Symbol(cprefix(ArbT), :_equal_si)
    @eval begin
        function Base.isequal(x::$ArbT, y::Int)
            res = ccall(@libarb($arbf), Cint, (Ref{$ArbT}, Clong), x, y)
            return !iszero(res)
        end
        Base.isequal(y::Int, x::$ArbT) = isequal(x,y)
    end
end

Base.:(==)(x::Arf, y::Arf) = isequal(x, y)
Base.:(==)(x::Arf, y::Int) = isequal(x, y)
Base.:(==)(y::Int, x::Arf) = isequal(x, y)

for (suffix, jltype, ctype) in (
        ("",   Arf, Ref{Arf}),
        (:_si, Int, Clong),
        (:_ui, UInt, Culong),
        (:_d,  Float64, Cdouble)
        )
    arbf = Symbol(:arf_cmp, suffix)
    @eval begin
        function Base.isless(x::Arf, y::$jltype)
            res = ccall(@libarb($arbf), Cint, (Ref{Arf}, $ctype), x, y)
            return res < 0
        end
        Base.:(<)(x::Arf, y::$jltype) = isless(x, y)
        Base.:(<=)(x::Arf, y::$jltype) = isequal(x,y) | isless(x,y)
    end
end

for (ArbT, args) in (
    (Arb, (
        (:(==), :_eq), (:(!=), :_ne),
        (:(<),  :_lt), (:(<=), :_le),
        (:(>),  :_gt), (:(>=), :_ge),
        )),
    (Acb, (
        (:(==), :_eq), (:(!=), :_ne),
        )),
    )
    for (jlf, suffix) in args
        arbf = Symbol(cprefix(ArbT), suffix)
        @eval begin
            function Base.$jlf(x::$ArbT, y::$ArbT)
                res = ccall(@libarb($arbf), Cint, (Ref{$ArbT}, Ref{$ArbT}), x, y)
                return !iszero(res)
            end
        end
    end
end
