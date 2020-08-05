struct Arf <: Real
    arf::arf_struct
    prec::Int

    function Arf(; prec::Integer = DEFAULT_PRECISION[])
        res = new(arf_struct(), prec)
        return res
    end

    function Arf(x::arf_struct; prec::Integer = DEFAULT_PRECISION[], shallow::Bool = false)
        if shallow
            res = new(x, prec)
        else
            res = Arf(prec = prec)
            set!(res, x)
        end

        return res
    end

    function Arf(x::Union{UInt,Int}; prec::Integer = DEFAULT_PRECISION[])
        res = new(arf_struct(x), prec)
        return res
    end
end

struct Mag <: Real
    mag::mag_struct

    function Mag()
        res = new(mag_struct())
        return res
    end

    function Mag(x::mag_struct; shallow::Bool = false)
        if shallow
            res = new(x)
        else
            res = new(mag_struct(x))
        end

        return res
    end

    function Mag(x::Union{Mag,Arf})
        res = new(mag_struct(cstruct(x)))
        return res
    end
end

struct Arb <: Real
    arb::arb_struct
    prec::Int

    function Arb(; prec::Integer = DEFAULT_PRECISION[])
        res = new(arb_struct(), prec)
        return res
    end

    function Arb(x::arb_struct; prec::Integer = DEFAULT_PRECISION[], shallow::Bool = false)
        if shallow
            res = new(x, prec)
        else
            res = Arb(prec = prec)
            set!(res, x)
        end

        return res
    end
end

struct Acb <: Number
    acb::acb_struct
    prec::Int

    function Acb(; prec::Integer = DEFAULT_PRECISION[])
        res = new(acb_struct(), prec)
        return res
    end

    function Acb(x::acb_struct; prec::Integer = DEFAULT_PRECISION[], shallow::Bool = false)
        if shallow
            res = new(x, prec)
        else
            res = Acb(prec = prec)
            set!(res, x)
        end

        return res
    end
end


struct AcbMatrix <: AbstractMatrix{Acb}
    acb_mat::acb_mat_struct
    prec::Int

    function AcbMatrix(m::Integer, n::Integer; prec::Integer = DEFAULT_PRECISION[])
        res = new(acb_mat_struct(m, n), prec)
        return res
    end
end

for (T, prefix) in
    ((Mag, :mag), (Arf, :arf), (Arb, :arb), (Acb, :acb), (AcbMatrix, :acb_mat))
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
end
