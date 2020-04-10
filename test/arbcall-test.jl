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
    for str in ("char * arb_get_str(const arb_t x, slong n, ulong flags)",)
        @test_throws ArgumentError Arblib.Arbfunction(str)
    end
end
