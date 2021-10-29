# Mag
set!(res::MagLike, x::Integer) = set!(res, convert(UInt, x))
set!(res::MagLike, ::Irrational{:π}) = const_pi!(res)
set!(res::MagLike, x::Integer, y::Integer) = set_ui_2exp!(res, convert(UInt, x), y)

# Arf
function set!(res::ArfLike, x::UInt128)
    # Split x into x = a * 2^64 + b
    a = UInt64(x >> 64)
    b = x % UInt64
    set!(res, a)
    mul_2exp!(res, res, 64)
    add!(res, res, b)
    return res
end

function set!(res::ArfLike, x::Int128)
    set!(res, UInt128(abs(x)))
    return x < 0 ? neg!(res, res) : res
end

function set!(res::ArfLike, x::Rational; prec::Integer = precision(res))
    set!(res, numerator(x))
    div!(res, res, denominator(x), prec = prec)
    return res
end

function set!(
    res::ArfLike,
    x::Rational{<:Union{UInt128,Int128,BigInt}};
    prec::Integer = precision(res),
)
    set!(res, numerator(x))
    div!(res, res, Arf(denominator(x), prec = prec), prec = prec)
    return res
end

# Arb
function set!(res::ArbLike, x::Union{UInt128,Int128,MagLike,BigInt,BigFloat})
    set!(midref(res), x)
    zero!(radref(res))
    return res
end

function set!(res::ArbLike, x::Rational; prec::Integer = precision(res))
    set!(res, numerator(x))
    return div!(res, res, denominator(x), prec = prec)
end

function set!(
    res::ArbLike,
    x::Rational{<:Union{UInt128,Int128,BigInt}};
    prec::Integer = precision(res),
)
    set!(res, numerator(x))
    return div!(res, res, Arb(denominator(x), prec = prec), prec = prec)
end

for (irr, suffix) in ((:π, "pi"), (:ℯ, "e"), (:γ, "euler"), (:catalan, "catalan"))
    jlf = Symbol("const_$suffix", "!")
    IrrT = Irrational{irr}
    @eval begin
        set!(res::ArbLike, ::$IrrT; prec::Integer = precision(res)) = $jlf(res, prec = prec)
    end
end

function set!(res::ArbLike, ::Irrational{:φ}; prec::Integer = precision(res))
    set!(res, 5)
    sqrt!(res, res, prec)
    add!(res, res, 1, prec)
    return div!(res, res, 2, prec)
end

function set!(
    res::ArbLike,
    (a, b)::NTuple{2,Union{MagLike,ArfLike,BigFloat}};
    prec::Integer = precision(res),
)
    # Checking a > b instead of a <= b also handles NaN correctly
    a > b && throw(ArgumentError("must have a <= b, got a = $a and b = $b"))
    return set_interval!(res, a, b, prec = prec)
end

function set!(res::ArbLike, (a, b)::Tuple{<:Real,<:Real}; prec::Integer = precision(res))
    # This is not strictly required to check since the union will give
    # an enclosure anyway. But since thus method is designed for a <=
    # b adding this check could catch some bugs.
    a > b && throw(ArgumentError("must have a <= b, got a = $a and b = $b"))
    if !(a isa ArbLike)
        a = Arb(a, prec = prec)
    end
    if !(b isa ArbLike)
        b = Arb(b, prec = prec)
    end
    return union!(res, a, b, prec = prec)
end

# Acb
function set!(res::AcbLike, x::Union{Real,arf_struct,mag_struct,Tuple{<:Real,<:Real}})
    set!(realref(res), x)
    zero!(imagref(res))
    return res
end

# This needs to be a separate function for disambiguation with Integer
function set!(res::AcbLike, x::Union{UInt128,Int128,BigInt})
    set!(realref(res), x)
    zero!(imagref(res))
    return res
end

# Doesn't support aliasing between realref(res) and im
function set!(
    res::AcbLike,
    re::Union{Real,arb_struct,arf_struct,mag_struct,Tuple{<:Real,<:Real}},
    im::Union{Real,arb_struct,arf_struct,mag_struct,Tuple{<:Real,<:Real}},
)
    set!(realref(res), re)
    set!(imagref(res), im)
    return res
end

set!(res::AcbLike, z::Complex) = set!(res, real(z), imag(z))
set!(res::AcbLike, ::Irrational{:π}) = const_pi!(res)
