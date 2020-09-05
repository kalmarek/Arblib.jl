digits_prec(prec::Integer) = floor(Int, prec * log(2) / log(10))

Base.show(io::IO, x::Mag) = print(io, _string(x))
Base.show(io::IO, x::Union{Arb,ArbRef,Acb,AcbRef}) = print(io, string_nice(x))
Base.show(io::IO, x::Arf) = print(io, string_decimal(x))

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

for ArbT in (Mag, Arf, Arb, ArbRef, Acb, AcbRef)
    arbf = Symbol(cprefix(ArbT), :_, :print)
    @eval begin
        function _string(x::$ArbT)
            Libc.flush_cstdio()
            Base.flush(stdout)
            original_stdout = stdout
            out_rd, out_wr = redirect_stdout()
            try
                ccall(@libarb($arbf), Cvoid, (Ref{$(cstructtype(ArbT))},), x)
                Libc.flush_cstdio()
            finally
                redirect_stdout(original_stdout)
                close(out_wr)
            end
            return read(out_rd, String)
        end
    end

    ArbT == Mag && continue # no mag_printd and mag_printn

    @eval begin
        function string_decimal(x::$ArbT, digits::Integer = digits_prec(precision(x)))
            Libc.flush_cstdio()
            Base.flush(stdout)
            original_stdout = stdout
            out_rd, out_wr = redirect_stdout()
            try
                printd(x, digits)
                Libc.flush_cstdio()
            finally
                redirect_stdout(original_stdout)
                close(out_wr)
            end
            return read(out_rd, String)
        end
    end

    ArbT == Arf && continue #no arf_printn

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

for ArbT in (Mag, Arf, Arb)
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
