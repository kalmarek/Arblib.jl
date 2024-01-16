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

## Conversion to integers
Base.Int(x::ArfOrRef; rnd::Union{arb_rnd,RoundingMode} = RoundNearest) =
    is_int(x) ? get_si(x, rnd) : throw(InexactError(:Int64, Int64, x))

## Conversion to Complex

# TODO: This currently allows construction of Complex{ArbRef}, which
# we probably don't want.
Base.Complex{T}(z::AcbOrRef) where {T} = Complex{T}(realref(z), imagref(z))
Base.Complex(z::AcbOrRef) = Complex{Arb}(z)
