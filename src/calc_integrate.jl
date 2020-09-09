function _acb_calc_func!(
    out::Ptr{acb_struct},
    inp::Ptr{acb_struct},
    param::Ptr{Cvoid}, # pointer to the actual function
    order::Cint,
    prec::Cint,
)
    @assert iszero(order) || isone(order) # ← we'd need to verify holomorphicity
    # x = Acb(unsafe_load(inp), prec=prec)
    x = inp
    f = unsafe_pointer_to_objref(param)
    # @debug "Evaluating at" x
    f(out, x, prec = prec)
    return zero(Cint)
end

_acb_calc_cfunc!() = @cfunction(
    _acb_calc_func!,
    Cint,
    (Ptr{acb_struct}, Ptr{acb_struct}, Ptr{Cvoid}, Cint, Cint)
)

function calc_integrate!(
    res::AcbLike,
    acb_calc_cfunc::Ptr{Cvoid}, # cfunction
    param,
    a::AcbLike,
    b::AcbLike,
    rel_goal::Clong,
    abs_tol::MagLike,
    options::calc_integrate_opt_struct,
    prec::Clong,
)
    @info "ccalling in calc_integrate!"
    return ccall(
        @libarb(acb_calc_integrate),
        Cint,
        (
            Ref{acb_struct},
            Ptr{Cvoid},
            Any,
            Ref{acb_struct},
            Ref{acb_struct},
            Clong,
            Ref{mag_struct},
            Ref{calc_integrate_opt_struct},
            Clong,
        ),
        res,
        acb_calc_cfunc,
        param,
        a,
        b,
        rel_goal,
        abs_tol,
        options,
        prec,
    )
end

function calc_integrate!(
    res::AcbLike,
    acb_calc_func,
    param,
    a::AcbLike,
    b::AcbLike,
    rel_goal::Clong,
    abs_tol::MagLike,
    options::Ptr{Cvoid},
    prec::Clong,
)
    return ccall(
        @libarb(acb_calc_integrate),
        Cint,
        (
            Ref{acb_struct},
            Ptr{Cvoid},
            Any,
            Ref{acb_struct},
            Ref{acb_struct},
            Clong,
            Ref{mag_struct},
            Ptr{Cvoid},
            Clong,
        ),
        res,
        acb_calc_func,
        param,
        a,
        b,
        rel_goal,
        abs_tol,
        options,
        prec,
    )
end


function integrate!(
    res::AcbLike,
    f,
    a::AcbLike,
    b::AcbLike;
    prec = max(_precision(a), _precision(b)),
    rel_goal = prec,
    abs_tol::MagLike = set_ui_2exp!(Arblib.Mag(), one(UInt), -prec),
    opts::Union{Ptr{Cvoid},calc_integrate_opt_struct} = C_NULL,
)

    return calc_integrate!(
        res,
        _acb_calc_cfunc!(),
        f,
        a,
        b,
        rel_goal,
        abs_tol,
        opts, # passing C_NULL uses the default options
        prec,
    )
end

"""
    integrate(f, a::Number, b::Number;
        prec = max(precision(a), precision(b)),
        rtol=0.0,
        atol=2.0^-prec,
        opts::Union{acb_calc_integrate_opt_struct, Ptr{Cvoid}} = C_NULL)
Computes a rigorous enclosure of the integral
∫ₐᵇ f(t) dt
where `f` is any (holomorphic) julia function. From Arb docs:
> The integral follows a straight-line path between the complex numbers `a` and
> `b`. For finite results, `a`, `b` must be finite and `f` must be bounded on
> the path of integration. To compute improper integrals, the user should
> therefore truncate the path of integration manually (or make a regularizing
> change of variables, if possible).
Parameters:
 * `rtol` relative tolerance
 * `atol` absolute tolerance
 * `opts` a `C_NULL` (using the default options), or an instance of
 `acb_calc_integrate_opt_struct` controlling the algorithmic aspects of integration.

!!! Note: `integrate` does not guarantee to satisfy provided tolerances. For more
information please consider arblib documentation.

!!! Note: It's users responsibility to verify holomorphicity of `f`.
"""
function integrate(
    f,
    a::Union{Acb,AcbRef},
    b::Union{Acb,AcbRef};
    prec = max(precision(a), precision(b)),
    rtol = 0.0,
    atol = set_ui_2exp!(Mag(), one(UInt), -prec),
    opts::Union{Ptr{Cvoid},calc_integrate_opt_struct} = C_NULL,
)
    # rel_goal = r where rel_tol ~2^-r
    rel_goal = iszero(rtol) ? prec : rel_goal = -floor(Int, log2(atol))

    res = Acb(prec = prec)

    status = integrate!(
        res,
        f,
        a,
        b;
        rel_goal = rel_goal,
        abs_tol = convert(Mag, atol),
        opts = opts,
        prec = prec,
    )

    # status:
    # ARB_CALC_SUCCESS = 0
    # ARB_CALC_NO_CONVERGENCE = 2
    status == 2 &&
        @warn "Arb integrate did not achived convergence, the result might be incorrect"
    return res
end

function integrate(
    f,
    a::Number,
    b::Number;
    prec::Integer,
    rtol = 0.0,
    atol = 0.0,
    opts::Union{Ptr{Cvoid},calc_integrate_opt_struct} = C_NULL,
)
    return integrate(
        f,
        Acb(a, prec = prec),
        Acb(b, prec = prec),
        prec = prec,
        rtol = rtol,
        atol = atol,
        opts = opts,
    )
end
