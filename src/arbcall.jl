const Ctypes = Dict{String, DataType}(
    "void"      => Cvoid,
    "int"       => Cint,
    "slong"     => Clong,
    "ulong"     => Culong,
    "double"    => Cdouble,
    "arf_t"     => Arf,
    "arb_t"     => Arb,
    "acb_t"     => Acb,
    "mag_t"     => Mag,
    "arf_rnd_t" => arb_rnd
)

struct Carg{ArgT}
    name::String
    isconst::Bool
end

function Carg(str)
    m = match(r"(?<const>const)?\s*(?<type>\w+)\s+(?<name>\w+)", str)
    isnothing(m) && throw(ArgumentError("string doesn't match c-argument pattern"))

    return Carg{Ctypes[m[:type]]}(m[:name], !isnothing(m[:const]))
end

name(ca::Carg) = ca.name
isconst(ca::Carg) = ca.isconst
jltype(::Carg{ArgT}) where ArgT = ArgT
ctype(ca::Carg) = jltype(ca)
ctype(::Carg{ArgT}) where ArgT <: Union{Arf, Arb, Acb, Mag}  = Ref{ArgT}

struct Arbfunction{ReturnT}
    fname::String
    args::Vector{Carg}
end

function Arbfunction(str)
    m = match(r"(?<returntype>\w+)\s+(?<arbfunction>[\w_]+)\((?<args>.*)\)",
        str)
    isnothing(m) && throw(ArgumentError("string doesn't match arblib function signature pattern"))

    args = Carg.(strip.(split(m[:args], ",")))

    return Arbfunction{Ctypes[m[:returntype]]}(m[:arbfunction], args)
end

function jlfname(arbfname,
        prefixes=("arf", "arb", "acb", "mag"),
        suffixes=("si", "ui", "d", "arf", "arb");
        inplace=false)
    strs = split(arbfname, "_")
    k = findfirst(s->s ∉ prefixes, strs)
    l = findfirst(s->s ∉ suffixes, reverse(strs))
    fname = join(strs[k:end-l+1], "_")
    return inplace ? Symbol(fname, "!") : Symbol(fname)
end

arbfname(af::Arbfunction) = af.fname
returntype(af::Arbfunction{ReturnT}) where ReturnT = ReturnT
arguments(af::Arbfunction) = af.args

function inplace(af::Arbfunction)
    firstarg = first(arguments(af))
    return !isconst(firstarg) && ctype(firstarg) <: Ref
end

function jlfname(af::Arbfunction,
        prefixes=("arf", "arb", "acb", "mag"),
        suffixes=("si", "ui", "d", "arf", "arb");
        inplace=inplace(af))
    return jlfname(arbfname(af), prefixes, suffixes, inplace=inplace)
end

function jlsignature(af::Arbfunction)
    returnT = returntype(af)
    args = arguments(af)

    arg_names = Symbol.(name.(args))
    jl_types = jltype.(args)

    jl_kwargs = Expr[]

    k = findfirst(==(:prec), arg_names)
    if !isnothing(k)
        @assert jl_types[k] == Int64
        p = :prec
        a = first(args)
        default = if jltype(a) ∈ (Arf, Arb, Acb)
            :(precision($(Symbol(name(a)))))
        else
            :(DEFAULT_PRECISION[])
        end
        push!(jl_kwargs, Expr(:kw, :($p::Integer), default))
        deleteat!(arg_names, k)
        deleteat!(jl_types, k)
    end

    k = findfirst(==(:rnd), arg_names)
    if !isnothing(k)
        @assert jl_types[k] == arb_rnd
        r = :rnd
        push!(jl_kwargs, Expr(:kw, :($r::Union{arb_rnd, RoundingMode}), :(RoundNearest)))
        deleteat!(arg_names, k)
        deleteat!(jl_types, k)
    end

    jl_args = [:($a::$T) for (a, T) in zip(arg_names, jl_types)]

    :($(jlfname(af))($(jl_args...); $(jl_kwargs...))::$(returnT))
end

function arbsignature(af::Arbfunction)
    jltoctype = Dict(value => key for (key, value) in Ctypes)

    creturnT = jltoctype[returntype(af)]
    args = arguments(af)

    arg_consts = isconst.(args)
    arg_ctypes = [jltoctype[jltype(arg)] for arg in args]
    arg_names = name.(args)


    c_args = join([ifelse(isconst, "const ", "")*"$type $name" for (isconst, type, name)
                   in zip(arg_consts, arg_ctypes, arg_names)], ", ")

    c_args = join([ifelse(isconst(arg), "const ", "") *
                   "$(jltoctype[jltype(arg)]) $(name(arg))" for arg in args], ", ")

    "$creturnT $(arbfname(af))($c_args)"
end

function jlcode(af::Arbfunction, jl_fname=jlfname(af))
    returnT = returntype(af)
    args = arguments(af)
    c_types = ctype.(args)

    arg_names = Symbol.(name.(args))
    jl_types = jltype.(args)

    kwargs = Expr[]

    k = findfirst(==(:prec), arg_names)
    if !isnothing(k)
        @assert jl_types[k] == Int64
        p = :prec
        a = first(args)
        default = if jltype(a) ∈ (Arf, Arb, Acb)
            :(precision($(Symbol(name(a)))))
        else
            :(DEFAULT_PRECISION[])
        end
        push!(kwargs, Expr(:kw, :($p::Integer), default))
        deleteat!(arg_names, k)
        deleteat!(jl_types, k)
    end

    k = findfirst(==(:rnd), arg_names)
    if !isnothing(k)
        @assert jl_types[k] == arb_rnd
        r = :rnd
        push!(kwargs, Expr(:kw, :($r::Union{arb_rnd, RoundingMode}), :(RoundNearest)))
        deleteat!(arg_names, k)
        deleteat!(jl_types, k)
    end

    jl_args = [:($a::$T) for (a, T) in zip(arg_names, jl_types)]

    res = first(arg_names)

    return :(
        function $jl_fname($(jl_args...); $(kwargs...))
            ccall(Arblib.@libarb($(arbfname(af))),
            $returnT,
            $(Expr(:tuple, c_types...)),
            $(Symbol.(name.(args))...))
            return $res
        end
        )
end

macro arbcall_str(str)
    af = Arbfunction(str)
    return jlcode(af)
end
