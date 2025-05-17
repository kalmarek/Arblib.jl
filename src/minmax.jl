Base.min(x::MagOrRef, y::MagOrRef) = Arblib.min!(zero(x), x, y)
Base.max(x::MagOrRef, y::MagOrRef) = Arblib.max!(zero(x), x, y)
Base.minmax(x::MagOrRef, y::MagOrRef) = (min(x, y), max(x, y))

for T in (ArfOrRef, ArbOrRef)
    @eval Base.min(x::$T, y::$T) =
        Arblib.min!($(_nonreftype(T))(prec = _precision(x, y)), x, y)
    @eval Base.max(x::$T, y::$T) =
        Arblib.max!($(_nonreftype(T))(prec = _precision(x, y)), x, y)
end

Base.minmax(x::ArfOrRef, y::ArfOrRef) = (min(x, y), max(x, y))
function Base.minmax(x::ArbOrRef, y::ArbOrRef)
    z1 = Arb(prec = _precision(x, y))
    z2 = Arb(prec = _precision(x, y))
    minmax!(z1, z2, x, y)
    return z1, z2
end


if VERSION < v"1.13.0-DEV.536"
    ### minimum and maximum
    # The default implemented in Julia have several issues for the Arb type.
    # See https://github.com/JuliaLang/julia/issues/45932.
    # Note that it works fine for Mag and Arf.

    # Is is possible to fix the Base implementation by overloading some
    # internal methods.

    # The default implementation in Base is not correct for Arb
    Base._fast(::typeof(min), x::ArbOrRef, y::ArbOrRef) = min(x, y)
    Base._fast(::typeof(min), x::ArbOrRef, y) = min(x, y)
    Base._fast(::typeof(min), x, y::ArbOrRef) = min(x, y)
    Base._fast(::typeof(max), x::ArbOrRef, y::ArbOrRef) = max(x, y)
    Base._fast(::typeof(max), x::ArbOrRef, y) = max(x, y)
    Base._fast(::typeof(max), x, y::ArbOrRef) = max(x, y)
    # Handle ambiguous methods
    Base._fast(::typeof(min), x::ArbOrRef, y::AbstractFloat) = min(x, y)
    Base._fast(::typeof(min), x::AbstractFloat, y::ArbOrRef) = min(x, y)
    Base._fast(::typeof(max), x::ArbOrRef, y::AbstractFloat) = max(x, y)
    Base._fast(::typeof(max), x::AbstractFloat, y::ArbOrRef) = max(x, y)

    # Arf and Arb don't have signed zeros
    Base.isbadzero(::typeof(min), x::Union{ArfOrRef,ArbOrRef}) = false
    Base.isbadzero(::typeof(max), x::Union{ArfOrRef,ArbOrRef}) = false
else
    # The special handling for minimum and maximum was removed in
    # https://github.com/JuliaLang/julia/pull/58267 and it is hence no
    # longer necessary to work around it.
end
