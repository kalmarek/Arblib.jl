digits_prec(prec::Integer) = floor(Int, prec * (log(2) / log(10)))

function _string(x::MagOrRef)
    Libc.flush_cstdio()
    Base.flush(stdout)
    io = IOStream("arb")
    original_stdout = stdout
    out_rd, out_wr = redirect_stdout()
    try
        ccall(@libarb(mag_print), Cvoid, (Ref{mag_struct},), x)
        Libc.flush_cstdio()
    finally
        redirect_stdout(original_stdout)
        close(out_wr)
    end
    return read(out_rd, String)
end

function Base.show(io::IO, x::MagOrRef)
    if isdefined(Main, :IJulia) && Main.IJulia.inited
        print(io, Float64(x))
    else
        print(io, _string(x))
    end
end

Base.show(io::IO, x::ArfOrRef) = print(io, BigFloat(x))

function Base.show(io::IO, x::ArbOrRef)
    cstr = ccall(
        @libarb(arb_get_str),
        Ptr{UInt8},
        (Ref{arb_struct}, Int, UInt),
        x,
        digits_prec(precision(x)),
        UInt(0),
    )
    print(io, unsafe_string(cstr))
    ccall(@libflint(flint_free), Nothing, (Ptr{UInt8},), cstr)
end

function Base.show(io::IO, x::AcbOrRef)
    show(io, realref(x))
    if !iszero(imagref(x))
        print(io, " + ")
        show(io, imagref(x))
        print(io, "im")
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

for ArbT in (Mag, MagRef, Arf, ArfRef, Arb, ArbRef, Acb, AcbRef)
    arbf = Symbol(cprefix(ArbT), :_, :print)
    @eval begin
        function string_nice(
            x::$ArbT,
            digits::Integer = digits_prec(precision(x)),
            flags::UInt = UInt(0),
        )
            Libc.flush_cstdio()
            Base.flush(stdout)
            original_stdout = stdout
            out_rd, out_wr = redirect_stdout()
            try
                printn(x, digits, flags)
                Libc.flush_cstdio()
            finally
                redirect_stdout(original_stdout)
                close(out_wr)
            end
            return read(out_rd, String)
        end
    end
end

for ArbT in (Mag, MagRef, Arf, ArfRef, Arb, ArbRef)
    @eval begin
        function load_string!(x::$ArbT, str::AbstractString)
            res = load!(x, str)
            iszero(res) || throw(ArgumentError("could not load $str as " * $(string(ArbT))))
            return x
        end

        function dump_string(x::$ArbT)
            char_ptr = dump(x)
            str = unsafe_string(char_ptr)
            ccall(@libflint(flint_free), Cvoid, (Cstring,), char_ptr)
            return str
        end
    end
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
]
    @eval Base.show(io::IO, ::Type{$T}) = print(io, $(QuoteNode(T)))
end
