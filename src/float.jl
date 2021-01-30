function eps!(res::ArfOrRef, x::ArfOrRef)
    # FIXME: Should we return NaN here?
    isspecial(x) && throw(ArgumentError("eps not defined for special values, got $x"))
    return set!(res, set_ulp!(Mag(), x, prec = precision(x)))
end

function eps!(res::ArbOrRef, x::ArbOrRef)
    # FIXME: Should we return NaN here?
    mid_x = midref(x)
    isspecial(mid_x) && throw(ArgumentError("eps not defined for special values, got $x"))
    rad_res = radref(res)
    set_ulp!(rad_res, mid_x, prec = precision(x))
    return set!(res, rad_res)
end

function Base.eps(T::Type{<:Union{ArfOrRef,ArbOrRef}})
    res = one(T)
    return eps!(res, res)
end
Base.eps(x::Union{ArfOrRef,ArbOrRef}) = eps!(zero(x), x)
