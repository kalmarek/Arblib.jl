# IMPROVE: In principle we could try to implement the currently
# unsupported rounding modes. One would however have to be a bit
# careful to get them correct, so for now we just throw an error.

# TODO: This is implemented in
# https://github.com/flintlib/flint/pull/2294 and we can add it once
# that version is released.
_round!(res::ArfOrRef, x::ArfOrRef, r::typeof(RoundNearest)) =
    throw(ArgumentError("rounding mode $r not supported for Arf"))
_round!(res::ArfOrRef, x::ArfOrRef, r::typeof(RoundNearestTiesAway)) =
    throw(ArgumentError("rounding mode $r not supported for Arf"))
_round!(res::ArfOrRef, x::ArfOrRef, r::typeof(RoundNearestTiesUp)) =
    throw(ArgumentError("rounding mode $r not supported for Arf"))
_round!(res::ArfOrRef, x::ArfOrRef, r::typeof(RoundToZero)) =
    signbit(x) ? _round!(res, x, RoundUp) : _round!(res, x, RoundDown)
_round!(res::ArfOrRef, x::ArfOrRef, r::typeof(RoundFromZero)) =
    signbit(x) ? _round!(res, x, RoundDown) : _round!(res, x, RoundUp)
_round!(res::ArfOrRef, x::ArfOrRef, ::typeof(RoundUp)) = ceil!(res, x)
_round!(res::ArfOrRef, x::ArfOrRef, ::typeof(RoundDown)) = floor!(res, x)

# TODO: There is currently a bug in arb_nint, see
# https://github.com/flintlib/flint/issues/2293. The implementation
# here is a correct implementation of the version in Flint. Once the
# fixed version in Flint is released we should however switch to that.
function _round!(res::ArbOrRef, x::ArbOrRef, r::typeof(RoundNearest))
    _round!(res, x + 0.5, RoundDown)

    u = (2x - 1) / 4
    if isinteger(u)
        sub!(res, res, 1)
    elseif contains_int(u)
        sub!(res, res, unit_interval!(zero(res)))
    end

    return res
end

_round!(res::ArbOrRef, x::ArbOrRef, r::typeof(RoundNearestTiesAway)) =
    throw(ArgumentError("rounding mode $r not supported for Arb"))
_round!(res::ArbOrRef, x::ArbOrRef, r::typeof(RoundNearestTiesUp)) =
    throw(ArgumentError("rounding mode $r not supported for Arb"))
_round!(res::ArbOrRef, x::ArbOrRef, r::typeof(RoundToZero)) = trunc!(res, x)
_round!(res::ArbOrRef, x::ArbOrRef, r::typeof(RoundFromZero)) =
    throw(ArgumentError("rounding mode $r not supported for Arb"))
_round!(res::ArbOrRef, x::ArbOrRef, ::typeof(RoundUp)) = ceil!(res, x)
_round!(res::ArbOrRef, x::ArbOrRef, ::typeof(RoundDown)) = floor!(res, x)

Base.round(x::Union{ArfOrRef,ArbOrRef}, r::RoundingMode) = _round!(zero(x), x, r)
# Handle ambiguities
Base.round(x::Union{ArfOrRef,ArbOrRef}, r::typeof(RoundNearestTiesAway)) =
    _round!(zero(x), x, r)
Base.round(x::Union{ArfOrRef,ArbOrRef}, r::typeof(RoundNearestTiesUp)) =
    _round!(zero(x), x, r)
Base.round(x::Union{ArfOrRef,ArbOrRef}, r::typeof(RoundFromZero)) = _round!(zero(x), x, r)

function Base.round(
    z::Union{AcfOrRef,AcbOrRef},
    rr::RoundingMode = RoundNearest,
    ri::RoundingMode = RoundNearest,
)
    res = zero(z)
    _round!(realref(res), realref(z), rr)
    _round!(imagref(res), imagref(z), ri)
    return res
end

# There is no Arf version of this since getting the correct rounding
# for that would require some more work.
function Base.div(x::ArbOrRef, y::ArbOrRef, r::RoundingMode)
    res = x / y
    return _round!(res, res, r)
end
