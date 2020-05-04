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
    "arf_rnd_t" => arb_rnd,
    "mpfr_t"    => BigFloat,
    "char *"    => Cstring,
    "slong *"   => Vector{Clong},
)

struct Carg{ArgT}
    name::String
    isconst::Bool
end

function Carg(str)
    m = match(r"(?<const>const)?\s*(?<type>\w+(\s\*)?)\s+(?<name>\w+)", str)
    isnothing(m) && throw(ArgumentError("string doesn't match c-argument pattern"))

    return Carg{Ctypes[m[:type]]}(m[:name], !isnothing(m[:const]))
end

name(ca::Carg) = ca.name
isconst(ca::Carg) = ca.isconst

rawtype(::Carg{T}) where T = T

jltype(ca::Carg) = rawtype(ca)
jltype(ca::Carg{Cint}) = Integer
jltype(ca::Carg{Clong}) = Integer
jltype(ca::Carg{Culong}) = Unsigned
jltype(ca::Carg{Cdouble}) = Base.GMP.CdoubleMax
jltype(ca::Carg{arb_rnd}) = Union{arb_rnd, RoundingMode}
jltype(ca::Carg{Vector{Clong}}) = Vector{<:Integer}

ctype(ca::Carg) = rawtype(ca)
ctype(::Carg{T}) where T <: Union{Arf, Arb, Acb, Mag, BigFloat}  = Ref{T}
ctype(::Carg{Vector{T}}) where T = Ref{T}

struct Arbfunction{ReturnT}
    fname::String
    args::Vector{Carg}
end

function Arbfunction(str)
    m = match(r"(?<returntype>\w+(\s\*)?)\s+(?<arbfunction>[\w_]+)\((?<args>.*)\)",
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

function jlargs(af::Arbfunction)
    cargs = arguments(af)
    arg_names = Symbol.(name.(cargs))
    c_types = ctype.(cargs)
    jl_types = jltype.(cargs)

    kwargs = Expr[]

    k = findfirst(==(:prec), arg_names)
    if !isnothing(k)
        @assert c_types[k] == Clong
        p = :prec
        a = first(cargs)
        default = if jltype(a) ∈ (Arf, Arb, Acb)
            :(precision($(Symbol(name(a)))))
        else
            :(DEFAULT_PRECISION[])
        end
        push!(kwargs, Expr(:kw, :($p::Integer), default))
        deleteat!(arg_names, k)
        deleteat!(c_types, k)
        deleteat!(jl_types, k)
    end

    k = findfirst(==(:rnd), arg_names)
    if !isnothing(k)
        @assert c_types[k] == arb_rnd
        r = :rnd
        push!(kwargs, Expr(:kw, :($r::Union{arb_rnd, RoundingMode}), :(RoundNearest)))
        deleteat!(arg_names, k)
        deleteat!(c_types, k)
        deleteat!(jl_types, k)
    end

    args = [:($a::$T) for (a, T) in zip(arg_names, jl_types)]

    return (args, kwargs)
end

function arbsignature(af::Arbfunction)
    jltoctype = Dict(value => key for (key, value) in Ctypes)

    creturnT = jltoctype[returntype(af)]
    args = arguments(af)

    arg_consts = isconst.(args)
    arg_ctypes = [jltoctype[rawtype(arg)] for arg in args]
    arg_names = name.(args)


    c_args = join([ifelse(isconst, "const ", "")*"$type $name" for (isconst, type, name)
                   in zip(arg_consts, arg_ctypes, arg_names)], ", ")

    "$creturnT $(arbfname(af))($c_args)"
end

function jlcode(af::Arbfunction, jl_fname=jlfname(af))
    returnT = returntype(af)
    cargs = arguments(af)
    args, kwargs = jlargs(af)

    return :(
        function $jl_fname($(args...); $(kwargs...))
        ccall(Arblib.@libarb($(arbfname(af))),
              $returnT,
              $(Expr(:tuple, ctype.(cargs)...)),
              $(Symbol.(name.(cargs))...))
        end
    )
end

macro arbcall_str(str)
    af = Arbfunction(str)
    return jlcode(af)
end
