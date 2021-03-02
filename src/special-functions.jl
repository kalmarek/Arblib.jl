##
## Gamma Function
##

SpecialFunctions.gamma(z::Union{ArbOrRef,AcbOrRef}) = gamma!(zero(z), z)

SpecialFunctions.digamma(x::Union{ArbOrRef,AcbOrRef}) = digamma!(zero(x), x)

#SpecialFunctions.invdigamma(x)
# Not implemented by Arb

function SpecialFunctions.trigamma(x::AcbOrRef)
    res = one(x)
    return polygamma!(res, res, x)
end

SpecialFunctions.polygamma(s::AcbOrRef, x::AcbOrRef) = polygamma!(zero(x), s, x)

function SpecialFunctions.gamma_inc(a::ArbOrRef, x::ArbOrRef)
    Γ = hypgeom_gamma_upper!(Arb(0, prec = _precision((a, x))), a, x, 1)
    # γ = 1 - Γ
    γ = neg!(Arb(0, prec = _precision((a, x))), Γ)
    add!(γ, γ, 1)
    return (γ, Γ)
end
function SpecialFunctions.gamma_inc(a::AcbOrRef, x::AcbOrRef)
    Γ = hypgeom_gamma_upper!(Acb(0, prec = _precision((a, x))), a, x, 1)
    # γ = 1 - Γ
    γ = neg!(Acb(0, prec = _precision((a, x))), Γ)
    add!(γ, γ, 1)
    return (γ, Γ)
end

#gamma_inc_inv(a, p, q)
# Not implemented by Arb

function SpecialFunctions.beta_inc(a::ArbOrRef, b::ArbOrRef, x::ArbOrRef)
    β = hypgeom_beta_lower!(Arb(prec = _precision((a, x))), a, b, x, 1)
    # Β = 1 - β
    Β = neg!(Arb(0, prec = _precision((a, x))), β)
    add!(Β, Β, 1)
    return (β, Β)
end
function SpecialFunctions.beta_inc(a::AcbOrRef, b::AcbOrRef, x::AcbOrRef)
    β = hypgeom_beta_lower!(Acb(prec = _precision((a, x))), a, b, x, 1)
    # Β = 1 - β
    Β = neg!(Acb(0, prec = _precision((a, x))), β)
    add!(Β, Β, 1)
    return (β, Β)
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
SpecialFunctions.expint(ν::ArbOrRef, x::ArbOrRef) =
    hypgeom_expint!(Arb(prec = _precision((ν, x))), ν, x)
SpecialFunctions.expint(ν::AcbOrRef, x::AcbOrRef) =
    hypgeom_expint!(Acb(prec = _precision((ν, x))), ν, x)

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
function SpecialFunctions.airyai(z::ArbOrRef)
    ai = zero(z)
    ccall(
        @libarb(arb_hypgeom_airy),
        Cvoid,
        (Ref{arb_struct}, Ref{Cvoid}, Ref{Cvoid}, Ref{Cvoid}, Ref{arb_struct}, Int64),
        ai,
        C_NULL,
        C_NULL,
        C_NULL,
        z,
        precision(z),
    )
    return ai
end
function SpecialFunctions.airyai(z::AcbOrRef)
    ai = zero(z)
    ccall(
        @libarb(acb_hypgeom_airy),
        Cvoid,
        (Ref{acb_struct}, Ref{Cvoid}, Ref{Cvoid}, Ref{Cvoid}, Ref{acb_struct}, Int64),
        ai,
        C_NULL,
        C_NULL,
        C_NULL,
        z,
        precision(z),
    )
    return ai
end

#SpecialFunctions.airyaiprime(z)
# TODO: If we could pass NULL for the three unused values we could
# speed up the computation.
function SpecialFunctions.airyaiprime(z::ArbOrRef)
    ai_prime = zero(z)
    ccall(
        @libarb(arb_hypgeom_airy),
        Cvoid,
        (Ref{Cvoid}, Ref{arb_struct}, Ref{Cvoid}, Ref{Cvoid}, Ref{arb_struct}, Int64),
        C_NULL,
        ai_prime,
        C_NULL,
        C_NULL,
        z,
        precision(z),
    )
    return ai_prime
end
function SpecialFunctions.airyaiprime(z::AcbOrRef)
    ai_prime = zero(z)
    ccall(
        @libarb(acb_hypgeom_airy),
        Cvoid,
        (Ref{Cvoid}, Ref{acb_struct}, Ref{Cvoid}, Ref{Cvoid}, Ref{acb_struct}, Int64),
        C_NULL,
        ai_prime,
        C_NULL,
        C_NULL,
        z,
        precision(z),
    )
    return ai_prime
end

#SpecialFunctions.airybi(z)
# TODO: If we could pass NULL for the three unused values we could
# speed up the computation.
function SpecialFunctions.airybi(z::ArbOrRef)
    bi = zero(z)
    ccall(
        @libarb(arb_hypgeom_airy),
        Cvoid,
        (Ref{Cvoid}, Ref{Cvoid}, Ref{arb_struct}, Ref{Cvoid}, Ref{arb_struct}, Int64),
        C_NULL,
        C_NULL,
        bi,
        C_NULL,
        z,
        precision(z),
    )
    return bi
end
function SpecialFunctions.airybi(z::AcbOrRef)
    bi = zero(z)
    ccall(
        @libarb(acb_hypgeom_airy),
        Cvoid,
        (Ref{Cvoid}, Ref{Cvoid}, Ref{acb_struct}, Ref{Cvoid}, Ref{acb_struct}, Int64),
        C_NULL,
        C_NULL,
        bi,
        C_NULL,
        z,
        precision(z),
    )
    return bi
end

#SpecialFunctions.airybiprime(z)
# TODO: If we could pass NULL for the three unused values we could
# speed up the computation.
function SpecialFunctions.airybiprime(z::ArbOrRef)
    bi_prime = zero(z)
    ccall(
        @libarb(arb_hypgeom_airy),
        Cvoid,
        (Ref{Cvoid}, Ref{Cvoid}, Ref{Cvoid}, Ref{arb_struct}, Ref{arb_struct}, Int64),
        C_NULL,
        C_NULL,
        C_NULL,
        bi_prime,
        z,
        precision(z),
    )
    return bi_prime
end
function SpecialFunctions.airybiprime(z::AcbOrRef)
    bi_prime = zero(z)
    ccall(
        @libarb(acb_hypgeom_airy),
        Cvoid,
        (Ref{Cvoid}, Ref{Cvoid}, Ref{Cvoid}, Ref{acb_struct}, Ref{acb_struct}, Int64),
        C_NULL,
        C_NULL,
        C_NULL,
        bi_prime,
        z,
        precision(z),
    )
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
SpecialFunctions.besselj(ν::ArbOrRef, z::ArbOrRef) =
    hypgeom_bessel_j!(Arb(0, prec = _precision((ν, z))), ν, z)
SpecialFunctions.besselj(ν::AcbOrRef, z::AcbOrRef) =
    hypgeom_bessel_j!(Acb(0, prec = _precision((ν, z))), ν, z)

#SpecialFunctions.besselj0(z)
function SpecialFunctions.besselj0(z::Union{ArbOrRef,AcbOrRef})
    res = zero(z)
    return hypgeom_bessel_j!(res, res, z)
end

#SpecialFunctions.besselj1(z)
function SpecialFunctions.besselj1(z::Union{ArbOrRef,AcbOrRef})
    res = one(z)
    return hypgeom_bessel_j!(res, res, z)
end

#SpecialFunctions.besseljx(nu,z)
# Arb doesn't implement a scaled version

#SpecialFunctions.sphericalbesselj(nu,z)
# The general method implemented by SpecialFunctions is not completely
# rigorous since it makes a cutoff for small values.
# TODO: We could check for the special case x = 0
function SpecialFunctions.sphericalbesselj(ν::ArbOrRef, x::ArbOrRef)
    # res = besselj(ν + 1 // 2, x)
    res = Arb(1 // 2, prec = _precision((ν, x)))
    add!(res, res, ν)
    hypgeom_bessel_j!(res, res, x)

    # factor = sqrt(π / 2x)
    factor = Arb(π, prec = _precision((ν, x)))
    div!(factor, factor, x)
    mul_2exp!(factor, factor, -1)
    sqrt!(factor, factor)

    return mul!(res, factor, res)
end

#SpecialFunctions.bessely(nu,z)
SpecialFunctions.bessely(ν::ArbOrRef, z::ArbOrRef) =
    hypgeom_bessel_y!(Arb(0, prec = _precision((ν, z))), ν, z)
SpecialFunctions.bessely(ν::AcbOrRef, z::AcbOrRef) =
    hypgeom_bessel_y!(Acb(0, prec = _precision((ν, z))), ν, z)

#SpecialFunctions.bessely0(z)
function SpecialFunctions.bessely0(z::Union{ArbOrRef,AcbOrRef})
    res = zero(z)
    return hypgeom_bessel_y!(res, res, z)
end

#SpecialFunctions.bessely1(z)
function SpecialFunctions.bessely1(z::Union{ArbOrRef,AcbOrRef})
    res = one(z)
    return hypgeom_bessel_y!(res, res, z)
end

#SpecialFunctions.besselyx(nu,z)
# Arb doesn't implement a scaled version

#SpecialFunctions.sphericalbessely(nu,z)
# Aliased to √((float(T))(π)/2x) * bessely(nu + one(nu)/2, x) which works fine

#SpecialFunctions.besselh(nu,k,z)
SpecialFunctions.besselh(ν::ArbOrRef, k::Integer, z::ArbOrRef) =
    SpecialFunctions.besselh(Acb(ν), k, Acb(z))
function SpecialFunctions.besselh(ν::AcbOrRef, k::Integer, z::AcbOrRef)
    J, Y = Acb(prec = _precision((ν, z))), Acb(prec = _precision((ν, z)))
    hypgeom_bessel_jy!(J, Y, ν, z)
    mul_onei!(Y, Y)
    if k == 1
        return add!(J, J, Y)
    elseif k == 2
        return sub!(J, J, Y)
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
SpecialFunctions.besseli(ν::ArbOrRef, z::ArbOrRef) =
    hypgeom_bessel_i!(Arb(prec = _precision((ν, z))), ν, z)
SpecialFunctions.besseli(ν::AcbOrRef, z::AcbOrRef) =
    hypgeom_bessel_i!(Acb(prec = _precision((ν, z))), ν, z)

#SpecialFunctions.besselix(nu,z)
# The scaling used by Arb seems to be different from that used by
# SpecialFunctions.

#SpecialFunctions.besselk(nu,z)
SpecialFunctions.besselk(ν::ArbOrRef, z::ArbOrRef) =
    hypgeom_bessel_k!(Arb(prec = _precision((ν, z))), ν, z)
SpecialFunctions.besselk(ν::AcbOrRef, z::AcbOrRef) =
    hypgeom_bessel_k!(Acb(prec = _precision((ν, z))), ν, z)

#SpecialFunctions.besselkx(nu,z)
SpecialFunctions.besselkx(ν::ArbOrRef, z::ArbOrRef) =
    hypgeom_bessel_k_scaled!(Arb(prec = _precision((ν, z))), ν, z)
SpecialFunctions.besselkx(ν::AcbOrRef, z::AcbOrRef) =
    hypgeom_bessel_k_scaled!(Acb(prec = _precision((ν, z))), ν, z)

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

#SpecialFunctions.zeta(x)
SpecialFunctions.zeta(s::Union{ArbOrRef,AcbOrRef}) = zeta!(zero(s), s)
SpecialFunctions.zeta(s::ArbOrRef, z::ArbOrRef) =
    hurwitz_zeta!(Arb(prec = _precision((s, z))), s, z)
SpecialFunctions.zeta(s::AcbOrRef, z::AcbOrRef) =
    hurwitz_zeta!(Acb(prec = _precision((s, z))), s, z)
