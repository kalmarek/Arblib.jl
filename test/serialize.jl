@testset "Serialize" begin
    # Tests are organized similar to in Serialization package

    function create_serialization_stream(f::Function)
        s = IOBuffer()
        f(s)
        close(s)
    end

    isequal_and_prec_equal(x, y) = isequal(x, y) && precision(x) == precision(y)

    # Mag
    create_serialization_stream() do s
        for x in (Mag(), Mag(1), Mag(π), Mag(typemax(UInt), typemax(Int)))
            Serialization.serialize(s, x)
            Arblib.zero!(x) # To catch aliasing issues
        end
        seek(s, 0)
        @test isequal(Serialization.deserialize(s), Mag())
        @test isequal(Serialization.deserialize(s), Mag(1))
        @test isequal(Serialization.deserialize(s), Mag(π))
        @test isequal(Serialization.deserialize(s), Mag(typemax(UInt), typemax(Int)))
    end

    # Arf
    create_serialization_stream() do s
        for x in (
            Arf(),
            Arf(1),
            Arf(-Inf),
            Arf(Inf),
            Arf(NaN),
            Arf(1 // 3, prec = 64),
            Arf(1 // 3, prec = 256),
            Arf(1 // 3, prec = 512),
        )
            Serialization.serialize(s, x)
            Arblib.zero!(x) # To catch aliasing issues

        end
        seek(s, 0)
        @test isequal_and_prec_equal(Serialization.deserialize(s), Arf())
        @test isequal_and_prec_equal(Serialization.deserialize(s), Arf(1))
        @test isequal_and_prec_equal(Serialization.deserialize(s), Arf(-Inf))
        @test isequal_and_prec_equal(Serialization.deserialize(s), Arf(Inf))
        @test isequal_and_prec_equal(Serialization.deserialize(s), Arf(NaN))
        @test isequal_and_prec_equal(Serialization.deserialize(s), Arf(1 // 3, prec = 64))
        @test isequal_and_prec_equal(Serialization.deserialize(s), Arf(1 // 3, prec = 256))
        @test isequal_and_prec_equal(Serialization.deserialize(s), Arf(1 // 3, prec = 512))
    end

    # Arb
    create_serialization_stream() do s
        for x in (
            Arb(),
            Arb(1),
            Arb(-Inf),
            Arb(Inf),
            Arb(NaN),
            Arb(π, prec = 64),
            Arb(π, prec = 256),
            Arb(π, prec = 512),
        )

            Serialization.serialize(s, x)
            Arblib.zero!(x) # To catch aliasing issues
        end
        seek(s, 0)
        @test isequal_and_prec_equal(Serialization.deserialize(s), Arb())
        @test isequal_and_prec_equal(Serialization.deserialize(s), Arb(1))
        @test isequal_and_prec_equal(Serialization.deserialize(s), Arb(-Inf))
        @test isequal_and_prec_equal(Serialization.deserialize(s), Arb(Inf))
        @test isequal_and_prec_equal(Serialization.deserialize(s), Arb(NaN))
        @test isequal_and_prec_equal(Serialization.deserialize(s), Arb(π, prec = 64))
        @test isequal_and_prec_equal(Serialization.deserialize(s), Arb(π, prec = 256))
        @test isequal_and_prec_equal(Serialization.deserialize(s), Arb(π, prec = 512))
    end

    # Acb
    create_serialization_stream() do s
        for x in (
            Acb(),
            Acb(1),
            Acb(0, 1),
            Acb(1, 2),
            Acb(-Inf, Inf),
            Acb(Inf, -Inf),
            Acb(NaN),
            Acb(0, NaN),
            Acb(π, ℯ, prec = 64),
            Acb(π, ℯ, prec = 256),
            Acb(π, ℯ, prec = 512),
        )
            Serialization.serialize(s, x)
            Arblib.zero!(x) # To catch aliasing issues
        end
        seek(s, 0)
        @test isequal_and_prec_equal(Serialization.deserialize(s), Acb())
        @test isequal_and_prec_equal(Serialization.deserialize(s), Acb(1))
        @test isequal_and_prec_equal(Serialization.deserialize(s), Acb(0, 1))
        @test isequal_and_prec_equal(Serialization.deserialize(s), Acb(1, 2))
        @test isequal_and_prec_equal(Serialization.deserialize(s), Acb(-Inf, Inf))
        @test isequal_and_prec_equal(Serialization.deserialize(s), Acb(Inf, -Inf))
        @test isequal_and_prec_equal(Serialization.deserialize(s), Acb(NaN))
        @test isequal_and_prec_equal(Serialization.deserialize(s), Acb(0, NaN))
        @test isequal_and_prec_equal(Serialization.deserialize(s), Acb(π, ℯ, prec = 64))
        @test isequal_and_prec_equal(Serialization.deserialize(s), Acb(π, ℯ, prec = 256))
        @test isequal_and_prec_equal(Serialization.deserialize(s), Acb(π, ℯ, prec = 512))
    end
end
