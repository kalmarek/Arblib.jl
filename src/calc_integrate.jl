function _acb_calc_func!(
    out::Ptr{acb_struct},
    inp::Ptr{acb_struct},
    param::Ptr{Cvoid}, # pointer to the actual function
    order::Int,
    prec::Int,
)
    @assert iszero(order) || isone(order)
    x = AcbRef(inp, nothing; prec)
    res = AcbRef(out, nothing; prec)
    f! = unsafe_pointer_to_objref(param)

    f!(res, x, analytic = isone(order); prec)

    return zero(Cint)
end

_acb_calc_cfunc!() = @cfunction(
    _acb_calc_func!,
    Cint,
    (Ptr{acb_struct}, Ptr{acb_struct}, Ptr{Cvoid}, Int, Int)
)

function calc_integrate!(
    res::AcbLike,
    acb_calc_cfunc::Ptr{Cvoid}, # cfunction
    param,
    a::AcbLike,
    b::AcbLike,
    rel_goal::Int,
    abs_tol::MagLike,
    options::calc_integrate_opt_struct,
    prec::Int,
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
            Int,
            Ref{mag_struct},
            Ref{calc_integrate_opt_struct},
            Int,
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
    rel_goal::Int,
    abs_tol::MagLike,
    options::Ptr{Cvoid},
    prec::Int,
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
            Int,
            Ref{mag_struct},
            Ptr{Cvoid},
            Int,
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

"""
    _integrate!(res, f, a, b; prec, rel_goal, abs_goal, opts)

Internal function for integration. Assumes that `f!` is of the type
`f!(out::AcbRef, inp::AcbRef; analytic::Bool, prec::Integer)` and
that all other parameters are set to valid values.
"""
function _integrate!(
    f!,
    res::AcbLike,
    a::AcbLike,
    b::AcbLike;
    prec::Integer = precision(res),
    rel_goal::Integer = prec,
    abs_tol::MagLike = set_ui_2exp!(Arblib.Mag(), one(UInt), -prec),
    warn_on_no_convergence = true,
    opts::Union{Ptr{Cvoid},calc_integrate_opt_struct} = C_NULL,
)
    status = calc_integrate!(
        res,
        _acb_calc_cfunc!(),
        f!,
        a,
        b,
        rel_goal,
        abs_tol,
        opts, # passing C_NULL uses the default options
        prec,
    )

    # status:
    # ARB_CALC_SUCCESS = 0
    # ARB_CALC_NO_CONVERGENCE = 2
    warn_on_no_convergence && status == 2 && @warn "integration did not converge"

    return res
end

"""
    integrate!(f!, res::Acb, a::Number, b::Number;
        check_analytic::Bool = false,
        take_prec::Bool = false,
        prec::Integer = precision(res),
        rtol = 0.0,
        atol = 2.0^-prec,
        warn_on_no_convergence = true,
        opts::Union{acb_calc_integrate_opt_struct, Ptr{Cvoid}} = C_NULL,
    )

Like [`integrate`](@ref), but make use of in-place operations. In
particular, there are three differences from `integrate`:

1. The function `f!` should be of the form `f!(y, x) = set!(y, f(x))`.
   That is, it writes the return value of the integand `f(x)` in-place
   into its first argument `y`. (The return value of `f!` is ignored).

2. `res` is set to the result.

3. The default precision is taken from `res` instead of from `a` and
   `b`.

# Examples
```jldoctest
julia> using Arblib

julia> Arblib.integrate!(Arblib.sin!, Acb(0), Acb(0), Acb(10)) # Integrate sin from 0 to 10
[1.83907152907645245225886394782406483451993016513316854683595373104879258687 +/- 5.15e-75]

julia> Arblib.integrate!(Arblib.inv!, Acb(0), Acb(1, -5), Acb(1, 5)) # Integrate 1/z from 1 - 5i to 1 + 5i
[+/- 2.02e-75] + [2.74680153389003172172254385288992229730199919179940161793956671182574846633 +/- 2.83e-75]im

julia> # Integrate √z from 1 - 5im to 1 + 5im, taking into account the branch cut at (-∞, 0]

julia> f! = (res, z; analytic = false) -> Arblib.sqrt_analytic!(res, z, analytic);

julia> Arblib.integrate!(f!, Acb(0), Acb(1, -5), Acb(1, 10), check_analytic = true, prec = 64)
[-9.0064084416559764 +/- 6.53e-17] + [23.8636067095598007 +/- 6.98e-17]im
```
"""
function integrate!(
    f!,
    res::AcbOrRef,
    a::AcbOrRef,
    b::AcbOrRef;
    check_analytic::Bool = false,
    take_prec::Bool = false,
    prec::Integer = precision(res),
    rtol = 0.0,
    atol = set_ui_2exp!(Mag(), one(UInt), -prec),
    warn_on_no_convergence = true,
    opts::Union{Ptr{Cvoid},calc_integrate_opt_struct} = C_NULL,
)
    # rtol ≈ 2^(-rel_goal)
    rel_goal = iszero(rtol) ? prec : max(-floor(Int, log2(rtol)), 0)

    if !check_analytic && !take_prec
        g! = (res, x; analytic, prec) -> f!(res, x)
    elseif !check_analytic && take_prec
        g! = (res, x; analytic, prec) -> f!(res, x; prec)
    elseif check_analytic && !take_prec
        g! = (res, x; analytic, prec) -> f!(res, x; analytic)
    else
        g! = f!
    end

    return _integrate!(
        g!,
        res,
        a,
        b;
        prec,
        rel_goal,
        abs_tol = convert(Mag, atol),
        warn_on_no_convergence,
        opts,
    )
end

function integrate!(
    f!,
    res::AcbOrRef,
    a::Number,
    b::Number;
    check_analytic::Bool = false,
    take_prec::Bool = false,
    prec::Integer = precision(res),
    rtol = 0.0,
    atol = set_ui_2exp!(Mag(), one(UInt), -prec),
    warn_on_no_convergence = true,
    opts::Union{Ptr{Cvoid},calc_integrate_opt_struct} = C_NULL,
)
    return integrate!(
        f!,
        res,
        Acb(a; prec),
        Acb(b; prec);
        check_analytic,
        take_prec,
        prec,
        rtol,
        atol,
        warn_on_no_convergence,
        opts,
    )
end


"""
    integrate(f, a::Number, b::Number;
        check_analytic::Bool = false,
        take_prec::Bool = false,
        prec = max(precision(a), precision(b)),
        rtol = 0.0,
        atol = 2.0^-prec,
        warn_on_no_convergence = true,
        opts::Union{acb_calc_integrate_opt_struct, Ptr{Cvoid}} = C_NULL)
Computes a rigorous enclosure of the integral ∫ₐᵇ f(x) dx where
`f(x::AcbRef)` is any (holomorphic) julia function. From Arb docs:

> The integral follows a straight-line path between the complex numbers `a` and
> `b`. For finite results, `a`, `b` must be finite and `f` must be bounded on
> the path of integration. To compute improper integrals, the user should
> therefore truncate the path of integration manually (or make a regularizing
> change of variables, if possible).

The error estimates used require that `f` is holomorphic on certain
ellipses around the path of integration.

> The integration algorithm combines direct interval enclosures,
> Gauss-Legendre quadrature where f is holomorphic, and adaptive
> subdivision. This strategy supports integrands with discontinuities
> while providing exponential convergence for typical piecewise
> holomorphic integrands.

In general the integration will work for any function which is
holomorpic or meromorphic on the whole complex plane. For functions
with branch cuts or other things which makes them non-holomorphic the
argument `check_analytic` has to be set to `true`. In this case `f`
will be given a keyword argument `analytic::Bool`, if `analytic` is
`false` then nothing special has to be done, but if `analytic` is
`true` then the output has to be non-finite (typically `Acb(NaN)`) if
`f` is not holomorphic on the whole input ball.

!!! Note: It's users responsibility to verify holomorphicity of `f`.

Parameters:
 * `take_prec` if true then `f` will be given the keyword argument
   `prec = prec`, useful for functions requiring an explicit precision
   to be given.
 * `rtol` relative tolerance
 * `atol` absolute tolerance
 * `warn_on_no_convergence` set this to false to avoid printing a
   warning in case the integration doesn't converge.
 * `opts` a `C_NULL` (using the default options), or an instance of
   `acb_calc_integrate_opt_struct` controlling the algorithmic aspects of integration.

!!! Note: `integrate` does not guarantee to satisfy provided
    tolerances. But the result is guaranteed to be contained in the
    resulting ball.

For more information please consider arblib documentation and the
paper
> Fredrik Johansson, Numerical integration in arbitrary-precision ball arithmetic,
> _Mathematical Software – ICMS 2018_
> https://doi.org/10.1007/978-3-319-96418-8
> https://arxiv.org/abs/1802.07942

See also: [`integrate!`](@ref).

# Examples
```jldoctest
julia> using Arblib

julia> Arblib.integrate(sin, 0, 10) # Integrate sin from 0 to 10
[1.83907152907645245225886394782406483451993016513316854683595373104879258687 +/- 5.15e-75]

julia> Arblib.integrate(z -> 1/z, Acb(1, -5), Acb(1, 5)) # Integrate 1/z from 1 - 5i to 1 + 5i
[+/- 2.02e-75] + [2.74680153389003172172254385288992229730199919179940161793956671182574846633 +/- 2.83e-75]im

julia> # Integrate √z from 1 - 5im to 1 + 5im, taking into account the branch cut at (-∞, 0]

julia> f = (z; analytic = false) -> begin
           if analytic && Arblib.contains_nonpositive(real(z))
               return Acb(NaN, prec = precision(z))
           else
               return sqrt(z)
           end
       end;

julia> Arblib.integrate(f, Acb(1, -5), Acb(1, 10), check_analytic = true, prec = 64)
[-9.0064084416559764 +/- 7.40e-17] + [23.8636067095598007 +/- 9.03e-17]im
```
"""
function integrate(
    f,
    a::AcbOrRef,
    b::AcbOrRef;
    check_analytic::Bool = false,
    take_prec::Bool = false,
    prec = max(precision(a), precision(b)),
    rtol = 0.0,
    atol = set_ui_2exp!(Mag(), one(UInt), -prec),
    warn_on_no_convergence = true,
    opts::Union{Ptr{Cvoid},calc_integrate_opt_struct} = C_NULL,
)
    f! = (res, x; kwargs...) -> set!(res, f(x; kwargs...))
    res = Acb(; prec)

    return integrate!(
        f!,
        res,
        a,
        b;
        check_analytic,
        take_prec,
        rtol,
        atol,
        warn_on_no_convergence,
        opts,
        prec,
    )
end

function integrate(
    f,
    a::Number,
    b::Number;
    check_analytic::Bool = false,
    take_prec::Bool = false,
    prec::Integer = max(_precision(a), _precision(b)),
    rtol = 0.0,
    atol = set_ui_2exp!(Mag(), one(UInt), -prec),
    warn_on_no_convergence = true,
    opts::Union{Ptr{Cvoid},calc_integrate_opt_struct} = C_NULL,
)
    return integrate(
        f,
        Acb(a; prec),
        Acb(b; prec);
        check_analytic,
        take_prec,
        prec,
        rtol,
        atol,
        warn_on_no_convergence,
        opts,
    )
end
