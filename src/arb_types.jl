"""
    mag_struct
"""
mutable struct mag_struct
    exponent::UInt       # fmpz
    mantissa::UInt       # mp_limb_t

    function mag_struct()
        res = new()
        init!(res)
        finalizer(clear!, res)
        return res
    end

    # Argument type should be MagLike but that is not defined yet
    function mag_struct(x::Union{mag_struct,Ptr{mag_struct}})
        res = new()
        init_set!(res, x)
        finalizer(clear!, res)
        return res
    end
end

"""
    arf_struct
"""
mutable struct arf_struct
    exponent::UInt      # fmpz
    size::UInt          # mp_size_t
    mantissa1::UInt     # mantissa_struct of length 128
    mantissa2::UInt

    function arf_struct()
        res = new()
        init!(res)
        finalizer(clear!, res)
        return res
    end

    function arf_struct(x::Union{UInt,Int})
        res = new()
        init_set!(res, x)
        finalizer(clear!, res)
        return res
    end
end

"""
    acf_struct
"""
mutable struct acf_struct
    # ┌ arf_struct (real part)
    exponent_r::UInt      # │ fmpz
    size_r::UInt          # │ mp_size_t
    mantissa1_r::UInt     # │ mantissa_struct of length 128
    mantissa2_r::UInt     # │
    # └
    # ┌ arf_struct (imaginary part)
    exponent_i::UInt      # │ fmpz
    size_i::UInt          # │ mp_size_t
    mantissa1_i::UInt     # │ mantissa_struct of length 128
    mantissa2_i::UInt     # │
    # └

    function acf_struct()
        res = new()
        init!(res)
        finalizer(clear!, res)
        return res
    end
end

"""
    arb_struct
"""
mutable struct arb_struct
    # ┌ arf_struct (midpoint)
    exponent::UInt      # │ fmpz
    size::UInt          # │ mp_size_t
    mantissa1::UInt     # │ mantissa_struct of length 128
    mantissa2::UInt     # │
    # └
    # ┌ mag_struct (radius)
    exponent_mag::UInt  # │ fmpz
    mantissa_mag::UInt  # │ mp_limb_t
    # └

    function arb_struct()
        res = new()
        init!(res)
        finalizer(clear!, res)
        return res
    end
end

"""
    acb_struct
"""
mutable struct acb_struct
    # ┌ arb_struct (real)
    exponent_r::UInt      # │ fmpz
    size_r::UInt          # │ mp_size_t
    mantissa1_r::UInt     # │ mantissa_struct of length 128
    mantissa2_r::UInt     # │
    exp_mag_r::Int        # │ fmpz
    mantissa_mag_r::UInt  # │ mp_limb_t
    # └
    # ┌ arb_struct (imag)
    exponent_i::Int       # │ fmpz
    size_i::UInt          # │ mp_size_t
    mantissa1_i::UInt     # │ mantissa_struct of length 128
    mantissa2_i::UInt     # │
    exp_mag_i::Int        # │ fmpz
    mantissa_mag_i::UInt  # │ mp_limb_t
    # └
    function acb_struct()
        res = new()
        init!(res)
        finalizer(clear!, res)
        return res
    end
end

"""
    arb_vec_struct
"""
mutable struct arb_vec_struct
    entries::Ptr{arb_struct}
    n::Int

    function arb_vec_struct(n::Integer)
        v = new(ccall(@libflint(_arb_vec_init), Ptr{arb_struct}, (Int,), n), n)
        finalizer(clear!, v)
        return v
    end
end

"""
    acb_vec_struct
"""
mutable struct acb_vec_struct
    entries::Ptr{acb_struct}
    n::Int

    function acb_vec_struct(n::Integer)
        v = new(ccall(@libflint(_acb_vec_init), Ptr{acb_struct}, (Int,), n), n)
        finalizer(clear!, v)
        return v
    end
end

"""
    arb_poly_struct
"""
mutable struct arb_poly_struct
    coeffs::Ptr{arb_struct}
    alloc::Int
    length::Int

    function arb_poly_struct()
        poly = new()
        init!(poly)
        finalizer(clear!, poly)
        return poly
    end
end

"""
    acb_poly_struct
"""
mutable struct acb_poly_struct
    coeffs::Ptr{acb_struct}
    alloc::Int
    length::Int

    function acb_poly_struct()
        poly = new()
        init!(poly)
        finalizer(clear!, poly)
        return poly
    end
end

"""
    arb_mat_struct
"""
mutable struct arb_mat_struct
    entries::Ptr{arb_struct}
    r::Int
    c::Int
    rows::Ptr{Ptr{arb_struct}}

    function arb_mat_struct(r::Integer, c::Integer)
        A = new()
        init!(A, r, c)
        finalizer(clear!, A)
        return A
    end
end

"""
    acb_mat_struct
"""
mutable struct acb_mat_struct
    entries::Ptr{acb_struct}
    r::Int
    c::Int
    rows::Ptr{Ptr{acb_struct}}

    function acb_mat_struct(r::Integer, c::Integer)
        A = new()
        init!(A, r, c)
        finalizer(clear!, A)
        return A
    end
end

const ArbStructTypes = Union{
    mag_struct,
    arf_struct,
    acf_struct,
    arb_struct,
    acb_struct,
    arb_vec_struct,
    acb_vec_struct,
    arb_poly_struct,
    acb_poly_struct,
    arb_mat_struct,
    acb_mat_struct,
}

function Base.deepcopy_internal(x::T, stackdict::IdDict) where {T<:ArbStructTypes}
    haskey(stackdict, x) && return stackdict[x]
    y = set!(T(), x)
    stackdict[x] = y
    return y
end

function Base.deepcopy_internal(
    x::T,
    stackdict::IdDict,
) where {T<:Union{arb_vec_struct,acb_vec_struct}}
    haskey(stackdict, x) && return stackdict[x]
    y = set!(T(x.n), x, x.n)
    stackdict[x] = y
    return y
end

function Base.deepcopy_internal(
    x::T,
    stackdict::IdDict,
) where {T<:Union{arb_mat_struct,acb_mat_struct}}
    haskey(stackdict, x) && return stackdict[x]
    y = set!(T(x.r, x.c), x)
    stackdict[x] = y
    return y
end

"""
    calc_integrate_opt_struct
"""
mutable struct calc_integrate_opt_struct
    deg_limit::Int
    eval_limit::Int
    depth_limit::Int
    use_heap::Cint
    verbose::Cint

    function calc_integrate_opt_struct(
        deg_limit::Integer,
        eval_limit::Integer,
        depth_limit::Integer,
        use_heap::Integer = 0,
        verbose::Integer = 0,
    )
        return new(deg_limit, eval_limit, depth_limit, use_heap, verbose)
    end

    function calc_integrate_opt_struct()
        opts = new()
        ccall(
            @libflint(acb_calc_integrate_opt_init),
            Cvoid,
            (Ref{calc_integrate_opt_struct},),
            opts,
        )
        return opts
    end
end
