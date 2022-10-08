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
    isinf(x) && return 1, 0, 0

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

# arb_poly_struct and acb_poly_struct use default hash implementation,
# this is okay since they don't implement an isequal method.
function Base.hash(p::Union{ArbPoly,AcbPoly}, h::UInt)
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
