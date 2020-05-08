mutable struct Arf <: Real
    arf::arf_struct
    prec::Int

    function Arf(;prec::Integer=DEFAULT_PRECISION[])
        res = new(arf_struct(0,0,0,0), prec)
        init!(res)
        finalizer(clear!, res)
        return res
    end

    function Arf(ui::UInt64; prec::Integer=DEFAULT_PRECISION[])
        res = new(arf_struct(0,0,0,0), prec)
        init_set!(res, ui)
        finalizer(clear!, res)
        return res
    end

    function Arf(si::Int64; prec::Integer=DEFAULT_PRECISION[])
        res = new(arf_struct(0,0,0,0), prec)
        init_set!(res, si)
        finalizer(clear!, res)
        return res
    end
end

mutable struct Mag <: Real
    mag::mag_struct

    function Mag()
        res = new(mag_struct(0,0))
        init!(res)
        finalizer(clear!, res)
        return res
    end

    function Mag(m::Mag)
        res = new(mag_struct(0,0))
        init_set!(res, m)
        finalizer(clear!, res)
        return res
    end

    function Mag(arf::Arf)
        res = new(mag_struct(0,0))
        init_set!(res, arf)
        finalizer(clear!, res)
        return res
    end
end

mutable struct Arb <: Real
    arb::arb_struct
    prec::Int

    function Arb(;prec::Integer=DEFAULT_PRECISION[])
        res = new(arb_struct(0,0,0,0, 0,0), prec)
        init!(res)
        finalizer(clear!, res)
        return res
    end
end

mutable struct Acb <: Number
    acb::acb_struct
    prec::Int

    function Acb(;prec::Integer=DEFAULT_PRECISION[])
        res = new(acb_struct(0,0,0,0,0,0, 0,0,0,0,0,0), prec)
        init!(res)
        finalizer(clear!, res)
        return res
    end
end

for (T, prefix) in ((Mag, :mag), (Arf, :arf), (Arb, :arb), (Acb, :acb))
    arbstruct = Symbol(prefix, :_struct)
    spref = "$prefix"
    @eval begin
        cprefix(::Type{$T}) = Symbol($spref) # useful for metaprogramming
        cstruct(t::$T) = getfield(t, cprefix($T))
    end
    T == Mag && continue
    @eval begin
        Base.precision(x::$T) = x.prec
    end
end
