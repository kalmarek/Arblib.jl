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

    function arf_struct(x::Union{UInt, Int})
        res = new()
        init_set!(res, x)
        finalizer(clear!, res)
        return res
    end
end

mutable struct mag_struct
    exponent::UInt       # fmpz
    mantissa::UInt       # mp_limb_t

    function mag_struct()
        res = new()
        init!(res)
        finalizer(clear!, res)
        return res
    end

    function mag_struct(x::Union{mag_struct, arf_struct})
        res = new()
        init_set!(res, x)
        finalizer(clear!, res)
        return res
    end
end

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
