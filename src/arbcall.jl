
function jlfname(arbfname,
        prefixes=("arf", "arb", "acb", "mag"),
        suffixes=("si", "ui", "d", "arf", "arb");
        inplace=true)
    strs = split(arbfname, "_")
    k = findfirst(s->s ∉ prefixes, strs)
    l = findfirst(s->s ∉ suffixes, reverse(strs))
    fname = join(strs[k:end-l+1], "_")
    return inplace ? Symbol(fname, "!") : Symbol(fname)
end

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


macro arbcall_str(str)
    header_regex = r"(?<returntype>\w+)\s+(?<arbfunction>[\w_]+)\((?<args>.*)\)"

    m = match(header_regex, str)

    returnT = Ctypes[m[:returntype]]

    args = match.(r"(?<const>const)?\s*(?<type>\w+)\s+(?<name>\w+)",
        strip.(split(m[:args], ","))
        )
    arg_names = Symbol.([m[:name] for m in args])
    jl_types = [Ctypes[m[:type]] for m in args]
    c_types = [T ∈ (Arf, Arb, Acb, Mag) ? Ref{T} : T for T in jl_types]
    jl_args = [:($a::$T) for (a, T) in zip(arg_names, jl_types)]

    arbf = String(m[:arbfunction])
    inplace = isnothing(args[1][:const]) && c_types[1] <: Ref
    jlf = jlfname(arbf, inplace=true)

    if :prec in arg_names
        k = findfirst(==(:prec), arg_names)
        @assert c_types[k] == Clong
        p = esc(:prec)
        if first(jl_types) ∈ (Arf, Arb, Acb)
            default = :(precision($(arg_names[1])))
        else
            default = :(Arblib.DEFAULT_PRECISION[])
        end
        jl_args[k] = Expr(:kw, :($p::Integer), default)
    end

    if :rnd in arg_names
        k = findfirst(==(:rnd), arg_names)
        @assert c_types[k] == arb_rnd
        r = esc(:rnd)
        jl_args[k] = Expr(:kw, :($r::Union{arb_rnd, RoundingMode}), :(RoundNearest))
    end

    res = first(arg_names)

    return :(
        function $jlf($(jl_args...))
            ccall(Arblib.@libarb($arbf),
            $returnT,
            $(Expr(:tuple, c_types...)),
            $(arg_names...))
            return $res
        end
        )
end
