@testset "Carg" begin
    mag_struct = Arblib.mag_struct
    arf_struct = Arblib.arf_struct
    arb_struct = Arblib.arb_struct
    acb_struct = Arblib.acb_struct

    @testset "Parsing" begin
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
            ("slong x", :x, false, Integer, Int),
            ("ulong x", :x, false, Unsigned, UInt),
            ("double x", :x, false, Base.GMP.CdoubleMax, Cdouble),
            (
                "complex_double x",
                :x,
                false,
                Union{ComplexF16,ComplexF32,ComplexF64},
                ComplexF64,
            ),
            ("slong * x", :x, false, Vector{<:Integer}, Ref{Int}),
            ("ulong * x", :x, false, Vector{<:Unsigned}, Ref{UInt}),
            ("double * x", :x, false, Vector{<:Base.GMP.CdoubleMax}, Ref{Float64}),
            (
                "complex_double * x",
                :x,
                false,
                Vector{<:Union{ComplexF16,ComplexF32,ComplexF64}},
                Ref{ComplexF64},
            ),
            ("const char * inp", :inp, true, AbstractString, Cstring),
            ("arb_ptr v", :v, false, Arblib.ArbVectorLike, Ptr{arb_struct}),
            ("arb_srcptr res", :res, true, Arblib.ArbVectorLike, Ptr{arb_struct}),
            ("acb_ptr v", :v, false, Arblib.AcbVectorLike, Ptr{acb_struct}),
            ("acb_srcptr res", :res, true, Arblib.AcbVectorLike, Ptr{acb_struct}),
        )
            arg = Arblib.ArbCall.Carg(str)
            @test Arblib.ArbCall.name(arg) == name
            @test Arblib.ArbCall.isconst(arg) == isconst
            @test Arblib.ArbCall.jltype(arg) == jltype
            @test Arblib.ArbCall.ctype(arg) == ctype
        end

        # Unsupported types
        for str in (
            "FILE * file",
            "fmpr_t x",
            "fmpr_rnd_t rnd",
            "flint_rand_t state",
            "bool_mat_t mat",
        )
            @test_throws Arblib.ArbCall.UnsupportedArgumentType arg =
                Arblib.ArbCall.Carg(str)
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
            @test_throws KeyError arg = Arblib.ArbCall.Carg(str)
        end

        # Parse errors
        for str in ()
            @test_throws ArgumentError arg = Arblib.ArbCall.Carg(str)
        end
    end

    @testset "precision_argument" begin
        @test Arblib.ArbCall.is_precision_argument(Arblib.ArbCall.Carg("slong prec"))
        @test !Arblib.ArbCall.is_precision_argument(Arblib.ArbCall.Carg("int prec"))
        @test !Arblib.ArbCall.is_precision_argument(Arblib.ArbCall.Carg("slong n"))

        carg = Arblib.ArbCall.Carg("slong prec")
        first_carg1 = Arblib.ArbCall.Carg("arb_t res")
        first_carg2 = Arblib.ArbCall.Carg("const arb_t z")
        first_carg3 = Arblib.ArbCall.Carg("mag_t res")
        first_carg4 = Arblib.ArbCall.Carg("int n")
        @test Arblib.ArbCall.extract_precision_argument(carg, first_carg1) ==
              Expr(:kw, :(prec::Integer), :(_precision(res)))
        @test Arblib.ArbCall.extract_precision_argument(carg, first_carg2) ==
              Expr(:kw, :(prec::Integer), :(_precision(z)))
        @test Arblib.ArbCall.extract_precision_argument(carg, first_carg3) ==
              :(prec::Integer)
        @test Arblib.ArbCall.extract_precision_argument(carg, first_carg4) ==
              :(prec::Integer)
        @test_throws ArgumentError Arblib.ArbCall.extract_precision_argument(
            Arblib.ArbCall.Carg("int prec"),
            first_carg1,
        )
    end

    @testset "flag_argument" begin
        @test Arblib.ArbCall.is_flag_argument(Arblib.ArbCall.Carg("int flags"))
        @test !Arblib.ArbCall.is_flag_argument(Arblib.ArbCall.Carg("slong flag"))
        @test !Arblib.ArbCall.is_flag_argument(Arblib.ArbCall.Carg("int n"))

        @test Arblib.ArbCall.extract_flag_argument(Arblib.ArbCall.Carg("int flags")) ==
              Expr(:kw, :(flags::Integer), 0)
        @test_throws ArgumentError Arblib.ArbCall.extract_flag_argument(
            Arblib.ArbCall.Carg("slong flag"),
        )
    end

    @testset "rounding_argument" begin
        @test Arblib.ArbCall.is_rounding_argument(Arblib.ArbCall.Carg("arf_rnd_t rnd"))
        @test Arblib.ArbCall.is_rounding_argument(Arblib.ArbCall.Carg("mpfr_rnd_t rnd"))
        @test !Arblib.ArbCall.is_rounding_argument(Arblib.ArbCall.Carg("arf_rnd_t rand"))
        @test !Arblib.ArbCall.is_rounding_argument(Arblib.ArbCall.Carg("mpfr_rnd_t rand"))
        @test !Arblib.ArbCall.is_rounding_argument(Arblib.ArbCall.Carg("arb_t rnd"))

        @test Arblib.ArbCall.extract_rounding_argument(
            Arblib.ArbCall.Carg("arf_rnd_t rnd"),
        ) == Expr(:kw, :(rnd::Union{Arblib.arb_rnd,RoundingMode}), :(RoundNearest))
        @test Arblib.ArbCall.extract_rounding_argument(
            Arblib.ArbCall.Carg("mpfr_rnd_t rnd"),
        ) == Expr(
            :kw,
            :(rnd::Union{Base.MPFR.MPFRRoundingMode,RoundingMode}),
            :(RoundNearest),
        )
        @test_throws ArgumentError Arblib.ArbCall.extract_rounding_argument(
            Arblib.ArbCall.Carg("arb_t rnd"),
        )
    end

    @testset "length_argument" begin
        prev_carg = Arblib.ArbCall.Carg("acb_srcptr A")
        prev_carg_bad = Arblib.ArbCall.Carg("acb_t x")
        carg1 = Arblib.ArbCall.Carg("slong lenA")
        carg2 = Arblib.ArbCall.Carg("slong len")
        carg3 = Arblib.ArbCall.Carg("slong n")
        carg4 = Arblib.ArbCall.Carg("slong m")

        @test Arblib.ArbCall.is_length_argument(carg1, prev_carg)
        @test Arblib.ArbCall.is_length_argument(carg2, prev_carg)
        @test Arblib.ArbCall.is_length_argument(carg3, prev_carg)
        @test !Arblib.ArbCall.is_length_argument(carg4, prev_carg)
        @test !Arblib.ArbCall.is_length_argument(carg1, prev_carg_bad)
        @test !Arblib.ArbCall.is_length_argument(carg2, prev_carg_bad)
        @test !Arblib.ArbCall.is_length_argument(carg3, prev_carg_bad)
        @test !Arblib.ArbCall.is_length_argument(carg4, prev_carg_bad)


        @test Arblib.ArbCall.extract_length_argument(carg1, prev_carg) ==
              :($(Expr(:kw, :(lenA::Integer), :(length(A)))))
        @test_throws ArgumentError Arblib.ArbCall.extract_length_argument(
            carg4,
            prev_carg,
        ) == :($(Expr(:kw, :(lenA::Integer), :(length(A)))))
    end

end
