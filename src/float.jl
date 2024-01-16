# Conversion to float types in Base

## Float64
Base.Float64(x::MagOrRef, r::RoundingMode = RoundUp) = Float64(x, convert(arb_rnd, r))
Base.Float64(x::ArfOrRef, r::RoundingMode) = Float64(x, convert(arb_rnd, r))
Base.Float64(x::ArbOrRef, r::RoundingMode = RoundNearest) = Float64(x, convert(arb_rnd, r))

function Base.Float64(x::MagOrRef, r::arb_rnd)
    r == ArbRoundUp ||
        throw(ArgumentError("only supports rounding up when converting Mag to Float64"))
    return get(x)
end
Base.Float64(x::ArfOrRef, r::arb_rnd) = get_d(x, r)
Base.Float64(x::ArbOrRef, r::arb_rnd) = Float64(midref(x), r)

# Deprecated
# TODO: This signature clashes with the above one...
Base.Float64(x::ArfOrRef; rnd::arb_rnd = ArbRoundNearest) = Float64(x, rnd)

## Float16 and Float32
Base.Float16(x::MagOrRef, r::RoundingMode = RoundUp) = Float16(Float64(x, r), r)
Base.Float32(x::MagOrRef, r::RoundingMode = RoundUp) = Float32(Float64(x, r), r)
Base.Float16(x::Union{ArfOrRef,ArbOrRef}, r::RoundingMode = RoundNearest) =
    Float16(Float64(x, r), r)
Base.Float32(x::Union{ArfOrRef,ArbOrRef}, r::RoundingMode = RoundNearest) =
    Float32(Float64(x, r), r)

## BigFloat

# Note that this uses different default values than the constructors
# in Base. I always defaults to RoundNearest and uses the precision
# given by the input argument. This means that it doesn't depend on
# the global rounding mode and precision.

Base.BigFloat(x::Union{ArfOrRef,ArbOrRef}, r::RoundingMode; precision = Base.precision(x)) =
    BigFloat(x, convert(Base.MPFR.MPFRRoundingMode, r); precision)

Base.BigFloat(x::Union{ArfOrRef,ArbOrRef}, r::arb_rnd; precision = Base.precision(x)) =
    BigFloat(x, convert(RoundingMode, r); precision)

function Base.BigFloat(
    x::ArfOrRef,
    r::Base.MPFR.MPFRRoundingMode = Base.MPFR.RoundNearest;
    precision = Base.precision(x),
)
    y = BigFloat(; precision)
    get!(y, x, r)
    return y
end
Base.BigFloat(
    x::ArbOrRef,
    r::Base.MPFR.MPFRRoundingMode = Base.MPFR.RoundNearest;
    precision = Base.precision(x),
) = BigFloat(midref(x), r; precision)

# Common methods in the AbstractFloat interface
function eps!(res::ArfOrRef, x::ArfOrRef)
    isspecial(x) && return nan!(res)
    return set!(res, set_ulp!(Mag(), x, prec = precision(x)))
end

function eps!(res::ArbOrRef, x::ArbOrRef)
    mid_x = midref(x)
    isspecial(mid_x) && return indeterminate!(res)
    rad_res = radref(res)
    set_ulp!(rad_res, mid_x, prec = precision(x))
    return set!(res, rad_res)
end

function Base.eps(T::Type{<:Union{ArfOrRef,ArbOrRef}})
    res = one(T)
    return eps!(res, res)
end
Base.eps(x::Union{ArfOrRef,ArbOrRef}) = eps!(zero(x), x)

Base.typemin(::Type{<:MagOrRef}) = zero!(Mag())
Base.typemin(x::Union{ArfOrRef,ArbOrRef}) = neg_inf!(zero(x))
Base.typemin(T::Type{<:Union{ArfOrRef,ArbOrRef}}) = neg_inf!(zero(T))

Base.typemax(::Type{<:MagOrRef}) = inf!(Mag())
Base.typemax(x::Union{ArfOrRef,ArbOrRef}) = pos_inf!(zero(x))
Base.typemax(T::Type{<:Union{ArfOrRef,ArbOrRef}}) = pos_inf!(zero(T))

function Base.frexp(x::ArfOrRef)
    m = zero(x)
    e = fmpz_struct()
    ccall(
        @libflint(arf_frexp),
        Nothing,
        (Ref{arf_struct}, Ref{fmpz_struct}, Ref{arf_struct}),
        m,
        e,
        x,
    )

    return m, BigInt(e)
end

function Base.frexp(x::ArbOrRef)
    # Compute for midpoint and just scale radius
    _, e = frexp(midref(x))
    return ldexp(x, -e), e
end

Base.ldexp(x::Union{ArfOrRef,ArbOrRef}, n::Integer) = mul_2exp!(zero(x), x, n)
