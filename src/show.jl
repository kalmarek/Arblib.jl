digits_prec(prec::Integer) = floor(Int, prec * (log(2) / log(10)))

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

function Base.string(x::MagOrRef; digits::Integer = digits_prec(30))
    cstr = ccall(@libflint(arf_get_str), Ptr{UInt8}, (Ref{arf_struct}, Int), Arf(x), digits)
    str = unsafe_string(cstr)
    ccall(@libflint(flint_free), Nothing, (Ptr{UInt8},), cstr)

    return str
end

function Base.string(x::ArfOrRef; digits::Integer = digits_prec(precision(x)))
    cstr = ccall(@libflint(arf_get_str), Ptr{UInt8}, (Ref{arf_struct}, Int), x, digits)
    str = unsafe_string(cstr)
    ccall(@libflint(flint_free), Nothing, (Ptr{UInt8},), cstr)

    return str
end

function Base.string(
    x::ArbOrRef;
    digits::Integer = digits_prec(precision(x)),
    more::Bool = false,
    no_radius::Bool = false,
    condense::Integer = 0,
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

    return str
end

function Base.string(
    z::AcbOrRef;
    digits::Integer = digits_prec(precision(z)),
    more::Bool = false,
    no_radius::Bool = false,
    condense::Integer = 0,
)
    str = string(realref(z); digits, more, no_radius, condense)

    if !iszero(imagref(z))
        str *= " + " * string(imagref(z); digits, more, no_radius, condense) * "im"
    end

    return str
end

function Base.show(io::IO, x::Union{MagOrRef,ArfOrRef})
    if Base.get(io, :compact, false)
        digits = min(6, digits_prec(precision(x)))
        print(io, string(x; digits))
    else
        print(io, string(x))
    end
end

Base.show(io::IO, x::Union{ArbOrRef,AcbOrRef}) = print(io, string(x))

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

load_string(T::Type{<:Union{Mag,Arf,Arb}}, str::AbstractString) = load_string!(zero(T), str)

function dump_string(x::Union{MagLike,ArfLike,ArbLike})
    char_ptr = dump(x)
    str = unsafe_string(char_ptr)
    ccall(@libflint(flint_free), Cvoid, (Cstring,), char_ptr)
    return str
end

for T in [
    :MagLike,
    :ArfLike,
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
