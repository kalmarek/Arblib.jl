struct ArbFPWrapfunction{ReturnT<:Union{Float64,ComplexF64}}
    fname::String
    args::Vector{Carg}
end

function ArbFPWrapfunction(str)
    m = match(r"(?<returnflag>\w+(\s\*)?)\s+(?<arbfunction>[\w_]+)\((?<args>.*)\)", str)
    isnothing(m) &&
        throw(ArgumentError("string doesn't match arblib function signature pattern"))
    m[:returnflag] == "int" ||
        throw(ArgumentError("expected function to return int, got $returnflag"))


    args = Carg.(strip.(split(m[:args], ",")))

    fname_split = split(m[:arbfunction], "_", limit = 4)

    type_str = fname_split[3]

    if type_str == "double"
        return_type = Float64
    elseif type_str == "cdouble"
        return_type = ComplexF64
    else
        throw(ArgumentError("return type is not double or cdouble, got $type_str"))
    end

    return ArbFPWrapfunction{return_type}(m[:arbfunction], args)
end

arbfname(af::ArbFPWrapfunction) = af.fname
jlfname(af::ArbFPWrapfunction) = Symbol("fpwrap_" * split(af.fname, "_", limit = 4)[4])

returntype(af::ArbFPWrapfunction{ReturnT}) where {ReturnT} = ReturnT
arguments(af::ArbFPWrapfunction) = af.args

function jlargs(af::ArbFPWrapfunction{ReturnT}) where {ReturnT}
    cargs = arguments(af)

    # First argument is return value and last argument is flag
    cargs[1] == Carg{Vector{ReturnT}}(:res, false) ||
        throw(ArgumentError("expected first argument to be res::$ReturnT, got $(cargs[1])"))
    cargs[end] == Carg{Cint}(:flags, false) ||
        throw(ArgumentError("expected last argument to be flags::Cint, got $(cargs[end])"))
    cargs = cargs[2:end-1]

    jl_arg_names_types = [(name(carg), jltype(carg)) for carg in cargs]

    args = [:($a::$T) for (a, T) in jl_arg_names_types]

    return args
end

function jlcode(af::ArbFPWrapfunction, jl_fname = jlfname(af))
    jl_args = jlargs(af)

    returnT = returntype(af)
    cargs = arguments(af)

    func = :(
        function $jl_fname(
            $(jl_args...);
            safe::Bool = true,
            accurate_parts::Bool = false,
            correct_rounding::Bool = false,
            work_limit::Integer = 8,
        )
            res = Ref{$returnT}()

            flags::Cint = accurate_parts + correct_rounding * 2 + work_limit * 65536

            success = ccall(
                Arblib.@libarb($(arbfname(af))),
                Cint,
                $(Expr(:tuple, Ptr{returnT}, ctype.(cargs)..., Cint)),
                res,
                $(name.(cargs)...),
                flags,
            )

            if iszero(success) || !safe
                return res[]
            else
                error("unable to evaluate accurately")
            end
        end
    )

    return func
end

macro arbfpwrapcall_str(str)
    af = ArbFPWrapfunction(str)
    return esc(jlcode(af))
end
