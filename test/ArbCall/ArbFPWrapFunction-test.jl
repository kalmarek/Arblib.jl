@testset "ArbFPWrapFunction" begin
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

    @testset "jlargs" begin
        for (str, args, kwargs) in (
            (
                "int arb_fpwrap_double_exp(double * res, double x, int flags)",
                [:(x::$(Union{Float16,Float32,Float64}))],
                [
                    Expr(:kw, :(safe::Bool), :(false)),
                    Expr(:kw, :(correct_rounding::Bool), :(false)),
                    Expr(:kw, :(work_limit::Integer), :(8)),
                ],
            ),
            (
                "int arb_fpwrap_cdouble_exp(complex_double * res, complex_double x, int flags)",
                [:(x::$(Union{ComplexF16,ComplexF32,ComplexF64}))],
                [
                    Expr(:kw, :(safe::Bool), :(false)),
                    Expr(:kw, :(accurate_parts::Bool), :(false)),
                    Expr(:kw, :(correct_rounding::Bool), :(false)),
                    Expr(:kw, :(work_limit::Integer), :(8)),
                ],
            ),
            (
                "int arb_fpwrap_double_lambertw(double * res, double x, slong branch, int flags)",
                [:(x::$(Union{Float16,Float32,Float64})), :(branch::$Integer)],
                [
                    Expr(:kw, :(safe::Bool), :(false)),
                    Expr(:kw, :(correct_rounding::Bool), :(false)),
                    Expr(:kw, :(work_limit::Integer), :(8)),
                ],
            ),
            (
                "int arb_fpwrap_cdouble_lambertw(complex_double * res, complex_double x, slong branch, int flags)",
                [:(x::$(Union{ComplexF16,ComplexF32,ComplexF64})), :(branch::$Integer)],
                [
                    Expr(:kw, :(safe::Bool), :(false)),
                    Expr(:kw, :(accurate_parts::Bool), :(false)),
                    Expr(:kw, :(correct_rounding::Bool), :(false)),
                    Expr(:kw, :(work_limit::Integer), :(8)),
                ],
            ),
            (
                "int arb_fpwrap_double_legendre_root(double * res1, double * res2, ulong n, ulong k, int flags)",
                [:(n::$Unsigned), :(k::$Unsigned)],
                [
                    Expr(:kw, :(safe::Bool), :(false)),
                    Expr(:kw, :(correct_rounding::Bool), :(false)),
                    Expr(:kw, :(work_limit::Integer), :(8)),
                ],
            ),
            (
                "int arb_fpwrap_double_hypgeom_pfq(double * res, const double * a, slong p, const double * b, slong q, double z, int regularized, int flags)",
                [
                    :(a::$(Vector{<:Union{Float16,Float32,Float64}})),
                    :(p::$Integer),
                    :(b::$(Vector{<:Union{Float16,Float32,Float64}})),
                    :(q::$Integer),
                    :(z::$(Union{Float16,Float32,Float64})),
                    :(regularized::$Integer),
                ],
                [
                    Expr(:kw, :(safe::Bool), :(false)),
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
end
