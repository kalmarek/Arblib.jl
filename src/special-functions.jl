##
## Gamma Function
##

SpecialFunctions.gamma(z::Union{ArbOrRef,AcbOrRef}) = gamma!(zero(z), z)
SpecialFunctions.gamma(z::Series) = gamma_series!(zero(z), z, length(z))

SpecialFunctions.loggamma(x::Union{ArbOrRef,AcbOrRef}) = lgamma!(zero(x), x)
SpecialFunctions.loggamma(x::Series) = lgamma_series!(zero(x), x, length(x))

#SpecialFunctions.logabsgamma(x)
# Not implemented by Arb

#SpecialFunctions.logfactorial(x)
# Not relevant for Arblib, only implemented for x::Integer

SpecialFunctions.digamma(x::Union{ArbOrRef,AcbOrRef}) = digamma!(zero(x), x)
SpecialFunctions.digamma(x::Series) = digamma_series!(zero(x), x, length(x))

#SpecialFunctions.invdigamma(x)
# Not implemented by Arb

function SpecialFunctions.trigamma(x::AcbOrRef)
    res = one(x)
    return polygamma!(res, res, x)
end

SpecialFunctions.polygamma(s::AcbOrRef, x::AcbOrRef) = polygamma!(zero(x), s, x)

SpecialFunctions.gamma(a::ArbOrRef, z::ArbOrRef) =
    hypgeom_gamma_upper!(Arb(0, prec = _precision(a, z)), a, z, 0)
SpecialFunctions.gamma(a::AcbOrRef, z::AcbOrRef) =
    hypgeom_gamma_upper!(Acb(0, prec = _precision(a, z)), a, z, 0)
SpecialFunctions.gamma(a::ArbOrRef, z::ArbSeries) =
    hypgeom_gamma_upper_series!(zero(z), a, z, 0, length(z))
SpecialFunctions.gamma(a::AcbOrRef, z::AcbSeries) =
    hypgeom_gamma_upper_series!(zero(z), a, z, 0, length(z))

#loggamma(a,z)
# Not implemented by Arb

function SpecialFunctions.gamma_inc(a::ArbOrRef, x::ArbOrRef)
    Γ = hypgeom_gamma_upper!(Arb(0, prec = _precision(a, x)), a, x, 1)
    # γ = 1 - Γ
    γ = neg!(Arb(0, prec = _precision(a, x)), Γ)
    add!(γ, γ, 1)
    return (γ, Γ)
end
function SpecialFunctions.gamma_inc(a::AcbOrRef, x::AcbOrRef)
    Γ = hypgeom_gamma_upper!(Acb(0, prec = _precision(a, x)), a, x, 1)
    # γ = 1 - Γ
    γ = neg!(Acb(0, prec = _precision(a, x)), Γ)
    add!(γ, γ, 1)
    return (γ, Γ)
end
function SpecialFunctions.gamma_inc(a::ArbOrRef, x::ArbSeries)
    Γ = hypgeom_gamma_upper_series!(zero(x), a, x, 1, length(x))
    γ = 1 - Γ
    return (γ, Γ)
end
function SpecialFunctions.gamma_inc(a::AcbOrRef, x::AcbSeries)
    Γ = hypgeom_gamma_upper_series!(zero(x), a, x, 1, length(x))
    γ = 1 - Γ
    return (γ, Γ)
end

function SpecialFunctions.beta_inc(a::ArbOrRef, b::ArbOrRef, x::ArbOrRef)
    β = hypgeom_beta_lower!(Arb(prec = _precision(a, x)), a, b, x, 1)
    # Β = 1 - β
    Β = neg!(Arb(0, prec = _precision(a, x)), β)
    add!(Β, Β, 1)
    return (β, Β)
end
function SpecialFunctions.beta_inc(a::AcbOrRef, b::AcbOrRef, x::AcbOrRef)
    β = hypgeom_beta_lower!(Acb(prec = _precision(a, x)), a, b, x, 1)
    # Β = 1 - β
    Β = neg!(Acb(0, prec = _precision(a, x)), β)
    add!(Β, Β, 1)
    return (β, Β)
end
function SpecialFunctions.beta_inc(a::ArbOrRef, b::ArbOrRef, x::ArbSeries)
    β = hypgeom_beta_lower_series!(zero(x), a, b, x, 1, length(x))
    Β = 1 - β
    return (β, Β)
end
function SpecialFunctions.beta_inc(a::AcbOrRef, b::AcbOrRef, x::AcbSeries)
    β = hypgeom_beta_lower_series!(zero(x), a, b, x, 1, length(x))
    Β = 1 - β
    return (β, Β)
end

#gamma_inc_inv(a, p, q)
# Not implemented by Arb

#beta(x,y)
# Not implemented directly by Arb, could use beta_inc or gamma to implement it?

#logbeta(x,y)
#Not implemented by Arb

#logabsbeta(x,y)
#Not implemented by Arb

#logabsbinomial(x,y)
#Not implemented by Arb

##
## Exponential and Trigonometric Integrals
##

# The version when ν is not specified could be defined directly, but
# it would likely be better if it was defined in SpecialFunctions
# directly.
SpecialFunctions.expint(ν::ArbOrRef, x::ArbOrRef) =
    hypgeom_expint!(Arb(prec = _precision(ν, x)), ν, x)
SpecialFunctions.expint(ν::AcbOrRef, x::AcbOrRef) =
    hypgeom_expint!(Acb(prec = _precision(ν, x)), ν, x)
SpecialFunctions.expint(ν::ArbOrRef, x::ArbSeries) =
    hypgeom_gamma_upper_series!(zero(x), 1 - ν, x, 2, length(x))
SpecialFunctions.expint(ν::AcbOrRef, x::AcbSeries) =
    hypgeom_gamma_upper_series!(zero(x), 1 - ν, x, 2, length(x))

function SpecialFunctions.expint(x::Union{ArbOrRef,AcbOrRef})
    ν = one(x)
    return hypgeom_expint!(ν, ν, x)
end
SpecialFunctions.expint(x::Series) =
    SpecialFunctions.expint(eltype(x)(1, prec = precision(x)), x)

SpecialFunctions.expinti(x::Union{ArbOrRef,AcbOrRef}) = hypgeom_ei!(zero(x), x)
SpecialFunctions.expinti(x::Series) = hypgeom_ei_series!(zero(x), x, length(x))

#expintx(x)
# Not implemented by arb

SpecialFunctions.sinint(x::Union{ArbOrRef,AcbOrRef}) = hypgeom!(zero(x), x)
SpecialFunctions.sinint(x::Series) = hypgeom_si_series!(zero(x), x, length(x))

SpecialFunctions.cosint(x::Union{ArbOrRef,AcbOrRef}) = hypgeom_ci!(zero(x), x)
SpecialFunctions.cosint(x::Series) = hypgeom_ci_series!(zero(x), x, length(x))

##
## Error Functions, Dawson’s and Fresnel Integrals
##

SpecialFunctions.erf(x::Union{ArbOrRef,AcbOrRef}) = hypgeom_erf!(zero(x), x)
SpecialFunctions.erf(x::Series) = hypgeom_erf_series!(zero(x), x, length(x))

#SpecialFunctions.erf(x,y)
# Not implemented by Arb

SpecialFunctions.erfc(x::Union{ArbOrRef,AcbOrRef}) = hypgeom_erfc!(zero(x), x)
SpecialFunctions.erfc(x::Series) = hypgeom_erfc_series!(zero(x), x, length(x))

SpecialFunctions.erfcinv(x::ArbOrRef) = hypgeom_erfcinv!(zero(x), x)

#SpecialFunctions.erfcx(x)
# Not implemented by Arb

#SpecialFunctions.logerfc(x)
# Not implemented by Arb

#SpecialFunctions.logerfcx(x)
# Not implemented by Arb

SpecialFunctions.erfi(x::Union{ArbOrRef,AcbOrRef}) = hypgeom_erfi!(zero(x), x)
SpecialFunctions.erfi(x::Series) = hypgeom_erfi_series!(zero(x), x, length(x))

SpecialFunctions.erfinv(x::ArbOrRef) = hypgeom_erfinv!(zero(x), x)

#SpecialFunctions.dawson(x)
# Not implemented by Arb

##
## Airy and Related Functions
##

function SpecialFunctions.airyai(z::ArbOrRef)
    ai = zero(z)
    ccall(
        @libflint(arb_hypgeom_airy),
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
        @libflint(acb_hypgeom_airy),
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
function SpecialFunctions.airyai(z::ArbSeries)
    ai = zero(z)
    ccall(
        @libflint(arb_hypgeom_airy_series),
        Cvoid,
        (
            Ref{arb_poly_struct},
            Ref{Cvoid},
            Ref{Cvoid},
            Ref{Cvoid},
            Ref{arb_poly_struct},
            Int64,
            Int64,
        ),
        ai,
        C_NULL,
        C_NULL,
        C_NULL,
        z,
        length(z),
        precision(z),
    )
    return ai
end
function SpecialFunctions.airyai(z::AcbSeries)
    ai = zero(z)
    ccall(
        @libflint(acb_hypgeom_airy_series),
        Cvoid,
        (
            Ref{acb_poly_struct},
            Ref{Cvoid},
            Ref{Cvoid},
            Ref{Cvoid},
            Ref{acb_poly_struct},
            Int64,
            Int64,
        ),
        ai,
        C_NULL,
        C_NULL,
        C_NULL,
        z,
        length(z),
        precision(z),
    )
    return ai
end

function SpecialFunctions.airyaiprime(z::ArbOrRef)
    ai_prime = zero(z)
    ccall(
        @libflint(arb_hypgeom_airy),
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
        @libflint(acb_hypgeom_airy),
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
function SpecialFunctions.airyaiprime(z::ArbSeries)
    ai_prime = zero(z)
    ccall(
        @libflint(arb_hypgeom_airy_series),
        Cvoid,
        (
            Ref{Cvoid},
            Ref{arb_poly_struct},
            Ref{Cvoid},
            Ref{Cvoid},
            Ref{arb_poly_struct},
            Int64,
            Int64,
        ),
        C_NULL,
        ai_prime,
        C_NULL,
        C_NULL,
        z,
        length(z),
        precision(z),
    )
    return ai_prime
end
function SpecialFunctions.airyaiprime(z::AcbSeries)
    ai_prime = zero(z)
    ccall(
        @libflint(acb_hypgeom_airy_series),
        Cvoid,
        (
            Ref{Cvoid},
            Ref{acb_poly_struct},
            Ref{Cvoid},
            Ref{Cvoid},
            Ref{acb_poly_struct},
            Int64,
            Int64,
        ),
        C_NULL,
        ai_prime,
        C_NULL,
        C_NULL,
        z,
        length(z),
        precision(z),
    )
    return ai_prime
end

function SpecialFunctions.airybi(z::ArbOrRef)
    bi = zero(z)
    ccall(
        @libflint(arb_hypgeom_airy),
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
        @libflint(acb_hypgeom_airy),
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
function SpecialFunctions.airybi(z::ArbSeries)
    bi = zero(z)
    ccall(
        @libflint(arb_hypgeom_airy_series),
        Cvoid,
        (
            Ref{Cvoid},
            Ref{Cvoid},
            Ref{arb_poly_struct},
            Ref{Cvoid},
            Ref{arb_poly_struct},
            Int64,
            Int64,
        ),
        C_NULL,
        C_NULL,
        bi,
        C_NULL,
        z,
        length(z),
        precision(z),
    )
    return bi
end
function SpecialFunctions.airybi(z::AcbSeries)
    bi = zero(z)
    ccall(
        @libflint(acb_hypgeom_airy_series),
        Cvoid,
        (
            Ref{Cvoid},
            Ref{Cvoid},
            Ref{acb_poly_struct},
            Ref{Cvoid},
            Ref{acb_poly_struct},
            Int64,
            Int64,
        ),
        C_NULL,
        C_NULL,
        bi,
        C_NULL,
        z,
        length(z),
        precision(z),
    )
    return bi
end

function SpecialFunctions.airybiprime(z::ArbOrRef)
    bi_prime = zero(z)
    ccall(
        @libflint(arb_hypgeom_airy),
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
        @libflint(acb_hypgeom_airy),
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
function SpecialFunctions.airybiprime(z::ArbSeries)
    bi_prime = zero(z)
    ccall(
        @libflint(arb_hypgeom_airy_series),
        Cvoid,
        (
            Ref{Cvoid},
            Ref{Cvoid},
            Ref{Cvoid},
            Ref{arb_poly_struct},
            Ref{arb_poly_struct},
            Int64,
            Int64,
        ),
        C_NULL,
        C_NULL,
        C_NULL,
        bi_prime,
        z,
        length(z),
        precision(z),
    )
    return bi_prime
end
function SpecialFunctions.airybiprime(z::AcbSeries)
    bi_prime = zero(z)
    ccall(
        @libflint(acb_hypgeom_airy_series),
        Cvoid,
        (
            Ref{Cvoid},
            Ref{Cvoid},
            Ref{Cvoid},
            Ref{acb_poly_struct},
            Ref{acb_poly_struct},
            Int64,
            Int64,
        ),
        C_NULL,
        C_NULL,
        C_NULL,
        bi_prime,
        z,
        length(z),
        precision(z),
    )
    return bi_prime
end

#SpecialFunctions.airyaix(z)
# Not implemented by Arb

#SpecialFunctions.airyaiprimex(z)
# Not implemented by Arb

#SpecialFunctions.airybix(z)
# Not implemented by Arb

#SpecialFunctions.airybiprimex(z)
# Not implemented by Arb

##
## Bessel Functions
##

SpecialFunctions.besselj(ν::ArbOrRef, z::ArbOrRef) =
    hypgeom_bessel_j!(Arb(0, prec = _precision(ν, z)), ν, z)
SpecialFunctions.besselj(ν::AcbOrRef, z::AcbOrRef) =
    hypgeom_bessel_j!(Acb(0, prec = _precision(ν, z)), ν, z)

function SpecialFunctions.besselj0(z::Union{ArbOrRef,AcbOrRef})
    res = zero(z)
    return hypgeom_bessel_j!(res, res, z)
end

function SpecialFunctions.besselj1(z::Union{ArbOrRef,AcbOrRef})
    res = one(z)
    return hypgeom_bessel_j!(res, res, z)
end

#SpecialFunctions.besseljx(nu,z)
# Not implemented by Arb

#SpecialFunctions.sphericalbesselj(nu,z)
# The general method implemented by SpecialFunctions is not completely
# rigorous since it makes a cutoff for small values.
# TODO: We could check for the special case x = 0
function SpecialFunctions.sphericalbesselj(ν::ArbOrRef, x::ArbOrRef)
    # res = besselj(ν + 1 // 2, x)
    res = Arb(1 // 2, prec = _precision(ν, x))
    add!(res, res, ν)
    hypgeom_bessel_j!(res, res, x)

    # factor = sqrt(π / 2x)
    factor = Arb(π, prec = _precision(ν, x))
    div!(factor, factor, x)
    mul_2exp!(factor, factor, -1)
    sqrt!(factor, factor)

    return mul!(res, factor, res)
end

SpecialFunctions.bessely(ν::ArbOrRef, z::ArbOrRef) =
    hypgeom_bessel_y!(Arb(0, prec = _precision(ν, z)), ν, z)
SpecialFunctions.bessely(ν::AcbOrRef, z::AcbOrRef) =
    hypgeom_bessel_y!(Acb(0, prec = _precision(ν, z)), ν, z)

function SpecialFunctions.bessely0(z::Union{ArbOrRef,AcbOrRef})
    res = zero(z)
    return hypgeom_bessel_y!(res, res, z)
end

function SpecialFunctions.bessely1(z::Union{ArbOrRef,AcbOrRef})
    res = one(z)
    return hypgeom_bessel_y!(res, res, z)
end

#SpecialFunctions.besselyx(nu,z)
# Not implemented by Arb

#SpecialFunctions.sphericalbessely(nu,z)
# Aliased to √((float(T))(π)/2x) * bessely(nu + one(nu)/2, x) which works fine

SpecialFunctions.besselh(ν::ArbOrRef, k::Integer, z::ArbOrRef) =
    SpecialFunctions.besselh(Acb(ν), k, Acb(z))
function SpecialFunctions.besselh(ν::AcbOrRef, k::Integer, z::AcbOrRef)
    J, Y = Acb(prec = _precision(ν, z)), Acb(prec = _precision(ν, z))
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

#SpecialFunctions.besselhx(nu,k,z)
# Not implemented by Arb

#SpecialFunctions.hankelh1(nu,z)
# Aliased to besselh(nu, 1, z)

#SpecialFunctions.hankelh1x(nu,z)
# Aliased to besselhx(nu, 1, z)

#SpecialFunctions.hankelh2(nu,z)
# Aliased to besselh(nu, 2, z)

#SpecialFunctions.hankelh2x(nu,z)
# Aliased to besselhx(nu, 2, z)

SpecialFunctions.besseli(ν::ArbOrRef, z::ArbOrRef) =
    hypgeom_bessel_i!(Arb(prec = _precision(ν, z)), ν, z)
SpecialFunctions.besseli(ν::AcbOrRef, z::AcbOrRef) =
    hypgeom_bessel_i!(Acb(prec = _precision(ν, z)), ν, z)

#SpecialFunctions.besselix(nu,z)
# The scaling used by Arb seems to be different from that used by
# SpecialFunctions.

SpecialFunctions.besselk(ν::ArbOrRef, z::ArbOrRef) =
    hypgeom_bessel_k!(Arb(prec = _precision(ν, z)), ν, z)
SpecialFunctions.besselk(ν::AcbOrRef, z::AcbOrRef) =
    hypgeom_bessel_k!(Acb(prec = _precision(ν, z)), ν, z)

SpecialFunctions.besselkx(ν::ArbOrRef, z::ArbOrRef) =
    hypgeom_bessel_k_scaled!(Arb(prec = _precision(ν, z)), ν, z)
SpecialFunctions.besselkx(ν::AcbOrRef, z::AcbOrRef) =
    hypgeom_bessel_k_scaled!(Acb(prec = _precision(ν, z)), ν, z)

#jinc(x)
# Aliased to 2 * besselj1(π*x) / (π*x) which works fine

##
## Elliptic Integrals
##

SpecialFunctions.ellipk(m::AcbOrRef) = elliptic_k!(zero(m), m)
SpecialFunctions.ellipk(m::AcbSeries) = elliptic_k_series!(zero(m), m, length(m))

SpecialFunctions.ellipe(m::AcbOrRef) = elliptic_e!(zero(m), m)

##
## Zeta and Related Functions
##

SpecialFunctions.eta(x::AcbOrRef) = dirichlet_eta!(zero(x), x)

SpecialFunctions.zeta(s::Union{ArbOrRef,AcbOrRef}) = zeta!(zero(s), s)
SpecialFunctions.zeta(s::Series) =
    SpecialFunctions.zeta(s, eltype(s)(1, prec = precision(s)))
SpecialFunctions.zeta(s::ArbOrRef, z::ArbOrRef) =
    hurwitz_zeta!(Arb(prec = _precision(s, z)), s, z)
SpecialFunctions.zeta(s::AcbOrRef, z::AcbOrRef) =
    hurwitz_zeta!(Acb(prec = _precision(s, z)), s, z)
SpecialFunctions.zeta(s::ArbSeries, z::ArbOrRef) = zeta_series!(zero(s), s, z, 0, length(s))
SpecialFunctions.zeta(s::AcbSeries, z::AcbOrRef) = zeta_series!(zero(s), s, z, 0, length(s))
