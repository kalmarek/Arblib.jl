# The Base implementation of hash(::Real) is based on Base.decompose
# to guarantee that all numbers that compare equal are given the same
# hash. We implement Base.decompose for Mag and Arf.
function Base.decompose(x::Union{mag_struct,Ptr{mag_struct}})::Tuple{UInt,BigInt,Int}
    isinf(x) && return 1, 0, 0

    if x isa Ptr{mag_struct}
        x = unsafe_load(x)
    end

    pow = BigInt()
    ccall(@libflint(fmpz_get_mpz), Nothing, (Ref{BigInt}, Ref{UInt}), pow, x.exponent)
    pow -= 30

    return x.mantissa, pow, 1
end

function Base.decompose(x::Union{arf_struct,Ptr{arf_struct}})::Tuple{BigInt,BigInt,Int}
    isnan(x) && return 0, 0, 0
    isinf(x) && return ifelse(x < 0, -1, 1), 0, 0

    num = fmpz_struct()
    pow = fmpz_struct()
    ccall(
        @libarb(arf_get_fmpz_2exp),
        Cvoid,
        (Ref{fmpz_struct}, Ref{fmpz_struct}, Ref{arf_struct}),
        num,
        pow,
        x,
    )

    return BigInt(num), BigInt(pow), 1
end

Base.decompose(x::Union{MagOrRef,ArfOrRef}) = Base.decompose(cstruct(x))

# Hashes of structs are computed using the method for the wrapping
# type
Base.hash(x::mag_struct, h::UInt) = hash(Mag(x), h)
Base.hash(x::arf_struct, h::UInt) = hash(Arf(x), h)
Base.hash(x::arb_struct, h::UInt) = hash(Arb(x), h)
Base.hash(x::acb_struct, h::UInt) = hash(Acb(x), h)

# Hashes of Mag and Arf are computed using the Base implementation
# which used Base.decompose defined above.

function Base.hash(x::ArbLike, h::UInt)
    # If the radius is zero we compute the hash using only the
    # midpoint, so that we get identical hashes as for the
    # corresponding Arf
    if !isexact(x)
        h = hash(Arblib.radref(x), h)
    end
    return hash(Arblib.midref(x), h)
end

function Base.hash(z::AcbLike, h::UInt)
    # Same as for Complex{T}
    hash(realref(z), h ⊻ hash(imagref(z), Base.h_imag) ⊻ Base.hash_0_imag)
end
