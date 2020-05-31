mutable struct Arf <: Real
    arf::arf_struct
    prec::Int

    function Arf(;prec::Integer=DEFAULT_PRECISION[])
        res = new(arf_struct(), prec)
        return res
    end

    function Arf(x::Union{UInt, Int}; prec::Integer=DEFAULT_PRECISION[])
        res = new(arf_struct(x), prec)
        return res
    end
end

mutable struct Mag <: Real
    mag::mag_struct

    function Mag()
        res = new(mag_struct())
        return res
    end

    function Mag(x::Union{Mag, Arf})
        res = new(mag_struct(cstruct(x)))
        return res
    end
end

mutable struct Arb <: Real
    arb::arb_struct
    prec::Int

    function Arb(;prec::Integer=DEFAULT_PRECISION[])
        res = new(arb_struct(), prec)
        return res
    end
end

mutable struct Acb <: Number
    acb::acb_struct
    prec::Int

    function Acb(;prec::Integer=DEFAULT_PRECISION[])
        res = new(acb_struct(), prec)
        return res
    end
end

for (T, prefix) in ((Mag, :mag), (Arf, :arf), (Arb, :arb), (Acb, :acb))
    arbstruct = Symbol(prefix, :_struct)
    spref = "$prefix"
    @eval begin
        cstructtype(::Type{$T}) = $arbstruct
    end
    @eval begin
        cprefix(::Type{$T}) = $(QuoteNode(Symbol(prefix)))
        cstruct(x::$T) = getfield(x, cprefix($T))
        Base.convert(::Type{$(cstructtype(T))}, x::$T) = cstruct(x)
    end
    T == Mag && continue
    @eval begin
        Base.precision(x::$T) = x.prec
    end
end
