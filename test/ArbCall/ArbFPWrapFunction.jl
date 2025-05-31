@testset "ArbFPWrapFunction" begin
    @testset "parse" begin
        @test_throws ArgumentError Arblib.ArbCall.ArbFPWrapFunction("")
        @test_throws ArgumentError Arblib.ArbCall.ArbFPWrapFunction(
            "slong arb_fpwrap_double_exp(double * res, double x, int flags)",
        )
        @test_throws ArgumentError Arblib.ArbCall.ArbFPWrapFunction(
            "int arb_fpwrap_slong_exp(double * res, double x, int flags)",
        )
        @test_throws ArgumentError Arblib.ArbCall.ArbFPWrapFunction(
            "int arb_fpwrap_double_exp(double x, int flags)",
        )
    end

    @testset "jlfname" begin
        for (str, name) in (
            ("int arb_fpwrap_double_exp(double * res, double x, int flags)", :fpwrap_exp),
            (
                "int arb_fpwrap_cdouble_exp(complex_double * res, complex_double x, int flags)",
                :fpwrap_exp,
            ),
            (
                "int arb_fpwrap_double_sin_pi(double * res, double x, int flags)",
                :fpwrap_sin_pi,
            ),
            (
                "int arb_fpwrap_cdouble_sin_pi(complex_double * res, complex_double x, int flags)",
                :fpwrap_sin_pi,
            ),
            (
                "int arb_fpwrap_double_legendre_root(double * res1, double * res2, ulong n, ulong k, int flags)",
                :fpwrap_legendre_root,
            ),
        )
            af = Arblib.ArbCall.ArbFPWrapFunction(str)
            @test Arblib.ArbCall.jlfname(af) == name
        end
    end

    @testset "basetype" begin
        for (str, T) in (
            ("int arb_fpwrap_double_exp(double * res, double x, int flags)", Float64),
            (
                "int arb_fpwrap_cdouble_exp(complex_double * res, complex_double x, int flags)",
                ComplexF64,
            ),
            (
                "int arb_fpwrap_double_legendre_root(double * res1, double * res2, ulong n, ulong k, int flags)",
                Float64,
            ),
        )
            af = Arblib.ArbCall.ArbFPWrapFunction(str)
            @test Arblib.ArbCall.basetype(af) == T
        end
    end

    @testset "returntype" begin
        for (str, T) in (
            ("int arb_fpwrap_double_exp(double * res, double x, int flags)", Float64),
            (
                "int arb_fpwrap_cdouble_exp(complex_double * res, complex_double x, int flags)",
                ComplexF64,
            ),
            (
                "int arb_fpwrap_double_legendre_root(double * res1, double * res2, ulong n, ulong k, int flags)",
                NTuple{2,Float64},
            ),
        )
            af = Arblib.ArbCall.ArbFPWrapFunction(str)
            @test Arblib.ArbCall.returntype(af) == T
        end
    end

    @testset "fpwrap_error_on_failure" begin
        @test !Arblib.ArbCall.fpwrap_error_on_failure_default()
        Arblib.ArbCall.fpwrap_error_on_failure_default_set(true)
        @test Arblib.ArbCall.fpwrap_error_on_failure_default()
        Arblib.ArbCall.fpwrap_error_on_failure_default_set(true)
        @test Arblib.ArbCall.fpwrap_error_on_failure_default()
        Arblib.ArbCall.fpwrap_error_on_failure_default_set(false)
        @test !Arblib.ArbCall.fpwrap_error_on_failure_default()
        Arblib.ArbCall.fpwrap_error_on_failure_default_set(false)
        @test !Arblib.ArbCall.fpwrap_error_on_failure_default()
    end

    @testset "jlargs" begin
        for (str, args, kwargs) in (
            (
                "int arb_fpwrap_double_exp(double * res, double x, int flags)",
                [:(x::$(Union{Float16,Float32,Float64}))],
                [
                    Expr(
                        :kw,
                        :(error_on_failure::Bool),
                        :(Arblib.ArbCall.fpwrap_error_on_failure_default()),
                    ),
                    Expr(:kw, :(correct_rounding::Bool), :(false)),
                    Expr(:kw, :(work_limit::Integer), :(8)),
                ],
            ),
            (
                "int arb_fpwrap_cdouble_exp(complex_double * res, complex_double x, int flags)",
                [:(x::$(Union{ComplexF16,ComplexF32,ComplexF64}))],
                [
                    Expr(
                        :kw,
                        :(error_on_failure::Bool),
                        :(Arblib.ArbCall.fpwrap_error_on_failure_default()),
                    ),
                    Expr(:kw, :(accurate_parts::Bool), :(false)),
                    Expr(:kw, :(correct_rounding::Bool), :(false)),
                    Expr(:kw, :(work_limit::Integer), :(8)),
                ],
            ),
            (
                "int arb_fpwrap_double_lambertw(double * res, double x, slong branch, int flags)",
                [:(x::$(Union{Float16,Float32,Float64})), :(branch::$Integer)],
                [
                    Expr(
                        :kw,
                        :(error_on_failure::Bool),
                        :(Arblib.ArbCall.fpwrap_error_on_failure_default()),
                    ),
                    Expr(:kw, :(correct_rounding::Bool), :(false)),
                    Expr(:kw, :(work_limit::Integer), :(8)),
                ],
            ),
            (
                "int arb_fpwrap_cdouble_lambertw(complex_double * res, complex_double x, slong branch, int flags)",
                [:(x::$(Union{ComplexF16,ComplexF32,ComplexF64})), :(branch::$Integer)],
                [
                    Expr(
                        :kw,
                        :(error_on_failure::Bool),
                        :(Arblib.ArbCall.fpwrap_error_on_failure_default()),
                    ),
                    Expr(:kw, :(accurate_parts::Bool), :(false)),
                    Expr(:kw, :(correct_rounding::Bool), :(false)),
                    Expr(:kw, :(work_limit::Integer), :(8)),
                ],
            ),
            (
                "int arb_fpwrap_double_legendre_root(double * res1, double * res2, ulong n, ulong k, int flags)",
                [:(n::$Unsigned), :(k::$Unsigned)],
                [
                    Expr(
                        :kw,
                        :(error_on_failure::Bool),
                        :(Arblib.ArbCall.fpwrap_error_on_failure_default()),
                    ),
                    Expr(:kw, :(correct_rounding::Bool), :(false)),
                    Expr(:kw, :(work_limit::Integer), :(8)),
                ],
            ),
            (
                "int arb_fpwrap_double_hypgeom_pfq(double * res, const double * a, slong p, const double * b, slong q, double z, int regularized, int flags)",
                [
                    :(a::$(Vector{Float64})),
                    :(p::$Integer),
                    :(b::$(Vector{Float64})),
                    :(q::$Integer),
                    :(z::$(Union{Float16,Float32,Float64})),
                    :(regularized::$Integer),
                ],
                [
                    Expr(
                        :kw,
                        :(error_on_failure::Bool),
                        :(Arblib.ArbCall.fpwrap_error_on_failure_default()),
                    ),
                    Expr(:kw, :(correct_rounding::Bool), :(false)),
                    Expr(:kw, :(work_limit::Integer), :(8)),
                ],
            ),
        )
            (a, k) = Arblib.ArbCall.jlargs(Arblib.ArbCall.ArbFPWrapFunction(str))
            @test a == args
            @test k == kwargs
        end
    end

    @testset "arbsignature" begin
        for str in (
            "int arb_fpwrap_double_exp(double * res, double x, int flags)",
            "int arb_fpwrap_cdouble_exp(complex_double * res, complex_double x, int flags)",
            "int arb_fpwrap_double_sin_pi(double * res, double x, int flags)",
            "int arb_fpwrap_cdouble_sin_pi(complex_double * res, complex_double x, int flags)",
            "int arb_fpwrap_double_lambertw(double * res, double x, slong branch, int flags)",
            "int arb_fpwrap_cdouble_lambertw(complex_double * res, complex_double x, slong branch, int flags)",
            "int arb_fpwrap_double_hypgeom_pfq(double * res, const double * a, slong p, const double * b, slong q, double z, int regularized, int flags)",
            "int arb_fpwrap_cdouble_hypgeom_pfq(complex_double * res, const complex_double * a, slong p, const complex_double * b, slong q, complex_double z, int regularized, int flags)",
            "int arb_fpwrap_double_legendre_root(double * res1, double * res2, ulong n, ulong k, int flags)",
        )
            @test Arblib.ArbCall.arbsignature(Arblib.ArbCall.ArbFPWrapFunction(str)) == str
        end
    end

    @testset "jlcode" begin
        for str in (
            "int arb_fpwrap_double_exp(double * res, double x, int flags)",
            "int arb_fpwrap_cdouble_exp(complex_double * res, complex_double x, int flags)",
            "int arb_fpwrap_double_lambertw(double * res, double x, slong branch, int flags)",
            "int arb_fpwrap_cdouble_lambertw(complex_double * res, complex_double x, slong branch, int flags)",
            "int arb_fpwrap_double_hypgeom_pfq(double * res, const double * a, slong p, const double * b, slong q, double z, int regularized, int flags)",
            "int arb_fpwrap_cdouble_hypgeom_pfq(complex_double * res, const complex_double * a, slong p, const complex_double * b, slong q, complex_double z, int regularized, int flags)",
            "int arb_fpwrap_double_legendre_root(double * res1, double * res2, ulong n, ulong k, int flags)",
        )

            # We only check that evaluation of the code works, we
            # don't actually test the code
            af = Arblib.ArbCall.ArbFPWrapFunction(str)
            code = Arblib.ArbCall.jlcode(af)
            @test code isa Expr
            @test typeof(eval(code)) <: Function
        end

        # To avoid issues with world age it is better to define both
        # versions of the function before testing them.
        afs = Arblib.ArbCall.ArbFPWrapFunction.([
            "int arb_fpwrap_double_exp(double * res, double x, int flags)",
            "int arb_fpwrap_cdouble_exp(complex_double * res, complex_double x, int flags)",
        ])
        # Use a different name to avoid overwriting existing function
        fnames = Symbol.(Arblib.ArbCall.jlfname.(afs), :_test)
        eval.(Arblib.ArbCall.jlcode.(afs, fnames))

        for (af, fname) in zip(afs, fnames)
            f = eval(fname)
            T = Arblib.ArbCall.basetype(af)
            args = zeros(T, length(Arblib.ArbCall.jlargs(af)[1]))
            @test f(args...) isa T
            @test f(args..., error_on_failure = true) isa T
            if T == ComplexF64
                @test f(args..., accurate_parts = true) isa T
            else
                @test_throws MethodError f(args..., accurate_parts = true)
            end
            @test f(args..., work_limit = 16) isa T
        end

        af = Arblib.ArbCall.ArbFPWrapFunction(
            "int arb_fpwrap_double_bessel_j(double * res, double nu, double x, int flags)",
        )
        # Use a different name to avoid overwriting existing function
        eval(Arblib.ArbCall.jlcode(af, Symbol(Arblib.ArbCall.jlfname(af), :_test)))

        # Test that it errors on failure
        @test !isnan(fpwrap_bessel_j_test(1.0, 1e40))
        @test isnan(fpwrap_bessel_j_test(1.0, 1e40, work_limit = 1))
        @test_throws ErrorException fpwrap_bessel_j_test(
            1.0,
            1e40,
            error_on_failure = true,
            work_limit = 1,
        )
        Arblib.ArbCall.fpwrap_error_on_failure_default_set(true)
        @test_throws ErrorException fpwrap_bessel_j_test(1.0, 1e40, work_limit = 1)
        @test isnan(
            fpwrap_bessel_j_test(1.0, 1e40, error_on_failure = false, work_limit = 1),
        )
        Arblib.ArbCall.fpwrap_error_on_failure_default_set(false)
    end
end
