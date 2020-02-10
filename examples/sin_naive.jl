using Arblib

function sin_naive!(res, x)
   s, t, u = zero(x), zero(x), zero(x)
   tol = one(x)
   Arblib.mul_2exp!(tol, tol, -tol.prec)
   k = 0
   while true
      Arblib.pow!(t, x, 2k + 1)
      Arblib.fac!(u, 2k + 1)
      Arblib.div!(t, t, u)
      Arblib.abs!(u, t)
      if u ≤ tol
         @show u
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

x = Arb(big(π), 1024)
@time sin_naive!(res, x)


# arb_t x, y;
# slong prec;
# arb_init(x); arb_init(y);
#
# for (prec = 64; ; prec *= 2)
# {
#     arb_set_str(x, "2016.1", prec);
#     arb_sin_naive(y, x, prec);
#     printf("Using %5ld bits, sin(x) = ", prec);
#     arb_printn(y, 10, 0); printf("\n");
#     if (!arb_contains_zero(y))  /* stopping condition */
#         break;
# }
#
# arb_clear(x); arb_clear(y);
#

x = Arb("2016.1", 64)
y = sin_naive!(zero(x), x)
