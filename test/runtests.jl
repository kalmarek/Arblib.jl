using Arblib, Test

@testset "Arblib" begin
    @test isa(Arb(π), Arb)
end

@testset "setprecision" begin
    x = Arb("0.1")
    @test precision(x) == 256
    @test precision(Arb) == 256
    @test string(x) == "[0.1000000000000000000000000000000000000000000000000000000000000000000000000000 +/- 1.95e-78]"

    setprecision(Arb, 64)
    @test precision(x) == 256
    @test precision(Arb) == 64
    y = Arb("0.1")
    @test precision(y) == 64
    @test string(y) == "[0.100000000000000000 +/- 1.22e-20]"

    setprecision(Arb, 256)
end

@testset "Examples" begin
    @testset "Naive sin" begin
        function sin_naive!(res, x)
            s, t, u = zero(x), zero(x), zero(x)
            tol = one(x)
            Arblib.mul_2exp!(tol, tol, -precision(tol))
            # @show tol
            k = 0
            while true
                Arblib.pow!(t, x, 2k + 1)
                Arblib.fac!(u, UInt(2k + 1))
                Arblib.div!(t, t, u)
                Arblib.abs!(u, t)

                if u ≤ tol
                    # @show u
                    Arblib.add_error!(s, u)
                    break
                end
                if iseven(k)
                    Arblib.add!(s, s, t)
                else
                    Arblib.sub!(s, s, t)
                end
                k += 1
            end
            Arblib.set!(res, s)
        end

        @test let
            str = ""
            prec = 64
            while true
                x = Arb("2016.1"; prec = prec)
                y = zero(x)
                y = sin_naive!(y, x)
                str *= sprint(print, "Using $(lpad(prec, 5)) bits, sin(x) = ")
                str *= sprint(println, Arblib.string_nice(y, 10))
                y < zero(y) && break
                prec *= 2
            end
            str
        end == """
        Using    64 bits, sin(x) = [+/- 2.67e+859]
        Using   128 bits, sin(x) = [+/- 1.30e+840]
        Using   256 bits, sin(x) = [+/- 3.60e+801]
        Using   512 bits, sin(x) = [+/- 3.01e+724]
        Using  1024 bits, sin(x) = [+/- 2.18e+570]
        Using  2048 bits, sin(x) = [+/- 1.22e+262]
        Using  4096 bits, sin(x) = [-0.7190842207 +/- 1.20e-11]
        """
    end
end
