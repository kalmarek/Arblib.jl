digits_prec(prec::Integer) = max(floor(Int, prec * (log(2) / log(10))), 1)

function _remove_trailing_zeros(str::AbstractString)
    if occursin('.', str)
        if occursin('e', str)
            # Numbers on the form xxx.yyy0ezzz
            mantissa, exponent = split(str, 'e', limit = 2)
            mantissa = rstrip(mantissa, '0')
            if endswith(mantissa, '.') || endswith(mantissa, '}')
                mantissa *= '0'
            end
            str = mantissa * 'e' * exponent
        else
            # Numbers on the form xxx.yyy0
            str = rstrip(str, '0')
            if endswith(str, '.') || endswith(str, '}')
                str *= '0'
            end
        end
    end

    return str
end

function _string(x::MagOrRef)
    Libc.flush_cstdio()
    Base.flush(stdout)
    io = IOStream("arb")
    original_stdout = stdout
    out_rd, out_wr = redirect_stdout()
    try
        ccall(@libflint(mag_print), Cvoid, (Ref{mag_struct},), x)
        Libc.flush_cstdio()
    finally
        redirect_stdout(original_stdout)
        close(out_wr)
    end
    return read(out_rd, String)
end

function Base.string(
    x::MagOrRef;
    digits::Integer = digits_prec(30),
    remove_trailing_zeros::Bool = true,
)
    return string(Arf(x); digits, remove_trailing_zeros)
end

function Base.string(
    x::ArfOrRef;
    digits::Integer = digits_prec(precision(x)),
    remove_trailing_zeros::Bool = true,
)
    cstr = ccall(@libflint(arf_get_str), Ptr{UInt8}, (Ref{arf_struct}, Int), x, digits)
    str = unsafe_string(cstr)
    ccall(@libflint(flint_free), Nothing, (Ptr{UInt8},), cstr)

    return remove_trailing_zeros ? _remove_trailing_zeros(str) : str
end

function Base.string(
    z::AcfOrRef;
    digits::Integer = digits_prec(precision(z)),
    remove_trailing_zeros::Bool = true,
)
    str = string(realref(z); digits, remove_trailing_zeros)
    if !isreal(z)
        str *= " + " * string(imagref(z); digits, remove_trailing_zeros) * "im"
    end

    return str
end

"""
    string(x::ArbOrRef; digits, more, no_radius, condense, unicode, remove_trailing_zeros)

Convert `x` to a decimal string. By default, this uses the
midpoint-radius format "[m ± r]".

With default flags, the output can be parsed back as `Arb(string(x))`,
and this is guaranteed to produce an interval containing the original
interval `x` (but is generally wider). For lossless, but not human
readable, serialization as a string, see [`dump_string`](@ref) and
[`load_string`](@ref).

By default, the output is rounded so that the value given for the
midpoint is correct up to 1 ulp (unit in the last decimal place).

!!! warning
    The output can be confusing for wide inputs, when the radius is
    too large for even the first digit to be known up to 1 ulp. In
    this case the interval is printed in the format `[+/- R]` where
    `R` is an upper bound for the absolute value of `x`. The `more`
    keyword argument (see below) can then be used (possibly in
    combination with `digits`) to print more digits, which are however
    no longer guaranteed to be correct within 1 ulp.
    ```jldoctest
    julia> x = Arb((1, 2));

    julia> string(x)
    "[+/- 2.01]"

    julia> string(x, more = true)
    "[1.5000000000000000000000000000000000000000000000000000000000000000000000000000 +/- 0.501]"

    julia> string(x, digits = 5, more = true)
    "[1.5000 +/- 0.501]"
    ```
    The [`getball`](@ref) and [`getinterval`](@ref) functions can also
    be useful in this case.

# Keyword Arguments
- `digits::Integer = digits_prec(precision(x))`: The number of digits
  to display.
- `more::Bool = false`: If `true`, display more (possibly incorrect)
  digits.
- `no_radius::Bool = false`: If `true`, the radius is not displayed in
  the output. Unless `more` is set, the output is rounded so that the
  midpoint is correct to 1 ulp. As a special case, if there are no
  significant digits after rounding, the result will be shown as
  ``0e+n``, meaning that the result is between ``-1e+n`` and ``1e+n``
  (following the contract that the output is correct to within one
  unit in the only shown digit).
- `condense::Integer = 0`: If non-zero, strings of more than three
  times `condense` consecutive digits are condensed, only printing the
  leading and trailing `condense` digits along with brackets
  indicating the number of digits omitted (useful when computing
  values to extremely high precision).
- `unicode::Bool = false`: If `true`, use unicode characters in the
  output in the output, e.g., `±` instead of `+/-`.
- `remove_trailing_zeros::Bool = !no_radius`: If `true`, remove
  trailing zeros after the decimal point.

# Examples
```jldoctest
julia> x = Arb(π, prec = 64);

julia> string(x)
"[3.141592653589793239 +/- 5.96e-19]"

julia> string(x; no_radius=true)
"3.141592653589793239"

julia> y = Arb((1, 2), prec = 64);

julia> string(y)
"[+/- 2.01]"

julia> string(y, more = true)
"[1.500000000000000000 +/- 0.501]"

julia> string(y, digits = 30, more = true)
"[1.50000000000000000000000000000 +/- 0.501]"

julia> z = Arb(π, prec = 512);

julia> string(z)
"[3.141592653589793238462643383279502884197169399375105820974944592307816406286208998628034825342117067982148086513282306647093844609550582231725359408128481 +/- 2.99e-154]"

julia> string(z, condense = 2, unicode = true)
"[3.14{…149 digits…}81 ± 2.99e-154]"
```
"""
function Base.string(
    x::ArbOrRef;
    digits::Integer = digits_prec(precision(x)),
    more::Bool = false,
    no_radius::Bool = false,
    condense::Integer = 0,
    unicode::Bool = false,
    remove_trailing_zeros::Bool = !no_radius,
)
    flag = convert(UInt, more + 2no_radius + 16condense)

    cstr = ccall(
        @libflint(arb_get_str),
        Ptr{UInt8},
        (Ref{arb_struct}, Int, UInt),
        x,
        digits,
        flag,
    )
    str = unsafe_string(cstr)
    ccall(@libflint(flint_free), Nothing, (Ptr{UInt8},), cstr)

    if unicode
        str = replace(replace(str, "+/-" => "±"), "..." => "…")
    end

    if remove_trailing_zeros && !startswith(str, '[')
        str = _remove_trailing_zeros(str)
    end

    return str
end

function Base.string(
    z::AcbOrRef;
    digits::Integer = digits_prec(precision(z)),
    more::Bool = false,
    no_radius::Bool = false,
    condense::Integer = 0,
    unicode::Bool = false,
    remove_trailing_zeros::Bool = true,
)
    kwargs = (
        :digits => digits,
        :more => more,
        :no_radius => no_radius,
        :condense => condense,
        :unicode => unicode,
        :remove_trailing_zeros => remove_trailing_zeros,
    )

    str = string(realref(z); kwargs...)
    if !isreal(z)
        str *= " + " * string(imagref(z); kwargs...) * "im"
    end

    return str
end

function Base.show(io::IO, x::Union{MagOrRef,ArfOrRef,AcfOrRef})
    if Base.get(io, :compact, false)
        digits = min(6, digits_prec(precision(x)))
        print(io, string(x; digits))
    else
        print(io, string(x))
    end
end

function Base.show(io::IO, x::Union{ArbOrRef,AcbOrRef})
    if Base.get(io, :compact, false) && rel_accuracy_bits(x) > 48
        str = string(x, condense = 2, unicode = true)
        if isexact(x)
            # For exact values the shortest output is in some cases
            # not given by condensing the decimal digits, but by
            # removing trailing zeros. We try both options and take
            # the shortest.

            str_alt = string(x)

            if length(str_alt) < length(str)
                str = str_alt
            end
        end
        print(io, str)
    else
        print(io, string(x))
    end
end

function Base.show(io::IO, poly::T) where {T<:Union{ArbPoly,ArbSeries,AcbPoly,AcbSeries}}
    if (T == ArbPoly || T == AcbPoly) && iszero(poly)
        print(io, "0")
    end

    # We only want to print up until the last non-zero element, for
    # ArbPoly and AcbPoly this is given by the degree, for ArbSeries
    # and AcbSeries we get this by taking the degree of the underlying
    # polynomial.
    N = degree(cstruct(poly))
    for i = 0:N
        x = poly[i]
        if !iszero(x)
            str =
                ifelse(!isreal(x), "(", "") *
                "$x" *
                ifelse(!isreal(x), ")", "") *
                ifelse(i > 0, "⋅x", "") *
                ifelse(i > 1, "^$i", "") *
                ifelse(i != N, " + ", "")
            print(io, str)
        end
    end

    if T == ArbSeries || T == AcbSeries
        str =
            ifelse(iszero(poly), "", " + ") *
            "𝒪(x" *
            ifelse(degree(poly) == 0, "", "^$(degree(poly) + 1)") *
            ")"
        print(io, str)
    end
end

function load_string!(x::Union{MagLike,ArfLike,ArbLike}, str::AbstractString)
    res = load!(x, str)
    iszero(res) || throw(ArgumentError("could not load $str as $(string(typeof(x)))"))
    return x
end

"""
    load_string(T::Type{<:Union{Mag,Arf,Arb}}, str::AbstractString)

Parse a string `str` as outputted by [`dump_string`](@ref) and return
an identical new object of type `T`.
"""
load_string(T::Type{<:Union{Mag,Arf,Arb}}, str::AbstractString) = load_string!(zero(T), str)

"""
    dump_string(x::Union{MagLike,ArfLike,ArbLike})

Return a serialized string representation of `x`.

The result can be read back in using [`load_string`](@ref).

For human readable output, see [`string`](@ref).
"""
function dump_string(x::Union{MagLike,ArfLike,ArbLike})
    char_ptr = dump(x)
    str = unsafe_string(char_ptr)
    ccall(@libflint(flint_free), Cvoid, (Cstring,), char_ptr)
    return str
end

for T in [
    :MagLike,
    :ArfLike,
    :AcfLike,
    :ArbLike,
    :AcbLike,
    :ArbVectorLike,
    :AcbVectorLike,
    :ArbMatrixLike,
    :AcbMatrixLike,
    :ArbPolyLike,
    :AcbPolyLike,
]
    @eval Base.show(io::IO, ::Type{$T}) = print(io, $(QuoteNode(T)))
end
