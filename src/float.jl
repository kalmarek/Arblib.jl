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
