mutable struct Arf <: Real
    arf::arf_struct
    prec::Int

    function Arf(;prec::Integer=DEFAULT_PRECISION[])
        res = new(arf_struct(0,0,0,0), prec)
        init!(res)
        finalizer(clear!, res)
        return res
    end

    function Arf(si::Int64; prec::Integer=DEFAULT_PRECISION[])
        res = new(arf_struct(0,0,0,0), prec)
        ccall(@libarb(arf_init_set_si), Cvoid, (Ref{Arf}, Int), res, si)
        finalizer(clear!, res)
        return res
    end

    # ccall(@libarb(arf_init_set_ui), Cvoid, (Ref{Arf}, Int), res, ui)
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
        res = new(arb_struct(0,0,0,0, 0,0,0,0), prec)
        init!(res)
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

    function Mag(m::mag_struct)
        res = new(mag_struct(0,0))
        ccall(
            @libarb(mag_init_set),
            Cvoid,
            (Ref{Mag}, Ref{mag_struct}),
            res,
            m,
        )
        finalizer(clear!, res)
        return res
    end

    function Mag(arf::Arf)
        res = new(mag_struct(0,0))
        ccall(
            @libarb(mag_init_set_arf),
            Cvoid,
            (Ref{Mag}, Ref{Arf}),
            res,
            arf,
        )
        finalizer(clear!, res)
        return res
    end
end

for (T, prefix) in ((Arf, :arf), (Arb, :arb), (Acb, :acb), (Mag, :mag))
    arbstruct = Symbol(prefix, :_struct)
    spref = "$prefix"
    @eval begin
        init!(a::$T) = init!(a.$prefix)
        clear!(a::$T) = clear!(a.$prefix)
        cprefix(::Type{$T}) = Symbol($spref) # useful for metaprogramming
        cstruct(t::$T) = getfield(t, cprefix($T))
    end
    T == Mag && continue
    @eval begin
        Base.precision(x::$T) = x.prec
    end
end
