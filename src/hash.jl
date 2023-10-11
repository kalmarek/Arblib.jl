#=
The Base implementation of hash(::Real) is based on Base.decompose
to guarantee that all numbers that compare equal are given the same
hash. We implement Base.decompose for Mag and Arf.

It should return a, not necessarily canonical, decomposition of
rational values as `num*2^pow/den`. For Mag and Arf we always have den
= 1 and we hence only need to find num and pow, corresponding to the
mantissa end exponent. For Arf this is straight forward using
arf_get_fmpz_2exp. For Mag the mantissa is stored directly in the
struct as a UInt and the exponent as a fmpz.
=#
function Base.decompose(x::Union{mag_struct,Ptr{mag_struct}})::Tuple{UInt,BigInt,Int}
    Arblib.is_inf(x) && return 1, 0, 0

    if x isa Ptr{mag_struct}
        x = unsafe_load(x)
    end

    pow = BigInt()
    ccall(@libflint(fmpz_get_mpz), Nothing, (Ref{BigInt}, Ref{UInt}), pow, x.exponent)
    # There is an implicit factor 2^30 for the exponent, coming from
    # the number of bits of the mantissa
    pow -= 30

    return x.mantissa, pow, 1
end

function Base.decompose(x::Union{arf_struct,Ptr{arf_struct}})::Tuple{BigInt,BigInt,Int}
    Arblib.is_nan(x) && return 0, 0, 0
    Arblib.is_inf(x) && return ifelse(Arblib.cmp(x, 0) < 0, -1, 1), 0, 0

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
# type and then hashed together with a constant. Compare with
# Base.h_imag
if UInt === UInt64
    const h_mag = 0x5d9b5fdb71940a8e
    const h_arf = 0x9587d52d253e1dd1
    const h_arb = 0x5209056683bc3f7a
    const h_acb = 0x9ca782e3b04fab90
    const h_arb_vec = 0x25e99ee61f9a8792
    const h_acb_vec = 0x05f9e7ef121a65fe
    const h_arb_poly = 0xd821aefd7c0bb7d4
    const h_acb_poly = 0xed00c6f74947b740
    const h_arb_mat = 0x1caddefdf435e388
    const h_acb_mat = 0x68e0fd60c8bdd5d1
else
    const h_mag = 0x8fa1c5cc
    const h_arf = 0x695f4554
    const h_arb = 0x769d5541
    const h_acb = 0x5eda1191
    const h_arb_vec = 0x16f853e7
    const h_acb_vec = 0x31dc4078
    const h_arb_poly = 0x67d3910f
    const h_acb_poly = 0x55bdb518
    const h_arb_mat = 0xbe4a9fe3
    const h_acb_mat = 0x04460a47
end
Base.hash(x::mag_struct, h::UInt) = hash(Mag(x), hash(h_mag, h))
Base.hash(x::arf_struct, h::UInt) = hash(Arf(x), hash(h_arf, h))
Base.hash(x::arb_struct, h::UInt) = hash(Arb(x), hash(h_arb, h))
Base.hash(x::acb_struct, h::UInt) = hash(Acb(x), hash(h_acb, h))
Base.hash(x::arb_vec_struct, h::UInt) =
    hash(ArbVector(x, shallow = true), hash(h_arb_vec, h))
Base.hash(x::acb_vec_struct, h::UInt) =
    hash(AcbVector(x, shallow = true), hash(h_acb_vec, h))
Base.hash(x::arb_poly_struct, h::UInt) = hash(ArbPoly(x), hash(h_arb_poly, h))
Base.hash(x::acb_poly_struct, h::UInt) = hash(AcbPoly(x), hash(h_acb_poly, h))
Base.hash(x::arb_mat_struct, h::UInt) =
    hash(ArbMatrix(x, shallow = true), hash(h_arb_mat, h))
Base.hash(x::acb_mat_struct, h::UInt) =
    hash(AcbMatrix(x, shallow = true), hash(h_acb_mat, h))

# Hashes of Mag and Arf are computed using the Base implementation
# which used Base.decompose defined above.

function Base.hash(x::ArbOrRef, h::UInt)
    # If the radius is zero we compute the hash using only the
    # midpoint, so that we get identical hashes as for the
    # corresponding Arf
    if !isexact(x)
        h = hash(Arblib.radref(x), h)
    end
    return hash(Arblib.midref(x), h)
end

function Base.hash(z::AcbOrRef, h::UInt)
    # Same as for Complex{T}
    hash(realref(z), h ⊻ hash(imagref(z), Base.h_imag) ⊻ Base.hash_0_imag)
end

# Compare with Base.h_imag
if UInt === UInt64
    const h_poly = 0xfd6de1a6c0e66975
else
    const h_poly = 0xa0617887
end
# arb_poly_struct and acb_poly_struct use default hash implementation,
# this is okay since they don't implement an isequal method.
function Base.hash(p::Union{ArbPoly,AcbPoly}, h::UInt)
    h = hash(h_poly, h)
    for i = 0:degree(p)
        h = hash(ref(p, i), h)
    end
    return h
end

function Base.hash(p::Union{ArbSeries,AcbSeries}, h::UInt)
    # Conversion of Number to series gives a degree 0 series, we want
    # the hashes to match in this case
    degree(p) == 0 && return hash(ref(p, 0), h)

    hash(p.poly, hash(degree(p), h))
end

# Vectors and Matrices have an implementation in Base that works well
