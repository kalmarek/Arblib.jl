@testset "Examples" begin
    @testset "Naive sin" begin
        function sin_naive!(res, x)
            s, t, u = zero(x), zero(x), zero(x)
            tol = one(x)
            Arblib.mul_2exp!(tol, tol, -precision(tol))
            # @show tol
            k = 0
            while true
                Arblib.pow!(t, x, UInt(2k + 1))
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
            return res
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

    @testset "Logistic" begin
        """
            logistic(n[; x0 = 0.5, r = 3.75, digits = 10])
        Compute the nth iterate of the logistic map `x_{n + 1} = r x_n (1 -
        x_n).
        """
        function logistic(n; x0 = Arb(0.5), r = Arb(3.75), digits = 10)
            goalprec = digits*3.3219280948873623 + 3

            prec = 64
            if typeof(x0) == String
                x = Arb(x0, prec = prec)
            else
                x = Arb(prec = prec)
            end

            t = zero(x)
            while true
                if typeof(x0) == String
                    x = Arb(x0, prec = prec)
                else
                    Arblib.set!(x, x0)
                end

                for i in 1:n
                    Arblib.sub!(t, x, 1)
                    Arblib.neg!(t, t)
                    Arblib.mul!(x, x, t)
                    Arblib.mul!(x, x, r)

                    if Arblib.rel_accuracy_bits(x) < goalprec
                        break
                    end
                end

                if Arblib.rel_accuracy_bits(x) >= goalprec
                    break
                end

                prec *= 2
                x = setprecision(x, prec, shallow = true)
                r = setprecision(r, prec, shallow = true)
                t = setprecision(t, prec, shallow = true)
            end

            return x
        end

        @test string(logistic(10, digits = 10)) == "[0.645367290830930 +/- 3.45e-16]"
        @test string(logistic(10, digits = 20)) == "[0.64536729083093027156146131423635101 +/- 5.18e-36]"
    end
end
