@testset "integration" begin
    prec = 64
    a = Acb(0, prec = prec)
    b = Acb(1, prec = prec)

    # Test with just a plain method
    f1 = sin
    f1! = Arblib.sin!
    res1 = "[0.459697694131860282 +/- 7.22e-19]"
    @test string(Arblib.integrate(f1, a, b, prec = prec)) == res1
    @test string(Arblib.integrate!(f1!, Acb(prec = prec), a, b)) == res1

    # Test with a method that accepts precision as a keyword argument
    f2 = (x; prec) -> Arblib.sin!(Acb(), x, prec = prec)
    f2! = Arblib.sin!
    res2 = "[0.459697694131860282 +/- 7.22e-19]"
    @test string(Arblib.integrate(f2, a, b, take_prec = true, prec = prec)) == res2
    @test string(Arblib.integrate!(f2!, Acb(prec = prec), a, b, take_prec = true)) == res2

    # Test with a method that accepts analytic as a keyword argument
    f3 = (x; analytic) -> Arblib.real_abs!(Acb(prec = prec), x, analytic)
    f3! = (res, x; analytic) -> Arblib.real_abs!(res, x, analytic)
    # FIXME: These are supposed to be identical but due to a bug in
    # Arb the produce slightly different results, see
    # https://github.com/kalmarek/Arblib.jl/issues/70. Once Arb is
    # updated so that they start to produce identical results this can
    # be updated and the issue closed.
    res3 = "[0.50000000000000000 +/- 2.68e-18]"
    res3! = "[0.50000000000000000 +/- 2.73e-18]"
    @test string(Arblib.integrate(f3, a, b, check_analytic = true, prec = prec)) == res3
    @test_broken string(Arblib.integrate!(
        f3!,
        Acb(prec = prec),
        a,
        b,
        check_analytic = true,
    )) == res3
    @test string(Arblib.integrate!(f3!, Acb(prec = prec), a, b, check_analytic = true)) ==
          res3!

    # Test with a method that accepts both precision and analytic as
    # a keyword arguments
    f4 = (x; analytic, prec) -> Arblib.real_abs!(Acb(), x, analytic, prec = prec)
    f4! = (res, x; analytic, prec) -> Arblib.real_abs!(res, x, analytic, prec = prec)
    # FIXME: See above
    res4 = "[0.50000000000000000 +/- 2.68e-18]"
    res4! = "[0.50000000000000000 +/- 2.73e-18]"
    @test string(Arblib.integrate(
        f4,
        a,
        b,
        check_analytic = true,
        take_prec = true,
        prec = prec,
    )) == res4
    @test string(Arblib.integrate!(
        f4!,
        Acb(prec = prec),
        a,
        b,
        check_analytic = true,
        take_prec = true,
    )) == res4!

    # Test with set tolerance
    f5 = x -> sin(exp(x))
    f5! = (res, x) -> Arblib.sin!(res, Arblib.exp!(res, x))
    res5 = "[0.8750 +/- 5.14e-5]"
    res5! = "[0.87495720 +/- 2.77e-9]"
    @test string(Arblib.integrate(f5, a, b, prec = prec, rtol = 1e-4)) == res5
    @test string(Arblib.integrate!(f5!, Acb(prec = prec), a, b, atol = 1e-8)) == res5!
end
