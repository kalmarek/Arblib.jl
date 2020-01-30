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

    function arf_struct(si::Int)
        res = new()
        ccall(@libarb(arf_init_set_si), Cvoid, (Ref{arf_struct}, Int), res, si)
        finalizer(clear!, res)
        return res
    end

    function arf_struct(ui::UInt)
        res = new()
        ccall(@libarb(arf_init_set_ui), Cvoid, (Ref{arf_struct}, Int), res, ui)
        finalizer(clear!, res)
        return res
    end

    # read-only access: arf_init_**_shallow (no heap allocation)
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
                          # ┌ arb_struct (real)
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

mutable struct mag_struct
    exponent::UInt       # fmpz
    mantissa::UInt       # mp_limb_t

    function mag_struct()
        res = new()
        init!(res)
        finalizer(clear!, res)
        return res
    end

    function mag_struct(m::mag_struct)
        res = new()
        ccall(
            @libarb(mag_init_set),
            Cvoid,
            (Ref{mag_struct}, Ref{mag_struct}),
            res,
            m,
        )
        finalizer(clear!, res)
        return res
    end

    function mag_struct(arf::arf_struct)
        res = new()
        ccall(
            @libarb(mag_init_set_arf),
            Cvoid,
            (Ref{mag_struct}, Ref{arf_struct}),
            res,
            arf,
        )
        finalizer(clear!, res)
        return res
    end
end

for prefix in (:arf, :arb, :acb, :mag)
    arbstruct = Symbol(prefix, :_struct)
    arb_init = Symbol(prefix, :_init)
    arb_clear = Symbol(prefix, :_clear)
    @eval begin
        init!(t::$arbstruct) =
            ccall(@libarb($arb_init), Cvoid, (Ref{$arbstruct},), t)
        clear!(t::$arbstruct) =
            ccall(@libarb($arb_clear), Cvoid, (Ref{$arbstruct},), t)
    end
end

struct arf_struct_ref
    exponent::UInt      # fmpz
    size::UInt          # mp_size_t
    mantissa1::UInt     # mantissa_struct of length 128
    mantissa2::UInt

    function arf_struct_ref(arf::arf_struct)
        return new(arf.exponent, arf.size, arf.mantissa1, arf.mantissa2)
    end
end

struct arb_struct_ref
    exponent::UInt      # fmpz
    size::UInt          # mp_size_t
    mantissa1::UInt     # mantissa_struct of length 128
    mantissa2::UInt
    exponent_mag::UInt  # fmpz
    mantissa_mag::UInt  #

    function arf_struct_ref(arf::arf_struct)
        return new(
            arf.exponent,
            arf.size,
            arf.mantissa1,
            arf.mantissa2,
            arf.exponent_mag,
            arf.mantissa_mag,
        )
    end
end

struct acb_struct_ref
    exponent_r::UInt
    size_r::UInt
    mantissa1_r::UInt
    mantissa2_r::UInt
    exp_mag_r::Int
    mantissa_mag_r::UInt

    exponent_i::Int
    size_i::UInt
    mantissa1_i::UInt
    mantissa2_i::UInt
    exp_mag_i::Int
    mantissa_mag_i::UInt

    function acb_struct_ref(acb::acb_struct)
        return new(
            acb.exponent_r,
            acb.size_r,
            acb.mantissa1_r,
            acb.mantissa2_r,
            acb.exponent_mag_r,
            acb.mantissa_mag_r,

            acb.exponent_i,
            acb.size_i,
            acb.mantissa1_i,
            acb.mantissa2_i,
            acb.exponent_mag_i,
            acb.mantissa_mag_i,
        )
    end
end
