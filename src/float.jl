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
