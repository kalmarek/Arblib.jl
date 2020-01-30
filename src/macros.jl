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
