digits_prec(prec::Integer) = floor(Int, prec * log(2) / log(10))

function Base.string(x::Arb)
    n = digits_prec(x.prec)
    s = ccall(@libarb(arb_get_str), Cstring, (Ref{Arb}, Int), x, n)
    unsafe_string(s)
end

# Not working, where is c stdout going to???
# function printn(x::Arb, n::Int, e::Int)
#     ccall(@libarb(arb_printn), Cvoid, (Ref{Arb}, Int, Int), x, n, e)
# end

Base.show(io::IO, x::Arb) = print(io, string(x))

@libcall arb_mul_2exp_si 2
@libcall arb_one 1
@libcall arb_pow_ui 2 prec=true
@libcall arb_fac_ui 1
@libcall arb_div 3 prec=true
@libcall arb_abs 2 prec=true
@libcall arb_add_error 2
@libcall arb_add 3 prec=true
@libcall arb_sub 3 prec=true

for (arb_pred, pred) in [
    (:arb_eq, :(==)),
    (:arb_ne, :(!=)),
    (:arb_lt, :(<)),
    (:arb_le, :(<=)),
    (:arb_gt, :(>)),
    (:arb_ge, :(>=)),
]
    @eval begin
        function Base.$pred(x::Arb, y::Arb)
            ccall(@libarb($arb_pred), Bool, (Ref{Arb}, Ref{Arb}), x, y)
        end
    end
end
