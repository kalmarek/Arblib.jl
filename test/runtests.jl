using Pkg
Pkg.activate(abspath(joinpath(@__DIR__, "..")))
using BenchmarkTools
using Arblib

function Base.big(arf::Arf)
    y = BigFloat()
    ccall(
        Arblib.@libarb(arf_get_mpfr),
        Cint,
        (Ref{BigFloat}, Ref{Arf}, Arblib.arb_rnd),
        y,
        arf,
        RoundNearest,
    )
    return y
end

Base.show(io::IO, arf::Arf) = show(io, big(arf))

function add!(res::Arf, x::Arf, y::Arf, rnd::RoundingMode = RoundNearest)
    ccall(
        Arblib.@libarb(arf_add),
        Cint,
        (Ref{Arf}, Ref{Arf}, Ref{Arf}, Clong, Arblib.arb_rnd),
        res,
        x,
        y,
        x.prec,
        rnd,
    )
    return res
end


x = Arblib.Arf(big(π), 128)
y = Arf(128)
z = add!(Arf(128), x, x)

@info "Arf creation"
@btime Arblib.Arf(128)
@info "Arf set!"
@btime Arblib.set!($y, $x)
@info "Arf add!"
@btime add!($y, $x, $z)
