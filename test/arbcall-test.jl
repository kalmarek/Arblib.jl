@testset "arbcall" begin
    Mag = Arblib.Mag
    mag_struct = Arblib.mag_struct
    arf_struct = Arblib.arf_struct
    arb_struct = Arblib.arb_struct
    acb_struct = Arblib.acb_struct

    @testset "Carg" begin
        # Supported types
        for (str, name, isconst, jltype, ctype) in (
            (
                "mag_t res",
                "res",
                false,
                Union{Mag,mag_struct,Ptr{mag_struct}},
                Ref{mag_struct},
            ),
            (
                "arf_t res",
                "res",
                false,
                Union{Arf,arf_struct,Ptr{arf_struct}},
                Ref{arf_struct},
            ),
            (
                "arb_t res",
                "res",
                false,
                Union{Arb,arb_struct,Ptr{arb_struct}},
                Ref{arb_struct},
            ),
            (
                "acb_t res",
                "res",
                false,
                Union{Acb,acb_struct,Ptr{acb_struct}},
                Ref{acb_struct},
            ),
            (
                "const mag_t x",
                "x",
                true,
                Union{Mag,mag_struct,Ptr{mag_struct}},
                Ref{mag_struct},
            ),
            (
                "const arf_t x",
                "x",
                true,
                Union{Arf,arf_struct,Ptr{arf_struct}},
                Ref{arf_struct},
            ),
            (
                "const arb_t x",
                "x",
                true,
                Union{Arb,arb_struct,Ptr{arb_struct}},
                Ref{arb_struct},
            ),
            (
                "const acb_t x",
                "x",
                true,
                Union{Acb,acb_struct,Ptr{acb_struct}},
                Ref{acb_struct},
            ),
            (
                "arf_rnd_t rnd",
                "rnd",
                false,
                Union{Arblib.arb_rnd,RoundingMode},
                Arblib.arb_rnd,
            ),
            ("mpfr_t x", "x", false, BigFloat, Ref{BigFloat}),
            (
                "mpfr_rnd_t rnd",
                "rnd",
                false,
                Union{Base.MPFR.MPFRRoundingMode,RoundingMode},
                Base.MPFR.MPFRRoundingMode,
            ),
            ("mpz_t x", "x", false, BigInt, Ref{BigInt}),
            ("int flags", "flags", false, Integer, Cint),
            ("slong x", "x", false, Integer, Clong),
            ("ulong x", "x", false, Unsigned, Culong),
            ("double x", "x", false, Base.GMP.CdoubleMax, Cdouble),
            ("slong * x", "x", false, Vector{<:Integer}, Ref{Clong}),
            ("ulong * x", "x", false, Vector{<:Unsigned}, Ref{Culong}),
            ("const char * inp", "inp", true, AbstractString, Cstring),
            (
                "arb_ptr v",
                "v",
                false,
                Union{ArbVector,Arblib.arb_vec_struct},
                Ptr{arb_struct},
            ),
            (
                "arb_srcptr res",
                "res",
                true,
                Union{ArbVector,Arblib.arb_vec_struct},
                Ptr{arb_struct},
            ),
            (
                "acb_ptr v",
                "v",
                false,
                Union{AcbVector,Arblib.acb_vec_struct},
                Ptr{acb_struct},
            ),
            (
                "acb_srcptr res",
                "res",
                true,
                Union{AcbVector,Arblib.acb_vec_struct},
                Ptr{acb_struct},
            ),
        )
            arg = Arblib.Carg(str)
            @test Arblib.name(arg) == name
            @test Arblib.isconst(arg) == isconst
            @test Arblib.jltype(arg) == jltype
            @test Arblib.ctype(arg) == ctype
        end

        # Unsupported types
        for str in (
            "FILE * file",
            "fmpr_t x",
            "fmpr_rnd_t rnd",
            "flint_rand_t state",
            "bool_mat_t mat",
        )
            @test_throws Arblib.UnsupportedArgumentType arg = Arblib.Carg(str)
        end

        # Unimplemented types
        for str in (
            "fmpz_t x",
            "fmpq_t x",
            "mag_ptr res",
            "const fmpz_t x",
            "const fmpq_t x",
            "mag_srcptr res",

            # Internal types
            "mp_limb_t lo",
            "mp_bitcnt_t r",
            "mp_ptr ycos",
            "mp_srcptr x",
            "mp_limb_t * error",
            "mp_bitcnt_t * Qexp",
        )
            @test_throws KeyError arg = Arblib.Carg(str)
        end

        # Parse errors
        for str in ()
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
            ("arf_set_mpfr", :set),
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
            ("acb_set_fmpq", :set_fmpq),
            ("arb_bin_uiui", :bin_uiui),

            # Deprecated types
            ("arf_set_mpz", :set_mpz),
            ("arf_set_fmpr", :set_fmpr),

            # Underscore methods
            ("_acb_vec_set", :set),

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
        for (str, T) in (
            ("void arb_init(arb_t x)", Nothing),
            ("slong arb_rel_error_bits(const arb_t x)", Int),
            ("int arb_is_zero(const arb_t x)", Int32),
            ("double arf_get_d(const arf_t x, arf_rnd_t rnd)", Float64),
            ("acb_ptr _acb_vec_init(slong n)", AcbVector),
        )
            @test Arblib.returntype(Arblib.Arbfunction(str)) == T
        end

        # Unsupported return types
        for str in ("mag_ptr _mag_vec_init(slong n)",)
            @test_throws KeyError Arblib.Arbfunction(str)
        end

        # Return types with parse errors
        for str in ()
            @test_throws ArgumentError Arblib.Arbfunction(str)
        end
    end

    @testset "jlargs" begin
        for (str, args, kwargs) in (
            (
                "void arb_init(arb_t x)",
                [:(x::$(Union{Arb,arb_struct,Ptr{arb_struct}}))],
                Expr[],
            ),
            (
                "void arb_add(arb_t z, const arb_t x, const arb_t y, slong prec)",
                [
                    :(z::$(Union{arb_struct,Ptr{arb_struct},Arb})),
                    :(x::$(Union{arb_struct,Ptr{arb_struct},Arb})),
                    :(y::$(Union{arb_struct,Ptr{arb_struct},Arb})),
                ],
                [Expr(:kw, :(prec::Integer), :(precision(z)))],
            ),
            (
                "int arf_add(arf_t res, const arf_t x, const arf_t y, slong prec, arf_rnd_t rnd)",
                [
                    :(res::$(Union{Arf,arf_struct,Ptr{arf_struct}})),
                    :(x::$(Union{Arf,arf_struct,Ptr{arf_struct}})),
                    :(y::$(Union{Arf,arf_struct,Ptr{arf_struct}})),
                ],
                [
                    Expr(:kw, :(prec::Integer), :(precision(res))),
                    Expr(:kw, :(rnd::Union{arb_rnd,RoundingMode}), :(RoundNearest)),
                ],
            ),
        )
            (a, k) = Arblib.jlargs(Arblib.Arbfunction(str))
            @test a == args
            @test k == kwargs
        end
    end

    @testset "arbsignature" begin
        for str in (
            "void arb_init(arb_t x)",
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
        @test Arblib.add!(z, x, y) isa Nothing
        @test Arblib.add!(
            Ptr{arb_struct}(pointer_from_objref(z.arb)),
            Ptr{arb_struct}(pointer_from_objref(x.arb)),
            Ptr{arb_struct}(pointer_from_objref(y.arb)),
        ) isa Nothing
        @test Arblib.add!(z.arb, x.arb, y.arb) isa Nothing

        Arblib.@arbcall_str "slong arb_rel_error_bits(const arb_t x)"
        @test Arblib.rel_error_bits(x) isa Int64
        @test Arblib.rel_error_bits(Ptr{arb_struct}(pointer_from_objref(x.arb))) isa Int64
        @test Arblib.rel_error_bits(x.arb) isa Int64

        Arblib.@arbcall_str "int arb_is_zero(const arb_t x)"
        @test Arblib.is_zero(x) isa Int32
        @test Arblib.is_zero(Ptr{arb_struct}(pointer_from_objref(x.arb))) isa Int32
        @test Arblib.is_zero(x.arb) isa Int32

        Arblib.@arbcall_str "double arf_get_d(const arf_t x, arf_rnd_t rnd)"
        @test Arblib.get(Arf(1)) isa Float64
        @test Arblib.get(Arf(1).arf) isa Float64

        # these were needed for examples tests:

        Arblib.@arbcall_str "int arb_le(const arb_t x, const arb_t y)"
        @test Arblib.le(x, y) == 1
        @test Arblib.le(x, x) == 1

        Arblib.@arbcall_str "int arb_lt(const arb_t x, const arb_t y)"
        @test Arblib.lt(x, y) == 1
        @test Arblib.lt(x, x) == 0

        Arblib.@arbcall_str "void arb_const_pi(arb_t x, slong prec)"
        res = Arb()
        @test isnothing(Arblib.const_pi!(res))
        @test Arblib.le(x, res) == 1

    end
end
