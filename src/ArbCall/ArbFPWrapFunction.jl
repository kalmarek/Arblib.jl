# TODO: Handle multiple return values
# TODO: Handle vector input

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

    m[:returnflag] == "int" ||
        throw(ArgumentError("expected function to return int, got $returnflag"))

    args = Carg.(strip.(split(m[:args], ",")))

    # Determine if it returns double or cdouble
    type_str = split(m[:arbfunction], "_", limit = 4)[3]
    if type_str == "double"
        return_type = Float64
    elseif type_str == "cdouble"
        return_type = ComplexF64
    else
        throw(ArgumentError("return type is not double or cdouble, got $type_str"))
    end

    return ArbFPWrapFunction{return_type}(m[:arbfunction], args)
end

returntype(::ArbFPWrapFunction{T}) where {T} = T
arbfname(af::ArbFPWrapFunction) = af.fname
arguments(af::ArbFPWrapFunction) = af.args

function arbsignature(af::ArbFPWrapFunction)
    c_args = join(arbsignature.(arguments(af)), ", ")

    return "int $(arbfname(af))($c_args)"
end

inplace(::ArbFPWrapFunction) = false
ispredicate(::ArbFPWrapFunction) = false

jlfname(af::ArbFPWrapFunction) = Symbol(:fpwrap_, split(arbfname(af), "_", limit = 4)[4])

function jlargs(af::ArbFPWrapFunction{ReturnT}) where {ReturnT}
    cargs = arguments(af)

    # First argument is return value and last argument is flag,
    # skip those
    cargs[1] == Carg{Vector{ReturnT}}(:res, false) ||
        throw(ArgumentError("expected first argument to be res::$ReturnT, got $(cargs[1])"))
    cargs[end] == Carg{Cint}(:flags, false) ||
        throw(ArgumentError("expected last argument to be flags::Cint, got $(cargs[end])"))

    args = [:($(name(carg))::$(jltype(carg))) for carg in cargs[2:end-1]]

    if returntype(af) == Float64
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
    returnT = returntype(af)
    cargs = arguments(af)
    jl_args, jl_kwargs = jlargs(af)

    func = :(
        function $jl_fname($(jl_args...); $(jl_kwargs...))
            res = Ref{$returnT}()

            # Set accurate_parts if it is not included as a kwarg
            $(ifelse(returnT == Float64, :(accurate_parts = false), :nothing))

            flags::Cint = accurate_parts + correct_rounding * 2 + work_limit * 65536

            return_flag = ccall(
                Arblib.@libarb($(arbfname(af))),
                Cint,
                $(Expr(:tuple, ctype.(cargs)...)),
                $(name.(cargs)...),
            )

            if iszero(return_flag) || !safe
                return res[]
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
