mutable struct Arf <: Real
    arf::arf_struct
    prec::Int

    Arf(prec::Integer) = new(arf_struct(), prec)
    Arf(si::Int, prec::Integer) = new(arf_struct(si), prec)
    Arf(ui::UInt, prec::Integer) = new(arf_struct(ui), prec)
end

mutable struct Arb <: Real
    arb::arb_struct
    prec::Int

    Arb(prec::Integer) = new(arb_struct(), prec)
end

mutable struct Acb <: Number
    acb::acb_struct
    prec::Int

    Acb(prec::Integer) = new(acb_struct(), prec)
end

mutable struct Mag <: Real
    mag::mag_struct

    Mag() = new(mag_struct())
    Mag(x::Arf) = new(mag_struct(cstruct(x)))
end

for (T, prefix) in ((Arf, :arf), (Arb, :arb), (Acb, :acb), (Mag, :mag))
    arbstruct = Symbol(prefix, :_struct)
    spref = "$prefix"
    @eval begin
        cprefix(::Type{$T}) = Symbol($spref) # useful for metaprogramming
        cstruct(t::$T) = getfield(t, cprefix($T))
        Base.cconvert(::Type{Ref{$T}}, t::$T) =
            Base.cconvert(Ref{$arbstruct}, cstruct(t))
        Base.unsafe_convert(::Type{Ref{$T}}, t::Base.RefValue{$arbstruct}) =
            Base.unsafe_convert(Ref{$arbstruct}, t)
    end
end
