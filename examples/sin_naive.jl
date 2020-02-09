using Arblib

function sin_naive!(res, x)
   s, t, u = zero(x), zero(x), zero(x)
   tol = one(x)
   Arblib.mul_2exp!(tol, tol, -tol.prec)
   @show tol
   k = 0
   while true
      Arblib.pow!(t, x, 2k + 1)
      Arblib.fac!(u, 2k + 1)
      Arblib.div!(t, t, u)
      Arblib.abs!(u, t)
      @show u tol u < tol
      if u < tol
         Arblib.add_error!(s, u)
         break
      end
      if iseven(k)
         Arblib.add!(s, s, t)
      else
         Arblib.sub!(s, s, t)
      end
      k += 1
      @show k
      if k == 30
         @show u ≤ tol
         @show u tol

         break
      end

   end
   res
end

res = zero(x)
x = Arb(big(π), 128)
sin_naive!(res, x)
