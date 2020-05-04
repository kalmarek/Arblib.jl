@testset "Carg" begin
    # Supported types
    for (str, name, isconst, jltype, ctype) in (("mag_t res", "res", false, Arblib.Mag, Ref{Arblib.Mag}),
        ("arf_t res", "res", false, Arf, Ref{Arf}),
        ("arb_t res", "res", false, Arb, Ref{Arb}),
        ("acb_t res", "res", false, Acb, Ref{Acb}),
        ("int flags", "flags", false, Integer, Cint),
        ("slong x", "x", false, Integer, Clong),
        ("ulong x", "x", false, Unsigned, Culong),
        ("double x", "x", false, Base.GMP.CdoubleMax, Cdouble),
        ("arf_rnd_t rnd", "rnd", false, Union{Arblib.arb_rnd, RoundingMode}, Arblib.arb_rnd),
        ("const mag_t x", "x", true, Arblib.Mag, Ref{Arblib.Mag}),
        ("const arf_t x", "x", true, Arf, Ref{Arf}),
        ("const arb_t x", "x", true, Arb, Ref{Arb}),
        ("const acb_t x", "x", true, Acb, Ref{Acb}),
        ("const char * inp", "inp", true, Cstring, Cstring),
    )
        arg = Arblib.Carg(str)
        @test Arblib.name(arg) == name
        @test Arblib.isconst(arg) == isconst
        @test Arblib.jltype(arg) == jltype
        @test Arblib.ctype(arg) == ctype
    end

    # Unsupported types
    for str in ("fmpz_t x",
                "fmpq_t x",
                "mag_ptr res",
                "arb_ptr res",
                "acb_ptr res",
                "const fmpz_t x",
                "const fmpq_t x",
                "mag_srcptr res",
                "arb_srcptr res",
                "acb_srcptr res",

                # Internal types
                "mpfr_rnd_t rnd",
                "mp_limb_t lo",
                "mp_bitcnt_t r",
                "mp_ptr ycos",
                "mp_srcptr x",
                )
        @test_throws KeyError arg = Arblib.Carg(str)
    end

    # Parsed incorrectly
    for str in (
                "mp_limb_t * error",
                "mp_bitcnt_t * Qexp",
                )
        @test_throws KeyError arg = Arblib.Carg(str)
    end


    # Parse errors
    for str in (# Internal types
                )
        @test_throws ArgumentError arg = Arblib.Carg(str)
    end
end

@testset "jlfname" begin
    for (arbfname, name) in (# Supported types
                             ("mag_set", :set),
                             ("mag_set_d", :set),
                             ("mag_set_ui", :set),
                             ("arf_set", :set),
                             ("arf_set_ui", :set),
                             ("arf_set_si", :set),
                             ("arf_set_d", :set),
                             ("arb_set", :set),
                             ("arb_set_arf", :set),
                             ("arb_set_si", :set),
                             ("arb_set_ui", :set),
                             ("arb_set_d", :set),
                             ("acb_set", :set),
                             ("acb_set_ui", :set),
                             ("acb_set_si", :set),
                             ("acb_set_d", :set),
                             ("acb_set_arb", :set),
                             ("acb_set_si_si", :set),
                             ("acb_set_d_d", :set),
                             ("acb_set_arb_arb", :set),

                             # Unsupported types
                             ("arf_set_fmpz", :set_fmpz),
                             ("arf_set_mpfr", :set_mpfr),
                             ("acb_set_fmpq", :set_fmpq),
                             ("arb_bin_uiui", :bin_uiui),

                             # Deprecated types
                             ("arf_set_mpz", :set_mpz),
                             ("arf_set_fmpr", :set_fmpr),

                             # Underscore methods
                             ("_arb_vec_set", :_arb_vec_set),

                             # Some special cases to be aware of and maybe change
                             ("mag_set_d_lower", :set_d_lower),
                             ("arb_ui_div", :ui_div),
                             ("arb_rising_ui_rec", :rising_ui_rec),
                             ("arb_zeta_ui_vec", :zeta_ui_vec),
                             )
        @test Arblib.jlfname(arbfname) == name
        @test Arblib.jlfname(arbfname, inplace = true) == Symbol(name, :!)
    end
end

@testset "returntype" begin
    # Supported return types
    for (str, T) in (("void arb_init(arb_t x)", Nothing),
                     ("slong arb_rel_error_bits(const arb_t x)", Int),
                     ("int arb_is_zero(const arb_t x)", Int32),
                     ("double arf_get_d(const arf_t x, arf_rnd_t rnd)", Float64))
        @test Arblib.returntype(Arblib.Arbfunction(str)) == T
    end

    # Unsupported return types
    for str in ("mag_ptr _mag_vec_init(slong n)",
                "arb_ptr _arb_vec_init(slong n)",
                "acb_ptr _acb_vec_init(slong n)",
                )
        @test_throws KeyError Arblib.Arbfunction(str)
    end

    # Return types with parse errors
    for str in ()
        @test_throws ArgumentError Arblib.Arbfunction(str)
    end
end

@testset "jlargs" begin
    for (str, args, kwargs) in (("void arb_init(arb_t x)",
                                 [:(x::$Arb)],
                                 Expr[]),
                                ("void arb_add(arb_t z, const arb_t x, const arb_t y, slong prec)",
                                 [:(z::$Arb), :(x::$Arb), :(y::$Arb)],
                                 [Expr(:kw, :(prec::Integer), :(precision(z)))]),
                                ("int arf_add(arf_t res, const arf_t x, const arf_t y, slong prec, arf_rnd_t rnd)",
                                 [:(res::$Arf), :(x::$Arf), :(y::$Arf)],
                                 [Expr(:kw, :(prec::Integer), :(precision(res))),
                                  Expr(:kw, :(rnd::Union{arb_rnd, RoundingMode}), :(RoundNearest))])
                                )
        (a, k) = Arblib.jlargs(Arblib.Arbfunction(str))
        @test a == args
        @test k == kwargs
    end
end

@testset "arbsignature" begin
    for str in ("void arb_init(arb_t x)",
                "slong arb_rel_error_bits(const arb_t x)",
                "int arb_is_zero(const arb_t x)",
                "void arb_add(arb_t z, const arb_t x, const arb_t y, slong prec)",
                "void arb_add_arf(arb_t z, const arb_t x, const arf_t y, slong prec)",
                "void arb_add_ui(arb_t z, const arb_t x, ulong y, slong prec)",
                "void arb_add_si(arb_t z, const arb_t x, slong y, slong prec)",
                "void arb_sin(arb_t s, const arb_t x, slong prec)",
                "void arb_cos(arb_t c, const arb_t x, slong prec)",
                "void arb_sin_cos(arb_t s, arb_t c, const arb_t x, slong prec)",
                # Pointer
                "char * arb_get_str(const arb_t x, slong n, ulong flags)",
                )
        @test Arblib.arbsignature(Arblib.Arbfunction(str)) == str
    end
end

@testset "jlcode" begin
    x = Arb(1)
    y = Arb(2)
    z = Arb(0)

    Arblib.@arbcall_str "void arb_add(arb_t z, const arb_t x, const arb_t y, slong prec)"
    @test typeof(Arblib.add!(z, x, y)) == Nothing

    Arblib.@arbcall_str "slong arb_rel_error_bits(const arb_t x)"
    @test typeof(Arblib.rel_error_bits(x)) == Int64

    Arblib.@arbcall_str "int arb_is_zero(const arb_t x)"
    @test typeof(Arblib.is_zero(x)) == Int32

    Arblib.@arbcall_str "double arf_get_d(const arf_t x, arf_rnd_t rnd)"
    @test typeof(Arblib.get(Arf(1))) == Float64
end
