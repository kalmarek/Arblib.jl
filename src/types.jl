struct Arf <: Real
    arf::arf_struct
    prec::Int

    function Arf(; prec::Integer = DEFAULT_PRECISION[])
        res = new(arf_struct(), prec)
        return res
    end

    function Arf(x::arf_struct; prec::Integer = DEFAULT_PRECISION[])
        res = Arf(prec = prec)
        set!(res, x)
        return res
    end

    function Arf(x::Union{UInt,Int}; prec::Integer = DEFAULT_PRECISION[])
        res = new(arf_struct(x), prec)
        return res
    end
end

struct ArfRef <: Real
    arf_ptr::Ptr{arf_struct}
    prec::Int
    parent::arb_struct
end
function ArfRef(ptr::Ptr{arf_struct}, parent::arb_struct; prec::Int)
    ArfRef(ptr, prec, parent)
end

ArfRef(; prec::Int = DEFAULT_PRECISION[]) = Arf(; prec = prec)
function Arf(x::ArfRef; prec::Integer = precision(x))
    res = Arf(prec = prec)
    set!(res, x)
    return res
end
Base.getindex(x::ArfRef) = Arf(x)


struct Mag <: Real
    mag::mag_struct

    function Mag()
        res = new(mag_struct())
        return res
    end

    function Mag(x::mag_struct)
        res = new(mag_struct(x))
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

    function Arb(x::arb_struct; prec::Integer = DEFAULT_PRECISION[])
        res = Arb(prec = prec)
        set!(res, x)
        return res
    end
end


struct ArbRef <: Real
    arb_ptr::Ptr{arb_struct}
    prec::Int
    parent::Union{arb_vec_struct,arb_mat_struct}
end
function ArbRef(
    ptr::Ptr{arb_struct},
    parent::Union{arb_vec_struct,arb_mat_struct};
    prec::Int,
)
    ArbRef(ptr, prec, parent)
end

ArbRef(; prec::Int = DEFAULT_PRECISION[]) = Arb(; prec = prec)
function Arb(x::ArbRef; prec::Integer = precision(x))
    res = Arb(prec = prec)
    set!(res, x)
    return res
end
Base.getindex(x::ArbRef) = Arb(x)


struct Acb <: Number
    acb::acb_struct
    prec::Int

    function Acb(; prec::Integer = DEFAULT_PRECISION[])
        res = new(acb_struct(), prec)
        return res
    end

    function Acb(x::acb_struct; prec::Integer = DEFAULT_PRECISION[])
        res = Acb(prec = prec)
        set!(res, x)
        return res
    end
end


struct AcbRef <: Number
    acb_ptr::Ptr{acb_struct}
    prec::Int
    parent::Union{acb_vec_struct,acb_mat_struct}
end
function AcbRef(
    ptr::Ptr{acb_struct},
    parent::Union{acb_vec_struct,acb_mat_struct};
    prec::Int,
)
    AcbRef(ptr, prec, parent)
end

AcbRef(; prec::Int = DEFAULT_PRECISION[]) = Acb(; prec = prec)
function Acb(x::AcbRef; prec::Integer = precision(x))
    res = Acb(prec = prec)
    set!(res, x)
    return res
end
Base.getindex(x::AcbRef) = Acb(x)

struct ArbVector <: DenseVector{ArbRef}
    arb_vec::arb_vec_struct
    prec::Int
end
ArbVector(n::Integer; prec::Integer = DEFAULT_PRECISION[]) =
    ArbVector(arb_vec_struct(n), prec)

struct AcbVector <: DenseVector{AcbRef}
    acb_vec::acb_vec_struct
    prec::Int
end
AcbVector(n::Integer; prec::Integer = DEFAULT_PRECISION[]) =
    AcbVector(acb_vec_struct(n), prec)

struct ArbMatrix <: DenseMatrix{ArbRef}
    arb_mat::arb_mat_struct
    prec::Int
end
ArbMatrix(r::Integer, c::Integer; prec::Integer = DEFAULT_PRECISION[]) =
    ArbMatrix(arb_mat_struct(r, c), prec)

struct AcbMatrix <: DenseMatrix{AcbRef}
    acb_mat::acb_mat_struct
    prec::Int
end
AcbMatrix(r::Integer, c::Integer; prec::Integer = DEFAULT_PRECISION[]) =
    AcbMatrix(acb_mat_struct(r, c), prec)

const ArbTypes =
    Union{Arf,ArfRef,Arb,ArbRef,Acb,AcbRef,ArbVector,AcbVector,ArbMatrix,AcbMatrix}

for (T, prefix) in (
    (Mag, :mag),
    (Arf, :arf),
    (Arb, :arb),
    (Acb, :acb),
    (ArbVector, :arb_vec),
    (AcbVector, :acb_vec),
    (ArbMatrix, :arb_mat),
    (AcbMatrix, :acb_mat),
)
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


cprefix(::Type{ArfRef}) = :arf_struct
cstructtype(::Type{ArfRef}) = Ptr{arf_struct}
cstruct(x::ArfRef) = x.arf_ptr
Base.convert(::Type{Ptr{arf_struct}}, x::ArfRef) = cstruct(x)
Base.cconvert(::Type{Ref{arf_struct}}, x::ArfRef) = cstruct(x)

cprefix(::Type{ArbRef}) = :arb_struct
cstructtype(::Type{ArbRef}) = Ptr{arb_struct}
cstruct(x::ArbRef) = x.arb_ptr
Base.convert(::Type{Ptr{arb_struct}}, x::ArbRef) = cstruct(x)
Base.cconvert(::Type{Ref{arb_struct}}, x::ArbRef) = cstruct(x)

cprefix(::Type{AcbRef}) = :acb_struct
cstructtype(::Type{AcbRef}) = Ptr{acb_struct}
cstruct(x::AcbRef) = x.acb_ptr
Base.convert(::Type{Ptr{acb_struct}}, x::AcbRef) = cstruct(x)
Base.cconvert(::Type{Ref{acb_struct}}, x::AcbRef) = cstruct(x)

function Base.setindex!(x::Union{Mag,Arf,ArfRef,Arb,ArbRef,Acb,AcbRef}, z::Number)
    set!(x, z)
    x
end
