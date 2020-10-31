# arf_get_d and arf_get_si clash
get_d(x::ArfLike; rnd::Union{arb_rnd,RoundingMode} = RoundNearest) = get_d(x, rnd)
function get_d(x::ArfLike, rnd::Union{arb_rnd,RoundingMode})
    ccall(@libarb(arf_get_d), Float64, (Ref{arf_struct}, arb_rnd), x, rnd)
end
get_si(x::ArfLike; rnd::Union{arb_rnd,RoundingMode} = RoundNearest) = get_si(x, rnd)
function get_si(x::ArfLike, rnd::Union{arb_rnd,RoundingMode})
    ccall(@libarb(arf_get_si), Int, (Ref{arf_struct}, arb_rnd), x, rnd)
end
