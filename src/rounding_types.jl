#=
    Specifies the rounding mode for the result of an approximate operation.
ARF_RND_NEAR   (4)
    Round to the nearest representable number, rounding to even if there is a tie.
ARF_RND_FLOOR  (2)
    Round to the nearest representable number in the direction towards minus infinity.
ARF_RND_CEIL   (3)
    Round to the nearest representable number in the direction towards plus infinity.
ARF_RND_DOWN   (0)
    Round to the nearest representable number in the direction towards zero.
ARF_RND_UP     (1)
    Round to the nearest representable number in the direction away from zero.
=#

@enum(
    arb_rnd::Cint,
    ArbRoundToZero, # ARF_RND_DOWN
    ArbRoundFromZero, # ARF_RND_UP
    ArbRoundDown, # ARF_RND_FLOOR
    ArbRoundUp, # ARF_RND_CEIL
    ArbRoundNearest, # ARF_RND_NEAR
)

Base.convert(::Type{arb_rnd}, ::RoundingMode{:ToZero}) = ArbRoundToZero
Base.convert(::Type{arb_rnd}, ::RoundingMode{:FromZero}) = ArbRoundFromZero
Base.convert(::Type{arb_rnd}, ::RoundingMode{:Down}) = ArbRoundDown
Base.convert(::Type{arb_rnd}, ::RoundingMode{:Up}) = ArbRoundUp
Base.convert(::Type{arb_rnd}, ::RoundingMode{:Nearest}) = ArbRoundNearest

function Base.convert(::Type{RoundingMode}, r::arb_rnd)
    if r == ArbRoundToZero
        return RoundToZero
    elseif r == ArbRoundFromZero
        return RoundFromZero
    elseif r == ArbRoundDown
        return RoundDown
    elseif r == ArbRoundUp
        return RoundUp
    elseif r == ArbRoundNearest
        return RoundNearest
    else
        throw(ArgumentError("invalid Arb rounding mode code: $r"))
    end
end
