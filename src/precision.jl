const DEFAULT_PRECISION = Ref{Int}(256)

let f
    f = if VERSION < v"1.11.0-DEV.1363"
        # Since Julia 1.8.0 Base.precision calls Base._precision and by
        # overloading that we automatically support giving base argument.
        # Ref: https://github.com/JuliaLang/julia/pull/42428
        :_precision
    else
        # Since Julia 1.11.0, the single-argument `Base._precision` is
        # renamed to `Base._precision_with_base_2`
        # Ref: https://github.com/JuliaLang/julia/pull/52910
        :_precision_with_base_2
    end

    @eval begin
        # Types
        Base.$f(::Type{<:Union{ArbTypes,ArbStructTypes,Ptr{<:ArbStructTypes}}}) =
            DEFAULT_PRECISION[]
        # Types not storing their precision
        Base.$f(x::Union{ArbStructTypes,Ptr{<:ArbStructTypes}}) = DEFAULT_PRECISION[]
        # Types storing their precision
        Base.$f(x::ArbTypes) = x.prec
        # Mag doesn't store a precision
        Base.$f(::MagOrRef) = DEFAULT_PRECISION[]
        # ArbSeries and AcbSeries don't store their precision directly
        Base.$f(x::Union{ArbSeries,AcbSeries}) = Base.$f(x.poly)
    end
end

# Base.precision only allows AbstractFloat, we want to be able to use
# all ArbLib types.
# Hence we have to define `Base.precision` on Julia versions for which
# it is not defined above
Base.precision(
    T::Type{<:Union{ArbTypes,ArbStructTypes,Ptr{<:ArbStructTypes}}};
    base::Integer = 2,
) = Base._precision(T, base)
Base.precision(x::Union{ArbTypes,ArbStructTypes,Ptr{<:ArbStructTypes}}; base::Integer = 2) =
    Base._precision(x, base)

# Used internally for determining the precision
@inline _precision(x::Union{ArbTypes,BigFloat}) = precision(x)
@inline _precision(z::Complex) = max(_precision(real(z)), _precision(imag(z)))
@inline _precision(v::Union{Tuple,AbstractVector}) =
    isempty(v) ? DEFAULT_PRECISION[] : _precision(first(v))
@inline _precision(
    a::Union{ArbTypes,BigFloat,Complex{<:Union{ArbTypes,BigFloat}}},
    b::Union{ArbTypes,BigFloat,Complex{<:Union{ArbTypes,BigFloat}}},
) = max(_precision(a), _precision(b))
@inline _precision(a::Union{ArbTypes,BigFloat,Complex{<:Union{ArbTypes,BigFloat}}}, _) =
    _precision(a)
@inline _precision(_, b::Union{ArbTypes,BigFloat,Complex{<:Union{ArbTypes,BigFloat}}}) =
    _precision(b)
@inline _precision(a, b) = max(_precision(a), _precision(b))
@inline _precision(@nospecialize _) = DEFAULT_PRECISION[]

"""
    setprecision(::Type{<:ArbTypes}, precision::Int; base::Integer = 2)

Set the precision (in bits) to be used for `Arblib` arithmetic. Note
that the precision is shared for all types, it doesn't matter which
type you use to set the precision.

If `base` is specified, then the precision is the minimum required to
give at least `precision` digits in the given `base`.

!!! warning
    This function is not thread-safe. It will affect code running on all threads, but
    its behavior is undefined if called concurrently with computations that use the
    setting.
"""
function Base.setprecision(::Type{<:ArbTypes}, precision::Integer; base::Integer = 2)
    base > 1 || throw(DomainError(base, "`base` cannot be less than 2."))
    precision > 1 || throw(DomainError(precision, "`precision` cannot be less than 2."))
    DEFAULT_PRECISION[] = base == 2 ? precision : ceil(Int, precision * log2(base))
    return precision
end

function Base.setprecision(x::T, precision::Integer; base::Integer = 2) where {T<:ArbTypes}
    base > 1 || throw(DomainError(base, "`base` cannot be less than 2."))
    precision > 1 || throw(DomainError(precision, "`precision` cannot be less than 2."))
    return T(x, prec = base == 2 ? precision : ceil(Int, precision * log2(base)))
end

# Since Julia 1.12, `Base.setprecision(::Function, ::Type, ::Integer; kwargs...)` is
# defined only for `Type{BigFloat}`
# Ref: https://github.com/JuliaLang/julia/pull/51362
if VERSION >= v"1.12.0-DEV.78"
    function Base.setprecision(
        f::Function,
        ::Type{T},
        prec::Integer;
        kws...,
    ) where {T<:ArbTypes}
        old_prec = Base.precision(T)
        Base.setprecision(T, prec; kws...)
        try
            return f()
        finally
            Base.setprecision(T, old_prec)
        end
    end
end
