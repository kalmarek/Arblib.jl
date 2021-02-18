@testset "Special Functions" begin
    @testset "Gamma Function" begin
        @test gamma(Arb(2)) ≈ gamma(2)
        @test gamma(Arb(3)) ≈ gamma(3)
        @test gamma(Acb(2 + 2im)) ≈ gamma(2 + 2im)
        @test gamma(Acb(3 + 3im)) ≈ gamma(3 + 3im)

        @test digamma(Arb(2)) ≈ digamma(2)
        @test digamma(Arb(3)) ≈ digamma(3)
        @test digamma(Acb(2 + 2im)) ≈ digamma(2 + 2im)
        @test digamma(Acb(3 + 3im)) ≈ digamma(3 + 3im)

        @test trigamma(Acb(2 + 2im)) ≈ trigamma(2 + 2im)
        @test trigamma(Acb(3 + 3im)) ≈ trigamma(3 + 3im)

        @test polygamma(Acb(2), Acb(3 + 3im)) ≈ polygamma(2, 3 + 3im)
        @test polygamma(Acb(3), Acb(4 + 4im)) ≈ polygamma(3, 4 + 4im)

        @test all(gamma_inc(Arb(2), Arb(3)) .≈ gamma_inc(2, 3))
        @test all(gamma_inc(Arb(3), Arb(4)) .≈ gamma_inc(3, 4))
        @test all(gamma_inc(Acb(2), Acb(3)) .≈ gamma_inc(2, 3))

        @test all(beta_inc(Arb(2), Arb(3), Arb(1 // 2)) .≈ beta_inc(2.0, 3.0, 0.5))
        @test all(beta_inc(Arb(3), Arb(4), Arb(1 // 4)) .≈ beta_inc(3.0, 4.0, 0.25))
        @test all(beta_inc(Acb(2), Acb(3), Acb(1 // 2)) .≈ beta_inc(2.0, 3.0, 0.5))
        @test all(beta_inc(Acb(3), Acb(4), Acb(1 // 4)) .≈ beta_inc(3.0, 4.0, 0.25))

        @test loggamma(Arb(2)) ≈ loggamma(2)
        @test loggamma(Arb(3)) ≈ loggamma(3)
        @test loggamma(Acb(2 + 2im)) ≈ loggamma(2 + 2im)
        @test loggamma(Acb(3 + 3im)) ≈ loggamma(3 + 3im)
    end

    @testset "Trigonometric Integrals" begin
        @test expint(Arb(2), Arb(3)) ≈ expint(2, 3)
        @test expint(Arb(3), Arb(4)) ≈ expint(3, 4)
        @test expint(Acb(2 + 2im), Acb(3 + 3im)) ≈ expint(2 + 2im, 3 + 3im)
        @test expint(Acb(3 + 3im), Acb(4 + 4im)) ≈ expint(3 + 3im, 4 + 4im)

        @test expinti(Arb(2)) ≈ expinti(2)
        @test expinti(Arb(3)) ≈ expinti(3)
        @test expinti(Acb(2)) ≈ expinti(2)
        @test expinti(Acb(3)) ≈ expinti(3)

        @test sinint(Arb(2)) ≈ sinint(2)
        @test sinint(Arb(3)) ≈ sinint(3)
        @test sinint(Acb(2)) ≈ sinint(2)
        @test sinint(Acb(3)) ≈ sinint(3)

        @test cosint(Arb(2)) ≈ cosint(2)
        @test cosint(Arb(3)) ≈ cosint(3)
        @test cosint(Acb(2)) ≈ cosint(2)
        @test cosint(Acb(3)) ≈ cosint(3)
    end

    @testset "Error Functions" begin
        @test erf(Arb(2)) ≈ erf(2)
        @test erf(Arb(3)) ≈ erf(3)
        @test erf(Acb(2 + 2im)) ≈ erf(2 + 2im)
        @test erf(Acb(3 + 3im)) ≈ erf(3 + 3im)

        @test erfc(Arb(2)) ≈ erfc(2)
        @test erfc(Arb(3)) ≈ erfc(3)
        @test erfc(Acb(2 + 2im)) ≈ erfc(2 + 2im)
        @test erfc(Acb(3 + 3im)) ≈ erfc(3 + 3im)
    end

    @testset "Airy Functions" begin
        @test airyai(Arb(2)) ≈ airyai(2)
        @test airyai(Arb(3)) ≈ airyai(3)
        @test airyai(Acb(2 + 2im)) ≈ airyai(2 + 2im)
        @test airyai(Acb(3 + 3im)) ≈ airyai(3 + 3im)

        @test airyaiprime(Arb(2)) ≈ airyaiprime(2)
        @test airyaiprime(Arb(3)) ≈ airyaiprime(3)
        @test airyaiprime(Acb(2 + 2im)) ≈ airyaiprime(2 + 2im)
        @test airyaiprime(Acb(3 + 3im)) ≈ airyaiprime(3 + 3im)

        @test airybi(Arb(2)) ≈ airybi(2)
        @test airybi(Arb(3)) ≈ airybi(3)
        @test airybi(Acb(2 + 2im)) ≈ airybi(2 + 2im)
        @test airybi(Acb(3 + 3im)) ≈ airybi(3 + 3im)

        @test airybiprime(Arb(2)) ≈ airybiprime(2)
        @test airybiprime(Arb(3)) ≈ airybiprime(3)
        @test airybiprime(Acb(2 + 2im)) ≈ airybiprime(2 + 2im)
        @test airybiprime(Acb(3 + 3im)) ≈ airybiprime(3 + 3im)
    end

    @testset "Bessel Functions" begin
        @test besselj(Arb(2), Arb(3)) ≈ besselj(2, 3)
        @test besselj(Arb(3), Arb(4)) ≈ besselj(3, 4)
        @test besselj(Acb(2), Acb(3 + 3im)) ≈ besselj(2, 3 + 3im)
        @test besselj(Acb(3), Acb(4 + 4im)) ≈ besselj(3, 4 + 4im)

        @test besselj0(Arb(2)) ≈ besselj0(2)
        @test besselj0(Arb(3)) ≈ besselj0(3)
        @test besselj0(Acb(2 + 2im)) ≈ besselj0(2 + 2im)
        @test besselj0(Acb(3 + 3im)) ≈ besselj0(3 + 3im)

        @test besselj1(Arb(2)) ≈ besselj1(2)
        @test besselj1(Arb(3)) ≈ besselj1(3)
        @test besselj1(Acb(2 + 2im)) ≈ besselj1(2 + 2im)
        @test besselj1(Acb(3 + 3im)) ≈ besselj1(3 + 3im)

        @test sphericalbesselj(Arb(2), Arb(3)) ≈ sphericalbesselj(2, 3)
        @test sphericalbesselj(Arb(3), Arb(4)) ≈ sphericalbesselj(3, 4)

        @test bessely(Arb(2), Arb(3)) ≈ bessely(2, 3)
        @test bessely(Arb(3), Arb(4)) ≈ bessely(3, 4)
        @test bessely(Acb(2), Acb(3 + 3im)) ≈ bessely(2, 3 + 3im)
        @test bessely(Acb(3), Acb(4 + 4im)) ≈ bessely(3, 4 + 4im)

        @test bessely0(Arb(2)) ≈ bessely0(2)
        @test bessely0(Arb(3)) ≈ bessely0(3)
        @test bessely0(Acb(2 + 2im)) ≈ bessely0(2 + 2im)
        @test bessely0(Acb(3 + 3im)) ≈ bessely0(3 + 3im)

        @test bessely1(Arb(2)) ≈ bessely1(2)
        @test bessely1(Arb(3)) ≈ bessely1(3)
        @test bessely1(Acb(2 + 2im)) ≈ bessely1(2 + 2im)
        @test bessely1(Acb(3 + 3im)) ≈ bessely1(3 + 3im)

        @test besselh(Arb(2), Arb(3)) ≈ besselh(2, 3)
        @test besselh(Arb(3), Arb(4)) ≈ besselh(3, 4)
        @test besselh(Acb(2), Acb(3)) ≈ besselh(2, 3)
        @test besselh(Acb(3), Acb(4)) ≈ besselh(3, 4)
        @test besselh(Arb(2), 1, Arb(3)) ≈ besselh(2, 1, 3)
        @test besselh(Arb(3), 1, Arb(4)) ≈ besselh(3, 1, 4)
        @test besselh(Acb(2), 1, Acb(3)) ≈ besselh(2, 1, 3)
        @test besselh(Acb(3), 1, Acb(4)) ≈ besselh(3, 1, 4)
        @test besselh(Arb(2), 2, Arb(3)) ≈ besselh(2, 2, 3)
        @test besselh(Arb(3), 2, Arb(4)) ≈ besselh(3, 2, 4)
        @test besselh(Acb(2), 2, Acb(3)) ≈ besselh(2, 2, 3)
        @test besselh(Acb(3), 2, Acb(4)) ≈ besselh(3, 2, 4)
        @test_throws SpecialFunctions.AmosException(1) besselh(Arb(2), 3, Arb(3))
        @test_throws SpecialFunctions.AmosException(1) besselh(Acb(2), 3, Acb(3))

        @test besseli(Arb(2), Arb(3)) ≈ besseli(2, 3)
        @test besseli(Arb(3), Arb(4)) ≈ besseli(3, 4)
        @test besseli(Acb(2), Acb(3 + 3im)) ≈ besseli(2, 3 + 3im)
        @test besseli(Acb(3), Acb(4 + 4im)) ≈ besseli(3, 4 + 4im)

        @test besselk(Arb(2), Arb(3)) ≈ besselk(2, 3)
        @test besselk(Arb(3), Arb(4)) ≈ besselk(3, 4)
        @test besselk(Acb(2), Acb(3 + 3im)) ≈ besselk(2, 3 + 3im)
        @test besselk(Acb(3), Acb(4 + 4im)) ≈ besselk(3, 4 + 4im)

        @test besselkx(Arb(2), Arb(3)) ≈ besselkx(2, 3)
        @test besselkx(Arb(3), Arb(4)) ≈ besselkx(3, 4)
        @test besselkx(Acb(2), Acb(3 + 3im)) ≈ besselkx(2, 3 + 3im)
        @test besselkx(Acb(3), Acb(4 + 4im)) ≈ besselkx(3, 4 + 4im)
    end

    @testset "Elliptic Integrals" begin
        @test ellipk(Acb(-1)) ≈ ellipk(-1)
        @test ellipk(Acb(-2)) ≈ ellipk(-2)

        @test ellipe(Acb(-1)) ≈ ellipe(-1)
        @test ellipe(Acb(-2)) ≈ ellipe(-2)
    end

    @testset "Zeta Functions" begin
        @test eta(Acb(2 + 2im)) ≈ eta(2 + 2im)
        @test eta(Acb(3 + 3im)) ≈ eta(3 + 3im)

        @test zeta(Arb(2)) ≈ zeta(2)
        @test zeta(Arb(3)) ≈ zeta(3)
        @test zeta(Acb(2 + 2im)) ≈ zeta(2 + 2im)
        @test zeta(Acb(3 + 3im)) ≈ zeta(3 + 3im)
        @test zeta(Arb(2), Arb(3)) ≈ zeta(2, 3)
        @test zeta(Arb(3), Arb(4)) ≈ zeta(3, 4)
        @test zeta(Acb(2 + 2im), Acb(3 + 3im)) ≈ zeta(2 + 2im, 3 + 3im)
        @test zeta(Acb(3 + 3im), Acb(4 + 4im)) ≈ zeta(3 + 3im, 4 + 4im)
    end
end
