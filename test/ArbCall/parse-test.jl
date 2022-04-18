@testset "parse" begin
    @testset "parse_doc $filename" for filename in ("arb.rst", "partitions.rst")
        path = joinpath(dirname(dirname(pathof(Arblib))), "test", "ArbCall", filename)
        title, sections = Arblib.ArbCall.parse_arbdoc(path)

        if filename == "arb.rst"
            @test title == "**arb.h** -- real numbers"
            @test getindex.(sections, 1) == [
                "Types, macros and constants",
                "Memory management",
                "Assignment and rounding",
                "Assignment of special values",
                "Input and output",
                "Random number generation",
                "Radius and interval operations",
                "Comparisons",
                "Arithmetic",
                "Dot product",
                "Powers and roots",
                "Exponentials and logarithms",
                "Trigonometric functions",
                "Inverse trigonometric functions",
                "Hyperbolic functions",
                "Inverse hyperbolic functions",
                "Constants",
                "Lambert W function",
                "Gamma function and factorials",
                "Zeta function",
                "Bernoulli numbers and polynomials",
                "Polylogarithms",
                "Other special functions",
                "Internals for computing elementary functions",
                "Vector functions",
            ]
        elseif filename == "partitions.rst"
            @test title == "**partitions.h** -- computation of the partition function"
            @test getindex.(sections, 1) == ["Computation of the partition function"]
        else
            error("unknown filename")
        end

        for (_, functions) in sections
            for str in functions
                try
                    af_str = Arblib.ArbCall.arbsignature(Arblib.ArbCall.ArbFunction(str))
                    @test af_str == str
                catch e
                    if !(e isa Arblib.ArbCall.UnsupportedArgumentType || e isa KeyError)
                        rethrow(e)
                    end
                end
            end
        end
    end

    @testset "generate_file" begin
        @test Arblib.ArbCall.generate_file("title!", [("section!", [])]) ==
              "###\n### title!\n###\n\n### section!\n"

        @test Arblib.ArbCall.generate_file(
            "title",
            [(
                "section",
                [
                    "void arb_init(arb_t x)",
                    "void arb_set_fmpz(arb_t y, const fmpz_t x)",
                    "void arb_fprint(FILE * file, const arb_t x)",
                ],
            )],
        ) == """
             ###
             ### title
             ###

             ### section
             arbcall"void arb_init(arb_t x)"
             #ni arbcall"void arb_set_fmpz(arb_t y, const fmpz_t x)"
             #ns arbcall"void arb_fprint(FILE * file, const arb_t x)"
             """

        @test Arblib.ArbCall.generate_file(
            "title",
            [("section", ["void arb_init(arb_t x)"])],
            manual_overrides = Dict("void arb_init(arb_t x)" => "override!"),
        ) == """
             ###
             ### title
             ###

             ### section
             #mo arbcall"void arb_init(arb_t x)" # override!
             """

        @test Arblib.ArbCall.generate_file(
            "title",
            [("section", ["int arb_fpwrap_double_exp(double * res, double x, int flags)"])],
            fpwrap = true,
        ) == """
             ###
             ### title
             ###

             ### section
             arbfpwrapcall"int arb_fpwrap_double_exp(double * res, double x, int flags)"
             """

        mktemp() do path, io
            Arblib.ArbCall.generate_file(path, "title!", [("section!", [])])
            @test read(io, String) == "###\n### title!\n###\n\n### section!\n"
        end
    end

    @testset "parse_and_generate_arbdoc" begin
        mktempdir() do tmpdir
            Arblib.ArbCall.parse_and_generate_arbdoc(
                joinpath(dirname(dirname(pathof(Arblib))), "test", "ArbCall"),
                tmpdir,
                filenames = ["arb", "partitions"],
                verbose = false,
            )

            # We only check so that the length of the files seem to be correct
            @test length(open(f -> read(f, String), joinpath(tmpdir, "arb.jl"))) == 24920
            @test length(open(f -> read(f, String), joinpath(tmpdir, "partitions.jl"))) ==
                  584

            # Check that there are no other files
            @test readdir(tmpdir) == ["arb.jl", "partitions.jl"]
        end
    end
end
