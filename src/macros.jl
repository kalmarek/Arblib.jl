macro libarb(function_name)
    return (:($function_name), libarb)
end

argsymbol(x::Symbol) = x
argsymbol(x::Expr) = (@assert x.head == Symbol("::"); argsymbol(first(x.args)))

function digest_call(function_call)
    templates = []
    if function_call.head == :where
        templates = function_call.args[2:end]
        function_call = function_call.args[1]
    end
    @assert function_call.head == :call
    fname = function_call.args[1]
    args = Symbol[ argsymbol(x) for x in function_call.args[2:end]]

    return fname, args, templates
end


function from_inplace(res, fname, args, templates)
    inplace_fname = Symbol(fname, "!")
    if isempty(templates)
        expr = :(
            function $fname($(args...))
                res = $(res)
                return $(inplace_fname)(res, $(args...))
            end
        )
    else
        expr = :(
            function $fname($(args...)) where {$(templates)...}
                res = $(res)
                return $(inplace_fname)(res, $(args...))
            end
        )
    end
    return expr
end

macro frominplace(function_call)
    fname, args, templates = digest_call(function_call)
    @assert !isempty(args)

    if args[1] isa Expr && args[1].head == Symbol("::")
        # the empty constructor of the type of the first argument
        res = :($(args[1].args[2])())
    else
        res = :(typeof($(first(args)))())
    end

    return from_inplace(res, fname, args, templates)
end

macro frominplace(res, function_call)
    fname, args, templates = digest_call(function_call)
    return from_inplace(res, fname, args, templates)
end

macro libcall(name::Symbol, n::Int, opts...)
    inplace = true
    prec = false
    for opt in opts
        if opt isa Expr && opt.head == :(=)
            if opt.args[1] == :inplace
                inplace = opt.args[2]::Bool
            elseif opt.args[1] == :prec
                prec = opt.args[2]::Bool
            else
                throw(UndefKeywordError(opts.args[1]))
            end
        else
            throw(ArgumentError("Unexpected argument: $opt"))
        end
    end

    typename, fname = split(String(name), "_"; limit = 2)
    T = Symbol(titlecase(typename))

    arg_names = Any[Symbol(:x, i) for i = 1:n]
    arg_types = Symbol[T for _ in 1:n]
    ccall_types = Any[:(Ref{$T}) for _ in 1:n]

    if endswith(fname, "_si")
        fname = chop(fname; tail = 3)
        push!(ccall_types, :Clong)
        push!(arg_names, :e)
        push!(arg_types, :Integer)
    elseif endswith(fname, "_ui")
        fname = chop(fname; tail = 3)
        push!(ccall_types, :Culong)
        push!(arg_names, :e)
        push!(arg_types, :Integer)
    end

    args = map(arg_names, arg_types) do x, T
        :($x::$T)
    end

    if prec
        push!(args, :(prec::Integer=precision($(arg_names[1]))))
        push!(ccall_types, :Clong)
        push!(arg_names, :prec)
    end

    fsymb = inplace ? Symbol(fname, "!") : Symbol(fname)

    quote
        function $(esc(fsymb))($(args...))
            ccall(
                ($(QuoteNode(name)), libarb),
                Cvoid,
                $(Expr(:tuple, ccall_types...)),
                $(arg_names...),
            )
            $(arg_names[1])
        end
    end
end
