# TODO: How to handle scaled (or in some other way simply modified)
# version not implemented by Arb? Should we just make a naive
# implementation? The user might assume that they are optimized for
# the scaled version, on the other hand the user will always get a
# bound on the error so knows if more precision is needed. Discuss
# with the developers of SpecialFunctions?

# TODO: Which input to take precision from?

# TODO: Should we handle promotion in any way? Would be better if
# SpecialFunctions could handle this directly.

# TODO: Some (which?) Arb functions are more general than those in
# SpecialFunctions. How should we handle that?

# TODO: I have not checked that the branch cuts are the same for
# SpecialFunctions and Arb, I believe in most cases they are.

# TODO: Should we add documentation for the methods which are not
# identical to those in SpecialFunctions (which are these?)? Should we
# just refer to Arbs documentation?

##
## Gamma Function
##

SpecialFunctions.gamma(z::Union{ArbOrRef,AcbOrRef}) = gamma!(zero(z), z)

SpecialFunctions.digamma(x::Union{ArbOrRef,AcbOrRef}) = digamma!(zero(x), x)

#SpecialFunctions.invdigamma(x)
# Not implemented by Arb

SpecialFunctions.trigamma(x::AcbOrRef) = polygamma(Acb(3, prec = precision(x)), x)

SpecialFunctions.polygamma(s::AcbOrRef, x::AcbOrRef) = polygamma!(zero(x), s, x)

function SpecialFunctions.gamma_inc(a::ArbOrRef, x::ArbOrRef)
    Γ = hypgeom_gamma_upper!(zero(x), a, x, 1)
    γ = 1 - Γ
    return (γ, Γ)
end
function SpecialFunctions.gamma_inc(a::AcbOrRef, x::AcbOrRef)
    Γ = hypgeom_gamma_upper!(zero(x), a, x, 1)
    γ = 1 - Γ
    return (γ, Γ)
end

#gamma_inc_inv(a, p, q)
# Not implemented by Arb

function SpecialFunctions.beta_inc(a::ArbOrRef, b::ArbOrRef, x::ArbOrRef)
    β = hypgeom_beta_lower!(zero(x), a, b, x, 1)
    B = 1 - β
    return (β, B)
end
function SpecialFunctions.beta_inc(a::AcbOrRef, b::AcbOrRef, x::AcbOrRef)
    β = hypgeom_beta_lower!(zero(x), a, b, x, 1)
    B = 1 - β
    return (β, B)
end

#loggamma(x)
SpecialFunctions.loggamma(x::Union{ArbOrRef,AcbOrRef}) = lgamma!(zero(x), x)

#logabsgamma(x)
# Not implemented by Arb

#logfactorial(x)
# Only relevant for integers, which doesn't apply to Arblib

#beta(x,y)
# Not implemented directly by Arb, could use beta_inc or gamma to implement it?

#logbeta(x,y)
#Not implemented by Arb

#logabsbeta(x,y)
#Not implemented by Arb

#logabsbinomial(x,y)
#Not implemented by Arb

##
## Trigonometric Integrals
##

# The version when ν is not specified could be defined directly, but
# it would likely be better if it was defined in SpecialFunctions
# directly.
SpecialFunctions.expint(ν::ArbOrRef, x::ArbOrRef) = hypgeom_expint!(zero(x), ν, x)
SpecialFunctions.expint(ν::AcbOrRef, x::AcbOrRef) = hypgeom_expint!(zero(x), ν, x)

SpecialFunctions.expinti(x::Union{ArbOrRef,AcbOrRef}) = hypgeom_ei!(zero(x), x)

SpecialFunctions.sinint(x::Union{ArbOrRef,AcbOrRef}) = hypgeom!(zero(x), x)

SpecialFunctions.cosint(x::Union{ArbOrRef,AcbOrRef}) = hypgeom_ci!(zero(x), x)

##
## Error Functions, Dawson’s and Fresnel Integrals
##

#SpecialFunctions.erf(x)
SpecialFunctions.erf(x::Union{ArbOrRef,AcbOrRef}) = hypgeom_erf!(zero(x), x)

#SpecialFunctions.erf(x,y)
#Not implemented by Arb

#SpecialFunctions.erfc(x)
SpecialFunctions.erfc(x::Union{ArbOrRef,AcbOrRef}) = hypgeom_erfc!(zero(x), x)

#SpecialFunctions.erfcinv(x)
#Not implemented by Arb

#SpecialFunctions.erfcx(x)
#Not implemented by Arb

#SpecialFunctions.logerfc(x)
#Not implemented by Arb

#SpecialFunctions.logerfcx(x)
#Not implemented by Arb

#SpecialFunctions.erfi(x)
#Not implemented by Arb

#SpecialFunctions.erfinv(x)
#Not implemented by Arb

#SpecialFunctions.dawson(x)
#Not implemented by Arb

##
## Airy and Related Functions
##

#SpecialFunctions.airyai(z)
# TODO: If we could pass NULL for the three unused values we could
# speed up the computation.
function SpecialFunctions.airyai(z::Union{ArbOrRef,AcbOrRef})
    ai = zero(z)
    hypgeom_airy!(ai, zero(z), zero(z), zero(z), z)
    return ai
end

#SpecialFunctions.airyaiprime(z)
# TODO: If we could pass NULL for the three unused values we could
# speed up the computation.
function SpecialFunctions.airyaiprime(z::Union{ArbOrRef,AcbOrRef})
    ai_prime = zero(z)
    hypgeom_airy!(zero(z), ai_prime, zero(z), zero(z), z)
    return ai_prime
end

#SpecialFunctions.airybi(z)
# TODO: If we could pass NULL for the three unused values we could
# speed up the computation.
function SpecialFunctions.airybi(z::Union{ArbOrRef,AcbOrRef})
    bi = zero(z)
    hypgeom_airy!(zero(z), zero(z), bi, zero(z), z)
    return bi
end

#SpecialFunctions.airybiprime(z)
# TODO: If we could pass NULL for the three unused values we could
# speed up the computation.
function SpecialFunctions.airybiprime(z::Union{ArbOrRef,AcbOrRef})
    bi_prime = zero(z)
    hypgeom_airy!(zero(z), zero(z), zero(z), bi_prime, z)
    return bi_prime
end

#SpecialFunctions.airyaix(z)
#Not implemented by Arb

#SpecialFunctions.airyaiprimex(z)
#Not implemented by Arb

#SpecialFunctions.airybix(z)
#Not implemented by Arb

#SpecialFunctions.airybiprimex(z)
#Not implemented by Arb

##
## Bessel Functions
##

#SpecialFunctions.besselj(nu, z)
SpecialFunctions.besselj(ν::ArbOrRef, z::ArbOrRef) = hypgeom_bessel_j!(zero(z), ν, z)
SpecialFunctions.besselj(ν::AcbOrRef, z::AcbOrRef) = hypgeom_bessel_j!(zero(z), ν, z)

#SpecialFunctions.besselj0(z)
SpecialFunctions.besselj0(z::Union{ArbOrRef,AcbOrRef}) =
    hypgeom_bessel_j!(zero(z), zero(z), z)

#SpecialFunctions.besselj1(z)
SpecialFunctions.besselj1(z::Union{ArbOrRef,AcbOrRef}) =
    hypgeom_bessel_j!(zero(z), one(z), z)

#SpecialFunctions.besseljx(nu,z)
# Arb doesn't implement a scaled version

#SpecialFunctions.sphericalbesselj(nu,z)
# The general method implemented by SpecialFunctions is not completely
# rigorous since it makes a cutoff for small values
SpecialFunctions.sphericalbesselj(ν::ArbOrRef, x::ArbOrRef) =
    sqrt(π / 2x) * SpecialFunctions.besselj(ν + 1 // 2, x)

#SpecialFunctions.bessely(nu,z)
SpecialFunctions.bessely(ν::ArbOrRef, z::ArbOrRef) = hypgeom_bessel_y!(zero(z), ν, z)
SpecialFunctions.bessely(ν::AcbOrRef, z::AcbOrRef) = hypgeom_bessel_y!(zero(z), ν, z)

#SpecialFunctions.bessely0(z)
SpecialFunctions.bessely0(z::Union{ArbOrRef,AcbOrRef}) =
    hypgeom_bessel_y!(zero(z), zero(z), z)

#SpecialFunctions.bessely1(z)
SpecialFunctions.bessely1(z::Union{ArbOrRef,AcbOrRef}) =
    hypgeom_bessel_y!(zero(z), one(z), z)

#SpecialFunctions.besselyx(nu,z)
# Arb doesn't implement a scaled version

#SpecialFunctions.sphericalbessely(nu,z)

#SpecialFunctions.besselh(nu,k,z)
SpecialFunctions.besselh(ν::ArbOrRef, k::Integer, z::ArbOrRef) =
    SpecialFunctions.besselh(Acb(ν), k, Acb(z))
function SpecialFunctions.besselh(ν::AcbOrRef, k::Integer, z::AcbOrRef)
    J, Y = zero(z), zero(z)
    hypgeom_bessel_jy!(J, Y, ν, z)
    if k == 1
        return J + im * Y
    elseif k == 2
        return J - im * Y
    else
        throw(SpecialFunctions.AmosException(1)) # This is what SpecialFunctions throw
    end
end

#SpecialFunctions.hankelh1(nu,z)
# Aliased to besselh(nu, 1, z)

#SpecialFunctions.hankelh1x(nu,z)
# Aliased to besselhx(nu, 1, z)

#SpecialFunctions.hankelh2(nu,z)
# Aliased to besselh(nu, 2, z)

#SpecialFunctions.hankelh2x(nu,z)
# Aliased to besselhx(nu, 2, z)

#SpecialFunctions.besseli(nu,z)
SpecialFunctions.besseli(ν::ArbOrRef, z::ArbOrRef) = hypgeom_bessel_i!(zero(z), ν, z)
SpecialFunctions.besseli(ν::AcbOrRef, z::AcbOrRef) = hypgeom_bessel_i!(zero(z), ν, z)

#SpecialFunctions.besselix(nu,z)
# The scaling used by Arb seems to be different from that used by
# SpecialFunctions.

#SpecialFunctions.besselk(nu,z)
SpecialFunctions.besselk(ν::ArbOrRef, z::ArbOrRef) = hypgeom_bessel_k!(zero(z), ν, z)
SpecialFunctions.besselk(ν::AcbOrRef, z::AcbOrRef) = hypgeom_bessel_k!(zero(z), ν, z)

#SpecialFunctions.besselkx(nu,z)
SpecialFunctions.besselkx(ν::ArbOrRef, z::ArbOrRef) =
    hypgeom_bessel_k_scaled!(zero(z), ν, z)
SpecialFunctions.besselkx(ν::AcbOrRef, z::AcbOrRef) =
    hypgeom_bessel_k_scaled!(zero(z), ν, z)

#jinc(x)
# Aliased to 2 * besselj1(π*x) / (π*x) which works fine

##
## Elliptic Integrals
##

#SpecialFunctions.ellipk(m)
SpecialFunctions.ellipk(m::AcbOrRef) = elliptic_k!(zero(m), m)

#SpecialFunctions.ellipe(m)
SpecialFunctions.ellipe(m::AcbOrRef) = elliptic_e!(zero(m), m)

##
## Zeta and Related Functions
##

#SpecialFunctions.eta(x)
SpecialFunctions.eta(x::AcbOrRef) = dirichlet_eta!(zero(x), x)

SpecialFunctions.zeta(s::Union{ArbOrRef,AcbOrRef}) = zeta!(zero(s), s)
SpecialFunctions.zeta(s::ArbOrRef, z::ArbOrRef) = hurwitz_zeta!(zero(s), s, z)
SpecialFunctions.zeta(s::AcbOrRef, z::AcbOrRef) = hurwitz_zeta!(zero(s), s, z)
