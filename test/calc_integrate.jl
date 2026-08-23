@testset "integration" begin
    prec = 64
    a = Acb(0; prec)
    b = Acb(1; prec)

    # Test with just a plain method
    f1 = sin
    f1! = Arblib.sin!
    res1 = "[0.459697694131860282 +/- 7.22e-19]"
    @test string(Arblib.integrate(f1, a, b; prec)) == res1
    @test string(Arblib.integrate(f1, real(a), real(b); prec)) == res1
    @test string(Arblib.integrate!(f1!, Acb(; prec), a, b)) == res1
    @test string(Arblib.integrate!(f1!, Acb(; prec), real(a), real(b))) == res1

    # Test with a method that accepts precision as a keyword argument
    f2 = (x; prec) -> Arblib.sin!(Acb(), x; prec)
    f2! = Arblib.sin!
    res2 = "[0.459697694131860282 +/- 7.22e-19]"
    @test string(Arblib.integrate(f2, a, b, take_prec = true; prec)) == res2
    @test string(Arblib.integrate(f2, real(a), real(b), take_prec = true; prec)) == res2
    @test string(Arblib.integrate!(f2!, Acb(; prec), a, b, take_prec = true)) == res2
    @test string(Arblib.integrate!(f2!, Acb(; prec), real(a), real(b), take_prec = true)) ==
          res2

    # Test with a method that accepts analytic as a keyword argument
    f3 = (x; analytic) -> Arblib.real_abs!(Acb(; prec), x, analytic)
    f3! = (res, x; analytic) -> Arblib.real_abs!(res, x, analytic)
    res3 = "[0.50000000000000000 +/- 2.73e-18]"
    @test string(Arblib.integrate(f3, a, b, check_analytic = true; prec)) == res3
    @test string(Arblib.integrate(f3, real(a), real(b), check_analytic = true; prec)) ==
          res3
    @test string(Arblib.integrate!(f3!, Acb(; prec), a, b, check_analytic = true)) == res3
    @test string(
        Arblib.integrate!(f3!, Acb(; prec), real(a), real(b), check_analytic = true),
    ) == res3

    # Test with a method that accepts both precision and analytic as
    # a keyword arguments
    f4 = (x; analytic, prec) -> Arblib.real_abs!(Acb(), x, analytic; prec)
    f4! = (res, x; analytic, prec) -> Arblib.real_abs!(res, x, analytic; prec)
    res4 = "[0.50000000000000000 +/- 2.73e-18]"
    @test string(
        Arblib.integrate(f4, a, b, check_analytic = true, take_prec = true; prec),
    ) == res4
    @test string(
        Arblib.integrate(
            f4,
            real(a),
            real(b),
            check_analytic = true,
            take_prec = true;
            prec,
        ),
    ) == res4
    @test string(
        Arblib.integrate!(f4!, Acb(; prec), a, b, check_analytic = true, take_prec = true),
    ) == res4
    @test string(
        Arblib.integrate!(
            f4!,
            Acb(; prec),
            real(a),
            real(b),
            check_analytic = true,
            take_prec = true,
        ),
    ) == res4

    # Test with set tolerance
    f5 = x -> sin(exp(x))
    f5! = (res, x) -> Arblib.sin!(res, Arblib.exp!(res, x))
    res5 = "[0.8750 +/- 5.14e-5]"
    res5! = "[0.87495720 +/- 2.77e-9]"
    @test string(Arblib.integrate(f5, a, b; prec, rtol = 1e-4)) == res5
    @test string(Arblib.integrate(f5, real(a), real(b); prec, rtol = 1e-4)) == res5
    @test string(Arblib.integrate!(f5!, Acb(; prec), a, b, atol = 1e-8)) == res5!
    @test string(Arblib.integrate!(f5!, Acb(; prec), real(a), real(b), atol = 1e-8)) ==
          res5!

    # Test with calc_integrate_opt_struct
    f6 = sin
    f6! = Arblib.sin!
    res6 = "[0.459697694131860282 +/- 7.22e-19]"
    opts = Arblib.calc_integrate_opt_struct()
    @test string(Arblib.integrate(f6, a, b; prec, opts)) == res6
    @test string(Arblib.integrate(f6, real(a), real(b); prec, opts)) == res6
    @test string(Arblib.integrate!(f6!, Acb(; prec), a, b; opts)) == res6
    @test string(Arblib.integrate!(f6!, Acb(; prec), real(a), real(b); opts)) == res6

    f7 = sin
    f7! = Arblib.sin!
    res7 = "[0.46 +/- 4.34e-3]"
    opts = Arblib.calc_integrate_opt_struct(5, 500, 0, true, 0)
    warn_on_no_convergence = false
    @test string(Arblib.integrate(f7, a, b; prec, warn_on_no_convergence, opts)) == res7
    @test string(
        Arblib.integrate(f7, real(a), real(b); prec, warn_on_no_convergence, opts),
    ) == res7
    @test string(Arblib.integrate!(f7!, Acb(; prec), a, b; warn_on_no_convergence, opts)) ==
          res7
    @test string(
        Arblib.integrate!(f7!, Acb(; prec), real(a), real(b); warn_on_no_convergence, opts),
    ) == res7
end
