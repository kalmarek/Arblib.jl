# Mag
set!(res::MagLike, ::Irrational{:π}) = const_pi!(res)

# Arb
function set!(res::ArbLike, x::Union{MagLike,BigFloat})
    set!(radref(res), UInt64(0))
    set!(midref(res), x)
    return res
end

function set!(res::ArbLike, x::Rational; prec::Integer = precision(res))
    set!(res, numerator(x))
    return div!(res, res, denominator(x), prec = prec)
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

# Acb
function set!(res::AcbLike, x::Union{Real,arf_struct,mag_struct})
    set!(realref(res), x)
    set!(imagref(res), 0)
    return res
end

function set!(
    res::AcbLike,
    re::Union{Real,arb_struct,arf_struct,mag_struct},
    im::Union{Real,arb_struct,arf_struct,mag_struct},
)
    set!(realref(res), re)
    set!(imagref(res), im)
    return res
end

set!(res::AcbLike, z::Complex) = set!(res, real(z), imag(z))
set!(res::AcbLike, ::Irrational{:π}) = const_pi!(res)
