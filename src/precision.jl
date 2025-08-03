const DEFAULT_PRECISION = Ref{Int}(256)
const CURRENT_PRECISION = ScopedValues.ScopedValue{Int}()

"""
    _current_precision()

Get the current default precision to use for `Arblib` types. This
value can be set, either globally or within a dynamical scope, using
[`setprecision`](@ref).
"""
_current_precision() = @something(ScopedValues.get(CURRENT_PRECISION), DEFAULT_PRECISION[])

# Types
_precision_with_base_2(::Type{<:Union{ArbTypes,ArbStructTypes,Ptr{<:ArbStructTypes}}}) =
    _current_precision()
# Types not storing their precision
_precision_with_base_2(x::Union{ArbStructTypes,Ptr{<:ArbStructTypes}}) =
    _current_precision()
# Types storing their precision
_precision_with_base_2(x::ArbTypes) = x.prec
# Mag doesn't store a precision
_precision_with_base_2(::MagOrRef) = _current_precision()
# ArbSeries and AcbSeries don't store their precision directly
_precision_with_base_2(x::Union{ArbSeries,AcbSeries}) = _precision_with_base_2(x.poly)

function _precision_in_base(x, base::Integer)
    base > 1 || throw(DomainError(base, "`base` cannot be less than 2."))
    p = _precision_with_base_2(x)
    return base == 2 ? p : floor(Int, p / log2(base))
end

Base.precision(
    T::Type{<:Union{ArbTypes,ArbStructTypes,Ptr{<:ArbStructTypes}}};
    base::Integer = 2,
) = _precision_in_base(T, base)
Base.precision(x::Union{ArbTypes,ArbStructTypes,Ptr{<:ArbStructTypes}}; base::Integer = 2) =
    _precision_in_base(x, base)

# Used internally for determining the precision
@inline _precision(x::Union{ArbTypes,BigFloat}) = precision(x)
@inline _precision(z::Complex) = max(_precision(real(z)), _precision(imag(z)))
@inline _precision(v::Union{Tuple,AbstractVector}) =
    isempty(v) ? _current_precision() : _precision(first(v))
@inline _precision(
    a::Union{ArbTypes,BigFloat,Complex{<:Union{ArbTypes,BigFloat}}},
    b::Union{ArbTypes,BigFloat,Complex{<:Union{ArbTypes,BigFloat}}},
) = max(_precision(a), _precision(b))
@inline _precision(a::Union{ArbTypes,BigFloat,Complex{<:Union{ArbTypes,BigFloat}}}, _) =
    _precision(a)
@inline _precision(_, b::Union{ArbTypes,BigFloat,Complex{<:Union{ArbTypes,BigFloat}}}) =
    _precision(b)
@inline _precision(a, b) = max(_precision(a), _precision(b))
@inline _precision(@nospecialize _) = _current_precision()

@inline function _convert_precision_from_base(precision::Integer, base::Integer)
    base > 1 || throw(DomainError(base, "`base` cannot be less than 2."))
    precision > 1 || throw(DomainError(precision, "`precision` cannot be less than 2."))
    base == 2 ? Int(precision) : ceil(Int, precision * log2(base))
end

"""
    setprecision(::Type{<:ArbTypes}, precision::Integer; base::Integer = 2)
    setprecision(f::Function, ::Type{<:ArbTypes}, precision::Integer; base=2)

Set the default precision (in bits) to be used for `Arblib`
arithmetic. Note that the precision is shared for all `Arblib` types,
it doesn't matter which type you use to set the precision.

If `base` is specified, then the precision is the minimum required to
give at least `precision` digits in the given `base`.

The version taking `f::Function` as the first argument only changes
the precision withing the dynamic scope of `f`. It works similarly to:
```
old = precision(Arb)
setprecision(Arb, precision)
f()
setprecision(Arb, old)
```
but uses `Base.ScopedValues.ScopedValue` to allow changing the default
precision only inside the dynamic scope of `f`.

!!! warning
    The version without `f::Function` is not thread-safe. It will
    affect code running on all threads, but its behavior is undefined
    if called concurrently with computations that use the setting. The
    version with `f::Function` is thread-safe.

Note that most `Arblib` types store their own precision and that value
is used for most computations, the default precision is primarily used
in the construction of new values. This is contrary to `BigFloat` for
which the default precision is used for (almost) all computations. As
an example we have:
```jldoctest
julia> x = Arb(0) # Default precision is 256 bits
0

julia> acos(x)
[1.5707963267948966192313216916397514420985846996875529104874722961539082031431 +/- 9.63e-78]

julia> setprecision(Arb, 128) do
           acos(x) # Still computed using 256 bits since that is the precision of x
       end
[1.5707963267948966192313216916397514420985846996875529104874722961539082031431 +/- 9.63e-78]

julia> y = BigFloat(0) # Default precision is 256 bits
0.0

julia> acos(y)
1.570796326794896619231321691639751442098584699687552910487472296153908203143099

julia> setprecision(BigFloat, 128) do
           acos(y)
       end
1.570796326794896619231321691639751442098
```
"""
function Base.setprecision(::Type{<:ArbTypes}, precision::Integer; base::Integer = 2)
    DEFAULT_PRECISION[] = _convert_precision_from_base(precision, base)
    return precision
end

function Base.setprecision(
    f::Function,
    ::Type{T},
    precision::Integer;
    base::Integer = 2,
) where {T<:ArbTypes}
    ScopedValues.@with(
        CURRENT_PRECISION => _convert_precision_from_base(precision, base),
        f()
    )
end

"""
    setprecision(x::ArbTypes, precision::Int; base::Integer = 2)

Return a copy of `x` with the precision set to the given value.
"""
function Base.setprecision(x::T, precision::Integer; base::Integer = 2) where {T<:ArbTypes}
    return T(x, prec = _convert_precision_from_base(precision, base))
end
