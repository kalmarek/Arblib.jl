# Type for handling the context for nfloat_t. In Flint it has the type
# gr_ctx_t which is a reference to a gr_ctx_struct. Both of these
# types are defined in src/gr_types.h in Flint. For type stability it
# seems best to create a separate type for a nfloat_ctx_struct, even
# if it is more general in theory.
const GR_CTX_STRUCT_DATA_BYTES = 6 * sizeof(UInt)
mutable struct nfloat_ctx_struct{P,F}
    data::NTuple{GR_CTX_STRUCT_DATA_BYTES,UInt8}
    which_ring::UInt
    sizeof_elem::Int
    methods::Ptr{Cvoid}
    size_limit::UInt

    function nfloat_ctx_struct{P,F}() where {P,F}
        @assert P isa Int && F isa Int
        ctx = new{P,F}()
        ret = init!(ctx, 64P, F)
        iszero(ret) || throw(DomainError(P, "cannot set precision to this value"))
        return ctx
    end
end

const NFLOAT_HEADER_LIMBS = 2
mutable struct nfloat_struct{P,F}
    head::NTuple{NFLOAT_HEADER_LIMBS,UInt}
    d::NTuple{P,UInt} # FIXME: Should be different for 32 bit systems

    function nfloat_struct{P,F}() where {P,F}
        @assert P isa Int && F isa Int
        res = new{P,F}()
        init!(res)
        return res
    end
end

struct NFloat{P,F} <: AbstractFloat
    nfloat::nfloat_struct{P,F}

    NFloat{P,F}() where {P,F} = new{P,F}(nfloat_struct{P,F}())
end

struct NFloatRef{P,F} <: AbstractFloat
    nfloat_ptr::Ptr{nfloat_struct{P,F}}
    parent::Union{Nothing}
end

const NFloatLike{P,F} = Union{NFloat{P,F},NFloatRef{P,F},nfloat_struct{P,F}}

nfloat_ctx_struct(::NFloatLike{P,F}) where {P,F} = nfloat_ctx_struct{P,F}()
nfloat_ctx_struct(::Type{NFloatLike{P,F}}) where {P,F} = nfloat_ctx_struct{P,F}()

# The contexts are precomputed in nfloat_late.jl
@generated function _get_nfloat_ctx_struct(
    ::Union{Type{<:NFloatLike{P,F}},NFloatLike{P,F}},
) where {P,F}
    Symbol(:_nfloat_ctx_struct_, P, :_, F)
end

# Helper function for constructing a flag argument for NFloat
nfloat_flag(;
    allow_underflow::Bool = false,
    allow_inf::Bool = false,
    allow_nan::Bool = false,
) = allow_underflow + 2allow_inf + 4allow_nan

# As in types.jl

cprefix(::Type{NFloat}) = :nfloat
cstruct(x::NFloat) = getfield(x, cprefix(NFloat))
cstruct(x::nfloat_struct) = x
cstructtype(::Type{NFloat{P,F}}) where {P,F} = nfloat_struct{P,F}
cstructtype(::Type{NFloat}) = nfloat_struct
Base.convert(::Type{nfloat_struct{P,F}}, x::NFloat{P,F}) where {P,F} = cstruct(x)
Base.convert(::Type{nfloat_struct}, x::NFloat{P,F}) where {P,F} = cstruct(x)

const NFloatOrRef{P,F} = Union{NFloat{P,F},NFloatRef{P,F}}

cprefix(::Type{NFloatRef}) = :nfloat
cstruct(x::NFloatRef) = x.nfloat_ref
cstructtype(::Type{NFloatRef}) = nfloat_struct
Base.convert(::Type{Ptr{nfloat_struct}}, x::NFloatRef) = cstruct(x)
Base.cconvert(::Type{Ref{nfloat_struct}}, x::NFloatRef) = cstruct(x)

_nonreftype(::Type{<:NFloatOrRef{P,F}}) where {P,F} = NFloat{P,F}

parentstruct(x::NFloat) = cstruct(x)
parentstruct(x::NFloatRef) = x
parentstruct(x::nfloat_struct) = x

Base.copy(x::T) where {T<:NFloatOrRef} = _nonreftype(T)(x)

# As in precision.jl

Base._precision_with_base_2(::Type{NFloatLike{P}}) where {P} = 64P
Base._precision_with_base_2(::NFloatLike{P}) where {P} = 64P

Base.precision(T::Type{NFloatLike{P}}; base::Integer = 2) where {P} =
    Base._precision(T, base)
Base.precision(x::NFloatLike; base::Integer = 2) = Base._precision(x, base)

@inline _precision(x::NFloatLike) = precision(x)

# As in setters.jl

# NFloat
function set!(res::NFloatLike, x::Rational)
    set!(res, numerator(x))
    div!(res, res, denominator(x))
    return res
end

set!(res::NFloatLike, x::Complex) =
    isreal(x) ? set!(res, real(x)) : throw(InexactError(:NFloat, NFloat, x))

set!(res::NFloatLike, ::Irrational{:π}) = pi!(res)

# Arf
set!(res::ArfLike, x::NFloatLike) = (get!(res, x, _get_nfloat_ctx_struct(x)); res)

# As in constructors.jl

NFloat{P,F}(x) where {P,F} = (res = NFloat{P,F}(); set!(res, x); res)
# disambiguation
NFloat{P,F}(x::NFloatLike{P,F}) where {P,F} = (res = NFloat{P,F}(); set!(res, x); res)
NFloat{P,F}(x::Rational) where {P,F} = (res = NFloat{P,F}(); set!(res, x); res)
NFloat{P,F}(x::Complex) where {P,F} = (res = NFloat{P,F}(); set!(res, x); res)

function NFloat{P,F}(str::AbstractString) where {P,F}
    res = NFloat{P,F}()
    ret = set!(res, str)
    iszero(ret) || throw(ArgumentError("could not parse $str as an NFloat{$P,$F}"))
    return res
end

Base.zero(::Union{NFloat{P,F},Type{NFloat{P,F}}}) where {P,F} = NFloat{P,F}()
Base.one(::Union{NFloat{P,F},Type{NFloat{P,F}}}) where {P,F} = one!(NFloat{P,F}())

Base.zeros(::Type{<:NFloat}, n::Integer) = [zero(T) for _ = 1:n]
Base.ones(::Type{<:NFloat}, n::Integer) = [one(T) for _ = 1:n]

# As in conversion.jl

# TODO

# As in predicates.jl

NFLOAT_EXP(x::nfloat_struct) = reinterpret(Int, x.head[1])
NFLOAT_EXP(x::NFloat) = NFLOAT_EXP(cstruct(x))
const NFLOAT_EXP_ZERO = typemin(Int)
const NFLOAT_EXP_POS_INF = typemin(Int) + 1
const NFLOAT_EXP_NEG_INF = typemin(Int) + 2
const NFLOAT_EXP_NAN = typemin(Int) + 3

Base.iszero(x::NFloatOrRef) = NFLOAT_EXP(x) == NFLOAT_EXP_ZERO
Base.isone(x::NFloatOrRef) = false # TODO: Need to wrap nfloat_is_one which returns truth_t
Base.isfinite(x::NFloatOrRef) = !isinf(x) && !isnan(x)
Base.isinf(x::NFloatOrRef) =
    (NFLOAT_EXP(x) == NFLOAT_EXP_POS_INF) || (NFLOAT_EXP(x) == NFLOAT_EXP_NEG_INF)
Base.isnan(x::NFloatOrRef) = NFLOAT_EXP(x) == NFLOAT_EXP_NAN

# As in show.jl

function Base.show(io::IO, x::NFloatOrRef)
    if Base.get(io, :compact, false)
        digits = min(6, digits_prec(precision(x)))
        print(io, string(x; digits))
    else
        print(io, string(x))
    end
end

function Base.string(
    z::NFloatOrRef;
    digits::Integer = digits_prec(precision(z)),
    remove_trailing_zeros::Bool = true,
)
    z_arf = Arf(prec = precision(z))
    get!(z_arf, z, ctx = nfloat_ctx_struct(z))
    return string(z_arf; digits, remove_trailing_zeros)
end

Base.show(io::IO, ::Type{NFloatLike}) = print(io, :NFloatLike)

# As in promotion.jl

Base.promote_rule(
    ::Type{<:NFloatOrRef{P1,F1}},
    ::Type{<:Union{NFloatOrRef{P2,F2}}},
) where {P1,P2,F1,F2} = NFloat{max(P1, P2),F1 | F2}

# As in arithmetic.jl

for (jf, af) in [(:+, :add!), (:-, :sub!), (:*, :mul!), (:/, :div!)]
    @eval function Base.$jf(x::NFloatOrRef{P,F}, y::NFloatOrRef{P,F}) where {P,F}
        z = zero(x)
        $af(z, x, y) # TODO: Handle return code?
        return z
    end
end

Base.:-(x::NFloat) = (res = zero(x); neg!(res, x); res)

Base.abs(x::NFloat) = (res = zero(x); abs!(res, x); res)

Base.:^(x::NFloatOrRef{P,F}, y::NFloatOrRef{P,F}) where {P,F} =
    (res = zero(x); pow!(res, x, y); res)

# As in elementary.jl

for f in [
    :sqrt,
    :log,
    :log1p,
    :exp,
    :expm1,
    :sin,
    :cos,
    :tan,
    #:cot,
    #:sec,
    #:csc,
    :atan,
    #:asin,
    #:acos,
    :sinh,
    :cosh,
    :tanh,
    #:coth,
    #:sech,
    #:csch,
    #:atanh,
    #:asinh,
    #:acosh,
]
    @eval Base.$f(x::NFloatOrRef) = (res = zero(x); $(Symbol(f, :!))(res, x); res)
end


export NFloat, NFloatRef
