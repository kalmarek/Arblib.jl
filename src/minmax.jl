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

### minimum and maximum
# The default implemented in Julia have several issues for the Arb type.
# See https://github.com/JuliaLang/julia/issues/45932.
# Note that it works fine for Mag and Arf.

# Before 1.8.0 there is no way to fix the implementation in Base.
# Instead we define a new method. Note that this doesn't fully fix the
# problem, there is no way to dispatch on for example
# minimum(x -> Arb(x), [1, 2, 3, 4]) or an array with only some Arb.
if VERSION < v"1.8.0-rc3"
    function Base.minimum(A::AbstractArray{<:ArbOrRef})
        isempty(A) &&
            throw(ArgumentError("reducing over an empty collection is not allowed"))
        res = copy(first(A))
        for x in Iterators.drop(A, 1)
            Arblib.min!(res, res, x)
        end
        return res
    end

    function Base.maximum(A::AbstractArray{<:ArbOrRef})
        isempty(A) &&
            throw(ArgumentError("reducing over an empty collection is not allowed"))
        res = copy(first(A))
        for x in Iterators.drop(A, 1)
            Arblib.max!(res, res, x)
        end
        return res
    end
end

# Since 1.8.0 it is possible to fix the Base implementation by
# overloading some internal methods. This also works before 1.8.0 but
# doesn't solve the full problem.

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
