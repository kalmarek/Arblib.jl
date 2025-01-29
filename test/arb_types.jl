@testset "arb_types" begin
    mag = Arblib.mag_struct()
    arf = Arblib.arf_struct()
    acf = Arblib.acf_struct()
    arb = Arblib.arb_struct()
    acb = Arblib.acb_struct()

    prec = 256
    for x in (arf, acf, arb, acb)
        @test precision(x) == prec
        @test precision(Ptr{typeof(x)}()) == prec
        @test precision(typeof(x)) == prec
        @test precision(Ptr{typeof(x)}) == prec
    end

    @testset "deepcopy" begin
        for x in [
            Arblib.mag_struct(),
            Arblib.arf_struct(),
            Arblib.acf_struct(),
            Arblib.arb_struct(),
            Arblib.acb_struct(),
            Arblib.arb_poly_struct(),
            Arblib.acb_poly_struct(),
            Arblib.arb_mat_struct(2, 3),
            Arblib.acb_mat_struct(2, 3),
        ]
            @test !iszero(Arblib.equal(x, deepcopy(x)))
        end

        # No Arblib.equal method for vectors, just check that the
        # length is correct.
        x = Arblib.arb_vec_struct(2)
        @test deepcopy(x).n == x.n
        x = Arblib.acb_vec_struct(2), @test deepcopy(x).n == x.n

        # Check that changing the deepcopy doesn't change the
        # original. We need to make sure to use large enough values so
        # that the data doesn't get inlined in the struct.
        x1 = Arblib.set!(Arblib.arb_struct(), π)
        x2 = Arblib.set!(Arblib.arb_struct(), π)
        y = deepcopy(x1)
        Arblib.set!(y, ℯ)
        @test isequal(x1, x2)

        # Check so that x is only copied once.
        x = Arblib.set!(Arblib.arb_struct(), π)
        v = [x, x]
        w = deepcopy(v)
        Arblib.set!(w[1], ℯ)
        @test isequal(x, Arblib.set!(Arblib.arb_struct(), π))
        @test isequal(w[1], w[2])
    end
end
