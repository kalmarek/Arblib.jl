struct Arbfunction{ReturnT}
    fname::String
    args::Vector{Carg}
end

function Arbfunction(str)
    m = match(r"(?<returntype>\w+(\s\*)?)\s+(?<arbfunction>[\w_]+)\((?<args>.*)\)", str)
    isnothing(m) &&
        throw(ArgumentError("string doesn't match arblib function signature pattern"))

    args = Carg.(strip.(split(m[:args], ",")))

    return Arbfunction{arbargtypes[m[:returntype]]}(m[:arbfunction], args)
end

function jlfname(
    arbfname,
    prefixes = (
        "arf",
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
    ),
    suffixes = ("si", "ui", "d", "mag", "arf", "arb", "acb", "mpz", "mpfr", "str");
    inplace = false,
)
    strs = filter(!isempty, split(arbfname, "_"))
    k = findfirst(s -> s ∉ prefixes, strs)
    l = findfirst(s -> s ∉ suffixes, reverse(strs))
    fname = join(strs[k:end-l+1], "_")
    return inplace ? Symbol(fname, "!") : Symbol(fname)
end

arbfname(af::Arbfunction) = af.fname
returntype(af::Arbfunction{ReturnT}) where {ReturnT} = ReturnT
arguments(af::Arbfunction) = af.args

function inplace(af::Arbfunction)
    firstarg = first(arguments(af))
    return !isconst(firstarg) &&
           (ctype(firstarg) <: Ref || ctype(firstarg) <: AbstractArray)
end

function jlfname(
    af::Arbfunction,
    prefixes = (
        "arf",
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
    ),
    suffixes = ("si", "ui", "d", "mag", "arf", "arb", "acb", "mpz", "mpfr", "str");
    inplace = inplace(af),
)
    return jlfname(arbfname(af), prefixes, suffixes, inplace = inplace)
end

function is_length_argument(carg, prev_carg, len_keywords)
    (startswith(string(name(carg)), "len") || carg == Carg{Int}(:n, false)) &&
        rawtype(prev_carg) ∈ (ArbVector, AcbVector) &&
        name(carg) ∉ len_keywords
end
function extract_length_argument!(kwargs, len_keywords, carg, prev_carg)
    vec_name = name(prev_carg)
    push!(kwargs, Expr(:kw, :($(name(carg))::Integer), :(length($vec_name))))
    push!(len_keywords, name(carg))
end
function ispredicate(af::Arbfunction)
    return isconst(first(arguments(af))) &&
           returntype(af) == Cint &&
           (
               any(s -> startswith(string(jlfname(af)), s), ("is_",)) ||
               any(
                   s -> occursin(s, string(jlfname(af))),
                   ("_is_", "contains", "can_", "check_", "validate_"),
               ) ||
               any(==(jlfname(af)), (:eq, :ne, :lt, :le, :gt, :ge, :overlaps, :equal))
           )
end

function jlargs(af::Arbfunction; argument_detection::Bool = true)
    cargs = arguments(af)

    jl_arg_names_types = Tuple{Symbol,Any}[]
    kwargs = Expr[]

    prec_kwarg = false
    rnd_kwarg = false
    flags_kwarg = false
    for (i, carg) in enumerate(cargs)
        if !argument_detection
            push!(jl_arg_names_types, (name(carg), jltype(carg)))
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
            push!(jl_arg_names_types, (name(carg), jltype(carg)))
        end
    end

    args = [:($a::$T) for (a, T) in jl_arg_names_types]

    return args, kwargs
end

function arbsignature(af::Arbfunction)
    creturnT = arbargtypes.supported_reversed[returntype(af)]
    args = arguments(af)

    arg_consts = isconst.(args)
    arg_ctypes = [arbargtypes.supported_reversed[rawtype(arg)] for arg in args]
    arg_names = name.(args)


    c_args = join(
        [
            ifelse(
                isconst && (type == "arb_ptr" || type == "acb_ptr"),
                "$(split(type, "_")[1])_srcptr $name",
                ifelse(isconst, "const ", "") * "$type $name",
            ) for (isconst, type, name) in zip(arg_consts, arg_ctypes, arg_names)
        ],
        ", ",
    )

    "$creturnT $(arbfname(af))($c_args)"
end

function jlcode(af::Arbfunction, jl_fname = jlfname(af))
    jl_args, jl_kwargs = jlargs(af; argument_detection = true)
    jl_full_args, _ = jlargs(af; argument_detection = false)

    returnT = returntype(af)
    cargs = arguments(af)

    func_full_args = :(
        function $jl_fname($(jl_full_args...))
            __ret = ccall(
                Arblib.@libarb($(arbfname(af))),
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

    if isempty(jl_kwargs)
        func_full_args
    else
        quote
            $func_full_args
            $jl_fname($(jl_args...); $(jl_kwargs...)) = $jl_fname($(name.(cargs)...))
        end
    end
end

macro arbcall_str(str)
    af = Arbfunction(str)
    return esc(jlcode(af))
end
