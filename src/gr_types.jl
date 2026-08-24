"""
    GRDomainError()

Used to throw an error corresponding to the `GR_DOMAIN` flag in Flint.

The Flint documentation gives the following description of this flag.

> The result does not have a value in the domain of the target ring or
> type, i.e. the result is mathematically undefined. This occurs, for
> example, on division by zero or when attempting to compute the
> square root of a non-square. It also occurs when attempting to
> convert a too large value to a bounded type (example: `get_ui()`
> with input ``n \\geq 2^64``).

See also [`GRUnableError`](@ref).
"""
struct GRDomainError <: Exception end

"""
    GRUnableError()

Used to throw an error corresponding to the `GR_UNABLE` flag in Flint.

The Flint documentation gives the following description of this flag.

> The operation could not be performed because of limitations of the
> implementation or the data representation, i.e. the result is
> unknown. Typical reasons:
> - The result would be too large to fit in memory
> - The inputs are inexact and an exact comparison is needed
> - The computation would take too long
> - An algorithm is not yet implemented for this case
> If this flag is set, there is also potentially a domain error (but
>  this is unknown).

See also [`GRDomainError`](@ref).
"""
struct GRUnableError <: Exception end

"""
    gr_handle_flag(flag::Cint)

Handle a GR return flag returned from a Flint function. If the flag is
zero it returns `nothing`, otherwise it throws an error depending on
the flag.

It first checks if the `GR_UNABLE` flag is set, in which case it
throws a [`GRUnableError`](@ref), it then checks if the `GR_DOMAIN`
flag is set, in which case it throws a [`GRDomainError`](@ref). If
none of these flags are set (and the result is non-zero) it throws an
[`ErrorException`](@ref) for an unknown GR return flag.
"""
function gr_handle_flag(flag::Cint)
    if iszero(flag)
        return nothing
    elseif !iszero(flag & Cint(2))
        throw(GRUnableError())
    elseif !iszero(flag & Cint(1))
        throw(GRDomainError())
    else
        throw(ErrorException("unknown GR return flag $flag"))
    end
end

const GR_CTX_STRUCT_DATA_BYTES = 6 * sizeof(UInt)
# This type is currently unused. At the moment it only serves to
# determine the size of gr_dft_acb_pre_struct. A proper wrapper of the
# generic ring interface is future work.
mutable struct gr_ctx_struct
    data::NTuple{GR_CTX_STRUCT_DATA_BYTES,UInt8}
    which_ring::UInt
    sizeof_elem::Int
    methods::Ptr{Cvoid}
    size_limit::UInt

    global _gr_ctx_struct() = new()
end

# This type is currently unused. At the moment it only serves to
# determine the size of gr_dft_acb_pre_struct. A proper wrapper of the
# generic ring interface is future work.
mutable struct gr_dft_pre_struct
    n::UInt
    depth::Cint
    alg::Cint
    flags::Cint
    ctx::Ptr{Cvoid}
    real_ctx::Ptr{Cvoid}
    roots::Ptr{Cvoid}
    stage_tab::Ptr{Cvoid}
    stage_len::Int
    wtab::Ptr{Cvoid}
    wclass::Ptr{UInt8}
    n1::UInt
    n2::UInt
    pfa_a::UInt
    pfa_b::UInt
    radices::Ptr{UInt}
    num_radices::Int
    conv_len::UInt
    bl_kern::Ptr{Cvoid}
    bl_wtab::Ptr{Cvoid}
    P1::Ptr{gr_dft_pre_struct}
    P2::Ptr{gr_dft_pre_struct}
    threads::Ptr{Cint}
    num_threads::Int
    serial_block::Int
    nfixed_root_err::Cdouble
    bl_shifted::Cint

    global _gr_dft_pre_struct() = new()
end

"""
    gr_dft_acb_pre_struct(len::Integer; prec::Integer = _current_precision())

Precomputed plan for discrete Fourier transforms of length `len` on
`acb` at precision `prec`.

The plan is created by Flint, which also owns the memory it points to.
For this reason the fields should be considered opaque, only `n` and
`prec` are read directly.

See [`AcbFFTPlan`](@ref) for the high level interface.
"""
mutable struct gr_dft_acb_pre_struct
    n::Int
    prec::Int
    which::Cint
    nl::Int
    p1e::Int
    in_mag::Float64
    errulps::Float64
    rctx::NTuple{sizeof(gr_ctx_struct),UInt8} # gr_ctx_struct
    cctx::NTuple{sizeof(gr_ctx_struct),UInt8} # gr_ctx_struct
    P::NTuple{sizeof(gr_dft_pre_struct),UInt8} # gr_dft_pre_struct

    function gr_dft_acb_pre_struct(len::Integer; prec::Integer = _current_precision())
        res = new()
        flag = @ccall libflint.gr_dft_acb_precomp_init(
            res::Ref{gr_dft_acb_pre_struct},
            len::Int,
            prec::Int,
        )::Cint
        gr_handle_flag(flag)
        finalizer(res) do Q
            @ccall libflint.gr_dft_acb_precomp_clear(Q::Ref{gr_dft_acb_pre_struct})::Cvoid
        end
        return res
    end
end

function Base.deepcopy_internal(x::gr_dft_acb_pre_struct, stackdict::IdDict)
    haskey(stackdict, x) && return stackdict[x]
    y = gr_dft_acb_pre_struct(x.n; prec = x.prec)
    stackdict[x] = y
    return y
end
