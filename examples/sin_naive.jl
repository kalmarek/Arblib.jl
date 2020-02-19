using Arblib

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

let prec = 1024
    x = Arb(π, prec)
    Y = sin_naive!(zero(x), x)
    y = sin_naive!(zero(x), Arb(big(π), prec))
    # @show Y
    Y, y
end

function main()
    prec = 64
    while true
        x = Arb("2016.1", prec)
        y = zero(x)
        y = sin_naive!(y, x)
        println("Using $(lpad(prec, 5)) bits, sin(x) = $y")
        y < zero(y) && break
        prec *= 2
    end
end


main()
