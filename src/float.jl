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

# Note that significand and exponent are equivalent to frexp except
# for a factor 2 and the fact that exponent throws an error for zero
# or non-finite values.
# Technically the documentation for exponent says that it "Returns the
# largest integer y such that 2^y ≤ abs(x).", which is not quite true
# for Arb input if the radius is non-zero.

function Base.significand(x::Union{ArfOrRef,ArbOrRef})
    if iszero(x) || !isfinite(x)
        return copy(x)
    else
        res = frexp(x)[1]
        return mul_2exp!(res, res, 1)
    end
end

function Base.exponent(x::Union{ArfOrRef,ArbOrRef})
    if iszero(x) || !isfinite(x)
        throw(DomainError(x, "`x` must be non-zero and finite."))
    else
        return frexp(x)[2] - 1
    end
end
