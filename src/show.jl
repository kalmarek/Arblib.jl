digits_prec(prec::Integer) = floor(Int, prec * log(2) / log(10))

Base.show(io::IO, x::Union{Arb, Acb}) = print(io, string_nice(x))
Base.show(io::IO, x::Arf) = print(io, string_decimal(x))

for ArbT in (Arf, Arb, Acb, Mag)
    arbf = Symbol(cprefix(ArbT), :_, :print)
    @eval begin
        function _string(x::$ArbT)
            Libc.flush_cstdio()
            Base.flush(stdout)
            original_stdout = stdout
            out_rd, out_wr = redirect_stdout()
            try
                ccall(@libarb($arbf), Cvoid, (Ref{$ArbT},), x)
                Libc.flush_cstdio()
            finally
                redirect_stdout(original_stdout)
                close(out_wr)
            end
            return read(out_rd, String)
        end
    end

    ArbT == Mag && continue # no mag_printd and mag_printn

    arbf = Symbol(cprefix(ArbT), :_printd)
    @eval begin
        function string_decimal(x::$ArbT, digits::Integer=digits_prec(x.prec))
            Libc.flush_cstdio()
            Base.flush(stdout)
            original_stdout = stdout
            out_rd, out_wr = redirect_stdout()
            try
                ccall(@libarb($arbf), Cvoid, (Ref{$ArbT}, Clong), x, digits)
                Libc.flush_cstdio()
            finally
                redirect_stdout(original_stdout)
                close(out_wr)
            end
            return read(out_rd, String)
        end
    end

    ArbT == Arf && continue #no arf_printn

    arbf = Symbol(cprefix(ArbT), :_, :printn)
    @eval begin
        function string_nice(x::$ArbT, digits::Integer=digits_prec(x.prec), flags::UInt=UInt(0))
            Libc.flush_cstdio()
            Base.flush(stdout)
            original_stdout = stdout
            out_rd, out_wr = redirect_stdout()
            try
                ccall(@libarb($arbf), Cvoid, (Ref{$ArbT}, Clong, Culong), x, digits, flags)
                Libc.flush_cstdio()
            finally
                redirect_stdout(original_stdout)
                close(out_wr)
            end
            return read(out_rd, String)
        end
    end
end

for ArbT in (Arf, Arb, Mag)
    jlf = :_load_string!
    arbf = Symbol(cprefix(ArbT), :_load_str)
    @eval begin
        function $(jlf)(x::$ArbT, str::AbstractString)
            res = ccall(@libarb($arbf), Cint, (Ref{$ArbT}, Cstring), x, str)
            iszero(res) || throw(ArgumentError("arblib could not load_str $str as "*$(string(ArbT))))
            return x
        end
    end

    jlf = :_dump_string
    arbf = Symbol(cprefix(ArbT), :_dump_str)
    @eval begin
        function $(jlf)(x::$ArbT)
            char_ptr = ccall(@libarb($arbf), Cstring, (Ref{$ArbT},), x)
            str = unsafe_string(char_ptr)
            ccall((:flint_free, libflint), Cvoid, (Cstring,), char_ptr)
            return str
        end
    end
end
