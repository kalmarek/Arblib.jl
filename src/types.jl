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


struct ArbRef <: Number
    arb_ptr::Ptr{arb_struct}
    prec::Int
    parent::Union{acb_struct,arb_vec_struct,arb_mat_struct}
end
function ArbRef(
    ptr::Ptr{arb_struct},
    parent::Union{acb_struct,arb_vec_struct,arb_mat_struct};
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

struct ArbVector <: DenseVector{Arb}
    arb_vec::arb_vec_struct
    prec::Int
end
ArbVector(n::Integer; prec::Integer = DEFAULT_PRECISION[]) =
    ArbVector(arb_vec_struct(n), prec)

struct AcbVector <: DenseVector{Acb}
    acb_vec::acb_vec_struct
    prec::Int
end
AcbVector(n::Integer; prec::Integer = DEFAULT_PRECISION[]) =
    AcbVector(acb_vec_struct(n), prec)

struct ArbPoly
    arb_poly::arb_poly_struct
    prec::Int

    ArbPoly(; prec::Integer = DEFAULT_PRECISION[]) = new(arb_poly_struct(), prec)

    function ArbPoly(poly::arb_poly_struct; prec::Integer = DEFAULT_PRECISION[])
        res = ArbPoly(prec = prec)
        set!(res, poly)

        return res
    end
end

struct ArbSeries <: Number
    arb_poly::arb_poly_struct
    degree::Int
    prec::Int

    ArbSeries(degree::Integer; prec::Integer = DEFAULT_PRECISION[]) =
        new(arb_poly_struct(), degree, prec)

    function ArbSeries(
        poly::arb_poly_struct,
        degree::Integer = degree(poly);
        prec::Integer = DEFAULT_PRECISION[],
    )
        res = ArbSeries(degree, prec = prec)
        set!(res, poly)

        return res
    end
end

struct AcbPoly
    acb_poly::acb_poly_struct
    prec::Int

    AcbPoly(; prec::Integer = DEFAULT_PRECISION[]) = new(acb_poly_struct(), prec)

    function AcbPoly(poly::acb_poly_struct; prec::Integer = DEFAULT_PRECISION[])
        res = AcbPoly(prec = prec)
        set!(res, poly)

        return res
    end
end

struct AcbSeries <: Number
    acb_poly::acb_poly_struct
    degree::Int
    prec::Int

    AcbSeries(degree::Integer; prec::Integer = DEFAULT_PRECISION[]) =
        new(acb_poly_struct(), degree, prec)

    function AcbSeries(
        poly::acb_poly_struct,
        degree::Integer = degree(poly);
        prec::Integer = DEFAULT_PRECISION[],
    )
        res = AcbSeries(degree, prec = prec)
        set!(res, poly)

        return res
    end
end

struct ArbMatrix <: DenseMatrix{Arb}
    arb_mat::arb_mat_struct
    prec::Int
end
ArbMatrix(r::Integer, c::Integer; prec::Integer = DEFAULT_PRECISION[]) =
    ArbMatrix(arb_mat_struct(r, c), prec)

struct AcbMatrix <: DenseMatrix{Acb}
    acb_mat::acb_mat_struct
    prec::Int
end
AcbMatrix(r::Integer, c::Integer; prec::Integer = DEFAULT_PRECISION[]) =
    AcbMatrix(acb_mat_struct(r, c), prec)

struct ArbRefVector <: DenseVector{ArbRef}
    arb_vec::arb_vec_struct
    prec::Int
end
ArbRefVector(n::Integer; prec::Integer = DEFAULT_PRECISION[]) =
    ArbRefVector(arb_vec_struct(n), prec)

struct AcbRefVector <: DenseVector{AcbRef}
    acb_vec::acb_vec_struct
    prec::Int
end
AcbRefVector(n::Integer; prec::Integer = DEFAULT_PRECISION[]) =
    AcbRefVector(acb_vec_struct(n), prec)

struct ArbRefMatrix <: DenseMatrix{ArbRef}
    arb_mat::arb_mat_struct
    prec::Int
end
ArbRefMatrix(r::Integer, c::Integer; prec::Integer = DEFAULT_PRECISION[]) =
    ArbRefMatrix(arb_mat_struct(r, c), prec)

struct AcbRefMatrix <: DenseMatrix{AcbRef}
    acb_mat::acb_mat_struct
    prec::Int
end
AcbRefMatrix(r::Integer, c::Integer; prec::Integer = DEFAULT_PRECISION[]) =
    AcbRefMatrix(acb_mat_struct(r, c), prec)

# conversion between ref and non-ref arrays.
for T in [:Arb, :Acb], A in [:Vector, :Matrix]
    TA = Symbol(T, A)
    TRefA = Symbol(T, :Ref, A)
    @eval begin
        $TRefA(M::$TA) = $TRefA(cstruct(M), precision(M))
        $TA(M::$TRefA) = $TA(cstruct(M), precision(M))
    end
end

const ArbLike = Union{Arb,ArbRef,Ptr{arb_struct},arb_struct}
const AcbLike = Union{Acb,AcbRef,Ptr{acb_struct},acb_struct}

for (T, prefix) in (
    (Mag, :mag),
    (Arf, :arf),
    (Arb, :arb),
    (Acb, :acb),
    (Union{ArbVector,ArbRefVector}, :arb_vec),
    (Union{AcbVector,AcbRefVector}, :acb_vec),
    (Union{ArbMatrix,ArbRefMatrix}, :arb_mat),
    (Union{AcbMatrix,AcbRefMatrix}, :acb_mat),
    (Union{ArbPoly,ArbSeries}, :arb_poly),
    (Union{AcbPoly,AcbSeries}, :acb_poly),
)
    arbstruct = Symbol(prefix, :_struct)
    spref = "$prefix"
    @eval begin
        cstructtype(::Type{<:$T}) = $arbstruct
    end
    @eval begin
        cprefix(::Type{<:$T}) = $(QuoteNode(Symbol(prefix)))
        cstruct(x::$T) = getfield(x, cprefix($T))
        cstruct(x::$arbstruct) = x
        Base.convert(::Type{$(cstructtype(T))}, x::$T) = cstruct(x)
    end
end

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

const MagLike = Union{Mag,cstructtype(Mag),Ptr{cstructtype(Mag)}}
const ArfLike = Union{Arf,cstructtype(Arf),Ptr{cstructtype(Arf)}}
const ArbLike = Union{Arb,ArbRef,cstructtype(Arb),Ptr{cstructtype(Arb)}}
const AcbLike = Union{Acb,AcbRef,cstructtype(Acb),Ptr{cstructtype(Acb)}}
const ArbVectorLike = Union{ArbVector,ArbRefVector,cstructtype(ArbVector)}
const AcbVectorLike = Union{AcbVector,AcbRefVector,cstructtype(AcbVector)}
const ArbMatrixLike = Union{ArbMatrix,ArbRefMatrix,cstructtype(ArbMatrix)}
const AcbMatrixLike = Union{AcbMatrix,AcbRefMatrix,cstructtype(AcbMatrix)}
const ArbPolyLike = Union{ArbPoly,ArbSeries,cstructtype(ArbPoly)}
const AcbPolyLike = Union{AcbPoly,AcbSeries,cstructtype(AcbPoly)}
const ArbTypes = Union{
    Arf,
    Arb,
    ArbRef,
    Acb,
    AcbRef,
    ArbVector,
    ArbRefVector,
    AcbVector,
    AcbRefVector,
    ArbMatrix,
    ArbRefMatrix,
    AcbMatrix,
    AcbRefMatrix,
    ArbPoly,
    ArbSeries,
    AcbPoly,
    AcbSeries,
}

Base.setindex!(x::Union{Mag,Arf,Arb,ArbRef,Acb,AcbRef}, z::Number) = set!(x, z)
Base.setindex!(x::Union{Arb,ArbRef}, z::Ptr{arb_struct}) = set!(x, z)
Base.setindex!(x::Union{Acb,AcbRef}, z::Ptr{acb_struct}) = set!(x, z)

Base.Float64(x::Mag) = get(x)
function Base.Float64(
    x::Union{Arf,Ptr{arf_struct}};
    rnd::Union{arb_rnd,RoundingMode} = RoundNearest,
)
    ccall(@libarb(arf_get_d), Cdouble, (Ref{arf_struct}, arb_rnd), x, rnd)
end
function Base.Int(
    x::Union{Arf,Ptr{arf_struct}};
    rnd::Union{arb_rnd,RoundingMode} = RoundNearest,
)
    ccall(@libarb(arf_get_si), Clong, (Ref{arf_struct}, arb_rnd), x, rnd)
end
