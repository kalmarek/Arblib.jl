function Base.round(x::ArfOrRef, r::RoundingMode)
    res = zero(x)
    if r == RoundDown
        floor!(res, x)
    elseif r == RoundUp
        ceil!(res, x)
    else
        throw(ArgumentError("rounding mode $r not supported in round for Arb"))
    end
    return res
end

function Base.round(
    z::AcfOrRef,
    rr::RoundingMode = RoundNearest,
    ri::RoundingMode = RoundNearest,
)
    res = zero(z)
    if rr == RoundDown
        floor!(realref(res), realref(z))
    elseif rr == RoundUp
        ceil!(realref(res), realref(z))
    else
        throw(ArgumentError("rounding mode $rr not supported in round for Acf"))
    end
    if ri == RoundDown
        floor!(imagref(res), imagref(z))
    elseif ri == RoundUp
        ceil!(imagref(res), imagref(z))
    else
        throw(ArgumentError("rounding mode $ri not supported in round for Acf"))
    end
    return res
end

function Base.round(x::ArbOrRef, r::RoundingMode)
    res = zero(x)
    if r == RoundDown
        floor!(res, x)
    elseif r == RoundUp
        ceil!(res, x)
    elseif r == RoundToZero
        trunc!(res, x)
    elseif r == RoundNearest
        nint!(res, x)
    else
        throw(ArgumentError("rounding mode $r not supported in round for Arb"))
    end
    return res
end

function Base.round(
    z::AcbOrRef,
    rr::RoundingMode = RoundNearest,
    ri::RoundingMode = RoundNearest,
)
    res = zero(z)
    if rr == RoundDown
        floor!(realref(res), realref(z))
    elseif rr == RoundUp
        ceil!(realref(res), realref(z))
    elseif rr == RoundToZero
        trunct!(realref(res), realref(z))
    elseif rr == RoundNearest
        nint!(realref(res), realref(z))
    else
        throw(ArgumentError("rounding mode $rr not supported in round for Acb"))
    end
    if ri == RoundDown
        floor!(imagref(res), imagref(z))
    elseif ri == RoundUp
        ceil!(imagref(res), imagref(z))
    elseif ri == RoundToZero
        trunct!(imagref(res), imagref(z))
    elseif ri == RoundNearest
        nint!(imagref(res), imagref(z))
    else
        throw(ArgumentError("rounding mode $ri not supported in round for Acb"))
    end
    return res
end

function Base.div(x::ArbOrRef, y::ArbOrRef, r::RoundingMode)
    res = x / y
    if r == RoundDown
        floor!(res, res)
    elseif r == RoundUp
        ceil!(res, res)
    elseif r == RoundToZero
        trunc!(res, res)
    elseif r == RoundNearest
        nint!(res, res)
    else
        throw(ArgumentError("rounding mode $r not supported in div for Arb"))
    end
    return res
end
