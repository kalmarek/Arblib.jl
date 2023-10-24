"""
    Arf <: AbstractFloat
"""
struct Arf <: AbstractFloat
    arf::arf_struct
    prec::Int

    Arf(; prec::Integer = DEFAULT_PRECISION[]) = new(arf_struct(), prec)

    Arf(x::Union{UInt,Int}; prec::Integer = DEFAULT_PRECISION[]) = new(arf_struct(x), prec)
end

"""
    Mag <: Real
"""
struct Mag <: Real
    mag::mag_struct

    Mag() = new(mag_struct())

    # Uses init_set! constructor. Argument type should be
    # Union{MagLike,ArfLike} but those are only defined further down.
    Mag(
        x::Union{
            Union{Mag,mag_struct,Ptr{mag_struct}},
            Union{Arf,arf_struct,Ptr{arf_struct}},
        },
    ) = new(mag_struct(cstruct(x)))
end

"""
    Arb <: AbstractFloat
"""
struct Arb <: AbstractFloat
    arb::arb_struct
    prec::Int

    Arb(; prec::Integer = DEFAULT_PRECISION[]) = new(arb_struct(), prec)
end

"""
    Acb <: Number
"""
struct Acb <: Number
    acb::acb_struct
    prec::Int

    Acb(; prec::Integer = DEFAULT_PRECISION[]) = new(acb_struct(), prec)
end

# Refs are in reverse order to model their possible depencies
"""
    AcbRef <: Number
"""
struct AcbRef <: Number
    acb_ptr::Ptr{acb_struct}
    prec::Int
    parent::Union{Nothing,acb_vec_struct,acb_poly_struct,acb_mat_struct}
end

"""
    ArbRef <: AbstractFloat
"""
struct ArbRef <: AbstractFloat
    arb_ptr::Ptr{arb_struct}
    prec::Int
    parent::Union{acb_struct,AcbRef,arb_vec_struct,arb_poly_struct,arb_mat_struct}
end

"""
    ArfRef <: AbstractFloat
"""
struct ArfRef <: AbstractFloat
    arf_ptr::Ptr{arf_struct}
    prec::Int
    parent::Union{arb_struct,ArbRef}
end

"""
    MagRef <: Real
"""
struct MagRef <: Real
    mag_ptr::Ptr{mag_struct}
    parent::Union{arb_struct,ArbRef}
end

"""
    ArbPoly
"""
struct ArbPoly
    arb_poly::arb_poly_struct
    prec::Int

    ArbPoly(; prec::Integer = DEFAULT_PRECISION[]) = new(arb_poly_struct(), prec)
end

"""
    ArbSeries <: Number

This type should be considered experimental, the interface for it
might change in the future.
"""
struct ArbSeries <: Number
    poly::ArbPoly
    degree::Int

    ArbSeries(; degree::Integer = 0, prec::Integer = DEFAULT_PRECISION[]) =
        fit_length!(new(ArbPoly(; prec), degree), degree + 1)
end

"""
    AcbPoly
"""
struct AcbPoly
    acb_poly::acb_poly_struct
    prec::Int

    AcbPoly(; prec::Integer = DEFAULT_PRECISION[]) = new(acb_poly_struct(), prec)
end

"""
    AcbSeries <: Number

This type should be considered experimental, the interface for it
might change in the future.
"""
struct AcbSeries <: Number
    poly::AcbPoly
    degree::Int

    AcbSeries(; degree::Integer = 0, prec::Integer = DEFAULT_PRECISION[]) =
        fit_length!(new(AcbPoly(; prec), degree), degree + 1)
end

"""
    ArbVector <: DenseVector{Arb}
    ArbVector(n::Integer; prec::Integer = DEFAULT_PRECISION[])
    ArbVector(v::ArbVectorLike; shallow::Bool = false, prec::Integer = precision(v))
    ArbVector(v::AbstractVector; prec::Integer = _precision(v))

The constructor with `n::Integer` returns a vector with `n` elements
filled with zeros. The other two constructors returns a copy of the
given vector. If `shallow = true` then the returned vector shares the
underlying data with the input, mutating one of them mutates both.

See also [`ArbRefVector`](@ref).
"""
struct ArbVector <: DenseVector{Arb}
    arb_vec::arb_vec_struct
    prec::Int

    function ArbVector(
        v::arb_vec_struct;
        shallow::Bool = false,
        prec::Integer = DEFAULT_PRECISION[],
    )
        if shallow
            return new(v, prec)
        else
            return set!(new(cstructtype(ArbVector)(v.n), prec), v, v.n)
        end
    end
end

"""
    AcbVector <: DenseVector{Acb}
    AcbVector(n::Integer; prec::Integer = DEFAULT_PRECISION[])
    AcbVector(v::AcbVectorLike; shallow::Bool = false, prec::Integer = precision(v))
    AcbVector(v::AbstractVector; prec::Integer = _precision(v))

The constructor with `n::Integer` returns a vector with `n` elements
filled with zeros. The other two constructors returns a copy of the
given vector. If `shallow = true` then the returned vector shares the
underlying data with the input, mutating one of them mutates both.

See also [`AcbRefVector`](@ref).
"""
struct AcbVector <: DenseVector{Acb}
    acb_vec::acb_vec_struct
    prec::Int

    function AcbVector(
        v::acb_vec_struct;
        shallow::Bool = false,
        prec::Integer = DEFAULT_PRECISION[],
    )
        if shallow
            return new(v, prec)
        else
            return set!(new(cstructtype(AcbVector)(v.n), prec), v, v.n)
        end
    end
end

"""
    ArbMatrix <: DenseMatrix{Arb}
    ArbMatrix(r::Integer, c::Integer; prec::Integer = DEFAULT_PRECISION[])
    ArbMatrix(A::ArbMatrixLike; shallow::Bool = false, prec::Integer = precision(v))
    ArbMatrix(A::AbstractMatrix; prec::Integer = _precision(v))
    ArbMatrix(v::AbstractVector; prec::Integer = _precision(v))

The constructor with `r::Integer, c::Integer` returns a `r × c` filled
with zeros. The other three constructors returns a copy of the given
matrix or vector. If `shallow = true` then the returned matrix shares
the underlying data with the input, mutating one of them mutates both.

See also [`ArbRefMatrix`](@ref).
"""
struct ArbMatrix <: DenseMatrix{Arb}
    arb_mat::arb_mat_struct
    prec::Int

    function ArbMatrix(
        A::arb_mat_struct;
        shallow::Bool = false,
        prec::Integer = DEFAULT_PRECISION[],
    )
        if shallow
            return new(A, prec)
        else
            return set!(new(cstructtype(ArbMatrix)(A.r, A.c), prec), A)
        end
    end
end

"""
    AcbMatrix <: DenseMatrix{Acb}
    AcbMatrix(r::Integer, c::Integer; prec::Integer = DEFAULT_PRECISION[])
    AcbMatrix(A::AcbMatrixLike; shallow::Bool = false, prec::Integer = precision(v))
    AcbMatrix(A::AbstractMatrix; prec::Integer = _precision(v))
    AcbMatrix(v::AbstractVector; prec::Integer = _precision(v))

The constructor with `r::Integer, c::Integer` returns a `r × c` filled
with zeros. The other three constructors returns a copy of the given
matrix or vector. If `shallow = true` then the returned matrix shares
the underlying data with the input, mutating one of them mutates both.

See also [`AcbRefMatrix`](@ref).
"""
struct AcbMatrix <: DenseMatrix{Acb}
    acb_mat::acb_mat_struct
    prec::Int

    function AcbMatrix(
        A::acb_mat_struct;
        shallow::Bool = false,
        prec::Integer = DEFAULT_PRECISION[],
    )
        if shallow
            return new(A, prec)
        else
            return set!(new(cstructtype(AcbMatrix)(A.r, A.c), prec), A)
        end
    end
end

"""
    ArbRefVector <: DenseMatrix{ArbRef}

Similar to [`ArbVector`](@ref) but indexing elements returns an
`ArbRef` referencing the corresponding element instead of an `Arb`
copy of the element. The constructors are the same as for
`ArbVector`
"""
struct ArbRefVector <: DenseVector{ArbRef}
    arb_vec::arb_vec_struct
    prec::Int

    function ArbRefVector(
        arb_vec::arb_vec_struct;
        shallow::Bool = false,
        prec::Integer = DEFAULT_PRECISION[],
    )
        if shallow
            return new(arb_vec, prec)
        else
            return set!(new(arb_vec_struct(arb_vec.n), prec), arb_vec, arb_vec.n)
        end
    end
end

"""
    AcbRefVector <: DenseMatrix{AcbRef}

Similar to [`AcbVector`](@ref) but indexing elements returns an
`AcbRef` referencing the corresponding element instead of an `Acb`
copy of the element. The constructors are the same as for
`AcbVector`
"""
struct AcbRefVector <: DenseVector{AcbRef}
    acb_vec::acb_vec_struct
    prec::Int

    function AcbRefVector(
        acb_vec::acb_vec_struct;
        shallow::Bool = false,
        prec::Integer = DEFAULT_PRECISION[],
    )
        if shallow
            return new(acb_vec, prec)
        else
            return set!(new(acb_vec_struct(acb_vec.n), prec), acb_vec, acb_vec.n)
        end
    end
end

"""
    ArbRefMatrix <: DenseMatrix{ArbRef}

Similar to [`ArbMatrix`](@ref) but indexing elements returns an
`ArbRef` referencing the corresponding element instead of an `Arb`
copy of the element. The constructors are the same as for
`ArbMatrix`
"""
struct ArbRefMatrix <: DenseMatrix{ArbRef}
    arb_mat::arb_mat_struct
    prec::Int

    function ArbRefMatrix(
        A::arb_mat_struct;
        shallow::Bool = false,
        prec::Integer = DEFAULT_PRECISION[],
    )
        if shallow
            return new(A, prec)
        else
            return set!(new(cstructtype(ArbRefMatrix)(A.r, A.c), prec), A)
        end
    end
end

"""
    AcbRefMatrix <: DenseMatrix{AcbRef}

Similar to [`AcbMatrix`](@ref) but indexing elements returns an
`AcbRef` referencing the corresponding element instead of an `Acb`
copy of the element. The constructors are the same as for
`AcbMatrix
"""
struct AcbRefMatrix <: DenseMatrix{AcbRef}
    acb_mat::acb_mat_struct
    prec::Int

    function AcbRefMatrix(
        A::acb_mat_struct;
        shallow::Bool = false,
        prec::Integer = DEFAULT_PRECISION[],
    )
        if shallow
            return new(A, prec)
        else
            return set!(new(cstructtype(AcbRefMatrix)(A.r, A.c), prec), A)
        end
    end
end

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
    @eval begin
        cprefix(::Type{<:$T}) = $(QuoteNode(Symbol(prefix)))
        cstruct(x::$T) = getfield(x, cprefix($T))
        cstruct(x::$arbstruct) = x
        cstructtype(::Type{<:$T}) = $arbstruct
        Base.convert(::Type{$arbstruct}, x::$T) = cstruct(x)
    end
end

# ArbSeries and AcbSeries requires a different cstruct implementation
cstruct(x::ArbSeries) = cstruct(x.poly)
cstruct(x::AcbSeries) = cstruct(x.poly)

# handle Ref types
for prefix in [:mag, :arf, :arb, :acb]
    T = Symbol(uppercasefirst(string(prefix)))
    TRef = Symbol(T, :Ref)
    TStruct = Symbol(prefix, :_struct)
    TPtr = Symbol(prefix, :_ptr)
    @eval begin
        cprefix(::Type{$TRef}) = $(QuoteNode(prefix))
        cstructtype(::Type{$TRef}) = $TStruct
        cstruct(x::$TRef) = x.$TPtr
        Base.convert(::Type{Ptr{$TStruct}}, x::$TRef) = cstruct(x)
        Base.cconvert(::Type{Ref{$TStruct}}, x::$TRef) = cstruct(x)

        _nonreftype(::Type{<:Union{$T,$TRef}}) = $T

        parentstruct(x::$T) = cstruct(x)
        parentstruct(x::$TRef) = x
        parentstruct(x::$TStruct) = x
        Base.copy(x::Union{$T,$TRef}) = $T(x)
    end
end

# Polynomials and series don't have Ref types but are often used in
# similar code. It's convenient to have this method then.
_nonreftype(::Type{T}) where {T<:Union{ArbPoly,AcbPoly,ArbSeries,AcbSeries}} = T

const MagOrRef = Union{Mag,MagRef}
const ArfOrRef = Union{Arf,ArfRef}
const ArbOrRef = Union{Arb,ArbRef}
const AcbOrRef = Union{Acb,AcbRef}
const ArbVectorOrRef = Union{ArbVector,ArbRefVector}
const AcbVectorOrRef = Union{AcbVector,AcbRefVector}
const ArbMatrixOrRef = Union{ArbMatrix,ArbRefMatrix}
const AcbMatrixOrRef = Union{AcbMatrix,AcbRefMatrix}

"""
    MagLike = Union{Mag,MagRef,mag_struct,Ptr{mag_struct}}
"""
const MagLike = Union{Mag,MagRef,cstructtype(Mag),Ptr{cstructtype(Mag)}}
"""
    ArfLike = Union{Arf,ArfRef,arf_struct,Ptr{arf_struct}}}
"""
const ArfLike = Union{Arf,ArfRef,cstructtype(Arf),Ptr{cstructtype(Arf)}}
"""
    ArbLike = Union{Arb,ArbRef,arb_struct,Ptr{arb_struct}}}
"""
const ArbLike = Union{Arb,ArbRef,cstructtype(Arb),Ptr{cstructtype(Arb)}}
"""
    AcbLike = Union{Acb,AcbRef,acb_struct,Ptr{acb_struct}}}
"""
const AcbLike = Union{Acb,AcbRef,cstructtype(Acb),Ptr{cstructtype(Acb)}}
"""
    ArbVectorLike = Union{ArbVector,ArbRefVector,arb_vec_struct}
"""
const ArbVectorLike = Union{ArbVector,ArbRefVector,cstructtype(ArbVector)}
"""
    AcbVectorLike = Union{AcbVector,AcbRefVector,acb_vec_struct}
"""
const AcbVectorLike = Union{AcbVector,AcbRefVector,cstructtype(AcbVector)}
"""
    ArbPolyLike = Union{ArbPoly,ArbSeries,arb_poly_struct}
"""
const ArbPolyLike = Union{ArbPoly,ArbSeries,cstructtype(ArbPoly)}
"""
    AcbPolyLike = Union{AcbPoly,AcbSeries,acb_poly_struct}
"""
const AcbPolyLike = Union{AcbPoly,AcbSeries,cstructtype(AcbPoly)}
"""
    ArbMatrixLike = Union{ArbMatrix,ArbRefMatrix,arb_mat_struct)}
"""
const ArbMatrixLike = Union{ArbMatrix,ArbRefMatrix,cstructtype(ArbMatrix)}
"""
    AcbMatrixLike = Union{AcbMatrix,AcbRefMatrix,acb_mat_struct}
"""
const AcbMatrixLike = Union{AcbMatrix,AcbRefMatrix,cstructtype(AcbMatrix)}

const ArbTypes = Union{
    Mag,
    MagRef,
    Arf,
    ArfRef,
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
