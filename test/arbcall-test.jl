@testset "arbcall" begin
    Mag = Arblib.Mag
    mag_struct = Arblib.mag_struct
    arf_struct = Arblib.arf_struct
    arb_struct = Arblib.arb_struct
    acb_struct = Arblib.acb_struct

    @testset "Carg" begin
        # Supported types
        for (str, name, isconst, jltype, ctype) in (
            ("mag_t res", :res, false, Arblib.MagLike, Ref{mag_struct}),
            ("arf_t res", :res, false, Arblib.ArfLike, Ref{arf_struct}),
            ("arb_t res", :res, false, Arblib.ArbLike, Ref{arb_struct}),
            ("acb_t res", :res, false, Arblib.AcbLike, Ref{acb_struct}),
            ("const mag_t x", :x, true, Arblib.MagLike, Ref{mag_struct}),
            ("const arf_t x", :x, true, Arblib.ArfLike, Ref{arf_struct}),
            ("const arb_t x", :x, true, Arblib.ArbLike, Ref{arb_struct}),
            ("const acb_t x", :x, true, Arblib.AcbLike, Ref{acb_struct}),
            (
                "arf_rnd_t rnd",
                :rnd,
                false,
                Union{Arblib.arb_rnd,RoundingMode},
                Arblib.arb_rnd,
            ),
            ("mpfr_t x", :x, false, BigFloat, Ref{BigFloat}),
            (
                "mpfr_rnd_t rnd",
                :rnd,
                false,
                Union{Base.MPFR.MPFRRoundingMode,RoundingMode},
                Base.MPFR.MPFRRoundingMode,
            ),
            ("mpz_t x", :x, false, BigInt, Ref{BigInt}),
            ("int flags", :flags, false, Integer, Cint),
            ("slong x", :x, false, Integer, Clong),
            ("ulong x", :x, false, Unsigned, Culong),
            ("double x", :x, false, Base.GMP.CdoubleMax, Cdouble),
            ("slong * x", :x, false, Vector{<:Integer}, Ref{Clong}),
            ("ulong * x", :x, false, Vector{<:Unsigned}, Ref{Culong}),
            ("const char * inp", :inp, true, AbstractString, Cstring),
            ("arb_ptr v", :v, false, Arblib.ArbVectorLike, Ptr{arb_struct}),
            ("arb_srcptr res", :res, true, Arblib.ArbVectorLike, Ptr{arb_struct}),
            ("acb_ptr v", :v, false, Arblib.AcbVectorLike, Ptr{acb_struct}),
            ("acb_srcptr res", :res, true, Arblib.AcbVectorLike, Ptr{acb_struct}),
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

            # Removing scalar
            ("_arb_vec_scalar_mul", :mul),

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

    @testset "Length argument detection" begin
        len_keywords = Set{Symbol}()
        prev_carg = Arblib.Carg("acb_srcptr A")
        prev_carg_bad = Arblib.Carg("acb_t x")
        carg1 = Arblib.Carg("slong lenA")
        carg2 = Arblib.Carg("slong len")
        carg3 = Arblib.Carg("slong n")
        carg4 = Arblib.Carg("slong m")

        @test Arblib.is_length_argument(carg1, prev_carg, len_keywords)
        @test Arblib.is_length_argument(carg2, prev_carg, len_keywords)
        @test Arblib.is_length_argument(carg3, prev_carg, len_keywords)
        @test !Arblib.is_length_argument(carg4, prev_carg, len_keywords)
        @test !Arblib.is_length_argument(carg1, prev_carg_bad, len_keywords)
        @test !Arblib.is_length_argument(carg2, prev_carg_bad, len_keywords)
        @test !Arblib.is_length_argument(carg3, prev_carg_bad, len_keywords)
        @test !Arblib.is_length_argument(carg4, prev_carg_bad, len_keywords)

        kwargs = []
        Arblib.extract_length_argument!(kwargs, len_keywords, carg1, prev_carg)
        @test kwargs[1] == :($(Expr(:kw, :(lenA::Integer), :(length(A)))))
        @test :lenA ∈ len_keywords
        @test !Arblib.is_length_argument(carg1, prev_carg, len_keywords)
    end

    @testset "Predicate detection" begin
        for sig in (
            "int acb_is_zero(const acb_t z)",
            "int acb_is_int_2exp_si(const acb_t x, slong e)",
            "int acb_equal_si(const acb_t x, slong y)",
            "int arb_ne(const arb_t x, const arb_t y)",
            "int acb_overlaps(const acb_t x, const acb_t y)",
            "int acb_contains(const acb_t x, const acb_t y)",
            "int acb_is_real(const acb_t x)",
            "int _acb_vec_is_zero(acb_srcptr vec, slong len)",
            "int _arb_vec_is_finite(arb_srcptr x, slong len)",
        )
            @test Arblib.ispredicate(Arblib.Arbfunction(sig))
        end

        for sig in (
            "int acb_mat_lu_classical(slong * perm, acb_mat_t LU, const acb_mat_t A, slong prec)",
            "int acb_mat_lu_recursive(slong * perm, acb_mat_t LU, const acb_mat_t A, slong prec)",
            "int acb_mat_lu(slong * perm, acb_mat_t LU, const acb_mat_t A, slong prec)",
            "int acb_mat_inv(acb_mat_t X, const acb_mat_t A, slong prec)",
            "int arb_sgn_nonzero(const arb_t x)",
            "int arf_set_round(arf_t res, const arf_t x, slong prec, arf_rnd_t rnd)",
            "int arf_cmp(const arf_t x, const arf_t y)",
        )
            @test !Arblib.ispredicate(Arblib.Arbfunction(sig))
        end
    end

    @testset "jlargs" begin
        for (str, args, kwargs) in (
            ("void arb_init(arb_t x)", [:(x::$(Arblib.ArbLike))], Expr[]),
            (
                "void arb_add(arb_t z, const arb_t x, const arb_t y, slong prec)",
                [:(z::$(Arblib.ArbLike)), :(x::$(Arblib.ArbLike)), :(y::$(Arblib.ArbLike))],
                [Expr(:kw, :(prec::Integer), :(_precision(z)))],
            ),
            (
                "int arf_add(arf_t res, const arf_t x, const arf_t y, slong prec, arf_rnd_t rnd)",
                [
                    :(res::$(Arblib.ArfLike)),
                    :(x::$(Arblib.ArfLike)),
                    :(y::$(Arblib.ArfLike)),
                ],
                [
                    Expr(:kw, :(prec::Integer), :(_precision(res))),
                    Expr(
                        :kw,
                        :(rnd::Union{$(Arblib.arb_rnd),RoundingMode}),
                        :(RoundNearest),
                    ),
                ],
            ),
            (
                "int _acb_vec_is_zero(acb_srcptr vec, slong len)",
                [:(vec::$(Arblib.AcbVectorLike))],
                [:($(Expr(:kw, :(len::Integer), :(length(vec)))))],
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
end
