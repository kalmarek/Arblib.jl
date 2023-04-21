# arf_get_d and arf_get_si clash
get_d(x::ArfLike; rnd::Union{arb_rnd,RoundingMode} = RoundNearest) = get_d(x, rnd)
function get_d(x::ArfLike, rnd::Union{arb_rnd,RoundingMode})
    ccall(@libflint(arf_get_d), Float64, (Ref{arf_struct}, arb_rnd), x, rnd)
end
get_si(x::ArfLike; rnd::Union{arb_rnd,RoundingMode} = RoundNearest) = get_si(x, rnd)
function get_si(x::ArfLike, rnd::Union{arb_rnd,RoundingMode})
    ccall(@libflint(arf_get_si), Int, (Ref{arf_struct}, arb_rnd), x, rnd)
end

# arf_mul is given using a #DEFINE which doesn't work in Julia, implement this manually
arbcall"int arf_mul_rnd_any(arf_t z, arf_t x, arf_t y, slong prec, arf_rnd_t rnd)"
mul!(
    res::ArfLike,
    x::ArfLike,
    y::ArfLike,
    prec::Integer,
    rnd::Union{arb_rnd,RoundingMode},
) = mul_rnd_any!(res, x, y, prec, rnd)
mul!(
    res::ArfLike,
    x::ArfLike,
    y::ArfLike;
    prec::Integer = precision(res),
    rnd::Union{arb_rnd,RoundingMode} = RoundNearest,
) = mul!(res, x, y, prec, rnd)
