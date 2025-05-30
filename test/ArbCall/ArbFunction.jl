@testset "ArbFunction" begin
    @testset "jlfname" begin
        for (arbfname, name) in (# Supported types
            ("mag_set", :set),
            ("mag_set_d", :set),
            ("mag_set_ui", :set),
            ("arf_set", :set),
            ("arf_set_ui", :set),
            ("arf_set_si", :set),
            ("arf_set_d", :set),
            ("acf_set", :set),
            ("arb_set", :set),
            ("arf_set_mpz", :set),
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

            # fpwrap
            ("arb_fpwrap_double_exp", :exp),

            # Unsupported types
            ("arf_set_fmpz", :set_fmpz),
            ("acb_set_fmpq", :set_fmpq),
            ("arb_bin_uiui", :bin_uiui),

            # Deprecated types
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
            @test Arblib.ArbCall.jlfname(arbfname) == name
            @test Arblib.ArbCall.jlfname(arbfname, inplace = true) == Symbol(name, :!)
        end
    end

    @testset "jlfname_series" begin
        for (arbfname, name) in (
            ("arb_poly_inv_series", :inv!),
            ("arb_poly_compose_series", :compose!),
            ("arb_poly_pow_arb_series", :pow!),
            # These are special cases
            ("arb_poly_mullow", :mul!),
            ("acb_poly_mullow", :mul!),
        )
            @test Arblib.ArbCall.jlfname_series(arbfname) == name
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
            @test Arblib.ArbCall.returntype(Arblib.ArbCall.ArbFunction(str)) == T
        end

        # Unsupported return types
        for str in ("mag_ptr _mag_vec_init(slong n)",)
            @test_throws KeyError Arblib.ArbCall.ArbFunction(str)
        end

        # Return types with parse errors
        for str in ()
            @test_throws ArgumentError Arblib.ArbCall.ArbFunction(str)
        end
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
            @test Arblib.ArbCall.ispredicate(Arblib.ArbCall.ArbFunction(sig))
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
            @test !Arblib.ArbCall.ispredicate(Arblib.ArbCall.ArbFunction(sig))
        end
    end

    @testset "is_series_method" begin
        for sig in (
            "void arb_poly_pow_series(arb_poly_t h, const arb_poly_t f, const arb_poly_t g, slong len, slong prec)",
            "void arb_poly_inv_series(arb_poly_t Q, const arb_poly_t A, slong n, slong prec)",
            "void arb_poly_add_series(arb_poly_t C, const arb_poly_t A, const arb_poly_t B, slong len, slong prec)",
            "void acb_poly_atan_series(acb_poly_t res, const acb_poly_t f, slong n, slong prec)",
            "void acb_poly_sin_pi_series(acb_poly_t s, const acb_poly_t h, slong n, slong prec)",
            "void acb_poly_rising_ui_series(acb_poly_t res, const acb_poly_t f, ulong r, slong trunc, slong prec)",
            "void acb_hypgeom_erf_series(acb_poly_t res, const acb_poly_t z, slong len, slong prec)",
            "void acb_hypgeom_beta_lower_series(acb_poly_t res, const acb_t a, const acb_t b, const acb_poly_t z, int regularized, slong n, slong prec)",
            # These are special cases
            "void arb_poly_mullow(arb_poly_t C, const arb_poly_t A, const arb_poly_t B, slong n, slong prec)",
            "void acb_poly_mullow(acb_poly_t C, const acb_poly_t A, const acb_poly_t B, slong n, slong prec)",
        )
            @test Arblib.ArbCall.is_series_method(Arblib.ArbCall.ArbFunction(sig))
        end

        for sig in (
            "void _arb_poly_inv_series(arb_ptr Q, arb_srcptr A, slong Alen, slong len, slong prec)",
            "void _arb_poly_compose_series(arb_ptr res, arb_srcptr poly1, slong len1, arb_srcptr poly2, slong len2, slong n, slong prec)",
            "void acb_set_ui(acb_t z, ulong x)",
            "int acb_mat_lu_recursive(slong * perm, acb_mat_t LU, const acb_mat_t A, slong prec)",
            "int acb_mat_lu(slong * perm, acb_mat_t LU, const acb_mat_t A, slong prec)",
            "int acb_mat_inv(acb_mat_t X, const acb_mat_t A, slong prec)",
            "int arb_sgn_nonzero(const arb_t x)",
            "int arf_set_round(arf_t res, const arf_t x, slong prec, arf_rnd_t rnd)",
            "int arf_cmp(const arf_t x, const arf_t y)",
        )
            @test !Arblib.ArbCall.is_series_method(Arblib.ArbCall.ArbFunction(sig))
        end
    end

    @testset "jlargs" begin
        for (str, args, kwargs, full_args) in (
            (
                "void arb_init(arb_t x)",
                [:(x::$(Arblib.ArbLike))],
                Expr[],
                [:(x::$(Arblib.ArbLike))],
            ),
            (
                "void arb_add(arb_t z, const arb_t x, const arb_t y, slong prec)",
                [:(z::$(Arblib.ArbLike)), :(x::$(Arblib.ArbLike)), :(y::$(Arblib.ArbLike))],
                [Expr(:kw, :(prec::$Integer), :(_precision(z)))],
                [
                    :(z::$(Arblib.ArbLike)),
                    :(x::$(Arblib.ArbLike)),
                    :(y::$(Arblib.ArbLike)),
                    :(prec::$Integer),
                ],
            ),
            (
                "int arf_add(arf_t res, const arf_t x, const arf_t y, slong prec, arf_rnd_t rnd)",
                [
                    :(res::$(Arblib.ArfLike)),
                    :(x::$(Arblib.ArfLike)),
                    :(y::$(Arblib.ArfLike)),
                ],
                [
                    Expr(:kw, :(prec::$Integer), :(_precision(res))),
                    Expr(
                        :kw,
                        :(rnd::$(Union{Arblib.arb_rnd,RoundingMode})),
                        :(RoundNearest),
                    ),
                ],
                [
                    :(res::$(Arblib.ArfLike)),
                    :(x::$(Arblib.ArfLike)),
                    :(y::$(Arblib.ArfLike)),
                    :(prec::$Integer),
                    :(rnd::$(Union{Arblib.arb_rnd,RoundingMode})),
                ],
            ),
            (
                "int acf_add(acf_t res, const acf_t x, const acf_t y, slong prec, arf_rnd_t rnd)",
                [
                    :(res::$(Arblib.AcfLike)),
                    :(x::$(Arblib.AcfLike)),
                    :(y::$(Arblib.AcfLike)),
                ],
                [
                    Expr(:kw, :(prec::$Integer), :(_precision(res))),
                    Expr(
                        :kw,
                        :(rnd::$(Union{Arblib.arb_rnd,RoundingMode})),
                        :(RoundNearest),
                    ),
                ],
                [
                    :(res::$(Arblib.AcfLike)),
                    :(x::$(Arblib.AcfLike)),
                    :(y::$(Arblib.AcfLike)),
                    :(prec::$Integer),
                    :(rnd::$(Union{Arblib.arb_rnd,RoundingMode})),
                ],
            ),
            (
                "void arb_lambertw(arb_t res, const arb_t x, int flags, slong prec)",
                [:(res::$(Arblib.ArbLike)), :(x::$(Arblib.ArbLike))],
                [
                    Expr(:kw, :(flags::$Integer), 0),
                    Expr(:kw, :(prec::$Integer), :(_precision(res))),
                ],
                [
                    :(res::$(Arblib.ArbLike)),
                    :(x::$(Arblib.ArbLike)),
                    :(flags::$Integer),
                    :(prec::$Integer),
                ],
            ),
            (
                "int _acb_vec_is_zero(acb_srcptr vec, slong len)",
                [:(vec::$(Arblib.AcbVectorLike))],
                [Expr(:kw, :(len::$Integer), :(length(vec)))],
                [:(vec::$(Arblib.AcbVectorLike)), :(len::$Integer)],
            ),
        )
            @test (args, kwargs) == Arblib.ArbCall.jlargs(Arblib.ArbCall.ArbFunction(str))
            @test (full_args, Expr[]) == Arblib.ArbCall.jlargs(
                Arblib.ArbCall.ArbFunction(str),
                argument_detection = false,
            )
        end
    end

    @testset "jlargs_series" begin
        for (str, args, kwargs) in (
            (
                "void arb_poly_atan_series(arb_poly_t res, const arb_poly_t f, slong n, slong prec)",
                [
                    :(res::$(Arblib.ArbSeries)),
                    :(f::$(Arblib.ArbSeries)),
                    Expr(:kw, :(n::$(Integer)), :(length(res))),
                ],
                [Expr(:kw, :(prec::$Integer), :(_precision(res)))],
            ),
            (
                "void acb_poly_div_series(acb_poly_t Q, const acb_poly_t A, const acb_poly_t B, slong n, slong prec)",
                [
                    :(Q::$(Arblib.AcbSeries)),
                    :(A::$(Arblib.AcbSeries)),
                    :(B::$(Arblib.AcbSeries)),
                    Expr(:kw, :(n::$Integer), :(length(Q))),
                ],
                [Expr(:kw, :(prec::$Integer), :(_precision(Q)))],
            ),
            (
                "void acb_hypgeom_u_1f1_series(acb_poly_t res, const acb_poly_t a, const acb_poly_t b, const acb_poly_t z, slong len, slong prec)",
                [
                    :(res::$(Arblib.AcbSeries)),
                    :(a::$(Arblib.AcbSeries)),
                    :(b::$(Arblib.AcbSeries)),
                    :(z::$(Arblib.AcbSeries)),
                    Expr(:kw, :(len::$Integer), :(length(res))),
                ],
                [Expr(:kw, :(prec::$Integer), :(_precision(res)))],
            ),
            (
                "void arb_poly_mullow(arb_poly_t C, const arb_poly_t A, const arb_poly_t B, slong n, slong prec)",
                [
                    :(C::$(Arblib.ArbSeries)),
                    :(A::$(Arblib.ArbSeries)),
                    :(B::$(Arblib.ArbSeries)),
                    Expr(:kw, :(n::$Integer), :(length(C))),
                ],
                [Expr(:kw, :(prec::$Integer), :(_precision(C)))],
            ),
        )
            @test (args, kwargs) ==
                  Arblib.ArbCall.jlargs_series(Arblib.ArbCall.ArbFunction(str))
        end
    end

    @testset "arbsignature" begin
        for str in (
            "slong acf_allocated_bytes(const acf_t x)",
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
            "int arb_fpwrap_double_exp(double * res, double x, int flags)",
            # Pointer
            "char * arb_get_str(const arb_t x, slong n, ulong flags)",
        )
            @test Arblib.ArbCall.arbsignature(Arblib.ArbCall.ArbFunction(str)) == str
        end
    end
end
