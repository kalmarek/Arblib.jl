struct mag_struct
    exponent::UInt       # fmpz
    mantissa::UInt       # mp_limb_t
end

struct arf_struct
    exponent::UInt      # fmpz
    size::UInt          # mp_size_t
    mantissa1::UInt     # mantissa_struct of length 128
    mantissa2::UInt
end

struct arb_struct
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
end

struct acb_struct
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
