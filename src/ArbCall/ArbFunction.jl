"""
    ArbFunction{T}(fname::String, args::Vector{Carg})

Struct representing a C-function in the Arb library.
"""
struct ArbFunction{T}
    fname::String
    args::Vector{Carg}
end

"""
    ArbFunction(str::AbstractString)

Parse a string as an ArbFunction. The string should be as a function
declaration in C. Note that note all types of function declarations
are supported, only those which are relevant for the Arb library.

```jldoctest
julia> Arblib.ArbCall.ArbFunction("void arb_zero(arb_t x)")
Arblib.ArbCall.ArbFunction{Nothing}("arb_zero", Arblib.ArbCall.Carg[Arblib.ArbCall.Carg{Arb}(:x, false)])
```
"""
function ArbFunction(str::AbstractString)
    m = match(r"(?<returntype>\w+(\s\*)?)\s+(?<arbfunction>[\w_]+)\((?<args>.*)\)", str)
    isnothing(m) &&
        throw(ArgumentError("string doesn't match arblib function signature pattern"))

    args = Carg.(strip.(split(m[:args], ",")))

    return ArbFunction{arbargtypes[m[:returntype]]}(m[:arbfunction], args)
end

returntype(af::ArbFunction{T}) where {T} = T
arbfname(af::ArbFunction) = af.fname
arguments(af::ArbFunction) = af.args

function arbsignature(af::ArbFunction)
    creturnT = arbargtypes.supported_reversed[returntype(af)]
    c_args = join(arbsignature.(arguments(af)), ", ")

    return "$creturnT $(arbfname(af))($c_args)"
end

function inplace(af::ArbFunction)
    firstarg = first(arguments(af))
    return !isconst(firstarg) &&
           (ctype(firstarg) <: Ref || ctype(firstarg) <: AbstractArray)
end

function ispredicate(af::ArbFunction)
    isconst(first(arguments(af))) || return false
    returntype(af) == Cint || return false
    jlname_starts = any(s -> startswith(string(jlfname(af)), s), ("is_",))
    jlname_contains = any(
        s -> occursin(s, string(jlfname(af))),
        ("_is_", "contains", "can_", "check_", "validate_"),
    )
    jlname_eq = any(==(jlfname(af)), (:eq, :ne, :lt, :le, :gt, :ge, :overlaps, :equal))
    return jlname_starts || jlname_contains || jlname_eq
end

is_series_method(af::ArbFunction) =
    (endswith(arbfname(af), "_series") || endswith(arbfname(af), "mullow")) &&
    (jltype(first(arguments(af))) <: Union{Arblib.ArbPolyLike,Arblib.AcbPolyLike})

const jlfname_prefixes = (
    "arf",
    "acf",
    "arb",
    "acb",
    "mag",
    "mat",
    "vec",
    "poly",
    "scalar",
    "fpwrap",
    "double",
    "cdouble",
)
const jlfname_suffixes =
    ("si", "ui", "d", "mag", "arf", "acf", "arb", "acb", "mpz", "mpfr", "str")

function jlfname(
    arbfname::AbstractString;
    prefixes = jlfname_prefixes,
    suffixes = jlfname_suffixes,
    inplace = false,
)
    strs = filter(!isempty, split(arbfname, "_"))
    k = findfirst(s -> s ∉ prefixes, strs)
    l = findfirst(s -> s ∉ suffixes, reverse(strs))
    fname = join(strs[k:(end-l+1)], "_")
    return inplace ? Symbol(fname, "!") : Symbol(fname)
end

jlfname(
    af::ArbFunction;
    prefixes = jlfname_prefixes,
    suffixes = jlfname_suffixes,
    inplace = inplace(af),
) = jlfname(arbfname(af); prefixes, suffixes, inplace)

function jlfname_series(arbfname::AbstractString)
    name = jlfname(arbfname, suffixes = (jlfname_suffixes..., "series"), inplace = true)
    if name == :mullow!
        # Handle this as a special case. There is no
        # arb_poly_mul_series method, it is instead called
        # arb_poly_mullow (same for acb_poly).
        return :mul!
    else
        return name
    end
end

jlfname_series(af::ArbFunction) = jlfname_series(arbfname(af))

function jlargs(af::ArbFunction; argument_detection::Bool = true)
    cargs = arguments(af)

    args = Expr[]
    kwargs = Expr[]

    prec_kwarg = false
    rnd_kwarg = false
    flags_kwarg = false
    for (i, carg) in enumerate(cargs)
        if !argument_detection
            push!(args, jlarg(carg))
            continue
        end

        if is_precision_argument(carg)
            @assert !prec_kwarg
            prec_kwarg = true

            push!(kwargs, extract_precision_argument(carg, first(cargs)))
        elseif is_flag_argument(carg)
            @assert !flags_kwarg
            flags_kwarg = true

            push!(kwargs, extract_flag_argument(carg))
        elseif is_rounding_argument(carg)
            @assert !rnd_kwarg
            rnd_kwarg = true

            push!(kwargs, extract_rounding_argument(carg))
        elseif i > 1 && is_length_argument(carg, cargs[i-1])
            push!(kwargs, extract_length_argument(carg, cargs[i-1]))
        else
            push!(args, jlarg(carg))
        end
    end

    return args, kwargs
end

"""
    jlargs_series(af::ArbFunction)

Compute `args` and `kwargs` for an Arb function `af` satisfying
`is_series_method(af)`. The values are similar to those computed by
[`jlargs`](@ref) with the following adjustements:
1. The argument giving the length of the result has the default value
   given by the length of the first argument.
2. Arguments accepting types `ArbPolyLike` and `AcbPolyLike` are
   restricted to only accept `ArbSeries` and `AcbSeries` respectively.
"""
function jlargs_series(af::ArbFunction)
    args, kwargs = jlargs(af)

    len_name = args[end].args[1]
    len_type = args[end].args[2]
    @assert len_name == :len || len_name == :n || len_name == :trunc
    @assert len_type == Integer
    first_name = args[1].args[1]
    args[end] = Expr(:kw, args[end], :(length($first_name)))

    for arg in args
        if arg.args[2] == Arblib.ArbPolyLike
            arg.args[2] = Arblib.ArbSeries
        elseif arg.args[2] == Arblib.AcbPolyLike
            arg.args[2] = Arblib.AcbSeries
        end
    end

    return args, kwargs
end

"""
    jlcode(af::ArbFunction, jl_fname = jlfname(af))

Generate the Julia code for calling the Arb function from Julia.
"""
function jlcode(af::ArbFunction, jl_fname = jlfname(af))
    jl_args, jl_kwargs = jlargs(af, argument_detection = true)
    jl_full_args, _ = jlargs(af, argument_detection = false)

    returnT = returntype(af)
    cargs = arguments(af)

    func_full_args = :(
        function $jl_fname($(jl_full_args...))
            __ret = ccall(
                Arblib.@libflint($(arbfname(af))),
                $returnT,
                $(Expr(:tuple, ctype.(cargs)...)),
                $(name.(cargs)...),
            )
            $(
                if returnT === Nothing && inplace(af)
                    name(first(arguments(af)))
                elseif ispredicate(af)
                    :(!iszero(__ret))
                else
                    :__ret
                end
            )
        end
    )

    if is_series_method(af)
        # Note that this currently doesn't respect any custom function
        # name given as an argument.
        jl_fname_series = jlfname_series(af)
        jl_args_series, jl_kwargs_series = jlargs_series(af)

        func_series = quote
            $jl_fname_series($(jl_args_series...); $(jl_kwargs_series...)) =
                $jl_fname($(name.(cargs)...))
        end

        code = quote
            $func_full_args
            $func_series
        end
    else
        code = func_full_args
    end

    if isempty(jl_kwargs)
        return code
    else
        return quote
            $code
            $jl_fname($(jl_args...); $(jl_kwargs...)) = $jl_fname($(name.(cargs)...))
        end
    end
end

"""
    @arbcall_str str

Parse a string as an [`Arblib.ArbCall.ArbFunction`](@ref), generate
the code for a corresponding method with
[`Arblib.ArbCall.jlcode`](@ref) and evaluate the code.

For example
```
arbcall"void arb_zero(arb_t x)"
```
defines the method `zero!(x::ArbLike)`.
"""
macro arbcall_str(str)
    af = ArbFunction(str)
    return esc(jlcode(af))
end
