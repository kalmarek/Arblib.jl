"""
    fmpz_struct()

Low level wrapper of `fmpz_t`. Not part of the Arblib interface but
only used internally by a few methods for conversion from `fmpz_t` to
`BigInt`.
"""
mutable struct fmpz_struct
    d::Int

    function fmpz_struct()
        z = new()
        ccall(@libflint(fmpz_init), Nothing, (Ref{fmpz_struct},), z)
        finalizer(fmpz_clear!, z)
        return z
    end
end

fmpz_clear!(x::fmpz_struct) = ccall(@libflint(fmpz_clear), Nothing, (Ref{fmpz_struct},), x)

function Base.BigInt(x::fmpz_struct)
    res = BigInt()
    ccall(@libflint(fmpz_get_mpz), Nothing, (Ref{BigInt}, Ref{fmpz_struct}), res, x)
    return res
end
