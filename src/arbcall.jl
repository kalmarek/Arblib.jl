struct UnsupportedArgumentType <: Exception
    key::String
end

struct ArbArgTypes
    supported::Dict{String,DataType}
    unsupported::Set{String}
    supported_reversed::Dict{DataType,String}
end

function ArbArgTypes(supported, unsupported)
    supported_reversed = Dict(value => key for (key, value) in supported)
    return ArbArgTypes(supported, unsupported, supported_reversed)
end

function Base.getindex(arbargtypes::ArbArgTypes, key::AbstractString)
    haskey(arbargtypes.supported, key) && return arbargtypes.supported[key]
    key in arbargtypes.unsupported && throw(UnsupportedArgumentType(key))
    throw(KeyError(key))
end

const arbargtypes = ArbArgTypes(
    Dict{String,DataType}(
        "void" => Cvoid,
        "void *" => Ptr{Cvoid},
        "int" => Cint,
        "slong" => Clong,
        "ulong" => Culong,
        "double" => Cdouble,
        "arf_t" => Arf,
        "arb_t" => Arb,
        "acb_t" => Acb,
        "mag_t" => Mag,
        "arb_srcptr" => ArbVector,
        "arb_ptr" => ArbVector,
        "acb_srcptr" => AcbVector,
        "acb_ptr" => AcbVector,
        "arb_mat_t" => ArbMatrix,
        "acb_mat_t" => AcbMatrix,
        "arf_rnd_t" => arb_rnd,
        "mpfr_t" => BigFloat,
        "mpfr_rnd_t" => Base.MPFR.MPFRRoundingMode,
        "mpz_t" => BigInt,
        "char *" => Cstring,
        "slong *" => Vector{Clong},
        "ulong *" => Vector{Culong},
    ),
    Set(["FILE *", "fmpr_t", "fmpr_rnd_t", "flint_rand_t", "bool_mat_t"]),
    Dict{DataType,String}(
        Cvoid => "void",
        Ptr{Cvoid} => "void *",
        Cint => "int",
        Clong => "slong",
        Culong => "ulong",
        Cdouble => "double",
        Arf => "arf_t",
        Arb => "arb_t",
        Acb => "acb_t",
        Mag => "mag_t",
        ArbVector => "arb_ptr",
        AcbVector => "acb_ptr",
        ArbMatrix => "arb_mat_t",
        AcbMatrix => "acb_mat_t",
        arb_rnd => "arf_rnd_t",
        BigFloat => "mpfr_t",
        Base.MPFR.MPFRRoundingMode => "mpfr_rnd_t",
        BigInt => "mpz_t",
        Cstring => "char *",
        Vector{Clong} => "slong *",
        Vector{Culong} => "ulong *",
    ),
)

struct Carg{ArgT}
    name::Symbol
    isconst::Bool
end

Carg{T}(n::AbstractString, isconst::Bool) where {T} = Carg{T}(Symbol(n), isconst)

Base.:(==)(a::Carg{T}, b::Carg{S}) where {T,S} =
    T == S && name(a) == name(b) && isconst(a) == isconst(b)

function Carg(str)
    m = match(r"(?<const>const)?\s*(?<type>\w+(\s\*)?)\s+(?<name>\w+)", str)
    isnothing(m) && throw(ArgumentError("string doesn't match c-argument pattern"))
    cnst =
        !isnothing(m[:const]) ||
        (!isnothing(m[:type]) && (m[:type] == "arb_srcptr" || m[:type] == "acb_srcptr"))
    return Carg{arbargtypes[m[:type]]}(m[:name], cnst)
end

name(ca::Carg) = ca.name
isconst(ca::Carg) = ca.isconst

rawtype(::Carg{T}) where {T} = T

jltype(ca::Carg) = rawtype(ca)
jltype(ca::Carg{Cint}) = Integer
jltype(ca::Carg{Clong}) = Integer
jltype(ca::Carg{Culong}) = Unsigned
jltype(ca::Carg{Cdouble}) = Base.GMP.CdoubleMax
jltype(ca::Carg{arb_rnd}) = Union{arb_rnd,RoundingMode}
jltype(ca::Carg{Base.MPFR.MPFRRoundingMode}) =
    Union{Base.MPFR.MPFRRoundingMode,RoundingMode}
jltype(ca::Carg{Cstring}) = AbstractString
jltype(ca::Carg{Vector{Clong}}) = Vector{<:Integer}
jltype(ca::Carg{Vector{Culong}}) = Vector{<:Unsigned}

jltype(::Carg{Mag}) = MagLike
jltype(::Carg{Arf}) = ArfLike
jltype(::Carg{Arb}) = ArbLike
jltype(::Carg{Acb}) = AcbLike
jltype(::Carg{ArbVector}) = ArbVectorLike
jltype(::Carg{AcbVector}) = AcbVectorLike
jltype(::Carg{ArbMatrix}) = ArbMatrixLike
jltype(::Carg{AcbMatrix}) = AcbMatrixLike

ctype(ca::Carg) = rawtype(ca)
ctype(::Carg{T}) where {T<:Union{ArbVector,arb_vec_struct}} = Ptr{arb_struct}
ctype(::Carg{T}) where {T<:Union{AcbVector,acb_vec_struct}} = Ptr{acb_struct}
ctype(::Carg{T}) where {T<:Union{Mag,Arf,Arb,Acb,ArbMatrix,AcbMatrix}} = Ref{cstructtype(T)}
ctype(::Carg{T}) where {T<:Union{BigFloat,BigInt}} = Ref{T}
ctype(::Carg{Vector{T}}) where {T} = Ref{T}

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
    prefixes = ("arf", "arb", "acb", "mag", "mat", "vec"),
    suffixes = ("si", "ui", "d", "mag", "arf", "arb", "mpfr", "str");
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
    prefixes = ("arf", "arb", "acb", "mag", "mat", "vec"),
    suffixes = ("si", "ui", "d", "mag", "arf", "arb", "mpfr", "str");
    inplace = inplace(af),
)
    return jlfname(arbfname(af), prefixes, suffixes, inplace = inplace)
end

function is_length_argument(carg, prev_carg, len_keywords)
    (startswith(string(name(carg)), "len") || carg == Carg{Clong}(:n, false)) &&
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
    len_keywords = Set{Symbol}()
    for (i, carg) in enumerate(cargs)
        if !argument_detection
            push!(jl_arg_names_types, (name(carg), jltype(carg)))
            continue
        end

        # Automatic detection of precision argument
        if carg == Carg{Clong}(:prec, false)
            @assert !prec_kwarg
            prec_kwarg = true

            # If the first argument has a precision,
            # then use this otherwise make it a mandatory kwarg
            if rawtype(cargs[1]) <: ArbTypes && rawtype(cargs[1]) != Mag
                push!(kwargs, Expr(:kw, :(prec::Integer), :(_precision($(name(cargs[1]))))))
            else
                push!(kwargs, :(prec::Integer))
            end

            # Automatic detection of rounding mode argument
        elseif carg == Carg{arb_rnd}(:rnd, false)
            @assert !rnd_kwarg
            rnd_kwarg = true

            push!(
                kwargs,
                Expr(:kw, :(rnd::Union{$(arb_rnd),RoundingMode}), :(RoundNearest)),
            )
        elseif carg == Carg{Base.MPFR.MPFRRoundingMode}(:rnd, false)
            @assert !rnd_kwarg
            rnd_kwarg = true
            push!(
                kwargs,
                Expr(
                    :kw,
                    :(rnd::Union{Base.MPFR.MPFRRoundingMode,RoundingMode}),
                    :(RoundNearest),
                ),
            )
            # Automatic detection of length arguments for vectors
        elseif i > 1 && is_length_argument(carg, cargs[i-1], len_keywords)
            extract_length_argument!(kwargs, len_keywords, carg, cargs[i-1])
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
