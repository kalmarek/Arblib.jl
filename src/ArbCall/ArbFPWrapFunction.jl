"""
    ArbFPWrapFunction{T}(fname, args)
    ArbFPWrapFunction(str)

Struct representing an Arb function from the `arb_fpwrap.h` module.
"""
struct ArbFPWrapFunction{T<:Union{Float64,ComplexF64}}
    fname::String
    args::Vector{Carg}
end

function ArbFPWrapFunction(str::AbstractString)
    m = match(r"(?<returnflag>\w+(\s\*)?)\s+(?<arbfunction>[\w_]+)\((?<args>.*)\)", str)
    isnothing(m) &&
        throw(ArgumentError("string doesn't match arblib function signature pattern"))

    # Check that it has the correct return type
    m[:returnflag] == "int" ||
        throw(ArgumentError("expected function to return int, got $(m[:returnflag])"))

    # Determine if it returns double or cdouble
    type_str = split(m[:arbfunction], "_", limit = 4)[3]
    if type_str == "double"
        T = Float64
    elseif type_str == "cdouble"
        T = ComplexF64
    else
        throw(ArgumentError("type is not double or cdouble, got $type_str"))
    end

    args = Carg.(strip.(split(m[:args], ",")))

    # Check that at least the first argument is a result argument
    is_fpwrap_res_argument(first(args), T) || throw(
        ArgumentError(
            "expected first argument to be a result argument, got $(first(args))",
        ),
    )

    return ArbFPWrapFunction{T}(m[:arbfunction], args)
end

basetype(::ArbFPWrapFunction{T}) where {T} = T
arbfname(af::ArbFPWrapFunction) = af.fname
arguments(af::ArbFPWrapFunction) = af.args

function count_res_arguments(af::ArbFPWrapFunction{T}) where {T}
    i = findfirst(ca -> !is_fpwrap_res_argument(ca, T), arguments(af))
    return i - 1
end

function returntype(af::ArbFPWrapFunction{T}) where {T}
    n = count_res_arguments(af)
    if n == 1
        return basetype(af)
    else
        return NTuple{n,basetype(af)}
    end
end

function arbsignature(af::ArbFPWrapFunction)
    c_args = join(arbsignature.(arguments(af)), ", ")

    return "int $(arbfname(af))($c_args)"
end

jlfname(af::ArbFPWrapFunction) = Symbol(:fpwrap_, split(arbfname(af), "_", limit = 4)[4])

# TODO: Improve support for vector arguments
function jlargs(af::ArbFPWrapFunction)
    cargs = arguments(af)

    # Skip return arguments

    # Count res arguments
    n = count_res_arguments(af)
    n >= 1 || throw(ArgumentError("expected at least one result argument"))
    # last argument is flag, skip this
    cargs[end] == Carg{Cint}(:flags, false) ||
        throw(ArgumentError("expected last argument to be flags::Cint, got $(cargs[end])"))

    args = [:($(name(carg))::$(jltype(carg))) for carg in cargs[n+1:end-1]]

    if basetype(af) == Float64
        kwargs = [
            Expr(:kw, :(safe::Bool), :(false)),
            Expr(:kw, :(correct_rounding::Bool), :(false)),
            Expr(:kw, :(work_limit::Integer), :(8)),
        ]
    else
        kwargs = [
            Expr(:kw, :(safe::Bool), :(false)),
            Expr(:kw, :(accurate_parts::Bool), :(false)),
            Expr(:kw, :(correct_rounding::Bool), :(false)),
            Expr(:kw, :(work_limit::Integer), :(8)),
        ]
    end

    return args, kwargs
end

function jlcode(af::ArbFPWrapFunction, jl_fname = jlfname(af))
    T = basetype(af)
    cargs = arguments(af)
    n = count_res_arguments(af)
    jl_args, jl_kwargs = jlargs(af)

    return_variables = Expr(:block, [:($(name(ca)) = Ref{$T}()) for ca in cargs[1:n]]...)
    if n == 1
        return_expr = :($(name(cargs[1]))[])
    else
        return_expr = Expr(:tuple, [:($(name(ca))[]) for ca in cargs[1:n]]...)
    end

    func = :(
        function $jl_fname($(jl_args...); $(jl_kwargs...))
            $return_variables

            # Set accurate_parts if it is not included as a kwarg
            $(ifelse(T == Float64, :(accurate_parts = false), :nothing))

            flags::Cint = accurate_parts + correct_rounding * 2 + work_limit * 65536

            return_flag = ccall(
                Arblib.@libarb($(arbfname(af))),
                Cint,
                $(Expr(:tuple, ctype.(cargs)...)),
                $(name.(cargs)...),
            )

            if iszero(return_flag) || !safe
                return $return_expr
            elseif isone(return_flag)
                error("unable to evaluate accurately")
            else
                error("unknown return flag $return_flag")
            end
        end
    )

    return func
end

macro arbfpwrapcall_str(str)
    af = ArbFPWrapFunction(str)
    return esc(jlcode(af))
end
