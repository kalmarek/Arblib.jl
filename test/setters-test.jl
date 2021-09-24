@testset "setters" begin
    @testset "$name" for (name, T) in [("Mag", Mag), ("MagRef", () -> Arblib.radref(Arb()))]
        # Integer
        @test Arblib.set!(T(), 1) == Arblib.set!(T(), UInt(1)) == one(Mag)

        # π
        @test Float64(Arblib.set!(T(), π)) ≈ π

        # Integer times power of 2
        @test Arblib.set!(T(), 3, 4) == Arblib.set!(T(), 3 * 2^4)
    end

    @testset "$name" for (name, T) in [("Arf", Arf), ("ArfRef", () -> Arblib.midref(Arb()))]
        # UInt128 and Int128
        let x = Int128(227725055589944414706309)
            @test Arblib.set!(T(), UInt128(x)) == Arb("227725055589944414706309")
            @test Arblib.set!(T(), x) == Arb("227725055589944414706309")
            @test Arblib.set!(T(), -x) == Arb("-227725055589944414706309")
        end

        # Rational
        @test Arblib.set!(T(), 2 // 3) == Arf(2) / Arf(3)
        @test Arblib.set!(T(), UInt128(2) // 3) == Arf(2) / Arf(3)
        @test Arblib.set!(T(), Int128(2) // 3) == Arf(2) / Arf(3)
        @test Arblib.set!(T(), BigInt(2) // 3) == Arf(2) / Arf(3)
        # Test that it works for big numerators and denominators
        let x = UInt128(typemax(Int)) + 1
            @test Arblib.set!(T(), x // 2) == Arf(x) / 2
            @test Arblib.set!(T(), 1 // x) == inv(Arf(x))
            @test Arblib.set!(T(), x // (x + 1)) == Arf(x) / Arf(x + 1)
            @test Arblib.set!(T(), Int128(x) // 2) == Arf(x) / 2
            @test Arblib.set!(T(), 1 // Int128(x)) == inv(Arf(x))
            @test Arblib.set!(T(), Int128(x) // (Int128(x) + 1)) == Arf(x) / Arf(x + 1)
            @test Arblib.set!(T(), BigInt(x) // 2) == Arf(x) / 2
            @test Arblib.set!(T(), 1 // BigInt(x)) == inv(Arf(x))
            @test Arblib.set!(T(), BigInt(x) // (BigInt(x) + 1)) == Arf(x) / Arf(x + 1)
        end
    end

    @testset "$name" for (name, T) in
                         [("Arb", Arb), ("ArbRef", () -> Arblib.realref(Acb()))]
        # MagLike, BigFloat
        @test Arblib.set!(T(), Mag(2)) == Arb(2)
        @test Arblib.set!(T(), BigFloat(2)) == Arb(2)

        # Check that aliasing works
        x = T()
        Arblib.set!(Arblib.radref(x), 1)
        @test Arblib.set!(x, Arblib.radref(x)) == one(Arb)

        # UInt128, Int128, BigInt
        let x = Int128(227725055589944414706309)
            @test Arblib.set!(T(), UInt128(x)) == Arb("227725055589944414706309")
            @test Arblib.set!(T(), x) == Arb("227725055589944414706309")
            @test Arblib.set!(T(), -x) == Arb("-227725055589944414706309")
            @test Arblib.set!(T(), BigInt(x)) == Arb("227725055589944414706309")
            @test Arblib.set!(T(), -BigInt(x)) == Arb("-227725055589944414706309")
        end

        # Rational
        @test Arblib.set!(T(), 1 // 2) == one(Arb) / 2
        @test Arblib.set!(T(), UInt128(1) // 2) == one(Arb) / 2
        @test Arblib.set!(T(), Int128(1) // 2) == one(Arb) / 2
        @test Arblib.set!(T(), BigInt(1) // 2) == one(Arb) / 2
        # Test that it works for big numerators and denominators
        let x = UInt128(typemax(Int)) + 1
            @test isequal(Arblib.set!(T(), x // 2), Arb(x) / 2)
            @test isequal(Arblib.set!(T(), 1 // x), inv(Arb(x)))
            @test isequal(Arblib.set!(T(), x // (x + 1)), Arb(x) / Arb(x + 1))
            @test isequal(Arblib.set!(T(), Int128(x) // 2), Arb(x) / 2)
            @test isequal(Arblib.set!(T(), 1 // Int128(x)), inv(Arb(x)))
            @test isequal(
                Arblib.set!(T(), Int128(x) // (Int128(x) + 1)),
                Arb(x) / Arb(x + 1),
            )
            @test isequal(Arblib.set!(T(), BigInt(x) // 2), Arb(x) / 2)
            @test isequal(Arblib.set!(T(), 1 // BigInt(x)), inv(Arb(x)))
            @test isequal(
                Arblib.set!(T(), BigInt(x) // (BigInt(x) + 1)),
                Arb(x) / Arb(x + 1),
            )
        end

        # Irrational
        for irr in [π, ℯ, MathConstants.γ, MathConstants.catalan, MathConstants.φ]
            @test Arblib.overlaps(Arblib.set!(T(), irr), Arb(BigFloat(irr)))
        end

        # Intervals
        let x = Arb(1.5)
            # Set x to the interval [1, 2]
            Arblib.set!(Arblib.radref(x), 1, -1)

            @test Arblib.contains(Arblib.set!(T(), (Mag(1), Mag(2))), x)
            @test Arblib.contains(Arblib.set!(T(), (Arf(1), Arf(2))), x)
            @test Arblib.contains(Arblib.set!(T(), (BigFloat(1), BigFloat(2))), x)

            @test Arblib.contains(Arblib.set!(T(), (1, 2)), x)
            @test Arblib.contains(Arblib.set!(T(), (1.0, 2.0)), x)
            @test Arblib.contains(Arblib.set!(T(), (1, 2.0)), x)
        end

        # Thin interval
        @test Arblib.set!(T(), (Mag(1), Mag(1))) == one(Arb)
        @test Arblib.set!(T(), (Arf(1), Arf(1))) == one(Arb)
        @test Arblib.set!(T(), (BigFloat(1), BigFloat(1))) == one(Arb)
        @test Arblib.set!(T(), (1, 1)) == one(Arb)
        @test Arblib.set!(T(), (1.0, 1.0)) == one(Arb)
        @test Arblib.set!(T(), (1, 1.0)) == one(Arb)

        # Check handling of precision
        @test !iszero(radius(Arblib.set!(Arb(prec = 64), (BigFloat(π), BigFloat(π)))))
        @test iszero(
            radius(
                Arblib.set!(
                    Arb(prec = 64),
                    (BigFloat(π), BigFloat(π)),
                    prec = precision(BigFloat),
                ),
            ),
        )
        @test Mag(1e-20) < radius(Arblib.set!(Arb(prec = 64), (π, π))) < Mag(1e-10)
        @test Mag(1e-80) <
              radius(Arblib.set!(Arb(prec = 64), (π, π), prec = 256)) <
              Mag(1e-70)

        # Check enclosure of irrationals
        @test Arblib.contains(Arblib.set!(T(), (1, π)), Arb(π))
        @test Arblib.contains(Arblib.set!(T(), (ℯ, Arb(4))), Arb(ℯ))

        @test_throws ArgumentError Arblib.set!(T(), (Mag(2), Mag(1)))
        @test_throws ArgumentError Arblib.set!(T(), (Arf(2), Arf(1)))
        @test_throws ArgumentError Arblib.set!(T(), (BigFloat(2), BigFloat(1)))
        @test_throws ArgumentError Arblib.set!(T(), (2, 1))
        @test_throws ArgumentError Arblib.set!(T(), (2.0, 1.0))
        @test_throws ArgumentError Arblib.set!(T(), (2, 1.0))
    end

    @testset "$name" for (name, T) in [
        ("Acb", Acb),
        ("AcbRef", (args...) -> AcbRefVector([Acb(args...)])[1]),
    ]
        # Setting real part
        @test Arblib.set!(T(), one(Mag)) == one(Acb)
        @test Arblib.set!(T(), one(Mag).mag) == one(Acb)
        @test Arblib.set!(T(), one(Arf)) == one(Acb)
        @test Arblib.set!(T(), one(Arf).arf) == one(Acb)
        @test Arblib.set!(T(), one(Arb)) == one(Acb)
        @test Arblib.set!(T(), one(Arb).arb) == one(Acb)
        @test Arblib.set!(T(), one(Int)) == one(Acb)
        @test Arblib.set!(T(), one(Int128)) == one(Acb)
        @test Arblib.set!(T(), one(Float64)) == one(Acb)
        @test Arblib.set!(T(), one(BigInt)) == one(Acb)
        @test Arblib.set!(T(), one(BigFloat)) == one(Acb)
        @test isequal(Arblib.set!(T(), ℯ), Acb(Arb(ℯ)))
        @test isequal(Arblib.set!(T(), (1, 2)), Acb(Arb((1, 2))))

        # Test that imaginary part is zeroed out
        @test Arblib.set!(T(0, 1), one(Mag)) == one(Acb)
        @test Arblib.set!(T(0, 1), one(Mag).mag) == one(Acb)
        @test Arblib.set!(T(0, 1), one(Arf)) == one(Acb)
        @test Arblib.set!(T(0, 1), one(Arf).arf) == one(Acb)
        @test Arblib.set!(T(0, 1), one(Arb)) == one(Acb)
        @test Arblib.set!(T(0, 1), one(Arb).arb) == one(Acb)
        @test Arblib.set!(T(0, 1), one(Int)) == one(Acb)
        @test Arblib.set!(T(0, 1), one(Int128)) == one(Acb)
        @test Arblib.set!(T(0, 1), one(BigInt)) == one(Acb)
        @test Arblib.set!(T(0, 1), one(Float64)) == one(Acb)
        @test Arblib.set!(T(0, 1), one(BigFloat)) == one(Acb)
        @test isequal(Arblib.set!(T(0, 1), ℯ), Acb(Arb(ℯ)))
        @test isequal(Arblib.set!(T(0, 1), (1, 2)), Acb(Arb((1, 2))))

        # Large integer
        let x = Int128(227725055589944414706309)
            @test Arblib.set!(T(), UInt128(x)) == Acb(Arb("227725055589944414706309"))
            @test Arblib.set!(T(), x) == Acb(Arb("227725055589944414706309"))
            @test Arblib.set!(T(), -x) == Acb(Arb("-227725055589944414706309"))
            @test Arblib.set!(T(), BigInt(x)) == Acb(Arb("227725055589944414706309"))
            @test Arblib.set!(T(), -BigInt(x)) == Acb(Arb("-227725055589944414706309"))
        end

        # Setting real and imaginary part
        # Testing with a various mix of arguments
        @test real(Arblib.set!(T(), 1, 2)) == 1
        @test imag(Arblib.set!(T(), 1, 2)) == 2
        @test real(Arblib.set!(T(), Arf(1), Mag(2))) == 1
        @test imag(Arblib.set!(T(), Arf(1), Mag(2))) == 2
        @test isequal(real(Arblib.set!(T(), (1, 2), π)), Arb((1, 2)))
        @test isequal(imag(Arblib.set!(T(), (1, 2), π)), Arb(π))
        @test real(Arblib.set!(T(), Arf(1).arf, Mag(2).mag)) == 1
        @test imag(Arblib.set!(T(), Arf(1).arf, Mag(2).mag)) == 2

        # From complex
        @test Arblib.set!(T(), Complex(1, 2)) == Acb(1, 2)
        @test Arblib.set!(T(), Complex(BigFloat(1), BigFloat(2))) == Acb(1, 2)
        @test Arblib.set!(T(), Complex(Arf(1), Arf(2))) == Acb(1, 2)
        @test Arblib.set!(T(), Complex(Arb(1), Arb(2))) == Acb(1, 2)

        # π
        @test isequal(Arblib.set!(T(), π), Acb(Arb(π)))
    end
end
