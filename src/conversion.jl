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
Base.Float64(x::ArfOrRef; rnd::arb_rnd = ArbRoundNearest) = Float64(x, rnd)

## Float16 and Float32
Base.Float16(x::MagOrRef, r::RoundingMode = RoundUp) = Float16(Float64(x, r), r)
Base.Float16(x::MagOrRef, r::arb_rnd) = Float16(x, convert(RoundingMode, r))
Base.Float32(x::MagOrRef, r::RoundingMode = RoundUp) = Float32(Float64(x, r), r)
Base.Float32(x::MagOrRef, r::arb_rnd) = Float32(x, convert(RoundingMode, r))
Base.Float16(x::Union{ArfOrRef,ArbOrRef}, r::RoundingMode = RoundNearest) =
    Float16(Float64(x, r), r)
Base.Float16(x::Union{ArfOrRef,ArbOrRef}, r::arb_rnd) = Float16(x, convert(RoundingMode, r))
Base.Float32(x::Union{ArfOrRef,ArbOrRef}, r::RoundingMode = RoundNearest) =
    Float32(Float64(x, r), r)
Base.Float32(x::Union{ArfOrRef,ArbOrRef}, r::arb_rnd) = Float32(x, convert(RoundingMode, r))

## BigFloat

# Note that this uses different default values than the constructors
# in Base. It always defaults to RoundNearest and uses the precision
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

# IMPROVE: We currently don't support any rounding to integers. This
# would maybe be nice to do.
# IMPROVE: Is there any point in supporting conversion to other
# integers?

function Base.Int(x::ArfOrRef)
    is_int(x) || throw(InexactError(:Int, Int, x))
    typemin(Int) <= x <= typemax(Int) || throw(InexactError(:Int, Int, x))
    return get_si(x, ArbRoundNearest)
end

Base.Int(x::AcfOrRef) = isreal(x) ? Int(realref(x)) : throw(InexactError(:Int, Int, x))

Base.Int(x::ArbOrRef) = is_int(x) ? Int(midref(x)) : throw(InexactError(:Int, Int, x))

Base.Int(x::AcbOrRef) =
    is_int(x) ? Int(midref(realref(x))) : throw(InexactError(:Int, Int, x))

function Base.BigInt(x::ArfOrRef)
    is_int(x) || throw(InexactError(:BigInt, BigInt, x))
    n = fmpz_struct()
    ccall(
        @libflint(arf_get_fmpz),
        Cint,
        (Ref{fmpz_struct}, Ref{arf_struct}, Ref{arb_rnd}),
        n,
        x,
        ArbRoundNearest,
    )
    return BigInt(n)
end

Base.BigInt(x::AcfOrRef) =
    isreal(x) ? BigInt(realref(x)) : throw(InexactError(:BigInt, BigInt, x))

Base.BigInt(x::ArbOrRef) =
    is_int(x) ? BigInt(midref(x)) : throw(InexactError(:BigInt, BigInt, x))

Base.BigInt(x::AcbOrRef) =
    is_int(x) ? BigInt(midref(realref(x))) : throw(InexactError(:BigInt, BigInt, x))

## Conversion to Complex
# TODO: This currently allows construction of Complex{ArfRef} and
# Complex{ArbRef}, which we probably don't want.
Base.Complex{T}(z::AcfOrRef) where {T} = Complex{T}(realref(z), imagref(z))
Base.Complex{T}(z::AcbOrRef) where {T} = Complex{T}(realref(z), imagref(z))
Base.Complex(z::Acf) = Complex{Arf}(z)
Base.Complex(z::AcbOrRef) = Complex{Arb}(z)
